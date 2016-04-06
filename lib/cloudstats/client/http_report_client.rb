require_relative './report_client'

module CloudStats
  class HTTPReportClient < ReportClient
    attr_reader :uri

    def initialize(url)
      @uri = URI.parse(url)
    end

    def send(payload)
      $logger.catch_and_log_socket_error("https://#{uri.host}:#{uri.port}") do
        send_request(payload)
      end
    end

    private

    def send_request(data)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path + '?' + uri.query)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.ssl_version = :TLSv1_2
        http.verify_mode = PublicConfig['verify_ssl'] ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
      end
      request.add_field('Content-Type', 'application/json')
      request.body = data.to_json
      response = http.request(request)
      response.body
    end
  end
end
