CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :puma

  require_process :puma
end
