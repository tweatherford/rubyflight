#!/usr/bin/env ruby
require 'csv'

runways = {}

if (ARGV.first.nil?) then $stderr.puts "usage: mkairports.rb <path to runways.csv>"; exit(1) end

puts "Parsing..."
CSV.open(ARGV.first, 'r') do |row|
  lat = row[2].to_f; long = row[3].to_f
  code = row[0].to_sym
  
  entry = [ code, lat, long ]
  if (!runways.key?(lat.to_i)) then runways[lat.to_i] = Hash.new end
  if (!runways[lat.to_i].key?(long.to_i)) then runways[lat.to_i][long.to_i] = [ entry ]
  elsif !runways[lat.to_i][long.to_i].any? {|entry| entry[0] == code} then
    runways[lat.to_i][long.to_i].push(entry)
  end
end

puts "Dumping"
File.open('airports.dump', 'w') {|io| Marshal.dump(runways,io)}
