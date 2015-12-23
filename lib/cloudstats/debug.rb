# src_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))

# set_trace_func(proc do |event, file, line, id, binding, classname|
#   if file
#     path = File.expand_path(File.dirname(file))
#     if path.start_with?(src_path)
#       open('/var/log/cloudstats.trace.log', 'a') { |f|
#         f.puts "#{file}:#{line} #{event} #{classname}##{id}"
#       }
#     end
#   end
# end)
