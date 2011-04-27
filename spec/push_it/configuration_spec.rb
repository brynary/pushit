require 'spec_helper'

module PushIt

  describe Configuration do
    it "allows setting a command" do
      PushIt.configure do |config|
        config.command = "/bin/echo"
      end
      PushIt.configuration.command.should == "/bin/echo"
    end

    it "will not allow setting an unspecified attribute" do
      expect {
        PushIt.configure do |config|
          config.gobbledegook = "foo"
        end
      }.to raise_error
    end

    it "can be configured with a new configuration object" do
      config = PushIt::Configuration.new
      config.command = "/usr/bin/true"
      PushIt.configure(config)
      PushIt.configuration.command.should == "/usr/bin/true"
    end
  end

end