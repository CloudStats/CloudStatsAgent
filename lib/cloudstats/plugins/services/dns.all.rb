CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :dns

  require_process :tinydns
  require_process :named
  require_process :pdns_server
end
