require 'rubyflight'
require 'classes/flight'
require 'classes/flightplan'
require 'classes/eventlogger'
require 'rexml/document'

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
