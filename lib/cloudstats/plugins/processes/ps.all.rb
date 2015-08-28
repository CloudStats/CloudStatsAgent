CloudStats::Sysinfo.plugin :processes do
  def psparse
    `ps -eo pid,ppid,rss,pcpu,pmem,command`
      .split("\n")[1..-1]
      .map(&:split)
      .map do |pr|
        { 
          pid:     pr[0],
          ppid:    pr[1],
          rss:     pr[2],
          cpu:     pr[3],
          mem:     pr[4],
          command: (pr[5..-1] || []).join(" ")
        }
      end
  end

  def pstree
    def acc(list, ppid)
      acc_fields = [:rss, :cpu, :mem]

      list
        .select { |p| p[:ppid] == ppid }
        .map do |pr|
          children = acc(list, pr[:pid])
          acc_fields.each do |field|
            pr[field] = pr[field].to_i + children.sum_field(field)
          end
          pr
        end
    end

    tree = acc(psparse, "1")
    tree.each do |pr|
      pr[:pretty_command] = File.basename(pr[:command].split("-").first)
    end
    tree
  end

  run do
    @ps = `ps -eo user,pid,ppid,rss,vsize,pcpu,pmem,command`
    {
      count: @ps.each_line.count - 1,
      ps: @ps,
      all: pstree
    }
  end
end
