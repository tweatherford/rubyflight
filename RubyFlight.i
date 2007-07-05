%module RubyFlight

%{
#undef write
#undef read
%}

%include "std_string.i"

%catches(RubyFlightError) fs_connect(void);
%catches(RubyFlightError) fs_disconnect(void);

%catches(RubyFlightError) getInt(unsigned long offset, unsigned long size);
%catches(RubyFlightError) getUInt(unsigned long offset, unsigned long size);
%catches(RubyFlightError) getString(unsigned long offset, unsigned long size);

%catches(RubyFlightError) setInt(unsigned long offset, unsigned long size, signed long value);
%catches(RubyFlightError) setUInt(unsigned long offset, unsigned long size, unsigned long value);
%catches(RubyFlightError) setReal(unsigned long offset, double value);
%catches(RubyFlightError) setString(unsigned long offset, unsigned long size, const std::string& value);

%rename("code") RubyFlightError::getCode();
%rename("connect") fs_connect(void);
%rename("disconnect") fs_disconnect(void);

%{
#include "RubyFlight.h"
#include "RubyFlightError.h"
%}

%include "RubyFlightError.h"
%include "RubyFlight.h"

