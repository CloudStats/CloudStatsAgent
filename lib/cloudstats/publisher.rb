require 'openssl'

module CloudStats
  # Entry point for publishing reports to server
  class Publisher
    attr_reader :statsd_client, :http_client

    def initialize
      @http_client = HTTPReportClient.new(url)
      @statsd_client = StatsdClient.new
    end

    def publish(to = :statsd)
      $logger.info 'Publishing...'
      if to == :http
        result = http_client.send_report

        log_and_parse_result(result) if result
      elsif statsd_client.connected?
        statsd_client.send_report
      end
      $logger.info 'Done publishing'
    end

    private

    def log_and_parse_result(response)
      if response['ok']
        $logger.info "Response: #{response}"
      else
        $logger.error 'There was an error posting the status'
        $logger.error "Response: #{response}"
      end
    end

    def url
      protocol  = Config[:protocol] || 'http'
      domain    = Config[:domain]
      port      = Config[:port].nil? ? '' : ":#{Config[:port]}"
      path      = Config[:uri_path]
      key       = PublicConfig['key']
      @url ||= "#{protocol}://api.#{domain}#{port}/#{path}?key=#{key}"
    end
  end
end
