CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :ssh

  require_process :sshd
end
