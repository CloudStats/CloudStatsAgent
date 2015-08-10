CloudStats::Sysinfo.plugin :network do
  run do
    { connections_count: `netstat -an`.each_line.grep(/:/).count }
  end
end
