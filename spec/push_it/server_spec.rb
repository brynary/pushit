require 'spec_helper'
require 'rack/test'
ENV['RACK_ENV'] = 'test'

module PushIt

  describe Server do
    include Rack::Test::Methods
    let(:app) { Server }

    describe "post /deploy" do
      before do
        PushIt::Server.stub(:synchronous_deploy => true)
        PushIt.configuration.stub(:command => "/usr/bin/true")
      end

      it "returns a text/plain response" do
        post "/deploy"
        last_response.headers["Content-Type"].should == "text/plain;charset=utf-8"
      end

      it "responds with a 409 if a deploy is currently running" do
        PushIt::Server.stub(:synchronous_deploy => false)
        PushIt.configuration.stub(:command => "/bin/sleep 1")
        post "/deploy"
        last_response.status.should == 200
        PushIt.configuration.stub(:command => "/usr/bin/true")
        post "/deploy"
        last_response.status.should == 409

        attempts = 0
        while last_response.body.split("\n").last !~ /Deploy ended/
          raise "Timed out awaiting for deploy to finish" if attempts > 4
          attempts += 1
          sleep 1
          get "/deploy"
        end
      end
    end

    describe "get /deploy" do
      before do
        PushIt::Server.stub(:synchronous_deploy => true)
        PushIt.configuration.stub(:command => "/bin/echo hi")
      end

      it "returns standard out" do
        post "/deploy"
        get "/deploy"
        last_response.body.split("\n").should include("I, hi")
      end

      it "returns a text/plain response" do
        post "/deploy"
        get "/deploy"
        last_response.headers["Content-Type"].should == "text/plain;charset=utf-8"
      end
    end

  end

end