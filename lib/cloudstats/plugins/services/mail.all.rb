CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :mail

  require_process :qmail
  require_process :exim
end
