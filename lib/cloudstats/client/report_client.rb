module CloudStats
  class ReportClient
    attr_reader :client_driver

    def initialize(client_driver)
      @client_driver = client_driver
    end

    def send_report
      info = collect_info
      data = CloudStats.serialize(server_key, info)
      client_driver.send(data)
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
