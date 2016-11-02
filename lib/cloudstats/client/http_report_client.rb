require_relative './report_client'
require 'faraday'

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
      http = Faraday.new(url: uri) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      response = http.post do |req|
        req.url uri.path
        req.headers['Content-Type'] = 'application/json'
        req.body = data.to_json
      end
      dsa
      $logger.info response
      response.body
    end
  end
end
