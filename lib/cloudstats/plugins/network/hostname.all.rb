CloudStats::Sysinfo.plugin :network do
  run do
    { hostname: Socket.gethostname }
  end
end
