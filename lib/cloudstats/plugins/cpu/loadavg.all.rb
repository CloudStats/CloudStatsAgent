CloudStats::Sysinfo.plugin :cpu do
  def format(l1, l5, l15)
    {
      load: {
        one_minute:      l1,
        five_minutes:    l5,
        fifteen_minutes: l15
      }
    }
  end

  os :linux do
    run do
      load_avg_file = '/proc/loadavg'
      (l1, l5, l15) = File.readlines(load_avg_file).first.split[0..2].map(&:to_f)
      format(l1, l5, l15)
    end
  end

  os :osx do
    run do
      (l1, l5, l15) = `sysctl -n vm.loadavg`.gsub(/[^\s0-9.]/, '').split.map(&:to_f)
      format(l1, l5, l15)
    end
  end
end
