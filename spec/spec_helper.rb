require 'push_it'

module PushIt

  def self.reset_configuration
    @@configuration = Configuration.new
  end

end

RSpec.configure do |config|
  config.after do
    PushIt.reset_configuration
  end
end