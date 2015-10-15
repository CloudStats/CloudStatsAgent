CloudStats::Sysinfo.plugin :openvz do
  run do
    JSON.parse(`vzlist -jo hostname,laverage,vpsid,diskspace,cpulimit,cpuunits,diskinodes,tcpsndbuf,tcprcvbuf,ostemplate,ip`)
  end
end
