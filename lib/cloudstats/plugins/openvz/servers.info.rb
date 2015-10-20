CloudStats::Sysinfo.plugin :openvz do
  run do
    begin
      JSON.parse(`vzlist -jo hostname,laverage,vpsid,diskspace,cpulimit,cpuunits,diskinodes,tcpsndbuf,tcprcvbuf,ostemplate,ip`)
    rescue SystemCallError
      nil
    end
  end
end
