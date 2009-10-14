#!/usr/bin/env ruby
require 'pathname'
require 'fileutils'
require 'rexml/document'

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
  airports = Hash.new{|h,k| h[k] = Hash.new{|h2,k2| h2[k2] = []}}
  
  doc = File.open(Pathname.new(ARGV.first) + Pathname("runways.xml"), 'r') {|io| REXML::Document.new(io)}
  doc.each_element('data/icao') do |icao_elem|
    airport = Airport.new
    airport.position = Position.new(icao_elem.elements['longitude'].text.to_f, icao_elem.elements['latitude'].text.to_f)
    airport.city = icao_elem.elements['city'].text
    airport.icao = icao_elem.attributes['id'].to_sym
    airport.name = icao_elem.elements['icaoname'].text
    lat,long = airport.position.lat.round,airport.position.long.round
    airports[lat][long] = airports[lat][long] + [ airport ]
  end
  
  puts "Saving to airports.dump ..."
  File.open('airports.dump','w') {|io| Marshal.dump(airports,io)}
  
rescue RuntimeError => e
  puts "Error!: #{e.message}"
  exit(1)  
end
