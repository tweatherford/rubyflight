module RubyFlight
  class Failures
    include Singleton
      
# TODO: move the following to a FailureGenerator or something
#    def initialize(failures = {})
#      @failures = failures
#    end
#    
#    def from_xml(elem)
#      
#    end
#
#    def set_probability(type)
#    end
#    
#    def process
#            
#    end

    FLAP_INHIBITED    = (1 << 0)
    SPOILER_INHIBITED = (1 << 1)
    GEAR_INHIBITED    = (1 << 2)
    # TODO: add reverser inhibits
    
    def inhibit_flaps
      status = RubyFlight.get(:hydraulic_failures)
      RubyFlight.set(:hydraulic_failures, status | FLAP_INHIBITED)
    end
    
    def free_flaps
      status = RubyFlight.get(:hydraulic_failures)
      RubyFlight.set(:hydraulic_failures, status & ~FLAP_INHIBITED)
    end
    
    def flaps_inhibited?
      (RubyFlight.get(:hydraulic_failures) & FLAP_INHIBITED) == FLAP_INHIBITED
    end
    
    def inhibit_spoilers
      status = RubyFlight.get(:hydraulic_failures)
      RubyFlight.set(:hydraulic_failures, status | SPOILER_INHIBITED)
    end
    
    def free_spoilers
      status = RubyFlight.get(:hydraulic_failures)
      RubyFlight.set(:hydraulic_failures, status & ~SPOILER_INHIBITED)
    end
    
    def spoilers_inhibited?
      (RubyFlight.get(:hydraulic_failures) & SPOILER_INHIBITED) == SPOILER_INHIBITED
    end
    
    def inhibit_landing_gear
      status = RubyFlight.get(:hydraulic_failures)
      RubyFlight.set(:hydraulic_failures, status | GEAR_INHIBITED)
    end
    
    def free_landing_gear
      status = RubyFlight.get(:hydraulic_failures)
      RubyFlight.set(:hydraulic_failures, status & ~GEAR_INHIBITED)
    end
    
    def landing_gear_inhibited?
      (RubyFlight.get(:hydraulic_failures) & GEAR_INHIBITED) == GEAR_INHIBITED
    end
  end
end
