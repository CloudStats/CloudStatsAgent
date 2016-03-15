module CloudStats
  class RPCClient
    def run(command, *args)
      $logger.warn "Plain RPC client won't do anything"
    end
  end
end
