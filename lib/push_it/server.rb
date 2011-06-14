require "sinatra/base"
require "posix/spawn"

module PushIt
  class Server < Sinatra::Base

    set :deploy_out, ''

    post "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      Thread.new { deploy! }
    end

    get "/deploy" do
      settings.deploy_out
    end

    def deploy!
      settings.deploy_out = ''
      child = StreamingChild.new(*command.split)
      child.exec! do |stream, data|
        settings.deploy_out = settings.deploy_out + data if stream == :stdout
      end
    end

    def command
      PushIt.configuration.command
    end

  end
end
