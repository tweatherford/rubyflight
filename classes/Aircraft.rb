require 'singleton'

module RubyFlight
  class Aircraft
    include Singleton
    
    HEADING_OFFSET=0x580
    PITCH_OFFSET=0x578
    BANK_OFFSET=0x57C
    ALTITUDE_OFFSET=0x570    
    RADIO_ALTITUDE_OFFSET=0x31E4
    GROUND_ALTITUDE_OFFSET=0x20
    ON_GROUND_OFFSET=0x366
    PARKING_BRAKE_OFFSET=0xBC8
    GROUND_SPEED_OFFSET=0x2B4
    TRUE_AIRSPEED_OFFSET=0x2B8
    INDICATED_AIRSPEED_OFFSET=0x2BC
    PUSHBACK_STATE_OFFSET=0x31F0
    LATITUDE_OFFSET=0x560
    LONGITUDE_OFFSET=0x568
    
    attr_reader(:thrust)
    def initialize
      @thrust = Thrust.new
    end
    
    def latitude
      low = RubyFlight::getUInt(LATITUDE_OFFSET, 4).to_f / (65536.0 * 65536.0)
      high = RubyFlight::getInt(LATITUDE_OFFSET + 4, 4).to_f
      res = (high < 0 ? high - low : high + low)
      return res * (90.0 / 10001750.0)
    end
    
    def longitude
      low = RubyFlight::getUInt(LONGITUDE_OFFSET, 4).to_f / (65536.0 * 65536.0)
      high = RubyFlight::getInt(LONGITUDE_OFFSET + 4, 4).to_f
      res = (high < 0 ? high - low : high + low)
      return res * (360.0 / (65536.0 * 65536.0)) 
    end
    
    # In degrees (Float)
    def heading
      RubyFlight::getUInt(HEADING_OFFSET, 4).to_f * (360.0/(65536.0 * 65536.0))
      #getInt(HEADING_OFFSET, 4)
    end
    
    # TODO: see this (Float)
    def pitch
      #getInt(PITCH_OFFSET, 4)
      RubyFlight::getReal(0x2e98)
    end
    
    # In degrees, positive to the right, negative to the left (Float)
    def bank
      RubyFlight::getInt(BANK_OFFSET, 4).to_f * (360.0 / (65536.0 * 65536.0))
    end
    
    # How should I read this?
    def altitude
      unit = RubyFlight::getUInt(ALTITUDE_OFFSET + 4, 4)
      fract = RubyFlight::getUInt(ALTITUDE_OFFSET, 4)
      puts "unit #{unit}, fract #{fract}"
    end
    
    # In metres
    def ground_altitude
      RubyFlight::getUInt(RADIO_ALTITUDE_OFFSET, 4) / 256.0
    end
    
    # In metres
    def radio_altitude
      RubyFlight::getUInt(RADIO_ALTITUDE_OFFSET, 4) / 65536.0
    end
    
    # This is not updated on slew mode
    def on_ground?
      RubyFlight::getUInt(ON_GROUND_OFFSET, 2) == 1
    end
    
    def engines_off?
      raise RuntimeError.new("Not implemented")      
    end
    
    def parking_brake?
      RubyFlight::getInt(PARKING_BRAKE_OFFSET, 2) == 32767
    end
    
    def pushing_back?
      RubyFlight::getUInt(PUSHBACK_STATE_OFFSET, 4) != 3
    end
    
    def airport
      raise RuntimeError.new("Not implemented")      
    end
    
    # In knots
    def indicated_airspeed
      RubyFlight::getInt(INDICATED_AIRSPEED_OFFSET, 4) / 128.0
    end
    
    # In knots
    def true_airspeed
      RubyFlight::getInt(TRUE_AIRSPEED_OFFSET, 4) / 128.0
    end
    
    # In metres/sec (not updated in slew mode)
    def ground_speed
      RubyFlight::getInt(GROUND_SPEED_OFFSET, 4) / 65536.0
    end
    
    def on_runway?
      raise RuntimeError.new("Not implemented")      
    end
  end
end
