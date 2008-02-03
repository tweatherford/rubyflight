%module RubyFlight

%{
#undef write
#undef read
%}

%include "std_string.i"

%catches(RubyFlightError) fsConnect(void);
%catches(RubyFlightError) fsDisconnect(void);

%catches(RubyFlightError) prepareRead(unsigned long offset, unsigned long size, FSType type);
%catches(RubyFlightError) unprepareRead(unsigned long offset);
%catches(RubyFlightError) doProcess(void);

%catches(RubyFlightError) getInt(unsigned long offset, unsigned long size);
%catches(RubyFlightError) getUInt(unsigned long offset, unsigned long size);
%catches(RubyFlightError) getReal(unsigned long offset);
%catches(RubyFlightError) getString(unsigned long offset, unsigned long size);

%catches(RubyFlightError) setInt(unsigned long offset, unsigned long size, signed long value);
%catches(RubyFlightError) setUInt(unsigned long offset, unsigned long size, unsigned long value);
%catches(RubyFlightError) setReal(unsigned long offset, double value);
%catches(RubyFlightError) setString(unsigned long offset, unsigned long size, const std::string& value);

%rename("connect") fsConnect(void);
%rename("disconnect") fsDisconnect(void);
%rename("code") RubyFlightError::getCode();

%{
#include "RubyFlight.h"
#include "RubyFlightError.h"
%}

%include "RubyFlightError.h"
%include "RubyFlight.h"

