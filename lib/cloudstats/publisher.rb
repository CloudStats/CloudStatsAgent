require 'openssl'

module CloudStats
  # Entry point for publishing reports to server
  class Publisher
    attr_reader :client

    def initialize
      @client = HTTPReportClient.new(url)
      @client2 = StatsdClient.new
    end

    def publish
      $logger.info 'Publishing...'
      result = client.send_report
      @client2.send_report if @client2.connected?

      log_and_parse_result(result) if result
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
