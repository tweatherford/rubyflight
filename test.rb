require 'rubyflight'

begin
  sim = RubyFlight::Simulator.instance
  sim.connect()
  if (!sim.initialized?) 
    $stderr.puts "Connected, but not initialized, something strange happened"
    exit(1)
  else
    puts "Connected, initialized ok"
  end
  
  sim.show_message("RubyFlight is working =]", 0)
  aircraft = RubyFlight::Aircraft.instance
  
  while (true)
    puts "Heading: #{aircraft.heading}"
    puts "Bank: #{aircraft.bank}"
    # puts "Pitch: #{aircraft.pitch}"
    # puts "Altitude: #{aircraft.altitude}"
    puts "Radio Altitude: #{aircraft.radio_altitude}"
    puts "On Ground? #{aircraft.on_ground?}"
    puts "Parking Break? #{aircraft.parking_brake?}"
    puts "Ground Speed: #{aircraft.ground_speed} m/s"    
    puts "TAS: #{aircraft.true_airspeed} kts"        
    puts "IAS: #{aircraft.indicated_airspeed} kts"        
    puts "Pushing Back?: #{aircraft.pushing_back?}"            
    puts "Latitude: #{aircraft.latitude}"                
    puts "Longitude: #{aircraft.longitude}"                
    sleep(0.5)
  end    
  
rescue RuntimeError => e
  puts "Runtime Error! (code: #{e.message})"
ensure
  RubyFlight::disconnect()
  puts "Disconnected"
end
