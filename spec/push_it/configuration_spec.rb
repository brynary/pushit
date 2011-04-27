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
  end

end