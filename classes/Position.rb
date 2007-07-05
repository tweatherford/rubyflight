module RubyFlight
  class Position
    attr_accessor(:lat, :long)
    def initialize(lat, long)
      @lat = lat
      @long = long
    end
    
    def distance_to(other)
      pos1 = Position.new(self.lat / 57.3, self.long / 57.3)
      pos2 = Position.new(other.lat / 57.3, other.long / 57.3)
      a = sin(pos1.lat) * sin(pos2.lat) +
          cos(pos1.lat) * cos(pos2.lat) *
          cos(pos2.long - pos1.long)
      return 3959 * atan(sqrt(1-a**2)/a)
    end
  end
end
