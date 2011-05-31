require 'spec_helper'
require 'test/unit'

module PushIt

  describe StreamingChild do
    include Test::Unit::Assertions

    it "test_argv_array_execs" do
      p = StreamingChild.new('printf', '%s %s %s', '1', '2', '3 4')
      p.exec! do |out, err|
        assert_equal "1 2 3 4", out
      end
      assert p.success?
    end

    it "test_argv_string_uses_sh" do
      p = StreamingChild.new("echo via /bin/sh")
      p.exec! do |out, err|
        assert_equal "via /bin/sh\n", out
      end
      assert p.success?
    end

    it "test_stdout" do
      p = StreamingChild.new('echo', 'boom')
      p.exec! do |out, err|
        assert_equal "boom\n", out
        assert_equal "", err
      end
    end

    it "test_stderr" do
      p = StreamingChild.new('echo boom 1>&2')
      p.exec! do |out, err|
        assert_equal "", out
        assert_equal "boom\n", err
      end
    end

    it "test_status" do
      p = StreamingChild.new('exit 3')
      p.exec! do |out, err|
      end
      assert !p.status.success?
      assert_equal 3, p.status.exitstatus
    end

    it "test_env" do
      p = StreamingChild.new({ 'FOO' => 'BOOYAH' }, 'echo $FOO')
      p.exec! do |out, err|
        assert_equal "BOOYAH\n", out
      end
    end

    it "test_chdir" do
      p = StreamingChild.new("pwd", :chdir => File.dirname(Dir.pwd))
      p.exec! do |out, err|
        assert_equal File.dirname(Dir.pwd) + "\n", out
      end
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

  end

end