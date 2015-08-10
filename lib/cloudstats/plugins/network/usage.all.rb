CloudStats::Sysinfo.plugin :network do
  def format(rxs, txs)
  end

  os :linux do
    def fetch
      lines = `ip -s link`.each_line.map(&:downcase)
      ifaces = lines.map(&:split)
      rxlines = ifaces.each_with_index.select { |x, i| x[0] =~ /^rx/ }.map { |x, i| i + 1 }
      txlines = ifaces.each_with_index.select { |x, i| x[0] =~ /^tx/ }.map { |x, i| i + 1 }

      # reject loopback
      rejects = lines
        .map { |x| /^\d+[:]\s*[^\s]+[:]\s*[<](.*)[>]/.match(x) }
        .reject(&:nil?)
        .map { |x| x[1].split(',').include?('loopback') }
      rxlines = rxlines.zip(rejects).reject(&:last).map(&:first)
      txlines = txlines.zip(rejects).reject(&:last).map(&:first)

      {
        rx: rxlines.map { |i| ifaces[i][0].to_f }.sum,
        tx: txlines.map { |i| ifaces[i][0].to_f }.sum
      }
    end
  end

  os :osx do
    def fetch
      data = `netstat -i -d -l -b -n`.each_line.map(&:split)
      inbytes_index  = data[0].map(&:downcase).index('ibytes')
      outbytes_index = data[0].map(&:downcase).index('obytes')

      table = data[1..-1].map_to_hash do |l|
        fact = data[0].size - l.size
        [
          l[0],
          [
            l[inbytes_index - fact].to_f,
            l[outbytes_index - fact].to_f
          ]
        ]
      end

      (rx, tx) = table.values.sum2
      { rx: rx, tx: tx }
    end
  end

  before_sleep do
    @start = fetch
  end

  after_sleep do
    @end = fetch
    {
      rx_speed: [0, (@end[:rx] - @start[:rx]) / Config[:timeout]].max,
      tx_speed: [0, (@end[:tx] - @start[:tx]) / Config[:timeout]].max
    }
  end
end
