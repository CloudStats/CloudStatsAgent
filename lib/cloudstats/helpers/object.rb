Object.module_eval do
  # Unset a constant without private access.
  def self.const_unset(const)
    self.instance_eval do
      if const_defined?(const)
        remove_const(const)
      end
    end
  end

  def const_unset const
    self.class.const_unset const
  end
end
