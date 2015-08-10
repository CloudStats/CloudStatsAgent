CloudStats::Sysinfo.plugin :memory do
  os :osx do
    run do
      memory = {}

      installed_memory = `sysctl -n hw.memsize`.to_i
      memory[:total] = installed_memory

      total_consumed = 0
      active = 0
      inactive = 0
      vm_stat = `vm_stat`
      vm_stat_match = /page size of (\d+) bytes/.match(vm_stat)
      page_size = if vm_stat_match and vm_stat_match[1]
                    vm_stat_match[1].to_i
                  else
                    4096
                  end
      vm_stat.split("\n").each do |line|
        ['wired down', 'active', 'inactive'].each do |match|
          unless line.index("Pages #{match}:").nil?
            pages = line.split.last.to_i
            megabyte_val = pages * page_size
            total_consumed += megabyte_val
            case match
            when 'wired down'
              active += megabyte_val.to_i
            when 'active'
              active += megabyte_val.to_i
            when 'inactive'
              inactive += megabyte_val.to_i
            end
          end
        end
      end

      memory[:active] = active if active > 0
      memory[:inactive] = inactive if inactive > 0

      free_memory = installed_memory - total_consumed
      memory[:free] = free_memory if total_consumed > 0

      memory[:summary] = {
        free: memory[:free],
        used: memory[:total] - memory[:free]
      }

      memory
    end
  end
end
