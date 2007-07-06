require 'singleton'

module RubyFlight
  class Aircraft
    include Singleton
    
    attr_reader(:thrust)
    def initialize
      @thrust = Thrust.new
			@vars = Variables::instance()
    end
    
    def latitude
			offset = @vars.offset(:latitude)
      low = @vars.get(offset, 4, :uint).to_f / (65536.0 * 65536.0)
      high = @vars::get(offset + 4, 4, :int).to_f
      res = (high < 0 ? high - low : high + low)
      return res * (90.0 / 10001750.0)
    end
    
    def longitude
			offset = @vars.offset(:longitude)			
      low = @vars.get(offset, 4, :uint).to_f / (65536.0 * 65536.0)
      high = @vars.get(offset + 4, 4, :int).to_f
      res = (high < 0 ? high - low : high + low)
      return res * (360.0 / (65536.0 * 65536.0)) 
    end
    
    # In degrees (Float)
    def heading
			@vars.get(:heading, 4, :uint).to_f * (360.0/(65536.0 * 65536.0))
    end
    
    # TODO: see this (Float)
    def pitch
			raise RuntimeError("Not finished")			
      #getInt(PITCH_OFFSET, 4)
      RubyFlight::getReal(0x2e98)
    end
    
    # In degrees, positive to the right, negative to the left (Float)
    def bank
      @vars.get(:bank, 4, :int).to_f * (360.0 / (65536.0 * 65536.0))
    end
    
    # TODO: How should I read this?
    def altitude
			raise RuntimeError("Not finished")
      #unit = RubyFlight::getUInt(ALTITUDE_OFFSET + 4, 4)
      #fract = RubyFlight::getUInt(ALTITUDE_OFFSET, 4)
      #puts "unit #{unit}, fract #{fract}"
    end
    
    # In metres
    def ground_altitude
      @vars.get(:ground_altitude, 4, :uint) / 256.0
    end
    
    # In metres
    def radio_altitude
      @vars.get(:radio_altitude, 4, :uint) / 65536.0
    end
    
    # This is not updated on slew mode
    def on_ground?
      @vars.get(:on_ground, 2, :uint) == 1
    end
    
    def engines_off?
      raise RuntimeError.new("Not implemented")      
    end
    
    def parking_brake?
      @vars.get(:parking_brake, 2, :int) == 32767
    end
    
    def pushing_back?
      @vars.get(:pushback, 4, :uint) != 3
    end
    
    # If it is near (given a radius in miles) a given airport. Note that only
    # one runways is considered for each airport. This method loads the pre-dumped
    # airports db every time it is called to save memory (loading is fast)
    def near_airport?(code, radius)
      airports = nil
      File.open('airports.dump', 'r') {|io| airports = Marshal.load(io)}
      lat = self.latitude
      long = self.longitude
      pos = Position.new(lat, long)      
      
      longitudes = airports[lat.to_i]
      if (longitudes.nil?) then return false end
      entries = longitudes[long.to_i]
      if (entries.nil?) then return false end
      
      entries.find {|entry|
        entry[0] == code && Position.new(entry[1], entry[2]).distance_to(pos).abs <= radius        
      }
    end
    
    # In knots
    def indicated_airspeed
      @vars.get(:ias, 4, :int) / 128.0
    end
    
    # In knots
    def true_airspeed
			@vars.get(:tas, 4, :int) / 128.0
    end
    
    # In metres/sec (not updated in slew mode)
    def ground_speed
			@vars.get(:ground_speed, 4, :int) / 65536.0
    end
  end
end
