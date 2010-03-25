#!/usr/bin/env ruby
$: << '../lib'
require 'pathname'
require 'fileutils'
require 'nokogiri'
require 'rubyflight/airport'
require 'rubyflight/position'

include RubyFlight
include Nokogiri

if (ARGV.first == '-h' || ARGV.first == '--help')
  puts "mkairports <Flight Simulator installation path>"
  puts "If not specified, it will search the registry."
  exit(1)
end

begin
  current_dir = Dir.getwd
  fspath = nil
  if (ARGV.first) then fspath = ARGV.first
  else
    require 'win32/registry'
    Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\\Microsoft\\Microsoft Games\\Flight Simulator\\10.0') do |r|
      fspath = r['SetupPath']
    end
    puts "Found installation path on registry: #{fspath}"
  end
  Dir.chdir(fspath)

  puts "Executing makerwys.exe ..."
  system(File.join(current_dir, 'makerwys.exe'))
  
  puts "Loading runways.xml ..."      
  airports = {}
  
  doc = File.open('runways.xml') {|io| XML.parse(io)}
  
  doc.root.children.each do |icao_elem|
    unless (icao_elem.text?)
      airport = Airport.new
      airport.position = Position.new(icao_elem.at_xpath('Latitude').content.to_f, icao_elem.at_xpath('Longitude').content.to_f)
      airport.city = icao_elem.at_xpath('City').content
      airport.icao = icao_elem['id'].to_sym
      airport.name = icao_elem.at_xpath('ICAOName').content
      lat,long = airport.position.lat.round,airport.position.long.round
      if (airports[lat].nil?) then airports[lat] = {} end
      if (airports[lat][long].nil?) then airports[lat][long] = [] end
      airports[lat][long] = airports[lat][long] + [ airport ]
    end
  end

  dump_dir = File.join(ENV['HOME'],'rubyflight')
  Dir.mkdir(dump_dir)
  dump_path = File.join(dump_dir,'airports.dump')
  puts "Saving to #{dump_path} ..."
  File.open(dump_path,'w') {|io| Marshal.dump(airports,io)}
  
rescue RuntimeError => e
  puts "Error!: #{e.message}"
  exit(1)  
end
