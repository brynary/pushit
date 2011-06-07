require "posix/spawn"

module PushIt

  class StreamingChild < POSIX::Spawn::Child

    def initialize(*args)
      @env, @argv, options = extract_process_spawn_arguments(*args)
      @options = options.dup
      @timeout = @options.delete(:timeout)
      @max = @options.delete(:max)
      @options.delete(:chdir) if @options[:chdir].nil?
    end

    def exec!(&block)
        # spawn the process and hook up the pipes
        pid, stdin, stdout, stderr = popen4(@env, *(@argv + [@options]))

        # async read from all streams
        read_and_write(stdin, stdout, stderr, @timeout, @max, &block)

        # grab exit status
        @status = waitpid(pid)
      rescue Object => boom
        [stdin, stdout, stderr].each { |fd| fd.close rescue nil }
        if @status.nil?
          ::Process.kill('TERM', pid) rescue nil
          @status = waitpid(pid)      rescue nil
        end
        raise
      ensure
        # let's be absolutely certain these are closed
        [stdin, stdout, stderr].each { |fd| fd.close rescue nil }
    end

    def read_and_write(stdin, stdout, stderr, timeout=nil, max=nil, &block)
      max = nil if max && max <= 0

      # force all string and IO encodings to BINARY under 1.9 for now
      if "".respond_to?(:force_encoding)
        [stdin, stdout, stderr].each do |fd|
          fd.set_encoding('BINARY', 'BINARY')
        end
      end

      timeout = nil if timeout && timeout <= 0.0
      @runtime = 0.0
      start = Time.now
      stdin.close
      total_stream_size = 0

      readers = [stdout, stderr]

      t = timeout
      while readers.any?
        ready = IO.select(readers, [], readers, t)
        raise TimeoutExceeded if ready.nil?

        # read from stdout and stderr streams
        ready[0].each do |fd|
          stream = (fd == stdout) ? :stdout : :stderr
          begin
            out = fd.readpartial(BUFSIZE)
            total_stream_size += out.size
            block.call(stream, out)
          rescue Errno::EAGAIN, Errno::EINTR
          rescue EOFError
            readers.delete(fd)
            fd.close
          end
        end

        # keep tabs on the total amount of time we've spent here
        @runtime = Time.now - start
        if timeout
          t = timeout - @runtime
          raise TimeoutExceeded if t < 0.0
        end

        # maybe we've hit our max output
        if max && ready[0].any? && total_stream_size > max
          raise MaximumOutputExceeded
        end
      end
    end

  end

end