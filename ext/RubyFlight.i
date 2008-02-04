%module RubyFlight

%{
#undef write
#undef read
%}

%include "std_string.i"

%catches(RubyFlightError) fs_connect(void);
%catches(RubyFlightError) fs_disconnect(void);

%catches(RubyFlightError) prepare_read(unsigned long offset, unsigned long size, FSType type);
%catches(RubyFlightError) unprepare_read(unsigned long offset);
%catches(RubyFlightError) process(void);

%catches(RubyFlightError) get_int(unsigned long offset, unsigned long size);
%catches(RubyFlightError) get_uint(unsigned long offset, unsigned long size);
%catches(RubyFlightError) get_real(unsigned long offset);
%catches(RubyFlightError) get_string(unsigned long offset, unsigned long size);

%catches(RubyFlightError) set_int(unsigned long offset, unsigned long size, signed long value);
%catches(RubyFlightError) set_uint(unsigned long offset, unsigned long size, unsigned long value);
%catches(RubyFlightError) set_real(unsigned long offset, double value);
%catches(RubyFlightError) set_string(unsigned long offset, unsigned long size, const std::string& value);

%rename("connect") fs_connect(void);
%rename("disconnect") fs_disconnect(void);
%rename("code") RubyFlightError::get_code();

%{
#include "RubyFlight.h"
#include "RubyFlightError.h"
%}

%include "RubyFlightError.h"
%include "RubyFlight.h"

