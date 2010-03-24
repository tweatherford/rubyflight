module RubyFlight
  class RubyFlightError
    def to_str
      case self.code
      when 0; "No error"
      when 1; "Cannot link to FSUIPC/WideClient"
      when 2; "Attempt to connect when already connected"
      when 3; "Failed to register common message with Windows"
      when 4; "Failed to create Atom for mapping filename"
      when 5; "Failed to create a file mapping object"
      when 6; "Failed to open a view to the file map"
      when 7; "Incorrect version of FSUIPC, or not FSUIPC"
      when 8; "Flight Simulator is not the version requested"
      when 9; "Call cannot execute: link not open"
      when 10; "Call cannot execute: no requests accumulated"
      when 11; "IPC timed out all retries"
      when 12; "IPC sendmessage failed all retries"
      when 13; "IPC request contains bad data"
      when 14; "Maybe running on WideClient, but FS not running"
      when 15; "Read or write request cannot be added, memory for process is full"
      else "Unknown error code #{self.code}"
      end      
    end
  end
end
