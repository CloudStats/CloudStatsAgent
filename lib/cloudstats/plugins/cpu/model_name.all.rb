CloudStats::Sysinfo.plugin :cpu do
  os :linux do
    run do
      { model_name: File.read('/proc/cpuinfo').scan(/model name.+:(.+)/)[0][0].strip }
    end
  end

end
