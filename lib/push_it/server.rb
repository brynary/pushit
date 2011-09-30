require "sinatra/base"
require "posix/spawn"
require "logger"

module PushIt
  class Server < Sinatra::Base

    post "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      Thread.new { deploy! }
    end

    get "/deploy" do
      self.class.deploy_output
    end

    def deploy!
      self.class.reset_log
      child = StreamingChild.new(*command.split)
      child.exec! do |stream, data|
        if stream == :stdout
          self.class.logger.info(data)
        else
          self.class.logger.error(data)
        end
      end
    end

    def command
      PushIt.configuration.command
    end

    def self.logger
      return @logger if @logger
      @logger = Logger.new(@deploy_output)
      @logger.formatter = proc { |severity, datetime, progname, msg| "#{severity}: #{datetime}, #{msg}" }
      @logger
    end

    def self.reset_log
      @deploy_output = StringIO.new
    end

    def self.deploy_output
      @deploy_output.string
    end

  end
end
