require "sinatra/base"
require "posix/spawn"

module PushIt
  class Server < Sinatra::Base

    post "/deploy" do
      Thread.new { deploy! }
      "started"
    end

    def deploy!
      child = POSIX::Spawn::Child.new(*command.split)
      puts child.out
      raise child.err unless child.status.success?
    end

    def command
      "cap staging deploy"
    end

  end
end
