CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :db

  require_process :mysql
  require_process :pg, :postgres
end
