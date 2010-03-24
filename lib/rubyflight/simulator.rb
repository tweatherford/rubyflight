require 'date'

module RubyFlight
  class Simulator
    include Singleton

    def initialize
      super
      @connected = false
    end
    
    # show String _s_ in a box (like in adventures) for the specified _duration_ in seconds (or until the text is replaced). If _scroll_ is true, the text will scroll.
    # If _duration_ is 0, the text will remain until replaced.
    def show_message(s, duration = 0, scroll = false)
      if (s.length > MAX_MESSAGE_SIZE) then raise RuntimeError.new("Cant show such a large message (maximum #{MAX_MESSAGE_SIZE} characters)") end
      
      if (scroll) 
        display_option = (duration == 0 ? -1 : -duration)
      else
        display_option = duration
      end

      RubyFlight.set(:message, s)
      RubyFlight.set(:send_message, display_option)
    end

    # Connect to FlightSimulator and yield the supplied block. Disconnects automatically
    def connect
      RubyFlight.connect
      @connected = true
      yield
    ensure
      RubyFlight.disconnect
      @connected = false
    end

    # If succesfully connected to the simulator. This will process all prepared reads, so it may be expensive.
    def connected?
      @connected
    end

    # After connecting, this will return true when you can start get/set-ting information.
    def initialized?
      return RubyFlight.get(:initialized) == 0xFADE
    end
    
    # Return a Time object containing the current Simulator utc time
    def utctime
      y = RubyFlight.get(:time_year)
      d = RubyFlight.get(:time_day)
      h = RubyFlight.get(:time_gmt_hour)
      m = RubyFlight.get(:time_gmt_minute)
      s = RubyFlight.get(:time_second)
      date = Date.ordinal(y,d)
      Time.utc(y, date.month, date.day, h, m, s)
    end
    
    alias_method :zulu_time, :utctime
    
    # Return a Time object containing the current Simulator local time
    # *NOTE*: the object is created using the #utctime and adding the timezone offset,
    # since I can't create a Time object with an arbitrary timezone with Time. Keep this in mind when substracting times, and such.
    def localtime
      of = RubyFlight.get(:timezone)
      self.utctime - of * 60
    end
    
    alias_method :local_time, :localtime
    
    # Returns :winter, :spring, :summer or :fall
    # *NOTE*: this is relative to the northern hemisphere
    def season
      case RubyFlight.get(:season)
      when 0; return :winter
      when 1; return :spring
      when 2; return :summer
      when 3; return :fall
      end
    end
    
    def simulation_rate
      RubyFlight.get(:simulation_rate) / 256
    end
  end
end
