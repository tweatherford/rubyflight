#/bin/ruby -w

require 'mkmf'
  
extra_flags = ' /EHsc'
with_cppflags($CPPFLAGS + extra_flags) { true }

create_makefile('RubyFlight')
