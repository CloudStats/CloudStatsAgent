module CloudStats
  class CommandProcessor
    attr_reader :server_driver, :server

    def initialize
      @server_driver = ServerDriver.new
      @server = CommandProcessorServer.new(server_driver)
    end

    def run
      server.run
    end
  end
end
