include Fox

module GuiLogic
  def create
    super
    self.main_window.connect(SEL_CLOSE) {
      result = FXMessageBox.question(self.main_window, MBOX_YES_NO, "Exit program", "Are you sure?")
      if (result == MBOX_CLICKED_YES) then @stop_loop = true; self.main_window = nil; 0
      else 1 end
    }

    self.main_window.switcher_widgets[:flight][:start_button].connect(SEL_COMMAND) {
      if (@flight.status == :parked_for_arrival) then @flight.start(:parked_for_departure) end
    }

    @flight_status = self.main_window.switcher_widgets[:flight][:status]

    @plane = RubyFlight::Aircraft.instance
    @sim = RubyFlight::Simulator.instance

#    self.main_window.switcher_widgets[:airport][:accept_destination].connect(SEL_COMMAND) {
#      icao = self.main_window.switcher_widgets[:airport][:destination].text
#      airport = RubyFlight::Airport.database[:by_icao][icao.to_sym]
#      if (airport.nil?) then self.inform("Invalid airport")
#      else
#
#      end
#    }
  end

  ## -- States -- ##
  def start_invalid
    @flight_status.text = 'Flight is not in a valid state'
  end

  def start_parked_for_departure
    @flight_status.text = 'Parked at departing airport'
    self.main_window.switcher_widgets[:flight][:aircraft] = @plane.name
    reload_cargo
  end

  def start_taxing_for_departure
    @flight_status.text = 'Taxing to runway'
  end

  def start_taking_off
    @flight_status.text = 'Taking off'
  end

  def start_ascending
    @flight_status.text = 'Taking off'
  end

  def start_cruising
    @flight_status.text = 'Cruising'
  end

  def start_descending
    @flight_status.text = 'Descending'
  end

  def start_landing
    @flight_status.text = 'Descending'
  end
  
  def start_taxing_for_arrival
    @flight_status.text = 'Taxing to terminal'
  end

  def start_parked_for_arrival
    @flight_status.text = 'Parked at destination airport'
    self.main_window.switcher_widgets[:flight][:main_button].enable
    reload_cargo
  end

  def status=(text)
    self.main_window.statusbar.statusLine.normalText = text
  end

  def inform(text)
    self.main_window.statusbar.statusLine.text = text
  end

  private
  def reload_cargo(destination)
#    t = self.main_window.switcher_widgets[:airport][:available_cargo]
#    t.removeRows(0, t.numRows)
#
#    airport = @plane.nearest_airport
#    unless airport.nil?
#      c = airport.available_cargo(destination)
#      t.appendRows(c.size)
#      t.numRows.times do |i|
#        t.setItemText(i, 0, c[i].name)
#        t.setItemText(i, 1, c[i].weight.to_s)
#      end
#    end
#    puts 'reloaded cargo table'
  end

  def clear_cargo
#    t = self.main_window.switcher_widgets[:airport][:available_cargo]
#    t.removeRows(0, t.numRows)
  end
#
#  def error=(text)
#    dialog = FXDialogBox.new(self.main_window, "Error!")
#    FXLabel.new(dialog, text)
#    FXButton.new(dialog, "Ok")
#    dialog.execute
#  end
end