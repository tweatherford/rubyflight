module RubyFlight
  class Weather
    include Singleton 
    
    def initialize
      @vars = RubyFlight::Variables.instance
    end
    
    def qnh
      @vars.get(:qnh,0,:real)
    end
  end
end