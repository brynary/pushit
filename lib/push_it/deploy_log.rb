module PushIt
  class DeployLog

    def initialize
      @log = []
    end

    def info(str)
      @log << "I, #{str.strip}"
    end

    def error(str)
      @log << "E, #{str.strip}"
    end

    def output
      @log.join("\n") + "\n"
    end

  end
end