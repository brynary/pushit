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
        deploy! if Thread.current['acquired_lock']
      }
      status = thread['acquired_lock'] ? 200 : 409
      thread.run
      thread.join if settings.synchronous_deploy
      status
    end

    def self.deploy_lock
      @mutex ||= Mutex.new
    end

    def deploy!
      self.class.logger.info("Deploy started at #{Time.now}")
      self.class.logger.info("Running: #{command}")
      child = StreamingChild.new(*command.split)
      child.exec! do |stream, data|
        if stream == :stdout
          self.class.logger.info(data)
        else
          self.class.logger.error(data)
        end
      end
    rescue StandardError => e
      self.class.logger.error("An error occurred attempting to run the deploy command: #{e.message}")
    ensure
      self.class.logger.info("Deploy ended at #{Time.now}")
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
