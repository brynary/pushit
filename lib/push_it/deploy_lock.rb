require 'singleton'
require 'thread'

module PushIt
  class DeployLock
    include Singleton

    def initialize
      @lock = false
    end

    def acquire
      if @lock
        false
      else
        @lock = true
      end
    end

    def release
      @lock = false
    end

  end
end