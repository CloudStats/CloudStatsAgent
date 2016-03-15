module CloudStats
  class ServerDriver
    class Request
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end

      def send_response(response)
        $logger.info "Plain ServerDriver response: #{response.to_json}"
      end
    end

    def subscribe(&block)
      $logger.warn "You've subscribed to plain ServerDriver! Nothing will happen"
    end
  end
end
