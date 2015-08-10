module CloudStats
  class Sysinfo < Hash
    @@plugins = []

    def self.load
      info = Sysinfo.new
      pass1 = @@plugins.select(&:pass1?)
      pass2 = @@plugins.select(&:pass2?)

      pass1.each do |p|
        result = p.pass1
        unless p.pass2?
          info.deep_merge!(result)
          yield p.path, result if block_given?
        end
      end

      if pass2.count > 0
        sleep(Config[:timeout])
        pass2.each do |p|
          result = p.pass2
          info.deep_merge!(result)
          yield p.path, result if block_given?
        end
      end

      info
    end

    def self.plugin(path, &block)
      plugin = Plugin.new(path)
      plugin.instance_eval(&block)
      @@plugins += [plugin]
    end

    def deep_merge!(second)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      self.merge!(second, &merger)
    end
  end
end
