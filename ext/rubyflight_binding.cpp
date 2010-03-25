#include <ruby.h>

#undef read
#undef write

#include <iostream>
#include <string>
#include <windows.h>
#include "variables.h"
#include "FSUIPC_User.h"
using namespace std;

/**
 * Local Vars
 */
map<unsigned long, Variable> variables;
const unsigned int MAX_MESSAGE_SIZE = 127;

VALUE rb_eRubyFlightError = Qnil;

void raise_fsuipc_error(DWORD error_code) {
  VALUE args[] = { ULONG2NUM(error_code) };
  VALUE inst = rb_class_new_instance(1, args, rb_eRubyFlightError);
  rb_exc_raise(inst);
}

static var_it lookup_var(VALUE sym) {
	if (!SYMBOL_P(sym)) rb_raise(rb_eTypeError, "Expected a Symbol");
	ID symbol_id = SYM2ID(sym);
	var_it it = variables.find(symbol_id);
	if (it == variables.end()) rb_raise(rb_eRubyFlightError, "FSUIPC Variable '%s' unknown", rb_id2name(symbol_id));
	return it;
}

/**
 * Connect / Disconnect
 */

/* Connect to MSFS */
static VALUE fs_connect(VALUE self) {
	DWORD error_code = 0;
	if (!FSUIPC_Open(SIM_ANY, &error_code)) raise_fsuipc_error(error_code);
	return Qtrue;
}

/* Disconnect from MSFS */
static VALUE fs_disconnect(VALUE self) {
	FSUIPC_Close();
	return Qtrue;
}

/**
 * Public Prepare/Unprepare methods
 */

/* Prepare a future get() */
static VALUE prepare_read(VALUE self, VALUE sym) {
  var_it it = lookup_var(sym);
  it->second.prepare();
  return Qtrue;
}

/* Call prepare_read() on all defined variables */
static VALUE prepare_all_reads(VALUE self) {
	for (var_it it = variables.begin(); it != variables.end(); ++it)
		it->second.prepare();

	return Qtrue;
}

/* Execute the prepared reads. After this call, all values are available for get()ing */
static VALUE process(VALUE self) {
	DWORD error_code = 0;
	if (!FSUIPC_Process(&error_code)) raise_fsuipc_error(error_code);
	return Qtrue;
}

/* Call prepare_all_reads() and then process() */
static VALUE read_all(VALUE self) {
	prepare_all_reads(self);
	process(self);

	return Qtrue;
}

/**
 * Reading functions
 */

/* Get a value from a variable (_sym_ should be a Symbol) */
static VALUE get_var(VALUE self, VALUE sym) {
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
				default: rb_raise(rb_eRuntimeError, "Invalid 'int' FSUIPC variable size of %lu", var.size); break;
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
				default: rb_raise(rb_eRuntimeError, "Invalid 'uint' FSUIPC variable size of %lu", var.size); break;
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

	return Qnil;
}

/**
 * Writing Functions
 */
 static void do_write(unsigned long offset, unsigned long size, void* data) {
 	DWORD error_code = 0;
 	if (!FSUIPC_Write(offset, size, data, &error_code)) raise_fsuipc_error(error_code);
 	process(Qnil);

}
/* Set a value to a variable (_sym_ should be a symbol, and _ruby_value_ should be of the corresponding type) */
static VALUE set_var(VALUE self, VALUE sym, VALUE ruby_value) {
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
				default: rb_raise(rb_eRuntimeError, "Invalid 'int' FSUIPC variable size of %lu", var.size); break;
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
				default: rb_raise(rb_eRuntimeError, "Invalid 'uint' FSUIPC variable size of %lu", var.size); break;
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
			const char* string_ptr = RSTRING_PTR(ruby_value_str);
			unsigned long string_length = RSTRING_LEN(ruby_value_str);

			std::string c_string(string_ptr, string_length);
			unsigned long real_length = min(var.size, (unsigned long)c_string.length());
			do_write(var.offset, min(real_length, (unsigned long)MAX_MESSAGE_SIZE) + 1, (void*)c_string.c_str());
		}
		break;
	}

	return Qtrue;
}

void define_var(const char* var_name, unsigned long offset, unsigned long size, FSType type) {
  pair<ID, Variable> new_definition(rb_intern(var_name), Variable(offset, size, type));
  variables.insert(new_definition);
}

/**
 * RubyFlight module definition. Methods directly under this module are the interface to MSFS.
 */
