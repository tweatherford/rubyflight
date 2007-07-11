module RubyFlight
  class Simulator
    include Singleton
    
    def initialize
      @vars = Variables::instance()
    end

    # show String s in a box (like in adventures). Display option is interpreted as:
    # 0: display till replaced, +n: display for n seconds, or until replaced
    # -1: display and scroll until replaced, -n: display and scroll for n seconds, or until replaced
    def show_message(s, display_option)
      if (s.length > 127) then raise RuntimeError.new("Cant show such a large message") end
      @vars.set(:message, s, s.length + 1)
      @vars.set(:send_message, display_option)
    end
    
    def connect
      RubyFlight.fsConnect()
    end
    
    def disconnect
      RubyFlight.fsDisconnect()
    end
    
    def initialized?
      return @vars.get(:initialized,2,:uint) == 0xFADE
    end
  end
end
