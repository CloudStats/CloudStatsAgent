CloudStats::Sysinfo.plugin :network do
  run do
    res = {}
    total = 0
    ['tcp', 'tcp6', 'udp', 'udp6'].each do |c|
      num = open("/proc/net/#{c}").readlines.count - 1 rescue 0
      total += num
      res["connections_#{c}".to_sym] = num
    end
    res[:connections_count] = total
    res
  end
end
