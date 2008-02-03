module RubyFlight
  # Redefine the concept of _now_ using Simulator#utctime
  class FSTimedEvent < FSM::TimedEvent
    def reset
      super(Simulator.instance.utctime)
    end
    
    def try
      super(Simulator.instance.utctime)
    end
  end
end