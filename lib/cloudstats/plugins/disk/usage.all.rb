CloudStats::Sysinfo.plugin :disk do

  def format(disks, usage)
    {
      all: disks,
      used: usage[0],
      available: usage[1],
      total: usage[0] + usage[1]
    }
  end

  os :linux do
    run do
      df = `df -P`.each_line
      disks = df
        .map do |line|
          case line
          when /^Filesystem\s+1024-blocks/
            next
          when /^(.+?)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+\%)\s+(.+)$/
            [$1, $3.to_f * 1024, $4.to_f * 1024, $3.to_f / ($3.to_f + $4.to_f) * 100]
          end
        end
        .reject(&:nil?)
      usage = disks.map { |x| x[1..2] }.sum2
      format(disks, usage)
    end
  end

  os :osx do
    run do
      df = `df -kl`
      disks = df
        .each_line
        .drop(1)
        .map { |l| l.split("\s") }
        .reject { |l| l[0] =~ /localhost/ }
        .map do |line|
          [
            line[0].to_s,
            line[2].to_f * 1024,
            line[3].to_f * 1024,
            line[2].to_f / (line[2].to_f + line[3].to_f) * 100
          ]
        end
      usage = disks.map { |x| x[1..2] }.sum2
      format(disks, usage)
    end
  end

end
