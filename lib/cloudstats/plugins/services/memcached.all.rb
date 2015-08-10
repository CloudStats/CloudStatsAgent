CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :memcached

  require_process :memcached
end
