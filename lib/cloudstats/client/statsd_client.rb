require 'statsd-ruby'
require_relative './report_client'


module CloudStats
  class StatsdClient < ReportClient
    def initialize
      @host = Statsd.new Config[:statsd_host], Config[:statsd_port]
    end

    def send(payload)
      [
        :services, :ps, :remote_calls_enabled, :agent_version, :os, :uptime,
        :kernel, :release, :hostname, :vms, :disk_smart
      ].each do |el|
        payload[:server].delete(el)
      end

      payload[:server][:processes][0..9].each do |k|
        @host.gauge "#{server_key}_#{k[:command]}_cpu", k[:cpu]
        @host.gauge "#{server_key}_#{k[:command]}_mem", k[:mem]
      end
      payload[:server].delete(:processes)

      payload[:server][:disks].each do |k, used, available|
        @host.gauge "#{server_key}_#{k}_used", used
        @host.gauge "#{server_key}_#{k}_available", available
      end

      payload[:server].delete(:disks)

      payload[:server][:interfaces].each do |k, rx, tx|
        @host.gauge "#{server_key}_#{k}_rx", rx
        @host.gauge "#{server_key}_#{k}_tx", tx
      end

      payload[:server].delete(:interfaces)

      payload[:server].each do |k, v|
        # puts "#{server_key}_#{k} #{v}\n"
        @host.gauge "#{server_key}_#{k}", v
      end
    end

    {ok: true}
  end
end
