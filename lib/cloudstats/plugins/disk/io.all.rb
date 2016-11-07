CloudStats::Sysinfo.plugin :disk do

  def format(usage)
    {
      used: usage[0],
      available: usage[1],
      total: usage[0] + usage[1]
    }
  end

  os :linux do
    def fetch
      file = File.exists?('/proc/diskstats') ? '/proc/diskstats' : '/proc/partitions'

      File.readlines(file).map do |line|
        if line =~ /^\s*\d+\s+\d+\s+[^\s]+\s+\d+\s+\d+\s+(\d+)\s+\d+\s+\d+\s+\d+\s+(\d+)\s+\d+\s+\d+\s+\d+\s+\d+/
          [$1.to_i, $2.to_i]
        elsif line =~ /^\s*\d+\s+\d+\s+\d+\s+[^\s]+\s+\d+\s+\d+\s+(\d+)\s+\d+\s+\d+\s+\d+\s+(\d+)\s+\d+\s+\d+\s+\d+\s+\d+/
          [$1.to_i, $2.to_i]
        end
      end.sum2
    rescue
      [0, 0]
    end

    @prev_stat = fetch
    @prev_time = Time.now.to_f

    run do
      @cur_stat = fetch
      @cur_time = Time.now.to_f

      {
        read_speed: (@cur_stat[0] - @prev_stat[0]) / (@cur_time - @prev_time),
        write_speed: (@cur_stat[1] - @prev_stat[1]) / (@cur_time - @prev_time)
      }
      @prev_time = @cur_time
      @prev_stat = @cur_stat
    end
  end

  os :osx do
    def fetch
      `top -c e -l 1`.each_line.grep(/^disks/i).map do |line|
        if line =~ /^disks:\s*([\d]+)\/[a-zA-Z0-9]+[^\d]*([\d]+)\/[a-zA-Z0-9]+.*$/i
          [
            BytesConverter::convert($1),
            BytesConverter::convert($2)
          ]
        end
      end.sum2
    end

    before_sleep do
      @fst = fetch
    end

    after_sleep do
      @snd = fetch

      {
        read_speed:  (@snd[0] - @fst[0]) / Config[:timeout],
        write_speed: (@snd[1] - @fst[1]) / Config[:timeout]
      }
    end
  end
end
