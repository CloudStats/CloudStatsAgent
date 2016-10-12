module ServicesHelper
  def require_process(*processes)
    processes = processes.map do |process|
      case process
      when Symbol, String then /#{process}/i
      else process
      end
    end
    @required_processes ||= []
    @required_processes += processes
  end

  def service(service_name)
    @service_name = service_name
  end

  def default_run
    return {} if @service_name.nil?

    result = {}
    result[@service_name] = false
    psax = `ps ax`.force_encoding('utf-8').each_line
    @required_processes.each do |process|
      result[@service_name] |= psax.grep(process).count > 0
    end
    result
  end
end
