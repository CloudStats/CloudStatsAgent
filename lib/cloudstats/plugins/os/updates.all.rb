CloudStats::Sysinfo.plugin :os do
  os :osx do
    after_sleep do # after_sleep as it takes too much time
      # { pending_updates: `softwareupdate -l`.each_line.grep(/\*/).count }
      {}
    end
  end

  os :linux do
    def has?(command)
      OS.has?(command)
    end

    def aptget
      `apt-get -u upgrade`.each_line.grep(/^[0-9]+\s.*/).first.to_i
    end

    def pacman
      `pacman -Syup`.each_line.grep(/^http[s]?:\/\//i).count
    end

    def yum
      finder = /(\.i386|\.x86_64|\.noarch|\.src|\.nosrc|\.alpha|\.sparc|\.mips|\.ppc|\.m68k|\.SGI)/
      `yum check-update`.each_line.grep(finder).count
    end

    after_sleep do
      pending_updates = if has? 'apt-get'
                          aptget
                        elsif has? 'pacman'
                          pacman
                        elsif has? 'yum'
                          yum
                        else
                          0
                        end

      { pending_updates: pending_updates }
    end
  end
end
