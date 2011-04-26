require 'choice'

module PushIt
  class CLI

    def start!(args)
      parse_options(args)
      PushIt::Server.run!
    end

  protected

    def load_configuration(configuration_file)
      load(configuration_file)
    end

    def parse_options(args)
      Choice.args = args
      Choice.options do
        banner "Usage: pushit-server [-c] configuration.rb"

        option :configuration_file do
          short '-c'
          long '--configuration_file=FILE'
          desc 'Load configuration file'
          default "configuration.rb"
        end

         separator ''
         separator 'Common options: '

        option :help do
          long '--help'
          desc 'Show this message'
        end
      end
      load_configuration(Choice.choices.configuration_file)
    end

  end
end