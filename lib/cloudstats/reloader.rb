module CloudStats
  module Reloader
    def self.watch(&block)
      instance_eval(&block)
    end

    def self.require_relative(file)
      add_dependency File.join(path, "#{file}.rb")
    end

    def self.require_dir(dir)
      Dir["#{path}/#{dir}/*.rb"].each do |file|
        add_dependency file
      end
    end

    def self.require_tree(dir)
      Dir["#{path}/#{dir}/**/*.rb"].each do |file|
        add_dependency file
      end
    end

    def self.reload
      dependencies.each do |file|
        load file
      end
    end

    def self.path
      File.dirname(__FILE__)
    end

    private

    def self.dependencies
      @@dependencies ||= []
    end

    def self.add_dependency(file)
      dependencies << file
      load file
    end
  end
end
