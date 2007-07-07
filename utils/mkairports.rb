#!/usr/bin/env ruby
require 'csv'

runways = {}

if (ARGV.first.nil?) then $stderr.puts "usage: mkairports.rb <path to runways.csv>"; exit(1) end

puts "Parsing..."
CSV.open(ARGV.first, 'r') do |row|
  lat = row[2].to_f; long = row[3].to_f
  code = row[0].to_sym
  
  if (!runways.key?(lat.to_i)) then runways[lat.to_i] = {} end  
  longs = runways[lat.to_i]
  if (!longs.key?(long.to_i)) then longs[long.to_i] = {} end
  entries = longs[long.to_i]
  if (!entries.key?(code)) then entries[code] = [ lat, long ] end
end

puts "Dumping"
File.open('airports.dump', 'w') {|io| Marshal.dump(runways,io)}
