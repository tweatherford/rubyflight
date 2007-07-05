module RubyFlight
  module Simulator
    MESSAGE_OFFSET=0x3380
    SEND_MESSAGE_OFFSET=0x32FA
    
    def Simulator.show_message(s, display_option)
      if (s.length > 127) then raise new.RubyFlightError(999) end
      setString(MESSAGE_OFFSET, s.length + 1, s)
      setInt(SEND_MESSAGE_OFFSET, 2, display_option)
    end
  end
end