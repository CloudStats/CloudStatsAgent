require 'faraday'
require_relative 'version.rb'

module CloudStats
  class Updater
    def self.STORAGE_SERVICE
      Config[:update_storage_service]
    end

    def initialize(update_type: Config[:update_type])
      repo = ENV['REPO'] || PublicConfig['repo'] || 'agent'
      @update_server = "#{Updater.STORAGE_SERVICE}/#{repo}/"
      @app_dir = Config[:install_path]
      @init_script = PublicConfig['init_script'] || '/etc/init.d/monitoring-agent'
      @update_type = update_type
      @conn = Faraday.new do |faraday|
        faraday.request :url_encoded             # form-encode POST params
        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def update
      $logger.info 'Checking for update'
      $logger.info "Current version: #{current_version}"

      latest_version = get_latest_version
      $logger.info "Latest version: #{latest_version}"

      if Gem::Version.new(latest_version) <= Gem::Version.new(current_version)
        $logger.info 'Already running the last version'
        return false
      end

      $logger.info "Latest version: #{latest_version}"
      current_package_name = package_name latest_version
      $logger.info "Package name: #{current_package_name}"

      download(current_package_name)
      install(current_package_name)
      update_init_script unless PublicConfig['disable_init_script_update']
      remove_archive(current_package_name)

      case @update_type
      when :restart
        $logger.info 'Restarting via :restart'
        exec "/etc/init.d/monitoring-agent", "restart"
      else
        $logger.info 'Restarting via :keepalive'
        exit # keepalive will start agent back
      end
      true
    end

    private

    def package_name(version)
      os = if OS.current_os == :osx
             'osx'
           else
             "linux-#{OS.architecture}"
           end
      "monitoring-agent-#{version}-#{os}.tar.gz"
    end

    def get_latest_version
      @conn.get(@update_server + 'cloudstats-version').body.tr("\n", '')
    end

    def current_version
      CloudStats::VERSION
    end

    def download(package_name)
      $logger.info 'Downloading latest version...'

      open("/tmp/#{package_name}", 'wb') do |file|
        file << @conn.get(@update_server + package_name).body
      end
      $logger.info 'Donwload completed'
    end

    def install(package_name)
      $logger.info "Installing the package #{package_name} to #{@app_dir}"
      `cd /tmp && tar zxf #{package_name} -C #{@app_dir} --strip-components 1`
    end

    def remove_archive(package_name)
      file = "/tmp/#{package_name}"
      $logger.debug "#{file} removed"
      File.delete(file)
    end

    def update_init_script
      `cp #{@app_dir}/init.d/monitoring-agent #{@init_script}`
    end
  end
end
