require 'open-uri'
require_relative 'version.rb'

module CloudStats
  class Updater
    def initialize
      repo = ENV['REPO'] || PublicConfig['repo'] || 'agent'
      @update_server = "https://cloudstatsstorage.blob.core.windows.net/#{repo}/"
      @app_dir = Config[:install_path]
      @init_script = PublicConfig['init_script'] || '/etc/init.d/cloudstats-agent'
    end

    def update
      $logger.info 'Checking for update'
      $logger.info "Current version: #{current_version}"

      latest_version = get_latest_version
      $logger.info "Latest version: #{latest_version}"

      if Gem::Version.new(latest_version) < Gem::Version.new(current_version)
        $logger.info 'Already running the last version'
        return false
      end

      $logger.info "Latest version: #{latest_version}"
      current_package_name = package_name latest_version
      $logger.info "Package name: #{current_package_name}"

      download(current_package_name)
      install(current_package_name)
      update_init_script
      remove_archive(current_package_name)

      Reloader.reload
      $logger.info "Reloader updated config to version #{CloudStats::VERSION}."

      case Config[:update_type]
      when :restart
        $logger.info 'Restarting via :restart'
        `/etc/init.d/cloudstats-agent restart`
      when :keepalive
        $logger.info 'Restarting via :keepalive'
        exit(1) # keepalive will start agent back
      else
        $logger.info 'Restarted via :reload'
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
      "cloudstats-agent-#{version}-#{os}.tar.gz"
    end

    def get_latest_version
      open(@update_server + 'version').read.tr("\n", '')
    end

    def current_version
      CloudStats::VERSION
    end

    def download(package_name)
      $logger.info 'Downloading latest version...'

      open("/tmp/#{package_name}", 'wb') do |file|
        file << open(@update_server + package_name).read
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
      `cp #{@app_dir}/init.d/cloudstats-agent #{@init_script}`
    end
  end
end
