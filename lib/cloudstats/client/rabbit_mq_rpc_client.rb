require_relative './rpc_client'

module CloudStats
  class RabbitMQRPCClient
    attr_reader :connection, :response, :call_id
    attr_reader :lock, :condition
    attr_writer :response, :call_id

    def initialize(connection, server_queue)
      @connection = connection
      @channel = connection.create_channel
      @exchange = @channel.default_exchange
      @server_queue = server_queue
      @reply_queue = @channel.queue("", :exclusive => true)

      @lock = Mutex.new
      @condition = ConditionVariable.new

      subscribe
    end

    def run(command, *args)
      payload = {command: command, args: args}.to_json

      @call_id = gen_correlation_id(command)
      @exchange.publish(payload.to_s, {
        routing_key: @server_queue,
        correlation_id: @call_id,
        reply_to: @reply_queue.name
      })

      lock.synchronize{condition.wait(lock)}
      response
    end

    private

    def subscribe
      that = self

      @reply_queue.subscribe do |delivery_info, properties, payload|
        if properties[:correlation_id] == that.call_id
          begin
            that.response = JSON.parse(payload)
          ensure
            that.lock.synchronize{that.condition.signal}
          end
        end
      end
    end

    def gen_correlation_id(command)
      "#{command}_#{SecureRandom.uuid}"
    end
  end
end
