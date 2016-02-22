module CloudStats
  class CommandProcessorServer
    attr_reader :server_driver

    def initialize(server_driver, opts={})
      @server_driver = server_driver
      @alive = false
      @block = !!opts[:block]
    end

    def run
      if @block
        run_body
      else
        Thread.new do
          run_body
        end
      end
    end

    def alive?
      @alive
    end

    private

    def run_body
      @alive = true
      server_driver.subscribe { |r| handle_request(r) }
    ensure
      @alive = false
    end

    def handle_request(request)
      command = request.payload['command']
      args = request.payload['args'] || []
      args = [args].flatten

      if command
        $logger.info "Received command: #{command} #{args}"
        handle_command(request, command, args)
      else
        $logger.warn "Received unknown command: #{request.payload}"
        send_reject(request, :unknown_format)
      end
    rescue
      send_reject(request, :internal_error)
    end

    def handle_command(request, command, args)
      exec_string = "#{command} #{args.join(' ')}"
      $logger.info "Executing: #{exec_string}"
      output = `#{exec_string}`
      code = $?.exitstatus
      request.send_response({
        output: output,
        exit_code: code,
        fulfilled: true
      })
    end

    def send_reject(request, message)
      request.send_response({
        fulfilled: false,
        error: message
      })
    end
  end
end
