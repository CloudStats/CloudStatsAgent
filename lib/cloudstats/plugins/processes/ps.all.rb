CloudStats::Sysinfo.plugin :processes do
  HighOrderProcesses = %w(
    bash zsh fish sh ksh tmux screen sudo).map { |x| [x, "-#{x}"] }.flatten

  def psparse
    `ps axo pid,ppid,rss,pcpu,pmem,vsize,command`
      .force_encoding('utf-8')
      .split("\n")[1..-1]
      .map(&:split)
      .map do |pr|
        {
          pid:     pr[0],
          ppid:    pr[1],
          rss:     pr[2],
          cpu:     pr[3],
          mem:     pr[4],
          vsize:   pr[5],
          command: pr[6].gsub('.', '_').split(' ').first
        }
      end.delete_if { |h| h[:ppid] == '2' }
  end

  def pstree
    def acc(list, ppid)
      acc_fields = [:rss, :cpu, :mem]

      list
        .select { |p| p[:ppid] == ppid }
        .map do |pr|
          children = acc(list, pr[:pid])
          pr[:children] = children
          pr[:exec] = File.basename(pr[:command].split.first || '').downcase
          acc_fields.each do |field|
            pr[field] = pr[field].to_i + children.sum_field(field)
          end
          pr
        end
    end

    tree = acc(psparse, '1')
    tree
   end

  def psflatten(tree)
    tree
      .map do |pr|
        children = pr.delete(:children)
        if /cloudstats/ =~ pr[:command]
          []
        elsif children.size == 0
          pr
        elsif /\Ainit\s?(\[\d+\])?\Z/ =~ pr[:command]
          psflatten(children)
        elsif HighOrderProcesses.include?(pr[:exec])
          psflatten(children)
        else
          pr
        end
      end
      .flatten
  end

  run do
    processes = psparse
    top_cpu_processes = processes.sort { |e| e[:cpu].to_f }.reverse[0..9]
    top_mem_processes = processes.sort { |e| e[:mem].to_f }.reverse[0..9]

    @ps = `ps axo user,pid,ppid,rss,vsize,pcpu,pmem,command`
    {
      count: @ps.each_line.count - 1,
      ps: @ps,
      top: (top_cpu_processes + top_mem_processes)
    }
  end
end
