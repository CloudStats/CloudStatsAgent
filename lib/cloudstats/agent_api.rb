module CloudStats
  class AgentApi
    def self.server_id
      @server_id ||= grab_server_id
    end

    def self.grab_server_id
      uri = URI("#{AgentApi.api_path}/server_id?#{AgentApi.params}")

      begin
        JSON.parse(Net::HTTP.get(uri))['id']
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error, JSON::ParserError => e
        $logger.error "Error getting the server id #{e}"

        nil
      end
    end

    def self.statsd_server
      uri = URI("#{AgentApi.api_path}/statsd_server?#{AgentApi.params}")

      begin
        r = Net::HTTP.get_response(uri)

        if r.code == "200"
          JSON.parse(r.body)
        else
          $logger.error "Error getting the statsd settings"
          $logger.error "Please check if your account is still active"  if r.code == "404"

          Config[:default_statsd]
        end
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error, JSON::ParserError => e
        $logger.error "Error getting the statsd settings #{e}"

        Config[:default_statsd]
      end
    end

    def self.api_path
      "#{Config[:protocol]}://api.#{Config[:domain]}:#{Config[:port]}/agent_api"
    end

    def self.params
      "key=#{PublicConfig['key']}&server_key=#{CloudStats.server_key(nil)}"
    end
  end
end
