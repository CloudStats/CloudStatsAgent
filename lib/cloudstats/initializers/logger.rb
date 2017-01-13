require 'logger'

module CloudStats
  class Logger < ::Logger
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
        @ios.each(&:close)
      end
    end

    def initialize
      logfile = begin
                  LogDevice.new('/var/log/cloudstats.log', shift_age: 5, shift_size: 10485760, shift_period_suffix: '%Y%m%d')
                rescue
                  nil
                end
      logfile = LogDevice.new('./cloudstats.log', shift_age: 5, shift_size: 10485760, shift_period_suffix: '%Y%m%d') unless logfile

      super(TeeIO.new(STDOUT, logfile))
    end
  end
end
