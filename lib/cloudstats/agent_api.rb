module CloudStats
  class AgentApi
    def self.server_id
      @server_id ||= grab_server_id
    end

    def self.grab_server_id
      uri = URI("#{AgentApi.api_path}/server_id?key=#{PublicConfig['key']}&server_key=#{CloudStats.server_key(nil)}")

      JSON.parse(Net::HTTP.get(uri))['id']
    end

    def self.api_path
      "#{Config[:protocol]}://api.#{Config[:domain]}:#{Config[:port]}/agent_api"
    end
  end
end
