module CloudStats
  def self.serialize(server_key, sysinfo)
    {
      version: CloudStats::VERSION,
      server_key: server_key,
      server: {
        agent_version:   CloudStats::VERSION,
        services:        sysinfo[:services],
        cpu_usage:       sysinfo[:cpu][:usage],
        disk_used:       sysinfo[:disk][:used],
        disk_size:       sysinfo[:disk][:total],
        mem_used:        sysinfo[:memory][:summary][:used],
        mem_free:        sysinfo[:memory][:summary][:free],
        mem_cached:      sysinfo[:memory][:cached],
        mem_buffers:     sysinfo[:memory][:buffers],
        running_procs:   sysinfo[:processes][:count],
        load_one:        sysinfo[:cpu][:load][:one_minute],
        load_five:       sysinfo[:cpu][:load][:five_minutes],
        load_fifteen:    sysinfo[:cpu][:load][:fifteen_minutes],
        net_in:          sysinfo[:network][:rx_speed],
        net_out:         sysinfo[:network][:tx_speed],
        number_of_cpus:  sysinfo[:cpu][:count],
        os:              sysinfo[:os][:type],
        ps:              sysinfo[:processes][:ps],
        blk_reads:       sysinfo[:disk][:read_speed],
        blk_writes:      sysinfo[:disk][:write_speed],
        uptime:          sysinfo[:os][:uptime],
        connections:     sysinfo[:network][:connections_count],
        kernel:          sysinfo[:os][:kernel],
        release:         "#{sysinfo[:os][:name]} #{sysinfo[:os][:version]}",
        pending_updates: sysinfo[:os][:pending_updates],
        hostname:        sysinfo[:network][:hostname],
        processes:       sysinfo[:processes][:all],
        disks:           sysinfo[:disk][:all],
        interfaces:      sysinfo[:network][:all],
        vms:             sysinfo[:openvz],
        disk_smart:      sysinfo[:disk][:smart]
      }
    }
  end
end
