module RubyFlight
  class EventLog    
    attr_reader(:events)
    
    def initialize
      @events = []    
    end
    
    def log(name, params = {})
      @events << Event.new(name, params)
    end
    
    def to_xml
      events_element = REXML::Element.new('events')
      events.each {|event| events_element << event.to_xml}
      return events_element
    end
  end
  
  class Event
    attr_reader(:name, :time, :params)
    
    def initialize(name, params)
      @name = name
      @time = Time.now.to_f  # TODO: this time should be MSFS's
      @params = params
    end
    
    def to_xml
      elem = REXML::Element.new(@name.to_s)
      elem.add_attributes(@params.map)
      return elem
    end
  end
end
