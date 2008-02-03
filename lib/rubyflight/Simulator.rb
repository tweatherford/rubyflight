require 'date'

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
    
    # Return a Time object containing the current Simulator utc time
    def utctime
      y = @vars.get(:time_year)
      d = @vars.get(:time_day)
      h = @vars.get(:time_gmt_hour)
      m = @vars.get(:time_gmt_minute)
      s = @vars.get(:time_second)
      Time.utc(y, Date.ordinal(y,d).day, h, m, s)
    end
    
    # Return a Time object containing the current Simulator local time
    # *NOTE*: the object is created using Time#utc and adding the corresponding offset of the current timezone,
    # since I can't create a Time object with an arbitrary timezone with Time. Keep this in mind when substracting times, and such.
    def localtime
      y = @vars.get(:time_year)
      d = @vars.get(:time_day)
      h = @vars.get(:time_local_hour)
      m = @vars.get(:time_local_minute)
      s = @vars.get(:time_second)
      of = @vars.get(:timezone)
      Time.utc(y, Date.ordinal(y,d).day, h, m, s) + of * 60
    end
    
    # Returns :winter, :spring, :summer or :fall
    def season
      case @vars.get(:season)
      when 0; return :winter
      when 1; return :spring
      when 2; return :summer
      when 3; return :fall
      end
    end
    
    def simulation_rate
      @vars.get(:simulation_rate) / 256
    end
  end
end
