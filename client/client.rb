require 'rubyflight'
require 'classes/flight'
require 'classes/flightplan'
require 'classes/eventlogger'
require 'rexml/document'

module RubyFlight
  def self.connect; end
  def self.disconnect; end
  def self.read_all; end
  def self.get(k); return 0 end
  def self.set=(k,v) end
end

class Application
  attr_accessor :stop_loop
  attr_reader :flight
  
  def run_loop
    @stop_loop = false

    RubyFlight::Simulator.instance.connect do
      #@flight = RubyFlight::Flight.new

      while !@stop_loop
        RubyFlight.read_all
        #@flight.process
      end
    end
  end
end
