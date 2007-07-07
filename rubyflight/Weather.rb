module RubyFlight
  class Weather
    include Singleton 
    
    # in milibars
    def qnh
      RubyFlight::Variables.instance.get(:qnh,0,:real)
    end
  end
end
