module RubyFlight
  class FlightPlan
    attr_reader(:from)    # the ICAO code for the departing airport
    attr_reader(:to)      # the ICAO code for the arrival airport
    attr_reader(:cruise_altitude)      # cruising altitude in feet
    
    def initialize(attributes)
      @from = attributes['from']['code'].to_sym
      @to = attributes['to']['code'].to_sym
      @cruise_altitude = attributes['cruise'].to_i
    end
    
    def FlightPlan.from_xml(file)
      attributes = {}      
      doc = File.open(file,'r') {|io| REXML::Document.new(io)}
      
      doc.each_element('flightplan') do |elem|
        if (!attributes.key?(elem.name)) then attributes[elem.name] = {} end
        elem.attributes.each {|key,value| attributes[key] = value}
      end
      
      FlightPlan.new(attributes)
    end
  end
end
