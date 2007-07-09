require 'singleton'

module RubyFlight
  class Aircraft
    include Singleton
    
    attr_reader(:engines,:fuel)
    def initialize
      @vars = Variables::instance()
      @engines = Engines.new
      @fuel = Fuel.new
      @airports = File.open('airports.dump', 'r') {|io| airports = Marshal.load(io)}
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
    
    # in degrees (Float)
    def heading
      @vars.get(:heading, 4, :uint).to_f * (360.0/(65536.0 * 65536.0))
    end
    
    # in degrees (Float), positive is down, negative is up
    def pitch
      @vars.get(:pitch, 4, :int) * (360.0 / (65536.0 * 65536.0))
    end
    
    # in degrees, positive to the right, negative to the left (Float)
    def bank
      @vars.get(:bank, 4, :int).to_f * (360.0 / (65536.0 * 65536.0))
    end
    
    # in feet (same as ground_altitude + radio_altitude)
    def altitude
      offset = @vars.offset(:altitude)
      unit = @vars.get(offset + 4, 4, :uint).to_f 
      fract = @vars.get(offset, 4, :uint).to_f  / (65536.0 * 65536.0)
      return (unit < 0 ? unit - fract : unit + fract)
    end
    
    # in feet
    def ground_altitude
      (@vars.get(:ground_altitude, 4, :uint) / 256.0).meters_to_feet
    end
    
    # in feet
    def radio_altitude
      (@vars.get(:radio_altitude, 4, :uint) / 65536.0).meters_to_feet
    end
    
    # this is not updated on slew mode
    def on_ground?
      @vars.get(:on_ground, 2, :uint) == 1
    end
    
    def airborne?
      !self.on_ground?
    end
    
    def parking_brake?
      @vars.get(:parking_brake, 2, :int) == 32767
    end
    
    def pushing_back?
      @vars.get(:pushback, 4, :uint) != 3
    end
    
    # If it is near (given a radius in miles) a given airport. Note that only
    # one runways is considered for each airport
    def near_airport?(code, radius)
      lat = self.latitude
      long = self.longitude
      pos = Position.new(lat, long)      
      
      longitudes = @airports[lat.to_i]
      if (longitudes.nil?) then puts "no lat"; return false end
      entries = longitudes[long.to_i]
      if (entries.nil?) then puts "no long"; return false end
      puts entries.keys.join(',')
      pos = entries[code]
      if (pos.nil?) then puts "no airport"; return false end
      
      return Position.new(pos[0], pos[1]).distance_to(Position.new(pos[0], pos[1])).abs <= radius 
    end
    
    # In knots
    def indicated_airspeed
      @vars.get(:ias, 4, :int) / 128.0
    end
    
    # In knots
    def true_airspeed
      @vars.get(:tas, 4, :int) / 128.0
    end
    
    # In knots (not updated in slew mode)
    def ground_speed
      (@vars.get(:ground_speed, 4, :int) / (1852.0 * 65536.0)) * 3600.0
    end
    
    def doors_open?
      @vars.get(:doors_open, 1, :uint) == 1
    end
    
    # In milibars
    def altimeter
      @vars.get(:altimeter, 2, :uint) / 16.0
    end
    
    # vertical speed (ft/m)
    def vertical_speed
      (@vars.get(:vs, 4, :int) / (256.0 * 60.0)).meters_to_feet
    end
    
    # vertical speed (ft/m) updated only while (airborne? == true)
    def last_vertical_speed
      (@vars.get(:vs_last, 4, :int) / (60.0 * 256.0)).meters_to_feet
    end
  end
end
