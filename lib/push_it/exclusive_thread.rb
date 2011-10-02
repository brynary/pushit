module PushIt

  class ExclusiveThread

    def initialize(join = false)
      @join = join
    end

    def start(&block)
      thread = Thread.new {
        Thread.current['acquired_lock'] = self.class.lock.try_lock
        Thread.stop
        block.call if Thread.current['acquired_lock']
      }
      ran_block = thread['acquired_lock']
      thread.run
      thread.join if @join
      ran_block
    end

    def self.lock
      @mutex ||= Mutex.new
    end

  end

end