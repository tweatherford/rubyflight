module RubyFlight
  def RubyFlight.initialized?
    return (getUInt(0x4D6,2) == 0xFADE)
  end
end