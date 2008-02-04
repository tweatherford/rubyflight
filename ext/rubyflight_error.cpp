#include "rubyflight_error.h"

RubyFlightError::RubyFlightError(unsigned long _code) : code(_code) { }

unsigned long RubyFlightError::get_code(void) { return code; }
