#/bin/ruby -w

require 'mkmf'
  
$libs = append_library($libs, "stdc++")

create_makefile('rubyflight_binding')