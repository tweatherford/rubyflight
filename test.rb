require 'RubyFlight'
require 'classes/Aircraft'
require 'classes/Thrust'
require 'classes/Simulator'
require 'classes/misc'

begin
  RubyFlight::connect()
  if (!RubyFlight::initialized?) 
    $stderr.puts "Connected, but not initialized, something strange happened"
    exit(1)
  else
    puts "Connected, initialized ok"
  end
  
  RubyFlight::Simulator.instance().show_message("=]", 0)
  
  while (true)
    puts "Heading: #{RubyFlight::Aircraft.instance().heading()}"
    puts "Bank: #{RubyFlight::Aircraft.instance().bank()}"
    puts "Pitch: #{RubyFlight::Aircraft.instance().pitch()}"
    puts "Altitude: #{RubyFlight::Aircraft.instance().altitude()}"
    puts "Radio Altitude: #{RubyFlight::Aircraft.instance().radio_altitude()}"
    puts "On Ground? #{RubyFlight::Aircraft.instance().on_ground?}"
    puts "Parking Break? #{RubyFlight::Aircraft.instance().parking_brake?}"
    puts "Ground Speed: #{RubyFlight::Aircraft.instance().ground_speed} m/s"    
    puts "TAS: #{RubyFlight::Aircraft.instance().true_airspeed} kts"        
    puts "IAS: #{RubyFlight::Aircraft.instance().indicated_airspeed} kts"        
    puts "Pushing Back?: #{RubyFlight::Aircraft.instance().pushing_back?}"            
    puts "Latitude: #{RubyFlight::Aircraft.instance().latitude}"                
    puts "Longitude: #{RubyFlight::Aircraft.instance().longitude}"                
    sleep(0.5)
  end    
  
rescue RuntimeError => e
  puts "Runtime Error! (code: #{e.message})"
ensure
  RubyFlight::disconnect()
  puts "Disconnected"
end
