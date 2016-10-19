CloudStats::Sysinfo.plugin :processes do
  HighOrderProcesses = %w(
    bash zsh fish sh ksh tmux screen sudo).map { |x| [x, "-#{x}"] }.flatten

  class MovingTop
    KEEP_PROCESSES = 200
    SEPARATOR = "\x00"

    def initialize(window)
      @graph = {}
      @start_time = get_current_time
      @window = window
    end

    def insert(pids)
      clear_stale_items
      insert_time = get_current_time
      pids.keys.each do |pid|
        key = pid.to_s + SEPARATOR + pids[pid][:command]
        unless @graph[key]
          @graph[key] = []
        end

        @graph[key] << [insert_time, pids[pid][:value].to_f]
      end
    end

    def output(top = 5, &block)
      clear_stale_items
      pids = get_top(top)

      pids.each do |key|
        pid, command = key.split(SEPARATOR)
        yield pid, command, @graph[key]
      end
    end

    private

    def get_top(top)
      @graph.keys.map do |pid|
        sum = 0
        @graph[pid].each do |point|
          sum += point[1]
        end
        [pid, sum / @graph[pid].length]
      end.sort { |x,y| y[1] <=> x[1] }[0..top - 1].map(&:first)
    end

    def clear_stale_items
      move_start_time
      @graph.keys.each do |key|
        index = nil
        @graph[key].each_with_index do |point, i|
          if point[0] >= @start_time
            index = i
            break
          end
        end
        if index and index > 0
          @graph[key] = @graph[key][index..-1]
        elsif not index
          if @graph[key].empty?
            @graph.delete(key)
          end
        end
      end

      if @graph.keys.length > KEEP_PROCESSES
        (@graph.keys - get_top(KEEP_PROCESSES)).each do |pid|
          @graph.delete(pid)
        end
      end
    end

    def move_start_time
      new_time = get_current_time - @window
      if new_time > @start_time
        @start_time = new_time
      end
    end

    def get_current_time
      ret = Time.now.utc + 5
      ret -= ret.sec
    end

  end

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
      end.delete_if { |h| h[:ppid] == '2' || h[:pid] == '2' }
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
    unless @mem_top and @cpu_top
      @mem_top = MovingTop.new(3600)
      @cpu_top = MovingTop.new(3600)
    end
    mem = {}
    cpu = {}
    processes.each do |process|
      mem[process[:pid]] = {value: process[:mem], command: process[:command]}
      cpu[process[:pid]] = {value: process[:cpu], command: process[:command]}
    end
    @mem_top.insert(mem)
    @cpu_top.insert(cpu)

    top_mem_graph = []
    @mem_top.output do |pid, command, graph|
      top_mem_graph << [pid, command, graph.map { |x| [x[0].to_i*1000, x[1]] } ]
    end
    top_cpu_graph = []
    @cpu_top.output do |pid, command, graph|
      top_cpu_graph << [pid, command, graph.map { |x| [x[0].to_i*1000, x[1]] } ]
    end

    @ps = `ps axo user,pid,ppid,rss,vsize,pcpu,pmem,command`
    {
      count: @ps.each_line.count - 1,
      ps: @ps,
      top_cpu_graph: top_cpu_graph,
      top_mem_graph: top_mem_graph
    }
  end
end
