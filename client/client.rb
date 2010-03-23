require 'rubyflight'
require 'classes/flight'
require 'classes/flightplan'
require 'classes/eventlogger'
require 'rexml/document'

begin
  sim = RubyFlight::Simulator.instance
  
  puts "Connecting to MSFS..."
  sim.connect
  RubyFlight.read_all
  puts "Connected"
  
  puts "Getting current flight plan"
  flightplan = RubyFlight::FlightPlan.from_xml('flightplan.xml')
  flight = RubyFlight::Flight.new(flightplan)
  
  while !flight.ended? && flight.valid?
    RubyFlight.read_all
    flight.process
  end
    
  if (!flight.valid?) then puts "Flight aborted!"
  else 
    puts "Flight Done. Saving."
    File.open('flight.xml','w') do |io|
      doc = REXML::Document.new
      doc << REXML::XMLDecl.default
      doc << flight.to_xml
      doc.write(io, 2, true)
    end
  end
  
rescue RubyFlight::RubyFlightError => e
  puts "RubyFlight Error! : #{e.message)"
rescue RuntimeError => e
  puts "RuntimeError! : #{e.message}"
ensure
  sim.disconnect()
  puts "Disconnected"
end
