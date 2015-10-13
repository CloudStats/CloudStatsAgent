require 'ripl'

def reload!
  CloudStats::Reloader.reload
end

def quit
  puts "quiting"
  exit
end

def run_plugins(path, *extra_path)
  plugs = CloudStats::Sysinfo.plugins_by_path(path)

  output = plugs.inject({}) do |agg, plug|
    output = plug.pass1 if plug.pass1?
    output = plug.pass2 if plug.pass2?
    agg.deep_merge!(output)
  end

  extra_path.inject(output[path]) { |agg, x| agg = agg[x] }
end

Ripl.start argv: [], binding: binding
