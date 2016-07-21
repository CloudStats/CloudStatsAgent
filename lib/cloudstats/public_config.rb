PublicConfig = YAML.load(File.read(Config[:public_config_path])) rescue {}

PublicConfig.define_singleton_method(:save_to_yml) do
  open(Config[:public_config_path], 'w') do |f|
    f.write PublicConfig.to_yaml
  end
end
