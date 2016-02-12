module CloudStats
  class CommandProcessor
    attr_reader :server_driver, :server

    def initialize(opts={})
      block = !!opts[:block]

      @connection = RabbitMQ.connection_for(:control)
      @server_driver = RabbitMQServerDriver.new(@connection, CloudStats.server_key(:nil), {
        block: block
      })
      @server = CommandProcessorServer.new(server_driver)

      @server.allow_command 'echo'
    end

    def run
      @server.run
    end
  end
end
