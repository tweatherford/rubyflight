#include "RubyFlightError.h"

RubyFlightError::RubyFlightError(unsigned long _code) : code(_code) { }

unsigned long RubyFlightError::getCode(void) { return code; }
