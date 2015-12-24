CloudStats::Sysinfo.plugin :cpu do
  os :linux do
    run do
      { count: File.readlines('/proc/cpuinfo').grep(/^processor/).count }
    end
  end

  os :osx do
    run do
      { count: `sysctl hw.ncpu`.gsub(/[^0-9]/, '').to_i }
    end
  end
end
