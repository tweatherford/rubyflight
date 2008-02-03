$:.push('..')
require 'rubyflight'
require 'classes/flight'
require 'classes/flightplan'
require 'classes/eventlogger'
require 'rexml/document'

begin
  sim = RubyFlight::Simulator.instance
  sim.connect()
  if (!sim.initialized?) 
    $stderr.puts "Connected, but not initialized, something strange happened"
    exit(1)
  else
    puts "Connected, initialized ok"
  end
  
  puts "Getting current flight plan"
  flightplan = RubyFlight::FlightPlan.from_xml('flightplan.xml')
  flight = RubyFlight::Flight.new(flightplan)
  
  vars = RubyFlight::Variables.instance
  
  while !flight.ended? && flight.valid?
    vars.prepare_all; vars.process  
    flight.process
  end
    
  if (!flight.valid?) then puts "Flight aborted!"
  else 
    puts "Flight Done. Saving."
    File.open('flight.xml','w') do |io|
      doc = REXML::Document.new
      doc << flight.to_xml
      doc.write(io, 2, false)
    end
  end
  
rescue RubyFlight::RubyFlightError => e
  puts "Error! (code: #{e.code})"
ensure
  sim.disconnect()
  puts "Disconnected"
end
