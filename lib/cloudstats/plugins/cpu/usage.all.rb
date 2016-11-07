require 'etc'

CloudStats::Sysinfo.plugin :cpu do
  os :linux do
    def fetch_stat
      File.readlines('/proc/stat').grep(/^cpu/).first.split(' ').map(&:to_f)
    end

    @prev_stat = fetch_stat

    def fetch_iowait
      stat = fetch_stat[1..8]
      uptime = stat.inject(0, :+)
      iowait = stat[4]
      iowait/(uptime) * 100
    end

    run do
      @cur_stat = fetch_stat

      diff_used  = @cur_stat[1..3].inject(0, :+) - @prev_stat[1..3].inject(0, :+)
      diff_total = @cur_stat[1..4].inject(0, :+) - @prev_stat[1..4].inject(0, :+)
      uptime = @cur_stat[1..8].inject(0, :+) - @prev_stat[1..8].inject(0, :+)
      iowait = @cur_stat[5] - @prev_stat[5]
      @prev_stat = @cur_stat
      { usage: 100.0 * (diff_used / diff_total), iowait: iowait.to_f/uptime * 100 }
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
