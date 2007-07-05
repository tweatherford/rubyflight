
module RubyFlight
  module Aircraft
    HEADING_OFFSET=0x580
    PITCH_OFFSET=0x578
    BANK_OFFSET=0x57C
    ALTITUDE_OFFSET=0x570
    
    def Aircraft.heading
      (getUInt(HEADING_OFFSET, 4).to_f * (360.0/(65536.0*65536.0))).to_i
      #getInt(HEADING_OFFSET, 4)
    end
    
    def Aircraft.pitch
      #getInt(PITCH_OFFSET, 4)
      getReal(0x2e98)
    end
    
    def Aircraft.bank
      getInt(BANK_OFFSET, 4)
    end
    
    def Aircraft.altitude
      unit = getUInt(ALTITUDE_OFFSET + 4, 4)
      fract = getUInt(ALTITUDE_OFFSET, 4)
      puts "unit #{unit}, fract #{fract}"
    end
  end
end
