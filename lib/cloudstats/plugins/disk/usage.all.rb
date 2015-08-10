CloudStats::Sysinfo.plugin :disk do

  def format(usage)
    {
      used: usage[0],
      available: usage[1],
      total: usage[0] + usage[1]
    }
  end

  os :linux do
    run do
      df = `df -P`.each_line
      usage = df
        .map do |line|
          case line
          when /^Filesystem\s+1024-blocks/
            next
          when /^(.+?)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+\%)\s+(.+)$/
            [$3.to_f * 1024, $4.to_f * 1024]
          end
        end
        .reject(&:nil?)
        .sum2
      format(usage)
    end
  end

  os :osx do
    run do
      df = `df -kl`
      usage = df
        .each_line
        .drop(1)
        .map { |l| l.split("\s") }
        .reject { |l| l[0] =~ /localhost/ }
        .map do |line|
          [
            line[2].to_f * 1024,
            line[3].to_f * 1024
          ]
        end
        .sum2
      format(usage)
    end
  end

end
