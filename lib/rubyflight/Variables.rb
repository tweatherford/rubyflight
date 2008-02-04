module RubyFlight
  # Class handling communication to C interface to MSFS. 
  # FIXME: move something most of this to C
  class Variables
    include Singleton
    include Offsets
		
    def initialize
      load_offsets()
    end
    
    def get(var)
      var_definition = @offsets[var]
      if (var_definition.nil?) then raise RuntimeError.new("Undefined var '#{var}'") end      
      offset,size,type = var_definition
      
      case type
      when :int; RubyFlight::get_int(offset, size)
      when :uint; RubyFlight::get_uint(offset, size)
      when :real; RubyFlight::get_real(offset)
      when :string; RubyFlight::get_string(offset, size)
      end    
    end
    
    def set(var, value, passed_size = 0)
      var_definition = @offsets[var]
      if (var_definition.nil?) then raise RuntimeError.new("Undefined var '#{var}'") end
      offset,size,type = var_definition
      
      case type
      when :int; RubyFlight::set_int(offset, size, value.to_i)
      when :uint; RubyFlight::set_uint(offset, size, value.to_i)
      when :real; RubyFlight::set_real(offset, value.to_f)
      when :string; RubyFlight::set_string(offset, passed_size, value.to_s)
      end
    end
    
    def prepare(var)
      var_definition = @offsets[var]
      if (var_definition.nil?) then raise RuntimeError.new("Undefined var '#{var}'") end
      offset,size,type = var_definition

      case type
      when :int; type = FS_INT
      when :uint; type = FS_UINT
      when :real; type = FS_REAL
      when :string; type = FS_STRING
      end
      RubyFlight::prepare_read(offset, size, type)
    end
    
    def read_all
      offsets.each_key {|key| prepare(key)}
      process()
    end
    
    def process
      RubyFlight::process
    end
    
    def forget(var)
      var_definition = @offsets[var]
      if (var_definition.nil?) then raise RuntimeError.new("Undefined var '#{var}'") end
      offset, = var_definition
      RubyFlight::unprepare_read(offset)
    end
  end
end
