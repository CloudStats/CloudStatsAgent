require 'backup'
require 'net/http'
require 'singleton'

module CloudStats
  class Backup
    include Singleton

    def initialize
      @config_dir = "#{File.expand_path(File.dirname(__FILE__))}/../../Backup"

      Dir.mkdir @config_dir unless File.exists?(@config_dir)
    end

    def perform
      download_config unless ENV['DONT_DOWNLOAD_BACKUP_CONFIG']

      $logger.info "Initializing the backup"
      ::Backup::Model.all.clear
      ::Backup::Config.load(root_path: @config_dir)
      ::Backup::Logger.clear!

      if ::Backup::Model.all.empty?
        $logger.info "No backups configured"
      else
        $logger.info "Performing the backup"
        $logger.debug "Notifying the backup start"
        notify_backup_start

        ::Backup::Model.all.each do |m|
          ::Backup::Model.find_by_trigger(m.trigger).first.perform!

          m.notifiers.each(&:perform!)
        end
      end
    end

    def download_config
      $logger.info "Downloading backup config..."

      backup_config_link = "#{server_link}?key=#{PublicConfig['key']}"

      open("#{@config_dir}/config.rb", 'w') do |file|
        file << open(backup_config_link).read
      end

      $logger.info "Backup config file downoloaded"
    end

    def notify_backup_start
      notification_link = "#{server_link}/notify?key=#{PublicConfig['key']}"
      message = {
        status: 'success',
        message: '[Backup::Starting] Starting the backup with the CloudStats agent'
      }

      CloudStats::Publisher.new(notification_link).publish(message)
    end

    def port
      port = Config[:port].nil? ? '' : ":#{Config[:port]}"
    end

    def server_link
      "#{Config[:protocol]}://api.#{Config[:domain]}#{port}/agent_api/backups/#{CloudStats.server_key_from_file}"
    end
  end
end
