CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :kiwiirc

  require_process :kiwiirc
end
