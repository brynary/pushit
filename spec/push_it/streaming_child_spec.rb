require 'spec_helper'
require 'test/unit'

module PushIt

  describe StreamingChild do

    it "test_argv_array_execs" do
      p = StreamingChild.new('printf', '%s %s %s', '1', '2', '3 4')
      p.exec! do |stream, data|
        next if stream != :stdout
        stream.should == :stdout
        data.should == "1 2 3 4"
      end
      p.success?.should be_true
    end

    it "test_argv_string_uses_sh" do
      p = StreamingChild.new("echo via /bin/sh")
      p.exec! do |stream, data|
        next if stream != :stdout
        stream.should == :stdout
        data.should == "via /bin/sh\n"
      end
      p.success?.should be_true
    end

    it "test_stdout" do
      p = StreamingChild.new('echo', 'boom')
      streams = []
      output = []
      p.exec! do |stream, data|
        streams << stream
        output << data
      end
      streams.should == [:stdout, :stderr]
      output.should == ["boom\n", ""]
    end

    it "test_stderr" do
      p = StreamingChild.new('echo boom 1>&2')
      streams = []
      output = []
      p.exec! do |stream, data|
        streams << stream
        output << data
      end
      streams.should == [:stdout, :stderr]
      output.should == ["", "boom\n"]
    end

    it "test_status" do
      p = StreamingChild.new('exit 3')
      p.exec! { |stream, data| }
      p.status.success?.should be_false
      p.status.exitstatus.should == 3
    end

    it "test_env" do
      p = StreamingChild.new({ 'FOO' => 'BOOYAH' }, 'echo $FOO')
      output = []
      p.exec! do |stream, data|
        output << data
      end
      output.should == ["BOOYAH\n", ""]
    end

    it "test_chdir" do
      p = StreamingChild.new("pwd", :chdir => File.dirname(Dir.pwd))
      output = []
      p.exec! do |stream, data|
        output << data
      end
      output.should == [File.dirname(Dir.pwd) + "\n", ""]
    end

    it "test_max" do
      expect do
        StreamingChild.new('yes', :max => 100_000).exec!
      end.to raise_error(POSIX::Spawn::MaximumOutputExceeded)
    end

    it "test_max_with_child_hierarchy" do
      expect do
        StreamingChild.new('/bin/sh', '-c', 'yes', :max => 100_000).exec!
      end.to raise_error(POSIX::Spawn::MaximumOutputExceeded)
    end

    it "test_max_with_stubborn_child" do
      expect do
        StreamingChild.new("trap '' TERM; yes", :max => 100_000).exec!
      end.to raise_error(POSIX::Spawn::MaximumOutputExceeded)
    end

    it "test_timeout" do
      expect do
        StreamingChild.new('sleep', '1', :timeout => 0.05).exec!
      end.to raise_error(POSIX::Spawn::TimeoutExceeded)
    end

    it "test_timeout_with_child_hierarchy" do
      expect do
        StreamingChild.new('/bin/sh', '-c', 'sleep 1', :timeout => 0.05).exec!
      end.to raise_error(POSIX::Spawn::TimeoutExceeded)
    end

  end

end