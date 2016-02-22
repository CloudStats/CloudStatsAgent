module CloudStats
  class CommandProcessor
    attr_reader :server_driver, :server

    def initialize(opts={})
      @block = !!opts[:block]
    end

    def run
      @connection = RabbitMQ.create_connection(:control)
      @server_driver = RabbitMQServerDriver.new(@connection, CloudStats.server_key(:nil))
      @server = CommandProcessorServer.new(server_driver, block: @block)
      @server.run
    rescue => m 
      $logger.warn "Error in command processor: #{m.message}"
    end

    def alive?
      @server && @server.alive?
    end
  end
end
