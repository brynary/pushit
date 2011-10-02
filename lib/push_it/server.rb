require "sinatra/base"
require "posix/spawn"

module PushIt
  class Server < Sinatra::Base

    set :synchronous_deploy, false

    post "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      thread = ExclusiveThread.new(settings.synchronous_deploy)
      acquired_lock = thread.start {
        self.class.log = DeployLog.new
        Deploy.new(command, self.class.log).run
      }
      acquired_lock ? 200 : 409
    end

    get "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      if self.class.log
        self.class.log.output
      else
        "No Deploy Found"
      end
    end

    def command
      PushIt.configuration.command
    end

    def self.log
      @log
    end

    def self.log=(log)
      @log = log
    end

  end
end
