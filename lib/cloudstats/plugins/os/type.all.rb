CloudStats::Sysinfo.plugin :os do
  def format(distro, version, uptime_in_seconds)
    {
      type:    `uname`.strip,
      uptime:  `uptime`.strip,
      uptime_seconds: uptime_in_seconds,
      name:    distro,
      version: version,
      kernel:  `uname -r`.strip,
      users:   `users | wc -w`.strip
    }
  end

  os :osx do
    run do
      uptime_in_seconds = `sysctl -n kern.boottime`.scan( /\d+/ ).first

      format('Mac OS X', `sw_vers -productVersion`.strip, uptime_in_seconds)
    end
  end

  os :linux do

    def grep_param(file, param)
      if File.exists? file
        File.open(file, 'r').read.each_line do |line|
          return $1 if line =~ /\A#{param}="(.*)"/
          return $1 if line =~ /\A#{param}=(.*)/
        end
        return nil
      end
    end

    run do
      distro  = grep_param('/etc/lsb-release', 'DISTRIB_ID')
      version = grep_param('/etc/lsb-release', 'DISTRIB_RELEASE')
      distro  = grep_param('/etc/os-release',  'NAME')    if distro.nil?
      version = grep_param('/etc/os-release',  'VERSION') if version.nil?
      uptime_in_seconds = `cat /proc/uptime`.split(' ').first
      if distro.nil?
        if File.exists? '/etc/debian_version'
          distro = 'debian'
          version = File.readlines('/etc/debian_version').first
        elsif File.exists? '/etc/centos-release'
          distro = 'centos'
          version = File.read('/etc/centos-release').gsub(/centos/i, '').strip rescue nil
        elsif File.exists? '/etc/fedora-release'
          distro = 'fedora'
        elsif File.exists? '/etc/redhat-release'
          distro = 'redhat'
          version = File.read('/etc/redhat-release').gsub(/redhat/i, '').strip rescue nil
        elsif File.exists?('/etc/SuSE-release')
          distro = 'sles'
        elsif File.exists?('/etc/issue')
          issue = File.read('/etc/issue')
          if issue =~ /arch/i
            distro = 'arch'
          else
            distro = issue.split('\n').join(' ')
          end
        else
          distro = `cat /etc/*release`.each_line.first.strip
        end
      end

      distro ||= 'unknown'
      version ||= ""

      distro = distro.capitalize.strip
      version = version.strip

      format(distro, version, uptime_in_seconds)
    end
  end
end
