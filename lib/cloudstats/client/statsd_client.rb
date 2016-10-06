require 'statsd-ruby'
require_relative './report_client'

module CloudStats
  class StatsdClient < ReportClient
    attr_reader :host

    def initialize
      $logger.info 'Initializing statsd client settings'
      @statsd_host = PublicConfig['statsd_host'] || Config[:default_statsd]['statsd_host']
      @statsd_port = PublicConfig['statsd_port'] || Config[:default_statsd]['statsd_port']
      @statsd_protocol = (PublicConfig['statsd_protocol'] || Config[:default_statsd]['statsd_protocol']).to_sym
    end

    def send(payload)
      $logger.info "Initializing statsd connection"
      @host = Statsd.new(
        @statsd_host,
        @statsd_port,
        @statsd_protocol
      )

      $logger.info "Sending the stats via statsd #{@statsd_protocol}://#{@statsd_host}:#{@statsd_port}"
      [
        :ps, :remote_calls_enabled, :agent_version, :os, :uptime,
        :kernel, :release, :hostname, :vms, :disk_smart
      ].each do |el|
        payload[:server].delete(el)
      end

      @host.gauge "statsd_protocol.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{@statsd_protocol.to_s}", @statsd_protocol == :udp ? 0 : 1

      (payload[:server].delete(:services) || []).each do |service, status|
        @host.gauge "services.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{service}", (status ? 1 : 0)
      end

      (payload[:server].delete(:disks) || []).each do |disk, used, available, perc|
        @host.gauge "partition_used.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{disk}", used
        @host.gauge "partition_free.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{disk}", available
        @host.gauge "partition_perc.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{disk}", perc
      end

      (payload[:server].delete(:interfaces) || []).each do |interface, interface_in, out, total|
        @host.gauge "interface_in.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{interface}", interface_in
        @host.gauge "interface_out.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{interface}", out
        @host.gauge "interface_total.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{interface}", total
      end

      (payload[:server][:processes] || [])[0..9].each do |k|
        @host.gauge "process_cpu.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{k[:command]}.#{k[:pid]}", k[:cpu]
        @host.gauge "process_mem.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{k[:command]}.#{k[:pid]}", k[:mem]
        @host.gauge "process_ppid.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{k[:command]}.#{k[:pid]}", k[:ppid]
        @host.gauge "process_rss.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{k[:command]}.#{k[:pid]}", k[:rss]
        @host.gauge "process_vsize.#{AgentApi.server_id}.#{AgentApi.domain_id}.#{k[:command]}.#{k[:pid]}", k[:vsize]
      end
      payload[:server].delete(:processes)

      results = payload[:server].collect do |k, v|
        @host.gauge "#{k}.#{AgentApi.server_id}.#{AgentApi.domain_id}", v
      end

      $logger.info "Statsd report sent"

      @host.close

      { ok: true }
    rescue SocketError, SystemCallError, Timeout::Error => e
      @connected = false
      $logger.error "Cannot send data to statsd #{@statsd_protocol}://#{@statsd_host}:#{@statsd_port}. Exception => #{e}\nPlease check if you firewall is blocking the connection."
    end
  end
end
