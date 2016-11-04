
require 'socket'
require 'yaml'
require 'json'
require 'bytes_converter'
require 'net/http'
require 'digest'
require 'ps-ruby'
require 'bunny'

require_relative './cloudstats/reloader'
CloudStats::Reloader.watch do
  require_relative 'initializers/debug'
  require_relative 'initializers/logger'
end
$logger = CloudStats::Logger.new

begin

  CloudStats::Reloader.watch do
    require_dir './helpers'
    require_dir '.'
    require_dir './rabbitmq'
    require_dir './client'
    require_dir './server'
    require_tree './plugins'
    require_relative 'initializers/raven'
  end

  $logger.info ''
  $logger.info "CloudStats Agent v#{CloudStats::VERSION}"
  $logger.info ''

  if $enable_repl
    require_relative 'cloudstats/repl/repl'
    exit
  end

  case ARGV[0]

  when '--setup'
    $logger.info "Setting up #{ARGV[1]} domain key"
    y = YAML.load('verify_ssl: true')

    y['key']                 = ARGV[1]
    y['enable_remote_calls'] = ARGV[2..-1].include?('--enable-remote-calls')
    y['statsd_host']         = 'data1.cloudstats.me'
    y['statsd_port']         = 8125
    y['statsd_protocol']     = 'udp'

    open(Config[:public_config_path], 'w') do |f|
      f.write y.to_yaml
    end

  when '--update'
    CloudStats::Updater.new(update_type: :restart).update

  when '--backup'
    CloudStats::Backup.instance.perform

  when '--first-time'
    publisher = CloudStats::Publisher.new
    publisher.publish(:http)
    # publisher.publish(:statsd)

    # CloudStats::StatsdShard.store_statsd_host

  when '--command-processor'
    CloudStats::CommandProcessor.new(block: true).run

  when '--help'
    puts "CloudStats Agent v.#{CloudStats::VERSION}\n"
    puts 'Usage: cloudstats-agent [option]'
    puts "\t--update\tUpdate to the latest version"
    puts "\t--first-time\tPerform a first time update"
    puts "\t--setup APIKEY\tSet the APIKEY"

  else
    CloudStats::Scheduler.new.schedule
  end

rescue StandardError, ScriptError, SecurityError => e
  if $enable_repl
    raise e
  else
    $logger.fatal "#{e.class.name}: #{e.message}"
    Raven.capture_exception e
  end
end
