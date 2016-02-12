require_relative './server_driver'

module CloudStats
  class RabbitMQServerDriver < ServerDriver

    class Request < ServerDriver::Request
      def initialize(exchange, properties, payload)
        @exchange = exchange
        @properties = properties
        @payload = payload
      end

      def send_response(response)
        @exchange.publish(response.to_json, {
          routing_key: @properties.reply_to,
          correlation_id: @properties.correlation_id
        })
      end
    end

    attr_reader :connection

    def initialize(connection, queue_name, opts={})
      @connection = connection
      @channel = connection.create_channel
      @queue = @channel.queue(queue_name)
      @exchange = @channel.default_exchange
      @block = !!opts[:block]
    end

    def subscribe(&block)
      $logger.info "Subscribed to queue #{@queue.name}"
      @queue.subscribe(block: @block) do |delivery_info, properties, payload|
        data = JSON.parse(payload)
        yield Request.new(@exchange, properties, data)
      end
    end
  end
end
