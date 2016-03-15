require_relative './command_executor'

module CloudStats
  # Listens to requests and responses command result
  class CommandProcessorServer
    attr_reader :server_driver, :executor, :alive
    alias alive? alive

    def initialize(server_driver, opts = {})
      @server_driver = server_driver
      @alive = false
      @block = opts.include?(:block) ? opts[:block] : false
      @executor = CommandExecutor.new
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

      executor.execute!(exec_string)

      $logger.info({
        output: executor.stdout,
        error: executor.stderr,
        exit_code: executor.exit_code,
        fulfilled: executor.fulfilled
      }.to_json)

      request.send_response(
        output: executor.stdout,
        error: executor.stderr,
        exit_code: executor.exit_code,
        fulfilled: executor.fulfilled
      )
    end

    def send_reject(request, message)
      request.send_response(
        fulfilled: false,
        error: message
      )
    end
  end
end
