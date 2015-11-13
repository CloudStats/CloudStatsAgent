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

      $logger.info "Performing the backup"
      $logger.debug "Notifying the backup start"
      notify_backup_start

      ::Backup::Model.all.each do |m|
        ::Backup::Model.find_by_trigger(m.trigger).first.perform!

        m.notifiers.each(&:perform!)
      end
    end

    def download_config
      $logger.info "Downloading backup config..."

      backup_config_link = "#{Config[:protocol]}://api.#{Config[:domain]}#{port}/agent_api/backups/#{CloudStats.server_key(nil)}?key=#{PublicConfig['key']}"

      open("#{@config_dir}/config.rb", 'w') do |file|
        file << open(backup_config_link).read
      end

      $logger.info "Backup config file downoloaded"
    end

    def notify_backup_start
      uri = URI("#{Config[:protocol]}://api.#{Config[:domain]}#{port}/agent_api/backups/#{CloudStats.server_key_from_file}/notify?key=#{PublicConfig['key']}")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri)
      request.add_field('Content-Type', 'application/json')
      request.body = {status: 'success', message: '[Backup::Starting] Starting the backup with the CloudStats agent'}.to_json

      http.request(request)
    end

    def port
      port = Config[:port].nil? ? '' : ":#{Config[:port]}"
    end
  end
end
