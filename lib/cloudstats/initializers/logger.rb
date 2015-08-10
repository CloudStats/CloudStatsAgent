require 'logger'

class CloudStats::Logger < Logger
  # https://gist.github.com/Peeja/5489388
  class TeeIO
    # TeeIO will write to each of these IOs when it is written to.
    def initialize(*ios)
      @ios = ios
    end

    def write(data)
      @ios.each { |io| io.write(data) }
    end

    def close
      @ios.each { |io| io.close }
    end
  end

  def initialize
    logfile = open('/var/log/cloudstats.log', 'a') rescue nil
    logfile = open('./cloudstats.log', 'a') unless logfile
    logfile.sync = true

    super(TeeIO.new(STDOUT, logfile))
  end
end
