CloudStats::Sysinfo.plugin :processes do
  os :osx do
    @ps = `ps -eo user,pid,ppid,rss,vsize,pcpu,pmem,command`
  end

  os :linux do
    @ps = `ps -eo user,pid,ppid,rss,vsize,pcpu,pmem,command --sort vsize`
  end

  run do
    {
      count: @ps.each_line.count - 1,
      ps: @ps[0..65_535-1], # cut to 64 kb
      all: PS.get_all_processes.map do |proc|
        {
          command: proc['COMMAND'],
          pid: proc['PID'],
          mem: proc['RSS'].to_i,
          cpu: proc['%CPU']
        }
      end
    }
  end
end
