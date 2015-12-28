require 'rufus/scheduler'

module CloudStats
  class << self
    def perform_update
      $logger.info 'Collecting information'
      info = Sysinfo.load {}
      $logger.info '[DONE]'

      $logger.info 'Publishing...'
      catch_and_log_socket_error('https://api.cloudstats.me') do
        response = CloudStats.publish(info)

        if response['ok']
          $logger.info "Response: #{response}"
        else
          $logger.error 'There was an error posting the status'
          $logger.error "Response: #{response}"
        end
        $logger.info '[DONE]'
      end
    end

    def start
      scheduler = Rufus::Scheduler.new

      def scheduler.on_error(job, error)
        $logger.error "#{error.class.name}: #{error.message}"
        Airbrake.catch(error, job_id: job.id)
      end

      $logger.info 'Starting the CloudStats agent'
      $logger.debug 'Scheduling the jobs'
      scheduler.every '1m' do
        CloudStats.perform_update
      end

      scheduler.every '5h' do
        catch_and_log_socket_error(Updater.STORAGE_SERVICE) { Updater.new.update }
      end

      scheduler.cron '0 0 * * *' do
        CloudStats::Backup.instance.perform
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

    def catch_and_log_socket_error(url, &block)
      begin
        block.call
      rescue SocketError => e
        $logger.error "Could not reach #{url}.\n
        It could be due to a faulty network or DNS.\n
        Please check if you can ping and load the api.cloudstats.me page from
        this server, otherwise please contact the CloudStats support.\n
        Please include in you report the following error:
        #{e}"
      end
    end
  end
end
