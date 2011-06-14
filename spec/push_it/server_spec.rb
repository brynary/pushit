require 'spec_helper'
require 'rack/test'
ENV['RACK_ENV'] = 'test'

module PushIt

  describe Server do
    include Rack::Test::Methods
    let(:app) { Server }

    describe "post /deploy" do

      before do
        Thread.stub(:new).and_yield
        PushIt.configure do |config|
          config.command = "/usr/bin/true"
        end
      end

      it "returns a text/plain response" do
        post "/deploy"
        last_response.headers["Content-Type"].should == "text/plain;charset=utf-8"
      end

      it "runs the configured command" do
        mock_result = mock(:exec! => nil)
        StreamingChild.should_receive(:new).with("/usr/bin/true").and_return(mock_result)
        post "/deploy"
      end

    end

    describe "get /deploy" do
      before do
        Thread.stub(:new).and_yield
        PushIt.configure do |config|
          config.command = "/bin/echo hi"
        end
      end

      it "returns standard out" do
        post "/deploy"
        get "/deploy"
        last_response.body.should == "hi\n"
      end
    end
  end

end