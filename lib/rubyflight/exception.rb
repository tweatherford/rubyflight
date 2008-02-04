module RubyFlight
  class RubyFlightError
    def to_str
      "Error code #{self.code}"
    end
  end
end