const_unset :Config
const_unset :PublicConfig

$PROGRAM_NAME = 'cloudstats-agent'
$SRC_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))

Config = {

  # url params
  protocol: ENV['PROT'] || 'https',
  domain:   ENV['DOMAIN'] || 'cloudstats.me',
  port:     ENV['PORT'] || 443,
  uri_path: 'agent_api/status',

  # sysinfo params
  timeout: 2,

  # serializer
  server_key_path: "#{$SRC_PATH}/../server.key",

  # agent
  install_path:     ENV['INSTALL_PATH'] || '/home/cloudstats_agent',
  version:          '1.1.4',
  restart_required: true
}

Config[:public_config_path] = "#{Config[:install_path]}/config.yml"
Config[:backup_bin_path] = "#{Config[:install_path]}/config.yml"

PublicConfig = YAML.load(File.read(Config[:public_config_path])) rescue {}
