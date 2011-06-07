require "sinatra/base"
require "posix/spawn"
require 'uuidtools'

module PushIt
  class Server < Sinatra::Base

    post "/deploy" do
      content_type 'text/plain', :charset => 'utf-8'
      Thread.new { deploy! }
      deploy_guid
    end

    def deploy!
      child = StreamingChild.new(*command.split)
      child.exec! do |stream, data|
        puts "#{stream}: #{data}"
      end
      raise child.err unless child.status.success?
    end

    def command
      PushIt.configuration.command
    end

  protected

    def deploy_guid
      UUIDTools::UUID.random_create.to_s.gsub("-","")
    end
  end
end
