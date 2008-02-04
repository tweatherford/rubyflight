module RubyFlight
  class Fuel
    MIN_FLOW=0.7

    # Individual tank's level (0.0 to 1.0), side can be :center,:left,:right; type can be :main,:aux,:tip (if side is not :center)
    def individual_level(side, type = :main)
      var = (side == :center ? "tank_center_level" : "tank_#{side}_#{type}_level").to_sym
      RubyFlight.get(var) / (128.0 * 65536.0)
    end
    
    # Individual tank's capacity (in Gallons), parameters as above
    def individual_capacity(side, type = :main)
      var = (side == :center ? "tank_center_capacity" : "tank_#{side}_#{type}_capacity").to_sym    
      RubyFlight.get(var)
    end
    
    # The total capacity of tanks in Gallons
    def capacity
      res = individual_capacity(:center)
      self.each_tank {|side,type| res += individual_capacity(side, type)}
      return res
    end
    
    # The total level of fuel in Gallons
    def level
      res = individual_level(:center) * individual_capacity(:center)
      self.each_tank {|side,type| res += individual_level(side, type) * individual_capacity(side, type)}
      return res
    end
    
    # FIXME: units?
    def flow(engine_number = 1)
      @aircraft = RubyFlight::Aircraft.instance    
      if (1 <= engine_number && engine_number <= @aircraft.engines.number)
        RubyFlight.get("fuel_flow_#{engine_number}".to_sym)
      end
    end
    
    # used to test flow as being near-to-zero (values below MIN_FLOW are considered as 0)
    def near_zero_flow?(engine_number = 1)
      self.flow(engine_number) < MIN_FLOW
    end    
    
    def valve_open?(engine_number = 1)
      @aircraft = RubyFlight::Aircraft.instance    
      if (1 <= engine_number && engine_number <= @aircraft.engines.number)
        RubyFlight.get("fuel_valve_#{engine_number}".to_sym)
      end      
    end
    
    def valve_closed?(engine_number = 1)
      !valve_open?(engine_number)
    end
    
    # Calls the block for each side/type combination (:center is not included)
    # FIXME: why isn't center included?
    def each_tank
      [:left,:right].each do |side|
        [:main,:aux,:tip].each do |type|
          yield(side,type)
        end
      end
    end
  end
end
