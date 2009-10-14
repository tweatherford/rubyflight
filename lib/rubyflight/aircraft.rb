module RubyFlight
  class Aircraft
    include Singleton
    
    attr_reader(:engines,:gears,:fuel)
    def initialize
      @engines = Engines.new
      @fuel = Fuel.new
      @gears = Gears.new
      @airports = Hash.new{|h,k| h[k] = Hash.new{|h2,k2| h2[k2] = []}}
    end
    
    def latitude
      fract = RubyFlight.get(:latitude_fract).to_f / (65536.0 * 65536.0)
      unit = RubyFlight.get(:latitude_unit).to_f
      res = (unit < 0 ? unit - fract : unit + fract)
      return res * (90.0 / 10001750.0)
    end
    
    def longitude
      fract = RubyFlight.get(:longitude_fract).to_f / (65536.0 * 65536.0)
      unit = RubyFlight.get(:longitude_unit).to_f
      res = (unit < 0 ? unit - fract : unit + fract)
      return res * (360.0 / (65536.0 * 65536.0)) 
    end
    
    # in degrees (Float)
    def heading
      RubyFlight.get(:heading).to_f * (360.0/(65536.0 * 65536.0))
    end
    
    # in degrees (Float), positive is down, negative is up
    def pitch
      RubyFlight.get(:pitch) * (360.0 / (65536.0 * 65536.0))
    end
    
    # in degrees, positive to the right, negative to the left (Float)
    def bank
      RubyFlight.get(:bank).to_f * (360.0 / (65536.0 * 65536.0))
    end
    
    # in feet (same as ground_altitude + radio_altitude)
    def altitude
      fract = RubyFlight.get(:altitude_fract).to_f  / (65536.0 * 65536.0)
      unit = RubyFlight.get(:altitude_unit).to_f      
      return (unit < 0 ? unit - fract : unit + fract)
    end
    
    # in feet
    def ground_altitude
      (RubyFlight.get(:ground_altitude) / 256.0).meters_to_feet
    end
    
    # in feet
    def radio_altitude
      (RubyFlight.get(:radio_altitude) / 65536.0).meters_to_feet
    end
    
    # this is not updated on slew mode
    def on_ground?
      RubyFlight.get(:on_ground) == 1
    end
    
    # Opposite of on_ground?
    def airborne?
      !self.on_ground?
    end
    
    def crashed?
      RubyFlight.get(:crashed) == 1
    end
    
    def crashed_off_runway?
      RubyFlight.get(:crashed_off_runway) == 1
    end
    
    def parking_brake?
      RubyFlight.get(:parking_brake) == 32767
    end
    alias_method :parked?, :parking_brake?
    
    def pushing_back?
      RubyFlight.get(:pushback) != 3
    end
    alias_method :pushback?, :pushing_back?
    
    # Returns the nearest Airport. This considers only airports withing one degree apart in both directions,
    # so it will return nil if no airport is found in such area.
    # NOTE: the "runways.xml" file needs to be in the current directory, and it will be loaded the first
    # time it is called, unless you call #load_airports by hand first.
    def nearest_airport(code, radius)
      if (@airports.nil?) then load_airports() end
      
      lat = self.latitude
      long = self.longitude
      pos = Position.new(lat, long)

      posible_airports = @airports[lat.round][long.round]
      return posible_airports.min {|a,b| a.distance_to(pos) <=> b.distance_to(pos)}
    end
    
    # Loads the runways.xml file from the current directory unless specified
    # This is automatically called by the apropriate methods in any case.
    def load_airports(xmlfile = 'runways.xml')
      require 'rexml/document'
      puts "Loading airports database..."      
      doc = File.open('runways.xml', 'r') {|io| Document.new(io)}
      doc.each_element('data/icao') do |icao_elem|
        airport = Airport.new
        airport.position = Position.new(icao_elem.elements['longitude'].text.to_f, icao_elem.elements['latitude'].text.to_f)
        airport.city = icao_elem.elements['city'].text
        airport.icao = icao_elem.attributes['id'].to_sym
        airport.name = icao_elem.elements['icaoname'].text
        lat,long = airport.position.lat.round,airport.position.long.round
        @airports[lat][long] = @airports[lat][long] + [ airport ]
      end
    end
    
    # In knots
    def indicated_airspeed
      RubyFlight.get(:ias) / 128.0
    end
    
    # In knots
    def true_airspeed
      RubyFlight.get(:tas) / 128.0
    end
    
    # In knots (not updated in slew mode)
    def ground_speed
      (RubyFlight.get(:ground_speed) / (1852.0 * 65536.0)) * 3600.0
    end
    
    def doors_open?
      RubyFlight.get(:doors_open) == 1
    end
    
    # In milibars
    def altimeter
      RubyFlight.get(:altimeter) / 16.0
    end
    
    # vertical speed (ft/m)
    def vertical_speed
      (RubyFlight.get(:vs) / 256.0).meters_to_feet * 60.0
    end
    
    # vertical speed (ft/m) updated only while (airborne? == true)
    def last_vertical_speed
      (RubyFlight.get(:vs_last) / 256.0).meters_to_feet * 60.0
    end
    
    # Unknown units
    # TODO: check if values can be negative (ie: if high values get negative, the value is uint)
    def gforce
      RubyFlight.get(:gforce) / 625.0
    end
    
    # Left/Right, relative to Body Axis, in ft/(s^2)
    def lateral_acceleration
      RubyFlight.get(:lateral_acceleration)
    end
    
    # Up/Down, relative to Body Axis, in ft/(s^2)
    def vertical_acceleration
      RubyFlight.get(:lateral_acceleration)
    end
    
    # Forward/Backward, relative to Body Axis, in ft/(s^2)
    def longitudinal_acceleration
      RubyFlight.get(:lateral_acceleration)
    end
    
    # Returns :normal, :wet, :icy or :snowed
    # *NOTE*: Probably only updated when #on_ground?
    def surface_condition
      case RubyFlight.get(:surface_condition)
      when 0; return :normal
      when 1; return :wet
      when 2; return :icy
      when 3; return :snowed
      end
    end
    
    # true if the corresponding switch is on
    # TODO: doesn't seem to work, be sure
    def structural_deice?
      RubyFlight.get(:structural_deice) == 1
    end
    
    # If _set_value_ is nil, the current left brake pressure (0.0 to 1.0) is returned.
    # Else, the value supplied is set as braking pressure. If _fixed_ is true, the value will remaing set until
    # changed with this method. Otherwise, it will act as pressure applied by pilot and it will decay with time.
    # *NOTE*: if parked?, it will report full pressure.
    # *NOTE 2*: the value returned by this method has less resolution than the value used if fixed is false
    def left_brake(set_value = nil, fixed = false)
      if (set_value.nil?) then RubyFlight.get(:left_brake) / 32767.0
      elsif (fixed) then RubyFlight.set(:left_brake, (set_value * 32767).round)
      else RubyFlight.set(:left_brake_pressure, (set_value * 200).round) end
    end
    
    # Analogous to #left_brake
    def right_brake(set_value = nil, fixed = false)
      if (set_value.nil?) then RubyFlight.get(:right_brake) / 32767.0
      elsif (fixed) then RubyFlight.set(:right_brake, (set_value * 32767).round)
      else RubyFlight.set(:right_brake_pressure, (set_value * 200).round) end
    end
    
    # Calls #left_brake and #right_brake. If set_value is not nil, the brake pressure
    # is returned as a two-element array (left and right)
    def both_brakes(set_value = nil, fixed = false)
      [ left_brake(set_value, fixed), right_brake(set_value, fixed) ]
    end
    
    # Almost an alias for both_brakes. This method allows you to apply non-fixed brakes easily.
    # e.g.: You can just call "brake" to brake.
    def brake(set_value = 1.0)
      both_brakes(set_value)
    end
  end
end
