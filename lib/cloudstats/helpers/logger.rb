module CloudStats
  class Logger

    def catch_and_log_socket_error(url, &block)
      block.call
    rescue SocketError => e
      self.error "Could not reach #{url}.\n
      It could be due to a faulty network or DNS.\n
      Please check if you can ping and load the api.cloudstats.me page from
      this server, otherwise please contact the CloudStats support.\n
      Please include in you report the following error:
      #{e}"
      nil
    end

  end
end
