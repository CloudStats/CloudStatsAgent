const_unset :Config
const_unset :PublicConfig

$PROGRAM_NAME = 'cloudstats-agent'
$SRC_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

Config = {
  cloudstats_agent_env: 'development',
  rabbitmq_server: ENV['RABBITMQ_HOST'] || 'sub.cloudstats.me',
  command_executor_timeout: 300,

  # url params
  protocol: ENV['PROT'] || 'https',
  domain:   ENV['DOMAIN'] || 'cloudstats.me',
  port:     ENV['PORT'] || 443,
  uri_path: 'agent_api/status',

  default_statsd: {
    'statsd_protocol' => 'udp',
    'statsd_host' => 'data1.cloudstats.me',
    'statsd_port' => 8125
  },

  default_processes_statsd: {
    'statsd_host' => 'data2.cloudstats.me'
  },

  # sysinfo params
  timeout: 2,

  # serializer
  server_key_path: ENV['SERVER_KEY_PATH'] || '/etc/cloudstats/server.key',
  old_server_key_path: "#{$SRC_PATH}/../server.key",

  # agent
  install_path: ENV['INSTALL_PATH'] || '/home/cloudstats_agent',
  update_storage_service: 'https://cloudstatsstorage.blob.core.windows.net',
  update_type:  :keepalive # :restart, :keepalive, :reload
}

Config[:public_config_path] = "#{Config[:install_path]}/config.yml"

PublicConfig = YAML.load(File.read(Config[:public_config_path])) rescue {}

PublicConfig.define_singleton_method(:save_to_yml) do
  open(Config[:public_config_path], 'w') do |f|
    f.write PublicConfig.to_yaml
  end
end
