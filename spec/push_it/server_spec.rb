require 'spec_helper'
require 'rack/test'

module PushIt

  describe Server do
    include Rack::Test::Methods
    let(:app) { Server }

    before(:all) do
      PushIt.configure do |config|
        config.command = "/bin/echo 'hi'"
      end
    end

    it "runs the configured command" do
      mock_result = mock(:out => "", :err => "", :status => mock(:success? => true))
      POSIX::Spawn::Child.should_receive(:new).with("/bin/echo", "'hi'").and_return(mock_result)
      post "/deploy"
    end
  end

end