require 'spec_helper'

module PushIt

  describe StreamingChild do

    def test_argv_array_execs
      p = StreamingChild.new('printf', '%s %s %s', '1', '2', '3 4')
      assert p.success?
      assert_equal "1 2 3 4", p.out
    end

    def test_argv_string_uses_sh
      p = StreamingChild.new("echo via /bin/sh")
      assert p.success?
      assert_equal "via /bin/sh\n", p.out
    end

    def test_stdout
      p = StreamingChild.new('echo', 'boom')
      assert_equal "boom\n", p.out
      assert_equal "", p.err
    end

    def test_stderr
      p = StreamingChild.new('echo boom 1>&2')
      assert_equal "", p.out
      assert_equal "boom\n", p.err
    end

    def test_status
      p = StreamingChild.new('exit 3')
      assert !p.status.success?
      assert_equal 3, p.status.exitstatus
    end

    def test_env
      p = StreamingChild.new({ 'FOO' => 'BOOYAH' }, 'echo $FOO')
      assert_equal "BOOYAH\n", p.out
    end

    def test_chdir
      p = StreamingChild.new("pwd", :chdir => File.dirname(Dir.pwd))
      assert_equal File.dirname(Dir.pwd) + "\n", p.out
    end

    def test_input
      input = "HEY NOW\n" * 100_000 # 800K
      p = StreamingChild.new('wc', '-l', :input => input)
      assert_equal 100_000, p.out.strip.to_i
    end

    def test_max
      assert_raise MaximumOutputExceeded do
        StreamingChild.new('yes', :max => 100_000)
      end
    end

    def test_max_with_child_hierarchy
      assert_raise MaximumOutputExceeded do
        StreamingChild.new('/bin/sh', '-c', 'yes', :max => 100_000)
      end
    end

    def test_max_with_stubborn_child
      assert_raise MaximumOutputExceeded do
        StreamingChild.new("trap '' TERM; yes", :max => 100_000)
      end
    end

    def test_timeout
      assert_raise TimeoutExceeded do
        StreamingChild.new('sleep', '1', :timeout => 0.05)
      end
    end

    def test_timeout_with_child_hierarchy
      assert_raise TimeoutExceeded do
        StreamingChild.new('/bin/sh', '-c', 'sleep 1', :timeout => 0.05)
      end
    end

    def test_lots_of_input_and_lots_of_output_at_the_same_time
      input = "stuff on stdin \n" * 1_000
      command = "
        while read line
        do
          echo stuff on stdout;
          echo stuff on stderr 1>&2;
        done
      "
      p = StreamingChild.new(command, :input => input)
      assert_equal input.size, p.out.size
      assert_equal input.size, p.err.size
      assert p.success?
    end

    def test_input_cannot_be_written_due_to_broken_pipe
      input = "1" * 100_000
      p = StreamingChild.new('false', :input => input)
      assert !p.success?
    end

    def test_utf8_input
      input = "hålø"
      p = StreamingChild.new('cat', :input => input)
      assert p.success?
    end

  end

end