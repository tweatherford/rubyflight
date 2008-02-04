module RubyFlight
  # A class representing all three (nose, left and right) gears
  # Methods can expect a _which_ parameter, which is used to select an individual gear (using :left, :right: or :nose)
  # or all of them (:all).
  # Note that not all gears move at the same speed when lowering or raising them.
  class Gears
    # Set all gears down
    def down
      RubyFlight.set(get_gear_variable(which), 16383)
    end
    
    alias_method :lower, :down
    
    # Set all gears up
    def up
      RubyFlight.set(get_gear_variable(which), 0)
    end
    
    alias_method :raise, :up
    
    # true if the specified gear is down
    def down?(which = :all)
      RubyFlight.get(get_gear_variable(which)) == 16383
    end
    
    # true if the specified gear is up
    def up?(which = :all)
      !self.down?(which)
    end

    private
    def get_gear_variable(which)
      case which
      when :all; return :gear_control
      when :nose; return :nose_gear_control
      when :left; return :left_gear_control
      when :right; return :right_gear_control
      end
    end
  end
end