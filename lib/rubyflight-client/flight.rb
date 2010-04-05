require 'pretty-fsm'

module RubyFlight
  class Flight
    MIN_TAXI_SPEED=5
    MAX_TAXI_SPEED=30
    MIN_ASCENDING_ALTITUDE=400
    CRUISE_ALTITUDE_MARGIN=2000
    DESCENT_FROM_CRUISE_DISTANCE=7000
    MIN_DESCENDING_ALTITUDE=800
    SLEEP_TIME=0.01
    
    include PrettyFSM::Abbreviate
    attr_reader(:fsm)
    
    def initialize
      @flightplan = nil
      @plane = RubyFlight::Aircraft.instance
      @sim = RubyFlight::Simulator.instance
      @invalidated = false
      @touchdown_speed = nil
      
      @fsm = PrettyFSM::FSM.new(self, :invalid) do
        transition :from => :invalid,               :to => :parked_for_departure, :if => :seems_parked?
        transition :from => :parked_for_departure,  :to => :taxing_for_departure, :if => :seems_taxing?
        transition :from => :taxing_for_departure,  :to => :taking_off,           :if => :seems_taking_off?
        transition :from => :taking_off,            :to => :ascending,            :if => :seems_ascending?
        transition :from => :ascending,             :to => :cruising,             :if => :seems_cruising?
        transition :from => :cruising,              :to => :descending,           :if => :seems_descending?
        transition :from => :descending,            :to => :landing,              :if => :seems_landing?
        transition :from => :landing,               :to => :taxing_for_arrival,   :if => :seems_taxing?
        transition :from => :taxing_for_arrival,    :to => :parked_for_arrival,   :if => :seems_parked?
        (defined_states - [:invalid]).each {|state| transition :from => state, :to => :invalid, :if => :seems_invalid? }
      end
    end

    # Flight status
    def status; @fsm.state end
    
    # must be called periodically to process the flight state
    def process; @fsm.advance end
    
    def to_xml
      flight_element = REXML::Element.new('flight')
      flight_element << EventLogger.instance.to_xml
      return flight_element
    end    
    
  protected
    ######### FSM Actions / Conditions #############
    ## Starting
    def seems_invalid?
      # TODO: no detecta cuando se cambia de posicion y eso
      (!@sim.ready_to_fly? || @plane.crashed? || @plane.crashed_off_runway?)
    end

    def while_invalid
      puts "Flight not valid, waiting"
    end

    def seems_parked?
      r = @plane.on_ground? && @plane.parking_brake? &&
             (@plane.engines.all? {|n| @plane.fuel.valve_closed?(n)} ||
              @plane.engines.all? {|n| @plane.fuel.near_zero_flow?(n)})
      puts "parked? #{r}"
      return r
    end
            
    def start_parked_for_departure
      EventLogger.instance.log('flight_start', 'initial_fuel' => @plane.fuel.level)
    end
    
    ## Taxing
    def seems_taxing?
      @plane.on_ground? &&
        MIN_TAXI_SPEED < @plane.ground_speed && @plane.ground_speed < MAX_TAXI_SPEED
    end
    
    def start_taxing_for_departure
      puts "start taxi for departure"
    end
    
    def while_taxing_for_departure
      puts "taxiing for departure"
    end
    
    ## Takeoff
    def seems_taking_off?
      @plane.ground_speed > MAX_TAXI_SPEED
    end
    
    def start_taking_off
      puts "start takeoff"
    end
    
    def while_taking_off
      puts "taking off"
    end
    
    # Ascent
    def seems_ascending?
      @plane.radio_altitude > MIN_ASCENDING_ALTITUDE      
    end
    
    def start_ascending
      puts "start ascent"
    end
    
    def while_ascending
      puts "while ascending"
    end
    
    # Cruise
    def seems_cruising?
      @plane.altitude.meters_to_feet >= @flightplan.cruise_altitude - CRUISE_ALTITUDE_MARGIN
    end
    
    def start_cruise
      puts "start cruise"
    end
    
    def while_cruising
      puts "while cruising"
    end
    
    # Descent
    def seems_descending?
      @plane.altitude.meters_to_feet < @flightplan.cruise_altitude - DESCENT_FROM_CRUISE_DISTANCE
    end
    
    def start_descending
      puts "start descent"
    end
    
    def while_descending
      puts "start descending"
    end
    
    # Landing
    def seems_landing?
      @plane.radio_altitude < MIN_DESCENDING_ALTITUDE
    end
    
    def start_landing
      puts "start landing"
    end
    
    def while_landing
      puts "while landing"
      check_touchdown_speed
    end
    
    def check_touchdown_speed
      if (@touchdown_speed.nil? && @plane.on_ground?) then
        @touchdown_speed = @plane.last_vertical_speed
        puts "Touchdown estimated at #{@touchdown_speed} kts"
        EventLogger.instance.log(:touchdown, { 'speed' => @touchdown_speed })
      end
    end    

    # Arrival Taxi
    def start_taxing_for_arrival
      puts "start taxi for arrival"
    end

    def while_taxing_for_arrival
      puts "taxiing for arrival"
    end
    
    # End
    def start_parked_for_arrival
      puts "finished"
      EventLogger.instance().log(:flight_end, {
        'final_fuel' => @plane.fuel.level,
        'correct_airport' => @plane.near_airport?(@flightplan.to)
      })
    end
    
    def while_parked_for_arrival
      puts "while finished"
    end
    
    ########### General Checks / Functions ############
    def check_flying_quality
      # check: cg, vertical speed, horizontal speed, bank/pitch angles
    end
    
    def check_weather
      # strong winds, precipitation, visibility
      # temperature: failure of moving surfaces (specially if de-ice is off)
    end
    
    # Apply brakes differently according to surface
    def check_landing_surface
      surface = @plane.landing_surface
      if (@plane.on_ground? && surface != :normal)
        case surface
        when :wet; max_pressure = 0.5
        when :icy; max_pressure = 0.1
        when :snowed; max_pressure = 0.3
        end
        left_brake_pressure, right_brake_pressure = plane.both_brakes
        if (left_brake_pressure > max_pressure) then plane.left_brake(max_pressure) end
        if (right_brake_pressure > max_pressure) then plane.right_brake(max_pressure) end        
      end
    end
    
    def check_doors
      # with altitude: for depresurization (plane should move violently for a second), passengers
      # would die (server side) after a while if above 10000ft
    end
    
    def check_lights
      #...
    end
  end
end
