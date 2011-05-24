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

    describe "deploy" do
      it "returns a GUID for the deploy" do
        UUIDTools::UUID.stub(:random_create => "1234-acbc")
        post "/deploy"
        last_response.body.should == "1234acbc"
      end
    end

    it "runs the configured command" do
      mock_result = mock(:out => "", :err => "", :status => mock(:success? => true))
      POSIX::Spawn::Child.should_receive(:new).with("/bin/echo", "'hi'").and_return(mock_result)
      post "/deploy"
    end
  end

end