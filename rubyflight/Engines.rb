module RubyFlight
  class Engines
    include Enumerable
    
    def initialize
      @vars = RubyFlight::Variables::instance
    end
    
    def number
      @vars.get(:engines_number, 2, :int)
    end
    
    def each
      self.number.times do |n|
        yield n+1
      end
    end
  end
end