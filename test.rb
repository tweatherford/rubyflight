require 'rubyflightclasses'

begin
  sim = RubyFlight::Simulator.instance
  sim.connect
  if (!sim.initialized?) 
    $stderr.puts "Connected, but not initialized, something strange happened"
    exit(1)
  else
    puts "Connected, initialized ok"
  end
  
  sim.show_message("RubyFlight is working =]", 10)
  aircraft = RubyFlight::Aircraft.instance
  weather = RubyFlight::Weather.instance
  
  while (true)
    if (!ARGV.first.nil?) then
      puts "In #{ARGV.first}?: #{aircraft.near_airport?(ARGV.first.to_sym,2)}"
    end
    puts "Heading: #{aircraft.heading}"
    puts "Bank: #{aircraft.bank}"
    puts "Pitch: #{aircraft.pitch}"
    puts "Altimeter: #{aircraft.altimeter}"    
    puts "QNH: #{weather.qnh}"        
    puts "Altitude: #{aircraft.altitude.meters_to_feet} ft"
    puts "Radio Altitude: #{aircraft.radio_altitude}"
    puts "Ground Altitude: #{aircraft.ground_altitude}"    
    puts "On Ground? #{aircraft.on_ground?}"
    puts "Parking Break? #{aircraft.parking_brake?}"
    puts "Ground Speed: #{aircraft.ground_speed} m/s"    
    puts "Vertical Speed: #{aircraft.vertical_speed} ft/m"
    puts "Last Vertical Speed: #{aircraft.last_vertical_speed} ft/m"            
    puts "TAS: #{aircraft.true_airspeed} kts"        
    puts "IAS: #{aircraft.indicated_airspeed} kts"        
    puts "Pushing Back?: #{aircraft.pushing_back?}"            
    puts "Latitude: #{aircraft.latitude}"                
    puts "Longitude: #{aircraft.longitude}"                
    puts "Fuel valves open?: #{aircraft.engines.all? {|n| aircraft.fuel.valve_open?(n)}}"
    puts "Fuel flow zero?: #{aircraft.engines.all? {|n| aircraft.fuel.near_zero_flow?(n)}}"    
    puts "----"
    sleep(0.25)
  end    
  
rescue RuntimeError => e
  puts "Runtime Error! (code: #{e.message})"
ensure
  sim.disconnect
  puts "Disconnected"
end
