require 'openssl'

module CloudStats
  class Publisher
    def initialize(url)
      @uri = URI.parse(url)
    end

    def publish(data)
      http = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.path + "?" + @uri.query)
      if @uri.scheme == 'https'
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
