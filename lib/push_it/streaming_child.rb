require "posix/spawn"

module PushIt

  class StreamingChild < POSIX::Spawn::Child

    def initialize(*args)
      @env, @argv, options = extract_process_spawn_arguments(*args)
      @options = options.dup
      @input = @options.delete(:input)
      @timeout = @options.delete(:timeout)
      @max = @options.delete(:max)
      @options.delete(:chdir) if @options[:chdir].nil?
    end

    def exec!
      super
    end

  end

end