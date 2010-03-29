module RubyFlight
  class Airport < Struct.new(:icao, :position, :city, :name)
    @@database = nil
    
    # Loads the airports.dump file from the home directory (unless other path is specified).
    # This is automatically called by the apropriate methods anyways.
    def self.load_database(dump_file = File.join(ENV['HOME'],'rubyflight','airports.dump'))
      if (@@database.nil?)
        puts "Loading airports database..."
        @@database = File.open(dump_file) {|io| Marshal.load(io)}
      end
    end

    def self.database
      self.load_database
      return @@database
    end

    def to_s
      self.name
    end
  end
end
