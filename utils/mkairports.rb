#!/usr/bin/env ruby
$: << '../lib'
require 'pathname'
require 'fileutils'
require 'xml'
require 'rubyflight/airport'
require 'rubyflight/position'

include RubyFlight

if (ARGV.first.nil?)
  puts "mkairports <Flight Simulator installation path>"
  exit(1)
end

begin
  current_dir = Dir.getwd
  puts "Executing makerwys.exe ..."
  Dir.chdir(ARGV.first)
  #system("makerwys.exe")
  
  puts "Loading runways.xml ..."      
  airports = {}
  
  parser = XML::Parser.file(File.join(ARGV.first, 'runways.xml'))
  puts 'Parsing...'
  doc =  parser.parse
  
  doc.root.each_element do |icao_elem|
    airport = Airport.new
    airport.position = Position.new(icao_elem.find_first('Longitude').content.to_f, icao_elem.find_first('Latitude').content.to_f)
    airport.city = icao_elem.find_first('City').content
    airport.icao = icao_elem['id'].to_sym
    airport.name = icao_elem.find_first('ICAOName').content
    lat,long = airport.position.lat.round,airport.position.long.round
    if (airports[lat].nil?) then airports[lat] = {} end
    if (airports[lat][long].nil?) then airports[lat][long] = [] end
    airports[lat][long] = airports[lat][long] + [ airport ]
  end
  
  puts "Saving to airports.dump ..."
  File.open('airports.dump','w') {|io| Marshal.dump(airports,io)}
  
rescue RuntimeError => e
  puts "Error!: #{e.message}"
  exit(1)  
end
