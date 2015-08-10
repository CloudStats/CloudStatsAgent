CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :nfs

  require_process :nfsd
end
