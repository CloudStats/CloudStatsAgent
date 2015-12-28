CloudStats::Sysinfo.plugin :cpu do
  os :linux do
    def fetch_stat
      File.readlines('/proc/stat').grep(/^cpu/).first.split(' ').map(&:to_f)
    end

    before_sleep do
      @proc1 = fetch_stat
    end

    after_sleep do
      @proc2 = fetch_stat

      @diff_used  = @proc2[1..3].inject(0, :+) - @proc1[1..3].inject(0, :+)
      @diff_total = @proc2[1..4].inject(0, :+) - @proc1[1..4].inject(0, :+)
      { usage: 100.0 * (@diff_used / @diff_total) }
    end
  end

  os :osx do
    run do
      top = `top -l1 | awk '/CPU usage/'`
      top = top.gsub(/[\,a-zA-Z:]/, '').split(' ')
      { usage: top[0].to_f }
    end
  end
end
