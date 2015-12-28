Object.module_eval do
  # Unset a constant without private access.
  def self.const_unset(const)
    instance_eval do
      remove_const(const) if const_defined?(const)
    end
  end

  def const_unset(const)
    self.class.const_unset const
  end
end
