module PushIt
  class Deploy

    def initialize(command, logger)
      @command = command
      @logger  = logger
    end

    def run
      @logger.info("Deploy started at #{Time.now}")
      @logger.info("Running: #{@command}")
      child = StreamingChild.new(*@command.split)
      child.exec! do |stream, data|
        if stream == :stdout
          @logger.info(data)
        else
          @logger.error(data)
        end
      end
    rescue StandardError => e
      @logger.error("An error occurred attempting to run the deploy command: #{e.message}")
    ensure
      @logger.info("Deploy ended at #{Time.now}")
    end

  end
end