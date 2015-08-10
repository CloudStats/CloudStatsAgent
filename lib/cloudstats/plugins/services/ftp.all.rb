CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :ftp

  require_process :proftpd
  require_process 'pure-ftpd'
  require_process 'pro-ftpd'
end
