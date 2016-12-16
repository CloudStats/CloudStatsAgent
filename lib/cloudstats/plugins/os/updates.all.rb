require 'timeout'

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
      launch_process("apt-get -u upgrade").each_line.grep(/^[0-9]+\s.*/).first.to_i
    end

    def pacman
      launch_process("pacman -Syup").each_line.grep(/^http[s]?:\/\//i).count
    end

    def yum
      finder = /(\.i386|\.x86_64|\.noarch|\.src|\.nosrc|\.alpha|\.sparc|\.mips|\.ppc|\.m68k|\.SGI)/
      launch_process("yum check-update").each_line.grep(finder).count
    end

    def launch_process(command)
      pid = nil
      output = ""
      aborted = false
      Timeout::timeout(30) do
        process = IO.popen(command, 'r', :err => [:child, :out]) do |io|
          pid = io.pid
          while true
            begin
              break if io.eof
              output += io.gets
            rescue
              break
            end
          end
          Process.wait(pid)
        end
      end rescue aborted = true
      if pid && aborted
        Raven.capture_message("Package manager terminated due to timeout", :extra => {'output' => output})
        Process.kill("TERM", pid)
        Process.wait(pid)
      end
      output
    end

    def get_updates_with_timeout
      pending_updates = nil
      Timeout::timeout(30) do
        pending_updates = if has? 'apt-get'
                            aptget
                          elsif has? 'pacman'
                            pacman
                          elsif has? 'yum'
                            yum
                          else
                            0
                          end
      end rescue nil
      pending_updates
    end

    @last_check = nil
    @pending_updates = 0

    after_sleep do
      cur_time = Time.now
      if !@last_check or (cur_time - @last_check >= 3600)
        cur_updates = get_updates_with_timeout
        if cur_updates
          @pending_updates = cur_updates
          @last_check = cur_time
        end
      end
      { pending_updates: @pending_updates }
    end
  end
end
