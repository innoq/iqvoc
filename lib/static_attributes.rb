module StaticAttributes

  def metaclass
    class << self
      self
    end
  end

  def static_attr(name, value)
    metaclass.instance_eval do
      define_method name do |*args|
        return value
      end
    end
  end

end
