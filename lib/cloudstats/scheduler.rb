require 'rufus/scheduler'

module CloudStats
  class << self
    def perform_update
      $logger.info "Collecting information"
      info = Sysinfo.load { }
      $logger.info "[DONE]"

      $logger.info "Publishing..."
      CloudStats.publish(info)
      $logger.info "[DONE]"
    end

    def start
      scheduler = Rufus::Scheduler.new

      def scheduler.on_error(job, error)
        $logger.error "#{error.class.name}: #{error.message}"
        Airbrake.catch(error, { job_id: job.id })
      end

      $logger.info 'Starting the CloudStats agent'

      scheduler.every '1m' do
        CloudStats.perform_update
      end

      scheduler.every '1m' do
        Updater.new.update
      end

      scheduler.every '10m' do
        CloudStats::Backup.new.perform
      end
      scheduler.join
    end

    def publish(info)
      url       = CloudStats.url
      publisher = CloudStats::Publisher.new(url)
      key       = CloudStats.server_key(info)
      data      = CloudStats.serialize(key, info)
      publisher.publish(data)
    end

    def url
      protocol  = Config[:protocol] || 'http'
      domain    = Config[:domain]
      port      = Config[:port].nil? ? '' : ":#{Config[:port]}"
      path      = Config[:uri_path]
      key       = PublicConfig['key']

      @@_url ||= "#{protocol}://api.#{domain}#{port}/#{path}?key=#{key}"
    end
  end
end
