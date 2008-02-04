module RubyFlight
  class Weather
    include Singleton 
    
    # in milibars
    def qnh
      RubyFlight.get(:qnh)
    end
  end
end
