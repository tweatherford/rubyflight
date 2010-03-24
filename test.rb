require 'rubyflight'
require 'pathname'

begin
  sim = RubyFlight::Simulator.instance
  sim.connect
  
  aircraft = RubyFlight::Aircraft.instance
  weather = RubyFlight::Weather.instance  
  failures = RubyFlight::Failures.instance
  
  RubyFlight::read_all
  if (!sim.initialized?) 
    $stderr.puts "Connected, but not initialized, something strange happened"
    exit(1)
  else
    puts "Connected, initialized ok"
  end
  
  sim.show_message("RubyFlight is working =]", 10)
  
  # failures.free_flaps
  
  last_loop = Time.now
  
  loop do
    RubyFlight::read_all
    
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
    puts "Vertical Speed: #{aircraft.vertical_speed} ft/m"
    puts "Last Vertical Speed: #{aircraft.last_vertical_speed} ft/m"            
    puts "Ground Speed: #{aircraft.ground_speed} knots"        
    puts "TAS: #{aircraft.true_airspeed} kts"        
    puts "IAS: #{aircraft.indicated_airspeed} kts"        
    puts "Pushing Back?: #{aircraft.pushing_back?}"            
    puts "Latitude: #{aircraft.latitude}"                
    puts "Longitude: #{aircraft.longitude}"                
    puts "Fuel valves open?: #{aircraft.engines.all? {|n| aircraft.fuel.valve_open?(n)}}"
    puts "Fuel flow zero?: #{aircraft.engines.all? {|n| aircraft.fuel.near_zero_flow?(n)}}"    
    puts "Fuel flow each: #{aircraft.engines.map {|n| aircraft.fuel.flow(n)}.join('-')}"
    puts "Fuel center level/capacity: #{aircraft.fuel.individual_level(:center) * 100}% of #{aircraft.fuel.individual_capacity(:center)}"
    aircraft.fuel.each_tank do |side,type|
      puts "Fuel #{side} #{type} level/capacity: #{aircraft.fuel.individual_level(side,type) * 100}% of #{aircraft.fuel.individual_capacity(side,type)}"
    end
    puts "Total Fuel capacity: #{aircraft.fuel.capacity}"        
    puts "Total Fuel level: #{aircraft.fuel.level}"        
    puts "G-Force: #{aircraft.gforce}"
    puts "Accelerations (lat, vert, long): (#{aircraft.lateral_acceleration}, #{aircraft.vertical_acceleration}, #{aircraft.longitudinal_acceleration})"
    puts "Surface Condition: #{aircraft.surface_condition}"
    puts "Structural de-ice?: #{aircraft.structural_deice?}"
    puts "Simulator UTC Time: #{sim.utctime}"
    puts "Simulator Local Time: #{sim.localtime}"
    puts "Simulator Season: #{sim.season}"
    puts "Simulation rate: #{sim.simulation_rate}"
    puts "Gears Up?: all: #{aircraft.gears.up?}, right: #{aircraft.gears.up?(:right)}, left: #{aircraft.gears.up?(:left)}, nose: #{aircraft.gears.up?(:nose)}"
    puts "Brake pressure: left: #{aircraft.left_brake} right: #{aircraft.right_brake}"
    puts "Loop Time #{Time.now - last_loop}"
    puts "----"
    sleep(0)
    last_loop = Time.now
  end    
  
ensure
  sim.disconnect
  puts "Disconnected"
end
