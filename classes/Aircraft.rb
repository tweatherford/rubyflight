module RubyFlight
  class Aircraft
    include Singleton
    
    HEADING_OFFSET=0x580
    PITCH_OFFSET=0x578
    BANK_OFFSET=0x57C
    ALTITUDE_OFFSET=0x570    
    
    attr_reader(:thrust)
    def initialize
      @thrust = Thrust.new
    end
    
    def heading
      (getUInt(HEADING_OFFSET, 4).to_f * (360.0/(65536.0*65536.0))).to_i
      #getInt(HEADING_OFFSET, 4)
    end
    
    def pitch
      #getInt(PITCH_OFFSET, 4)
      getReal(0x2e98)
    end
    
    def bank
      getInt(BANK_OFFSET, 4)
    end
    
    def altitude
      unit = getUInt(ALTITUDE_OFFSET + 4, 4)
      fract = getUInt(ALTITUDE_OFFSET, 4)
      puts "unit #{unit}, fract #{fract}"
    end
    
    def radio_altitude
      raise RuntimeError.new("Not implemented")
    end
    
    def on_ground?
      raise RuntimeError.new("Not implemented")      
    end
    
    def engines_off?
      raise RuntimeError.new("Not implemented")      
    end
    
    def parking_brake?
      raise RuntimeError.new("Not implemented")      
    end
    
    def airport
      raise RuntimeError.new("Not implemented")      
    end
    
    def speed
      raise RuntimeError.new("Not implemented")      
    end
    
    def on_runway?
      raise RuntimeError.new("Not implemented")      
    end
  end
end
