module CloudStats
  class AgentApi
    def self.server_id
      @server_id ||= grab_server_id
    end

    def self.grab_server_id
      uri = URI("#{AgentApi.api_path}/server_id?key=#{PublicConfig['key']}&server_key=#{CloudStats.server_key(nil)}")

      begin
        JSON.parse(Net::HTTP.get(uri))['id']
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error, JSON::ParserError => e
        $logger.error "Error getting the server id #{e}"

        nil
      end
    end

    def self.api_path
      "#{Config[:protocol]}://api.#{Config[:domain]}:#{Config[:port]}/agent_api"
    end
  end
end
