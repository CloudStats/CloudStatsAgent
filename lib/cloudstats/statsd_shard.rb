module CloudStats
  class StatsdShard
    def self.store_statsd_host
      statsd_host = AgentApi.statsd_shard
      PublicConfig.merge!('statsd_host' => statsd_host)
      p PublicConfig
      PublicConfig.save_to_yml
    end
  end
end
