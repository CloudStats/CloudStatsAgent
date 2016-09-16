module CloudStats
  class StatsdShard
    def self.store_statsd_host
      statsd_host = AgentApi.statsd_shard
      PublicConfig.merge!('statsd_host' => statsd_host)

      PublicConfig.save_to_yml
    end
  end
end
