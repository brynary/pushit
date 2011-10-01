require "sinatra/base"
require "posix/spawn"
require "logger"
require "thread"

module PushIt
  class Server < Sinatra::Base

    set :synchronous_deploy, false

    post "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      thread = Thread.new {
        Thread.current['acquired_lock'] = self.class.deploy_lock.try_lock
        Thread.stop
        Deploy.new(command, self.class.logger).run if Thread.current['acquired_lock']
      }
      status = thread['acquired_lock'] ? 200 : 409
      thread.run
      thread.join if settings.synchronous_deploy
      status
    end

    def self.deploy_lock
      @mutex ||= Mutex.new
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
