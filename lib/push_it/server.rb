require "sinatra/base"
require "posix/spawn"
require "logger"
require "thread"

module PushIt
  class Server < Sinatra::Base

    set :synchronous_deploy, false

    post "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      thread = ExclusiveThread.new(settings.synchronous_deploy)
      acquired_lock = thread.start { Deploy.new(command, self.class.logger).run }
      acquired_lock ? 200 : 409
    end

    get "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      self.class.logger.output
    end

    def command
      PushIt.configuration.command
    end

    def self.logger
      @logger ||= DeployLog.new
    end

  end
end
