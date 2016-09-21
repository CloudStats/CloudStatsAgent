module CloudStats
  class AgentApi
    def self.server_id
      @server_id ||= grab_server_id
    end

    def self.domain_id
      @domain_id ||= grab_domain_id
    end

    def self.grab_server_id
      $logger.info 'Grabbing server_id'
      uri = URI("#{AgentApi.api_path}/server_id?#{AgentApi.params}")

      begin
        JSON.parse(Net::HTTP.get(uri))['id']
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error, JSON::ParserError => e
        $logger.error "Error getting the server id #{e}"

        nil
      end
    end

    def self.delete_server?
      uri = URI("#{AgentApi.api_path}/server_id?#{AgentApi.params}")

      begin
        resp = Net::HTTP.get_response(uri)
        resp.code == '404' || resp.code == '403'
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error => e
        $logger.error "Can't reach api to determine server status #{e}"

        nil
      end

    end

    def self.grab_domain_id
      $logger.info 'Grabbing domain_id'
      uri = URI("#{AgentApi.api_path}/domain_id?#{AgentApi.params}")

      begin
        JSON.parse(Net::HTTP.get(uri))['id']
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error, JSON::ParserError => e
        $logger.error "Error getting the domain id #{e}"

        nil
      end
    end

    def self.statsd_shard
      $logger.info 'Grabbing shard'
      uri = URI("#{AgentApi.api_path}/statsd_shard?#{AgentApi.params}")

      begin
        JSON.parse(Net::HTTP.get(uri))['shard']
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error, JSON::ParserError => e
        $logger.error "Error getting the shard server #{e}"

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
