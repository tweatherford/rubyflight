module RubyFlight
  def initialized?
    return (getUInt(0x4D2,2) == 0xFFFF)
  end
end