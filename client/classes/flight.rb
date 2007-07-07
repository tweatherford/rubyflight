require 'fsm'
include Automaton

module OpenFS
  class Flight
    MIN_TAXI_SPEED=5
    MAX_TAXI_SPEED=25
    MIN_ASCENDING_ALTITUDE=250
    CRUISE_ALTITUDE_MARGIN=2000
    DESCENT_FROM_CRUISE_DISTANCE=7000
    MIN_DESCENDING_ALTITUDE=250
    
    def initialize(flightplan)
      @flightplan = flightplan
      @plane = RubyFlight::Aircraft.instance()
      @invalidated = false
      @initial_fuel = nil
      @used_fuel = nil
      
      initial_transition = Transition.new(:start, method(:start), method(:can_start?))
      states = {
        :start   => State.new([ Transition.new(:taxi_departure, method(:start_departure_taxi), method(:seems_taxing?)) ],
                              method(:while_started), lambda { !seems_taxing? }),
        :taxi_departure => State.new([ Transition.new(:takeoff, method(:start_takeoff), method(:seems_taking_off?)) ],
                                     method(:while_taxing_departure), lambda { !seems_taking_off? }),
        :takeoff => State.new([ Transition.new(:ascent, method(:start_ascent), method(:seems_ascending?)) ],
                              method(:while_taking_off), lambda { !seems_ascending? }),
        :ascent  => State.new([ Transition.new(:cruise, method(:start_cruise), method(:seems_cruising?)) ],
                              method(:while_ascending), lambda { !seems_cruising? }),
        :cruise  => State.new([ Transition.new(:descent, method(:start_descent), method(:seems_descending?)) ],
                              method(:while_cruising), lambda { !seems_descending? }),
        :descent => State.new([ Transition.new(:landing, method(:start_landing), method(:seems_landing?)) ],
                              method(:while_descending), lambda { !seems_landing? }),
        :landing => State.new([ Transition.new(:taxi_arrival, method(:start_arrival_taxi), method(:seems_taxing?)) ],
                              method(:while_landing), lambda { !seems_taxing? }),
        :taxi_arrival => State.new([ Transition.new(:end, method(:finish), method(:seems_ended?)) ],
                                   method(:while_taxing_arrival), lambda { !seems_ended? }),
        :end     => State.new([], method(:while_ended))                                   
      }
      @fsm = FSM.new(initial_transition, states)      
    end
    
    def status
      @fsm.state_name      
    end
    
    def ended?
      self.status == :end
    end
    
    # must be called periodically to process the flight state
    def process
      @fsm.process
    end
    
    def valid?
      !@invalidated
    end
    
    def abort
      @invalidated = true
    end
    
  private
    ## Starting    
    def can_start?
      return @plane.on_ground? && @plane.parking_brake? &&
             (@plane.engines.all? {|n| @plane.fuel.valve_closed?(n)} ||
              @plane.engines.all? {|n| @plane.fuel.near_zero_flow?(n)}) &&
              @plane.near_airport?(@flightplan.from, 2)
    end
    
    def start
      puts "start"
      EventLogger.instance.log('flight_start', 'initial_fuel' => @plane.fuel.level)
    end
    
    def while_started
      puts "while started"
    end    

    # Taxi
    def seems_taxing?
      @plane.on_ground? &&
        MIN_TAXI_SPEED < @plane.ground_speed && @plane.ground_speed < MAX_TAXI_SPEED
    end
    
    def start_departure_taxi
      puts "start taxi out"
    end
    
    def while_taxing_departure
      puts "taxiing out"
    end
    
    # Takeoff
    def seems_taking_off?
      @plane.ground_speed > MAX_TAXI_SPEED
    end
    
    def start_takeoff
      puts "start takeoff"
    end
    
    def while_taking_off
      puts "taking off"
    end
    
    # Ascent
    def seems_ascending?
      @plane.radio_altitude > MIN_ASCENDING_ALTITUDE      
    end
    
    def start_ascent
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
    
    def start_descent
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
    end
    
    # Arrival Taxi
    def start_arrival_taxi
      puts "start taxi out"
    end
        
    def while_taxing_arrival
      puts "taxiing out"
    end
    
    # End
    def seems_ended?
      @plane.parking_brake? &&
      (@plane.engines.all? {|n| @plane.fuel.valve_closed?(n)} ||
      @plane.engines.all? {|n| @plane.fuel.near_zero_flow?(n)})
    end
    
    def finish
      puts "finish"
      EventLogger.instance().log(:flight_end, {
        'final_fuel' => @plane.fuel.level,
        'correct_airport' => @plane.near_airport?(@flightplan.to, 2)
      })
    end
    
    def while_ended
      puts "while ended"
    end
    
    ## Other methods
    def to_xml
      flight_element = REXML::Element.new('flight')
      flight_element << EventLog.instance.to_xml
      return flight_element
    end
  end
end
