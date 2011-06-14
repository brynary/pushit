require "sinatra/base"
require "posix/spawn"

module PushIt
  class Server < Sinatra::Base

    post "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      Thread.new { deploy! }
    end

    def deploy!
      child = StreamingChild.new(*command.split)
      child.exec! do |stream, data|
        puts "#{stream}: #{data}"
      end
    end

    def command
      PushIt.configuration.command
    end

  end
end
