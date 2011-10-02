module PushIt
  class Deploy

    def initialize(command, log)
      @command = command
      @log     = log
    end

    def run
      @log.info("Deploy started at #{Time.now}")
      @log.info("Running: #{@command}")
      child = StreamingChild.new(*@command.split)
      child.exec! do |stream, data|
        if stream == :stdout
          @log.info(data)
        else
          @log.error(data)
        end
      end
    rescue StandardError => e
      @log.error("An error occurred attempting to run the deploy command: #{e.message}")
    ensure
      @log.info("Deploy ended at #{Time.now}")
    end

  end
end