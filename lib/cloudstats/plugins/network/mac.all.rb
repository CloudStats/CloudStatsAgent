CloudStats::Sysinfo.plugin :network do
  os :linux do
    run do
      ifaces = []
      iface = nil

      `ip link`.each_line do |line|
        if line =~ /^\d+:\s*([^\s:]+):.*$/
          iface = $1
        elsif line =~ /^\s*link\/ether\s+([0-9a-zA-Z:]{17}).*$/
          mac = $1
          ifaces << [iface, mac]
        end
      end

      { interfaces: Hash[ifaces] }
    end
  end

  os :osx do
    run do
      ifaces = []
      iface = nil

      `ifconfig`.each_line do |line|
        if line =~ /^([^\s:]+):.*$/
          iface = $1
        elsif line =~ /^\s+ether\s+([0-9a-zA-Z:]{17}).*$/
          mac = $1
          ifaces << [iface, mac]
        end
      end

      { interfaces: Hash[ifaces] }
    end
  end
end
