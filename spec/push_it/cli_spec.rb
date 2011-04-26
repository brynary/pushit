require 'push_it'

module PushIt
  describe CLI do
    before do
      Server.stub(:run!)
    end

    describe "#start" do
      it "starts the server" do
        Server.should_receive(:run!)
        cli = CLI.new
        cli.stub(:load_configuration)
        cli.start!([])
      end

      it "defaults to loading configuration.rb" do
        cli = CLI.new
        cli.should_receive(:load_configuration).with("configuration.rb")
        cli.start!([])
      end

      it "loads the configuration specified" do
        cli = CLI.new
        cli.should_receive(:load_configuration).with("my_configuration.rb")
        cli.start!(["-c", "my_configuration.rb"])
      end
    end

  end
end