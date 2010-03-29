module RubyFlight
  class Airport
    def randomize_available_cargo
      @available_cargo = Array.new(rand(10) + 3) { Cargo.random }
    end

    def available_cargo
      if (!defined?(@available_cargo) || @available_cargo.empty?) then randomize_available_cargo end
      return @available_cargo
    end
  end
end
