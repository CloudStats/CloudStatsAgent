module CloudStats
  class Plugin
    attr_reader :path

    def initialize(path)
      @pass1 = proc { default_run }
      @pass2 = nil
      @path = path
    end

    def before_sleep(&block)
      @pass1 = block
    end
    alias_method :run, :before_sleep

    def after_sleep(&block)
      @pass2 = block
    end

    def os(name)
      yield if OS.match?(name)
    end

    def include(helper)
      self.class.send(:include, helper)
    end

    def pass1?
      !@pass1.nil?
    end

    def pass2?
      !@pass2.nil?
    end

    def pass1
      wrap(@path, @pass1) if pass1?
    end

    def pass2
      wrap(@path, @pass2) if pass2?
    end

    private

    def wrap(key, pass)
      h = {}
      h[key] = pass.call
      h
    rescue => error
      $logger.warn "Failed to fetch :#{key} (#{error.message})"
      Raven.capture_exception(error)
      {}
    end
  end
end
