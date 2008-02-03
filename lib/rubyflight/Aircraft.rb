require 'singleton'

module RubyFlight
  class Aircraft
    include Singleton
    
    attr_reader(:engines,:fuel)
    def initialize
      @vars = Variables.instance
      @engines = Engines.new
      @fuel = Fuel.new
      @airports = nil
    end
    
    def latitude
      fract = @vars.get(:latitude_fract).to_f / (65536.0 * 65536.0)
      unit = @vars::get(:latitude_unit).to_f
      res = (unit < 0 ? unit - fract : unit + fract)
      return res * (90.0 / 10001750.0)
    end
    
    def longitude
      fract = @vars.get(:longitude_fract).to_f / (65536.0 * 65536.0)
      unit = @vars.get(:longitude_unit).to_f
      res = (unit < 0 ? unit - fract : unit + fract)
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
    
    # Opposite of on_ground?
    def airborne?
      !self.on_ground?
    end
    
    def crashed?
      @vars.get(:crashed) == 1
    end
    
    def crashed_off_runway?
      @vars.get(:crashed_off_runway) == 1
    end
    
    def parking_brake?
      @vars.get(:parking_brake) == 32767
    end
    
    def pushing_back?
      @vars.get(:pushback) != 3
    end
    
    # If it is near (given a radius in miles) a given airport. Note that only
    # one runways is considered for each airport.
    # NOTE: you need to create an 'airports.dump' file in your current directory.
    def near_airport?(code, radius)
      if (@airports.nil?) then
        puts "Loading airports database"
        @airports = File.open('airports.dump', 'r') {|io| Marshal.load(io)}
      end
      
      lat = self.latitude
      long = self.longitude
      pos = Position.new(lat, long)      
      
      longitudes = @airports[lat.to_i]
      if (longitudes.nil?) then puts "no lat"; return false end
      entries = longitudes[long.to_i]
      if (entries.nil?) then puts "no long"; return false end
      pos = entries[code]
      if (pos.nil?) then puts "no airport"; return false end
      
      return Position.new(pos[0], pos[1]).distance_to(Position.new(pos[0], pos[1])).abs <= radius 
    end
    
    # this "unloads" the airports database (which is un-marshaled by near_airport? when needed)
    def unload_airports
      puts "Unloading airports database"
      @airports = nil
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
      (@vars.get(:vs) / 256.0).meters_to_feet * 60.0
    end
    
    # vertical speed (ft/m) updated only while (airborne? == true)
    def last_vertical_speed
      (@vars.get(:vs_last) / 256.0).meters_to_feet * 60.0
    end
    
    # Unknown units
    # TODO: check if values can be negative (ie: if high values get negative, the value is uint)
    def gforce
      @vars.get(:gforce) / 625.0
    end
    
    # Left/Right, relative to Body Axis, in ft/(s^2)
    def lateral_acceleration
      @vars.get(:lateral_acceleration)
    end
    
    # Up/Down, relative to Body Axis, in ft/(s^2)
    def vertical_acceleration
      @vars.get(:lateral_acceleration)
    end
    
    # Forward/Backward, relative to Body Axis, in ft/(s^2)
    def longitudinal_acceleration
      @vars.get(:lateral_acceleration)
    end
    
    # Returns :normal, :wet, :icy or :snowed
    # *NOTE*: Probably only updated when #on_ground?
    def surface_condition
      case @vars.get(:surface_condition)
      when 0; return :normal
      when 1; return :wet
      when 2; return :icy
      when 3; return :snowed
      end
    end
    
    # true if the corresponding switch is on
    def structural_deice?
      @vars.get(:structural_deice) == 1
    end
  end
end
