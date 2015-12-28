CloudStats::Sysinfo.plugin :network do

  os :linux do
    def fetch
      lines = `ip -s link`.each_line.map(&:downcase)  
      ifaces = lines.map(&:split)
      rxlines = ifaces.each_with_index.select { |x, i| x[0] =~ /^rx/ }.map { |x, i| i + 1 }
      txlines = ifaces.each_with_index.select { |x, i| x[0] =~ /^tx/ }.map { |x, i| i + 1 }

      skip_ifaces = %w(loopback)

      lines
        .map { |x| /^\d+[:]\s*([^\s]+)[:]\s*[<](.*)[>]/.match(x) }
        .reject(&:nil?)
        .zip(rxlines, txlines)
        .reject do |match, rx, tx| 
          skip_ifaces.any? do |skip|
            match[2].split(',').include?(skip)
          end
        end
        .map_to_hash do |match, rx, tx|
          [match[1], [ifaces[rx][0].to_f, ifaces[tx][0].to_f]]
        end
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

      table
    end
  end

  def format(iface, present, past)
    if present && past
      rx = (present[0] - past[0]) / Config[:timeout]
      tx = (present[1] - past[1]) / Config[:timeout]
      [iface, [rx, 0].max, [tx, 0].max]
    else
      [iface, 0, 0]
    end
  end

  before_sleep do
    @start = fetch
  end

  after_sleep do
    values = fetch.map do |iface, present|
      past = @start[iface]
      format(iface, present, past)
    end
    {
      all: values,
      rx_speed: values.map { |x| x[1] }.sum,
      tx_speed: values.map { |x| x[2] }.sum
    }
  end
end
