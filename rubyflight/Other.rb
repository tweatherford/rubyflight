class Numeric
  def feet_to_meters
    self * 3.2808399      
  end
  
  # Assumes self is in meters, returns a Float
  def meters_to_feet
    self / 3.2808399
  end
end