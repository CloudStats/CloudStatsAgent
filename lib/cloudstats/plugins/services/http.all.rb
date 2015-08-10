CloudStats::Sysinfo.plugin :services do
  include ServicesHelper

  service :http

  require_process :lshttpd
  require_process :lighttpd
  require_process :nginx
  require_process :httpd
  require_process :apache2
end
