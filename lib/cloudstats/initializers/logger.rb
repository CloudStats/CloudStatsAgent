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
                  open('/var/log/monitoring_agent.log', 'a')
                rescue
                  nil
                end
      logfile = open('./monitoring_agent.log', 'a') unless logfile
      logfile.sync = true

      super(TeeIO.new(STDOUT, logfile))
    end
  end
end
