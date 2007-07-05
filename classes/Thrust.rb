module RubyFlight
  class Thrust
    def value
      raise RuntimeError.new("Not implemented")
    end    
    
    def idle?
      raise RuntimeError.new("Not implemented")
    end
  end
end