extern "C" void Init_rubyflight_binding(void) {
  VALUE mRubyFlight = rb_define_module("RubyFlight");
  rb_eRubyFlightError = rb_define_class_under(mRubyFlight, "RubyFlightError", rb_eRuntimeError);

  rb_define_module_function(mRubyFlight, "connect", RUBY_METHOD_FUNC(fs_connect), 0);
  rb_define_module_function(mRubyFlight, "disconnect", RUBY_METHOD_FUNC(fs_disconnect), 0);
  rb_define_module_function(mRubyFlight, "prepare_read", RUBY_METHOD_FUNC(prepare_read), 1);
  rb_define_module_function(mRubyFlight, "prepare_all_reads", RUBY_METHOD_FUNC(prepare_all_reads), 0);
  rb_define_module_function(mRubyFlight, "read_all", RUBY_METHOD_FUNC(read_all), 0);
  rb_define_module_function(mRubyFlight, "process", RUBY_METHOD_FUNC(process), 0);
  rb_define_module_function(mRubyFlight, "get", RUBY_METHOD_FUNC(get_var), 1);
  rb_define_module_function(mRubyFlight, "set", RUBY_METHOD_FUNC(set_var), 2);

  rb_define_const(mRubyFlight, "MAX_MESSAGE_SIZE", UINT2NUM(MAX_MESSAGE_SIZE));

  /** load all offsets **/
  define_var("heading", 0x580, 4, FS_UINT);
  define_var("pitch", 0x578, 4, FS_INT);
  define_var("bank", 0x57C, 4, FS_INT);
  define_var("altitude_fract", 0x570, 4, FS_UINT); define_var("altitude_unit", 0x574, 4, FS_INT);
  define_var("radio_altitude", 0x31E4, 4, FS_UINT);
  define_var("ground_altitude", 0x20, 4, FS_UINT);
  define_var("on_ground", 0x366, 2, FS_UINT);
  define_var("parking_brake", 0xBC8, 2, FS_INT);
  define_var("ground_speed", 0x2B4, 4, FS_INT);
  define_var("tas", 0x2B8, 4, FS_INT);
  define_var("ias", 0x2BC, 4, FS_INT);
  define_var("pushback", 0x31F0, 4, FS_UINT);
  define_var("latitude_fract", 0x560, 4, FS_UINT); define_var("latitude_unit", 0x564, 4, FS_INT);
  define_var("longitude_fract", 0x568, 4, FS_UINT); define_var("longitude_unit", 0x56C, 4, FS_INT);
  define_var("doors_open", 0x3367, 1, FS_UINT);
  define_var("altimeter", 0x330, 2, FS_UINT);
  define_var("vs_last", 0x30C, 4, FS_INT);
  define_var("vs", 0x2c8, 4, FS_INT);
  define_var("crashed", 0x840, 2, FS_UINT); define_var("crashed_off_runway", 0x848, 2, FS_UINT);
  define_var("gforce", 0x11BA, 2, FS_INT);
  define_var("lateral_acceleration", 0x3060, 0, FS_REAL); define_var("vertical_acceleration", 0x3068, 0, FS_REAL); define_var("longitudinal_acceleration", 0x3070, 0, FS_REAL);
  define_var("structural_deice", 0x337D, 1, FS_UINT); define_var("surface_condition", 0x31EC, 4, FS_UINT);
  define_var("hydraulic_failures", 0x32F8, 1, FS_UINT);
  define_var("gear_control", 0xBE8, 4, FS_UINT);
  define_var("nose_gear_control", 0xBEC, 4, FS_UINT); define_var("right_gear_control", 0xBF4, 4, FS_UINT); define_var("left_gear_control", 0xBF0, 4, FS_UINT);
  define_var("left_brake", 0xBC4, 2, FS_UINT); define_var("right_brake", 0xBC6, 2, FS_UINT);
  define_var("left_brake_pressure", 0xC00, 1, FS_UINT); define_var("right_brake_pressure", 0xC01, 1, FS_UINT);
  define_var("aircraft_type", 0x3160, 24, FS_STRING);
  define_var("aircraft_model", 0x3500, 24, FS_STRING);
  define_var("aircraft_name", 0x3D00, 256, FS_STRING);

  define_var("engines_number", 0xAEC, 2, FS_INT);

  define_var("fuel_flow_1", 0x918, 0, FS_REAL); define_var("fuel_flow_2", 0x9B0, 0, FS_REAL);
  define_var("fuel_flow_3", 0xA48, 0, FS_REAL); define_var("fuel_flow_4", 0xAE0, 0, FS_REAL);
  define_var("fuel_valve_1", 0x3590, 4, FS_UINT); define_var("fuel_valve_2", 0x3594, 4, FS_UINT);
  define_var("fuel_valve_3", 0x3598, 4, FS_UINT); define_var("fuel_valve_4", 0x359c, 4, FS_UINT);
  define_var("tank_center_level", 0xB74, 4, FS_INT); define_var("tank_center_capacity", 0xB78, 4, FS_INT);
  define_var("tank_right_main_level", 0xB94, 4, FS_INT); define_var("tank_right_aux_level", 0xB9C, 4, FS_INT); define_var("tank_right_tip_level", 0xBA4, 4, FS_INT);
  define_var("tank_left_main_level", 0xB7C, 4, FS_INT); define_var("tank_left_aux_level", 0xB84, 4, FS_INT); define_var("tank_left_tip_level", 0xB8C, 4, FS_INT);
  define_var("tank_right_main_capacity", 0xB98, 4, FS_INT); define_var("tank_right_aux_capacity", 0xBA0, 4, FS_INT); define_var("tank_right_tip_capacity", 0xBA8, 4, FS_INT);
  define_var("tank_left_main_capacity", 0xB80, 4, FS_INT); define_var("tank_left_aux_capacity", 0xB88, 4, FS_INT); define_var("tank_left_tip_capacity", 0xB90, 4, FS_INT);

  define_var("qnh", 0x34A0, 0, FS_REAL);

  define_var("message", 0x3380, 127, FS_STRING); define_var("send_message", 0x32FA, 2, FS_INT);
  define_var("initialized", 0x4D6, 2, FS_UINT); define_var("simulation_rate", 0xC1A, 2, FS_UINT);

  define_var("time_local_hour", 0x238, 1, FS_UINT); define_var("time_local_minute", 0x239, 1, FS_UINT); define_var("time_second", 0x23A, 1, FS_UINT);
  define_var("time_gmt_hour", 0x23B, 1, FS_UINT); define_var("time_gmt_minute", 0x23C, 1, FS_UINT);
  define_var("time_day", 0x23E, 2, FS_UINT); define_var("time_year", 0x240, 2, FS_UINT);
  define_var("timezone", 0x246, 2, FS_INT); define_var("season", 0x248, 2, FS_UINT);
}
