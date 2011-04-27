module PushIt
  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure(configuration = PushIt.configuration)
    yield configuration if block_given?
    @@configuration = configuration
  end

  class Configuration
    attr_accessor :command
  end
end