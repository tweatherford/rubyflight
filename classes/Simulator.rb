module RubyFlight
  class Simulator
    include Singleton

    MESSAGE_OFFSET=0x3380
    SEND_MESSAGE_OFFSET=0x32FA
    
    def message(s, display_option)
      if (s.length > 127) then raise RuntimeError.new("Cant show such a large message") end
      setString(MESSAGE_OFFSET, s.length + 1, s)
      setInt(SEND_MESSAGE_OFFSET, 2, display_option)
    end
  end
end
