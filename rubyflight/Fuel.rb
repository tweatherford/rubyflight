module RubyFlight
  class Fuel
    MIN_FLOW=0.7
    
    def initialize
      @vars = RubyFlight::Variables.instance
    end
    
    def flow(engine_number = 1)
      @aircraft = RubyFlight::Aircraft.instance    
      if (1 <= engine_number && engine_number <= @aircraft.engines.number)
        var = "fuel_flow_#{engine_number}".to_sym
        @vars.get(var, 0, :real)
      end
    end
    
    # used to test flow as being near-to-zero 
    def near_zero_flow?(engine_number = 1)
      self.flow(engine_number) < MIN_FLOW
    end    
    
    def valve_open?(engine_number = 1)
      @aircraft = RubyFlight::Aircraft.instance    
      if (1 <= engine_number && engine_number <= @aircraft.engines.number)
        var = "fuel_valve_#{engine_number}".to_sym
        @vars.get(var, 4, :uint)
      end      
    end
    
    def valve_closed?(engine_number = 1)
      !valve_open?(engine_number)
    end
  end
end