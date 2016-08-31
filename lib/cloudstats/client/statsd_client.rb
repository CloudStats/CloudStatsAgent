require 'statsd-ruby'
require_relative './report_client'

module CloudStats
  class StatsdClient < ReportClient
    attr_reader :host

    def initialize
      statsd_host = PublicConfig['statsd_host'] || Config[:default_statsd]['statsd_host']
      statsd_port = PublicConfig['statsd_port'] || Config[:default_statsd]['statsd_port']
      statsd_protocol = (PublicConfig['statsd_protocol'] || Config[:default_statsd]['statsd_protocol']).to_sym
      processes_statsd_host = PublicConfig['processes_statsd_host'] || Config[:default_processes_statsd]['statsd_host']

      @host = Statsd.new(
        statsd_host,
        statsd_port,
        statsd_protocol
      )

      @processes_host = Statsd.new(
        processes_statsd_host,
        statsd_port,
        statsd_protocol
      )

    rescue SocketError, SystemCallError, Timeout::Error => e
      $logger.error "Cannot send data to statsd #{statsd_host}:#{statsd_port}. Exception => #{e}\nPlease check if you firewall is blocking the connection."
    end

    def connected?
      !@host.nil?
    end

    def send(payload)
      [
        :ps, :remote_calls_enabled, :agent_version, :os, :uptime,
        :kernel, :release, :hostname, :vms, :disk_smart
      ].each do |el|
        payload[:server].delete(el)
      end

      payload[:server].delete(:services).each do |service, status|
        @host.gauge "services.#{AgentApi.server_id}.#{service}", (status ? 1 : 0)
      end

      payload[:server].delete(:disks).each do |disk, free, available|
        @host.gauge "disk_free.#{AgentApi.server_id}.#{disk}", free
        @host.gauge "disk_available.#{AgentApi.server_id}.#{disk}", available
      end

      payload[:server].delete(:interfaces).each do |interface, interface_in, out|
        @host.gauge "interface_in.#{AgentApi.server_id}.#{interface}", interface_in
        @host.gauge "interface_out.#{AgentApi.server_id}.#{interface}", out
      end

      payload[:server].delete(:processes).each do |k|
        @processes_host.gauge "process_cpu.#{AgentApi.server_id}.#{k[:command]}", k[:cpu]
        @processes_host.gauge "process_mem.#{AgentApi.server_id}.#{k[:command]}", k[:mem]
      end

      # payload[:server][:disks].each do |k, used, available|
      #   @host.gauge "#{k}_used.#{server_key}.#{PublicConfig['key']}", used
      #   @host.gauge "#{k}_available.#{server_key}.#{PublicConfig['key']}", available
      # end
      #
      # payload[:server].delete(:disks)

      # payload[:server][:interfaces].each do |k, rx, tx|
      #   @host.gauge "#{k}_rx.#{server_key}.#{PublicConfig['key']}", rx
      #   @host.gauge "#{k}_tx.#{server_key}.#{PublicConfig['key']}", tx
      # end
      #
      # payload[:server].delete(:interfaces)

      payload[:server].each do |k, v|
        # puts "#{server_key}_#{k} #{v}\n"
        @host.gauge "#{k}.#{AgentApi.server_id}", v
      end
    end

    { ok: true }
  end
end
