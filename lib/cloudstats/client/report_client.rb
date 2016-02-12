module CloudStats
  class ReportClient
    def send_report
      info = collect_info
      data = CloudStats.serialize(server_key, info)
      send(data)
    end

    protected

    def send(data)
      $logger.log "Plain ReportClient won't do anything!"
    end

    private

    def collect_info
      $logger.info 'Collecting information...'
      info = Sysinfo.load
      $logger.info 'Done collection information'
      info
    end

    def server_key
      CloudStats.server_key(nil)
    end
  end
end
