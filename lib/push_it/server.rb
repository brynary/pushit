require "sinatra/base"
require "posix/spawn"
require 'uuidtools'

module PushIt
  class Server < Sinatra::Base

    post "/deploy" do
      Thread.new { deploy! }
      deploy_guid
    end

    def deploy!
      child = POSIX::Spawn::Child.new(*command.split)
      puts child.out
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
