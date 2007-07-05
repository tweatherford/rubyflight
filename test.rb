require 'RubyFlight'
require 'classes/Aircraft'
require 'classes/Simulator'
require 'classes/misc'
include RubyFlight

begin
  connect()
  if (!initialized?) 
    $stderr.puts "Connected, but not initialized, something strange happened"
    exit(1)
  else
    puts "Connected, initialized ok"
  end
  
  Simulator.show_message("=]", 0)
  
  while (true)
    puts "Heading: #{Aircraft.heading()}"
    puts "Bank: #{Aircraft.bank()}"
    puts "Pitch: #{Aircraft.pitch()}"
    Aircraft.altitude
    sleep(0.5)
  end    
  
rescue RubyFlightError => e
  puts "Error! (code: #{e.code})"
ensure
  disconnect()
  puts "Disconnected"
end