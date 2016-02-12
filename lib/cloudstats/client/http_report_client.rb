require_relative './report_client'

module CloudStats
  class HTTPReportClient < ReportClient
    attr_reader :uri

    def initialize(url)
      @uri = URI.parse(url)
    end

    protected

    def send(payload)
      catch_and_log_socket_error("https://#{uri.host}:#{uri.port}") do
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

    def catch_and_log_socket_error(url, &block)
      begin
        block.call
      rescue SocketError => e
        $logger.error "Could not reach #{url}.\n
        It could be due to a faulty network or DNS.\n
        Please check if you can ping and load the api.cloudstats.me page from
        this server, otherwise please contact the CloudStats support.\n
        Please include in you report the following error:
        #{e}"
        nil
      end
    end
  end
end
