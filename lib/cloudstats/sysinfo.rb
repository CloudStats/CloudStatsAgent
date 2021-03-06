module CloudStats
  class Sysinfo < Hash
    @@plugins = []

    def self.plugins_by_path(path)
      @@plugins.select { |p| p.path == path }
    end

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

    def safe_get(*path)
      path.inject(self) do |acc, x|
        acc.nil? ? acc : acc[x]
      end
    end
  end
end
