require 'csv'

module RubyFlight
  CargoDefinition = Struct.new(:name)

  class Cargo < Struct.new(:name, :weight, :destination)
    @@definitions = []

    def self.load_definitions
      if (!@@definitions.empty?) then return end
      CSV.foreach(File.join('../data', 'cargo.csv')) do |row|
        @@definitions << CargoDefinition.new(*row)
        puts row
      end
    end

    def self.definitions
      self.load_definitions
      @@definitions
    end

    def self.random(destination)
      definition = self.definitions[rand(self.definitions.size)]
      Cargo.new(definition.name, rand(50) + 50, destination)
    end
  end
end
