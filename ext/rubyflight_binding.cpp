#include <ruby.h>
#include <windows.h>
#include <iostream>
#include "FSUIPC_User.h"
#include "rubyflight_error.h"
#include "rubyflight_preparedvar.h"
using namespace std;

/**
 * Local Vars
 */
map<unsigned long, PreparedVar> prepared_vars;

static void do_write(unsigned long offset, unsigned long size, void* data) {
	DWORD error_code = 0;
	if (!FSUIPC_Write(offset, size, data, &error_code)) rb_raise(rb_eRuntimeError, "FSUIPC returned error code %i", error_code);
	return process(Qnil);
}

static var_it lookup_var(VALUE sym) {
	if (!SYMBOL_P(sym)) rb_raise(rb_eTypeError, "Expected a Symbol");
	ID symbol_id = SYM2ID(sym);
	var_it it = variables.find(symbold_id);
	if (it == variables.end()) rb_raise(rb_eRuntimeError, "FSUIPC Variable '%s' unknown", rb_id2name(symbol_id));
	return it;	
}

/**
 * Connect / Disconnect
 */
static VALUE fs_connect(VALUE self) {
	DWORD error_code = 0;
	if (!FSUIPC_Open(SIM_FS2K4, &error_code)) rb_raise(rb_eRuntimeError, "FSUIPC returned error code %i", error_code);
	return Qtrue;
}

static VALUE fs_disconnect(VALUE self) {
	FSUIPC_Close();
	return Qtrue;
}

/**
 * Public Prepare/Unprepare methods
 */
static VALUE prepare_read(VALUE self, VALUE sym) {
	var_it it = lookup_var(sym);
	it->second.prepare();
}

VALUE process(VALUE self) {
	DWORD error_code = 0;
	if (!FSUIPC_Process(&error_code)) rb_raise(rb_eRuntimeError, "FSUIPC returned error code %i", error_code);
	return Qtrue;
}

/**
 * Reading functions
 */
VALUE get_var(VALUE self, VALUE sym) {
	var_it it = lookup_var(sym);
	const Variable& var = it->second;
	
	switch(var.type) {
		case FS_INT:
		{
			signed long result = 0;
			
			switch(var.size) {
				case 1: result = var.data.int8; break;
				case 2: result = var.data.int16; break;
				case 4: result = var.data.int32; break;
				default: rb_raise(rb_eRuntimeError, "Invalid 'int' FSUIPC variable size of %i", var.size); break;
			}
			
			return LONG2NUM(result);
		}
		break;
		case FS_UINT:
		{
			unsigned long result = 0;
			
			switch(var.size) {
				case 1: result = var.data.uint8; break;
				case 2: result = var.data.uint16; break;
				case 4: result = var.data.uint32; break;
				default: rb_raise(rb_eRuntimeError, "Invalid 'uint' FSUIPC variable size of %i", var.size); break;
			}
			
			return ULONG2NUM(result);
		}			
		break;
		case FS_REAL:
		{
			return rb_float_new(it->second.data.real);
		}			
		break;
		case FS_STRING:
		{
			return rb_str_new2(it->second.data.str);
		}			
		break;
	}
}

/**
 * Writing Functions
 */
VALUE set_var(VALUE self, VALUE sym, VALUE ruby_value) {
	var_it it = lookup_var(sym);
	Variable& var = it->second;
	
	switch(var.type) {
		case FS_INT:
		{
		  signed long value = NUM2LONG(ruby_value);
			switch(var.size) {
				case 1: { INT8	data = static_cast<INT8>(value); do_write(var.offset, var.size, &data); } break;
				case 2: { INT16 data = static_cast<INT16>(value); do_write(var.offset, var.size, &data); } break;
				case 4: { INT32 data = static_cast<INT32>(value); do_write(var.offset, var.size, &data); } break;
				default: rb_raise(rb_eRuntimeError, "Invalid 'int' FSUIPC variable size of %i", var.size); break;
			}
		}
		break;
		case FS_UINT:
		{
		  unsigned long value = NUM2LONG(ruby_value);
			switch(var.size) {
				case 1: { UINT8	data = static_cast<UINT8>(value); do_write(var.offset, var.size, &data); } break;
				case 2: { UINT16 data = static_cast<UINT16>(value); do_write(var.offset, var.size, &data); } break;
				case 4: { UINT32 data = static_cast<UINT32>(value); do_write(var.offset, var.size, &data); } break;
				default: rb_raise(rb_eRuntimeError, "Invalid 'uint' FSUIPC variable size of %i", var.size); break;
			}
		}
		break;
		case FS_REAL:
		{
			double value = NUM2DBL(ruby_value);
			do_write(var.offset, 8, &value);
		}
		break;
		case FS_STRING:
		{
			VALUE ruby_value_str = StringValue(ruby_value);
			const char* string_ptr = RSTRING(ruby_value_str)->len;
			unsigned long string_length = RSTRING(ruby_value_str)->len;
			
			std::string& c_string(string_ptr, string_length);
			do_write(var.offset, min(min(var.size, c_string.length() + 1), 128), (void*)c_string.c_str());
		}
		break;
	}
	
	return Qtrue;
}

/**
 * RubyFlight module definition
 */

extern "C" void Init_RubyFlightBinding(void) {
	VALUE mRubyFlight = rb_define_module("RubyFlight");
	
	rb_define_module_function(mRubyFlight, "connect", VALUEFUNC(fs_connect), 0);
  rb_define_module_function(mRubyFlight, "disconnect", VALUEFUNC(fs_disconnect), 0);
  rb_define_module_function(mRubyFlight, "prepare_read", VALUEFUNC(prepare_read), 1);
  rb_define_module_function(mRubyFlight, "process", VALUEFUNC(process), 0);
  rb_define_module_function(mRubyFlight, "get", VALUEFUNC(get_var), 1);
  rb_define_module_function(mRubyFlight, "set", VALUEFUNC(set_var), 2);
}
