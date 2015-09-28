
require 'socket'
require 'yaml'
require 'json'
require 'bytes_converter'
require 'net/http'
require 'digest'
require 'ps-ruby'

require_relative './cloudstats/reloader'
CloudStats::Reloader.watch do
  require_relative 'initializers/logger'
  require_relative 'initializers/airbrake'
end
$logger = CloudStats::Logger.new

begin

  CloudStats::Reloader.watch do
    require_dir './helpers'
    require_dir '.'
    require_tree './plugins'
  end

  $logger.info ""
  $logger.info "CloudStats Agent v#{Config[:version]}"
  $logger.info ""

  if $enable_repl
    require_relative 'cloudstats/repl/repl'
    exit
  end

  case ARGV[0]

  when '--setup'
    $logger.info "Setting up #{ARGV[1]} domain key"
    y = YAML.load('verify_ssl: true')
    y['key'] = ARGV[1]

    open(Config[:public_config_path], 'w') do |f|
      f.write y.to_yaml
    end

  when '--update'
    CloudStats::Updater.new.update

  when '--first-time'
    CloudStats.perform_update

  when '--help'
    puts "CloudStats Agent v.#{Config[:version]}\n"
    puts 'Usage: cloudstats-agent [option]'
    puts "\t--update\tUpdate to the latest version"
    puts "\t--first-time\tPerform a first time update"
    puts "\t--setup APIKEY\tSet the APIKEY"

  else
    CloudStats.start

  end
rescue Exception => e
  unless $enable_repl
    $logger.fatal "#{e.class.name}: #{e.message}"
    Airbrake.catch(e)
  end
  raise e
end
