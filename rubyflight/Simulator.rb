module RubyFlight
  class Simulator
    include Singleton
    
    def initialize
      @vars = Variables.instance()
    end
    
    MAX_MESSAGE_SIZE=127

    # show String _s_ in a box (like in adventures) for the specified _duration_ in seconds (or until the text is replaced). If _scroll_ is true, the text will scroll.
    # If _duration_ is 0, the text will remain until replaced.
    def show_message(s, duration = 0, scroll = false)
      if (s.length > MAX_MESSAGE_SIZE) then raise RuntimeError.new("Cant show such a large message (maximum #{MAX_MESSAGE_SIZE} characters)") end
      
      if (scroll) 
        display_option = (duration == 0 ? -1 : -duration)
      else
        display_option = duration
      end

      @vars.set(:message, s, s.length + 1)
      @vars.set(:send_message, display_option)
    end
    
    # Connect to FlightSimulator
    def connect
      RubyFlight.connect()
    end
    
    # Disconnect from FlightSimulator. You should _ensure_ this.
    def disconnect
      RubyFlight.disconnect()
    end

    # After connecting, this will return true when you can start get/set-ting information.
    def initialized?
      return @vars.get(:initialized) == 0xFADE
    end
  end
end
