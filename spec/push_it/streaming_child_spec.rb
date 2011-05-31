require 'spec_helper'
require 'test/unit'

module PushIt

  describe StreamingChild do
    include Test::Unit::Assertions

    it "test_argv_array_execs" do
      p = StreamingChild.new('printf', '%s %s %s', '1', '2', '3 4')
      p.exec!
      assert p.success?
      assert_equal "1 2 3 4", p.out
    end

    it "test_argv_string_uses_sh" do
      p = StreamingChild.new("echo via /bin/sh")
      p.exec!
      assert p.success?
      assert_equal "via /bin/sh\n", p.out
    end

    it "test_stdout" do
      p = StreamingChild.new('echo', 'boom')
      p.exec!
      assert_equal "boom\n", p.out
      assert_equal "", p.err
    end

    it "test_stderr" do
      p = StreamingChild.new('echo boom 1>&2')
      p.exec!
      assert_equal "", p.out
      assert_equal "boom\n", p.err
    end

    it "test_status" do
      p = StreamingChild.new('exit 3')
      p.exec!
      assert !p.status.success?
      assert_equal 3, p.status.exitstatus
    end

    it "test_env" do
      p = StreamingChild.new({ 'FOO' => 'BOOYAH' }, 'echo $FOO')
      p.exec!
      assert_equal "BOOYAH\n", p.out
    end

    it "test_chdir" do
      p = StreamingChild.new("pwd", :chdir => File.dirname(Dir.pwd))
      p.exec!
      assert_equal File.dirname(Dir.pwd) + "\n", p.out
    end

    it "test_input" do
      input = "HEY NOW\n" * 100_000 # 800K
      p = StreamingChild.new('wc', '-l', :input => input)
      p.exec!
      assert_equal 100_000, p.out.strip.to_i
    end

    it "test_max" do
      assert_raise POSIX::Spawn::MaximumOutputExceeded do
        StreamingChild.new('yes', :max => 100_000).exec!
      end
    end

    it "test_max_with_child_hierarchy" do
      assert_raise POSIX::Spawn::MaximumOutputExceeded do
        StreamingChild.new('/bin/sh', '-c', 'yes', :max => 100_000).exec!
      end
    end

    it "test_max_with_stubborn_child" do
      assert_raise POSIX::Spawn::MaximumOutputExceeded do
        StreamingChild.new("trap '' TERM; yes", :max => 100_000).exec!
      end
    end

    it "test_timeout" do
      assert_raise POSIX::Spawn::TimeoutExceeded do
        StreamingChild.new('sleep', '1', :timeout => 0.05).exec!
      end
    end

    it "test_timeout_with_child_hierarchy" do
      assert_raise POSIX::Spawn::TimeoutExceeded do
        StreamingChild.new('/bin/sh', '-c', 'sleep 1', :timeout => 0.05).exec!
      end
    end

    it "test_lots_of_input_and_lots_of_output_at_the_same_time" do
      input = "stuff on stdin \n" * 1_000
      command = "
        while read line
        do
          echo stuff on stdout;
          echo stuff on stderr 1>&2;
        done
      "
      p = StreamingChild.new(command, :input => input)
      p.exec!
      assert_equal input.size, p.out.size
      assert_equal input.size, p.err.size
      assert p.success?
    end

    it "test_input_cannot_be_written_due_to_broken_pipe" do
      input = "1" * 100_000
      p = StreamingChild.new('false', :input => input)
      p.exec!
      assert !p.success?
    end

    it "test_utf8_input" do
      input = "hålø"
      p = StreamingChild.new('cat', :input => input)
      p.exec!
      assert p.success?
    end

  end

end