module PushIt
  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
    configuration
  end

  class Configuration
    attr_accessor :command
  end
end