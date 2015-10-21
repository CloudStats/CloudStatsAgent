require 'backup'
require 'net/http'

module CloudStats
  class Backup
    def initialize
      @config_dir = "#{File.expand_path(File.dirname(__FILE__))}/../../Backup"

      Dir.mkdir @config_dir unless File.exists?(@config_dir)
      download_config

      $logger.info "Initializing the backup"
      ::Backup::Model.all.clear
      ::Backup::Config.load(root_path: @config_dir)
    end

    def perform
      $logger.info "Performing the backup"
      ::Backup::Logger.start!
      ::Backup::Model.all.each do |m|
        ::Backup::Model.find_by_trigger(m.trigger).first.perform!
      end
    end

    def download_config
      $logger.info "Downloading backup config..."

      port = Config[:port].nil? ? '' : ":#{Config[:port]}"
      backup_config_link = "#{Config[:protocol]}://api.#{Config[:domain]}#{port}/agent_api/backups/#{CloudStats.server_key(nil)}?key=#{PublicConfig['key']}"

      open("#{@config_dir}/config.rb", 'w') do |file|
        file << open(backup_config_link).read
      end

      $logger.info "Backup config file downoloaded"
    end
  end
end
