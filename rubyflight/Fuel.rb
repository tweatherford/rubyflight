module RubyFlight
  class Fuel
    MIN_FLOW=0.7
    
    def initialize
      @vars = RubyFlight::Variables.instance
    end
    
#    def level
#      [:left,:center,:right].each |side|
#        [:main,
#    end
#    
#    def level(side, type)
#      if (
#      var = "tank_#{side}_#{type}_level".to_sym
#      @vars.get(var, 4, :uint) / (128.0 * 65536.0)
#    end
#    
#    def capacity(side, type)
#      var = "tank_#{side}_#{type}_capacity".to_sym
#      @vars.get(var, 4, :uint)
#    end
    
    # TODO: units?
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
