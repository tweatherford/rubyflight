module RubyFlight
  class Engines
    include Enumerable

    def initialize
      @vars = RubyFlight::Variables.instance
    end
    
    # Number of engines on your aircraft
    def number
      @vars.get(:engines_number)
    end
    
    # Calls block for each engine number (counting engine numbers from 1)
    def each
      self.number.times do |n|
        yield n+1
      end
    end
  end
end
