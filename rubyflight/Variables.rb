module RubyFlight
  class Variables
    include Singleton
		
		attr_reader(:offsets)
    
    def initialize
      @offsets = {
        :heading => 0x580, :pitch => 0x578, :bank => 0x57C, :altitude => 0x570, :radio_altitude => 0x31E4,
        :ground_altitude => 0x20, :on_ground => 0x366, :parking_brake => 0xBC8, :ground_speed => 0x2B4,
        :tas => 0x2B8, :ias => 0x2BC, :pushback => 0x31F0, :latitude => 0x560, :longitude => 0x568,
        
        :message => 0x3380, :send_message => 0x32FA,
        :initialized => 0x4D6
      }
    end
    
    def get(offset, size, type)
			if (offset.kind_of?(Symbol)) then offset = @offsets[offset] end
      case type
      when :int; RubyFlight::getInt(offset, size)
      when :uint; RubyFlight::getUInt(offset, size)
      when :real; RubyFlight::getReal(offset)
      when :string; RubyFlight::getString(offset, size)
      end    
    end
    
		def set(offset, size, type, value)
			if (offset.kind_of?(Symbol)) then offset = @offsets[offset] end			
			case type
			when :int; RubyFlight::setInt(offset, size, value.to_i)
			when :uint; RubyFlight::setUInt(offset, size, value.to_i)
			when :real; RubyFlight::setReal(offset, value.to_f)
			when :string; RubyFlight::setString(offset, size, value.to_s)
			end
		end
  end
end
