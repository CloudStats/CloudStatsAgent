module CloudStats
  class ClientDriver
    def send(payload)
      $logger.info "Plain ClientDriver sends: #{payload.to_json}"
    end
  end


  class RabbitMQClientDriver
    attr_reader :connection, :channel, :queue

    def intialize(connection, queue)
      @connection = connection
      @channel = connection.create_channel
      @queue = @channel.queue(CloudStats.server_key(nil))
    end

    def send(payload, opts={})
      queue.publish(payload.to_json, publish_options(opts))
    end

    private

    def publish_options(opts)
      { persistent: true }
    end
  end
end
