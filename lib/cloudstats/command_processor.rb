module CloudStats
  # Instantiates command processor server with specific driver
  class CommandProcessor
    attr_reader :server_driver, :server
    attr_accessor :auth_failures

    def initialize(opts = {})
      @block = !!opts[:block]
      @auth_failures = 0
    end

    def run
      @connection = RabbitMQ.create_connection(:control)
      @server_driver = RabbitMQServerDriver.new(@connection,
                                                CloudStats.server_key(:nil))
      @server = CommandProcessorServer.new(server_driver, block: @block)
      @server.run
    rescue => m
      @auth_failures += 1 if m.class == Bunny::AuthenticationFailureError
      $logger.warn "Error in command processor: #{m.message}"
    end

    def alive?
      @server && @server.alive?
    end
  end
end
