require 'singleton'

module RubyFlight
  class Simulator
    include Singleton
    
    def initialize
      @vars = Variables::instance()
    end

    # TODO: verify display_option
    def show_message(s, display_option)
      if (s.length > 127) then raise RuntimeError.new("Cant show such a large message") end
      @vars.set(:message, s.length + 1, :string, s)
      @vars.set(:send_message, 2, :int, display_option)
    end
    
    def connect
      RubyFlight.connect()
    end
    
    def disconnect
      RubyFlight.disconnect()
    end
    
    def initialized?
      return @vars.get(:initialized,2,:uint) == 0xFADE
    end
  end
end
