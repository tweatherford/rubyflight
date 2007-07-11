module RubyFlight
  class Variables
    include Singleton
    include Offsets
		
    def initialize
      load_offsets()
    end
    
    def get(var)
      if (@offsets[var].nil?) then raise RuntimeError.new("Undefined var '#{var}'") end      
      offset,size,type = @offsets[var]
      
      case type
      when :int; RubyFlight::getInt(offset, size)
      when :uint; RubyFlight::getUInt(offset, size)
      when :real; RubyFlight::getReal(offset)
      when :string; RubyFlight::getString(offset, size)
      end    
    end
    
    def set(var, value, passed_size = 0)
      if (@offsets[var].nil?) then raise RuntimeError.new("Undefined var '#{var}'") end
      offset,size,type = @offsets[var]
      
      case type
      when :int; RubyFlight::setInt(offset, size, value.to_i)
      when :uint; RubyFlight::setUInt(offset, size, value.to_i)
      when :real; RubyFlight::setReal(offset, value.to_f)
      when :string; RubyFlight::setString(offset, passed_size, value.to_s)
      end
    end
    
    def prepare(var)
      if (@offsets[var].nil?) then raise RuntimeError.new("Undefined var '#{var}'") end      
      offset,size,type = @offsets[var]

      case type
      when :int; type = FS_INT
      when :uint; type = FS_UINT
      when :real; type = FS_REAL
      when :string; type = FS_STRING
      end
      RubyFlight::prepareRead(offset, size, type)
    end
    
    def process
      RubyFlight::doProcess
    end
    
    def forget(var)
      if (@offsets[var].nil?) then raise RuntimeError.new("Undefined var '#{var}'") end
      offset, = @offsets[var]
      RubyFlight::unprepareRead(offset)
    end
  end
end
