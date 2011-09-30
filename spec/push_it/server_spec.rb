require 'spec_helper'
require 'rack/test'
ENV['RACK_ENV'] = 'test'

module PushIt

  describe Server do
    include Rack::Test::Methods
    let(:app) { Server }

    describe "post /deploy" do
      before do
        PushIt.configure do |config|
          config.command = "/usr/bin/true"
        end
      end

      it "returns a text/plain response" do
        post "/deploy"
        last_response.headers["Content-Type"].should == "text/plain;charset=utf-8"
      end
    end

    describe "get /deploy" do
      it "returns standard out" do
        PushIt.configure do |config|
          config.command = "/bin/echo hi"
        end
        post "/deploy"
        get "/deploy"
        last_response.body.split("\n").should include("I, hi")
      end
    end

  end

end