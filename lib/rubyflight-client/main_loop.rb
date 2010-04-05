class Application < Fox::FXApp
  def run_loop
    RubyFlight::Airport.load_database

    @stop_loop = false
    @flight = RubyFlight::Flight.new
    @flight.fsm.add_observer(self)
    
    self.status = 'Connecting...'
    begin
      self.runWhileEvents
      RubyFlight::Simulator.instance.connect do
        self.status = 'Connected'

        while !@stop_loop
          RubyFlight.read_all
          @flight.process
          self.runWhileEvents
        end
      end
    rescue RubyFlight::RubyFlightError => e
      unless (self.main_window.nil?)
        self.status = "Disconnected! (Error: #{e.message}, code: #{e.code}). Attempting reconnection..."
        #self.error = "Disconnected! (Error: #{e.message}, code: #{e.code})"
        retry
      else
        raise
      end
    end
  end
end
