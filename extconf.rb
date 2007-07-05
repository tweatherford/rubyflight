#/bin/ruby -w

require 'mkmf'
  
#$libs = append_library($libs, "libstdc++")

extra_flags = ' /EHsc'
with_cppflags($CPPFLAGS + extra_flags) { true }

#extra_ldflags = ' -libpath:"c:/archiv~1/micros~4/lib"'
#extra_ldflags += ' -libpath:"c:\gnu\rubyflight\fsuipc"'
#with_ldflags($DLDFLAGS + extra_ldflags) { true }

create_makefile('RubyFlight')
