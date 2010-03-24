require 'singleton'

module RubyFlight
  class EventLogger
    include Singleton
    
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
      @time = Time.now.to_i  # TODO: this time should be MSFS's (pause and that)
      @params = params
    end
    
    def to_xml
      elem = REXML::Element.new(@name.to_s)
      @params.each_pair {|k,v| elem.add_attribute(k.to_s, v.to_s)}
      elem.add_attribute('when', @time.to_s)
      return elem
    end
  end
end
