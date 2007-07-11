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
      fract = @vars.get(:latitude_fract).to_f / (65536.0 * 65536.0)
      unit = @vars::get(:latitude_unit).to_f
      res = (unit < 0 ? unit - low : unit + low)
      return res * (90.0 / 10001750.0)
    end
    
    def longitude
      offset = @vars.offset(:longitude)			
      low = @vars.get(:lontiude_fract).to_f / (65536.0 * 65536.0)
      high = @vars.get(:longitude_unit).to_f
      res = (unit < 0 ? unit - low : unit + low)
      return res * (360.0 / (65536.0 * 65536.0)) 
    end
    
    # in degrees (Float)
    def heading
      @vars.get(:heading).to_f * (360.0/(65536.0 * 65536.0))
    end
    
    # in degrees (Float), positive is down, negative is up
    def pitch
      @vars.get(:pitch) * (360.0 / (65536.0 * 65536.0))
    end
    
    # in degrees, positive to the right, negative to the left (Float)
    def bank
      @vars.get(:bank).to_f * (360.0 / (65536.0 * 65536.0))
    end
    
    # in feet (same as ground_altitude + radio_altitude)
    def altitude
      fract = @vars.get(:altitude_fract).to_f  / (65536.0 * 65536.0)
      unit = @vars.get(:altitude_unit).to_f      
      return (unit < 0 ? unit - fract : unit + fract)
    end
    
    # in feet
    def ground_altitude
      (@vars.get(:ground_altitude) / 256.0).meters_to_feet
    end
    
    # in feet
    def radio_altitude
      (@vars.get(:radio_altitude) / 65536.0).meters_to_feet
    end
    
    # this is not updated on slew mode
    def on_ground?
      @vars.get(:on_ground) == 1
    end
    
    def airborne?
      !self.on_ground?
    end
    
    def parking_brake?
      @vars.get(:parking_brake) == 32767
    end
    
    def pushing_back?
      @vars.get(:pushback) != 3
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
      @vars.get(:ias) / 128.0
    end
    
    # In knots
    def true_airspeed
      @vars.get(:tas) / 128.0
    end
    
    # In knots (not updated in slew mode)
    def ground_speed
      (@vars.get(:ground_speed) / (1852.0 * 65536.0)) * 3600.0
    end
    
    def doors_open?
      @vars.get(:doors_open) == 1
    end
    
    # In milibars
    def altimeter
      @vars.get(:altimeter) / 16.0
    end
    
    # vertical speed (ft/m)
    def vertical_speed
      (@vars.get(:vs) / (256.0 * 60.0)).meters_to_feet
    end
    
    # vertical speed (ft/m) updated only while (airborne? == true)
    def last_vertical_speed
      (@vars.get(:vs_last) / (60.0 * 256.0)).meters_to_feet
    end
  end
end
