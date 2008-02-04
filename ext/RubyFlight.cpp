#include <windows.h>
#include <iostream>
#include "FSUIPC_User.h"
#include "RubyFlightError.h"
#include "RubyFlight_PreparedVar.h"
using namespace std;

/**
 * Local Vars
 */
map<unsigned long, PreparedVar> prepared_vars;

/**
 * Connect / Disconnect
 */
void fs_connect(void) {
	DWORD error_code = 0;
	if (!FSUIPC_Open(SIM_FS2K4, &error_code)) throw RubyFlightError(error_code);
}

void fs_disconnect(void) {
	FSUIPC_Close();
}

/**
 * Private Read/Write methods
 */
static void do_write(unsigned long offset, unsigned long size, void* data) {
	DWORD error_code = 0;
	if (!FSUIPC_Write(offset, size, data, &error_code)) throw RubyFlightError(error_code);
	process();
}

/**
 * Public Prepare/Unprepare methods
 */
void prepare_read(unsigned long offset, unsigned long size, FSType type) {
	if (type == FS_REAL) size = 8;
	
	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) {
		pair<unsigned long, PreparedVar> new_pair(offset, PreparedVar(offset, size, type));
		it = prepared_vars.insert(new_pair).first;
	}
	
	DWORD error_code = 0;
	if (!FSUIPC_Read(offset, size, it->second.ptr(), &error_code)) throw RubyFlightError(error_code);
}

void unprepare_read(unsigned long offset) {
	var_it it = prepared_vars.find(offset);
	if (it != prepared_vars.end()) prepared_vars.erase(it);
}

void process(void) {
	DWORD error_code = 0;
	if (!FSUIPC_Process(&error_code)) throw RubyFlightError(error_code);
}

/**
 * Reading functions
 */

signed long get_int(unsigned long offset, unsigned long size) {
	signed long output = 0;

	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) throw RubyFlightError(FSUIPC_ERR_DATA);

	const PreparedVar& var = it->second;
	switch(var.size) {
		case 1: output = var.data.int8; break;
		case 2: output = var.data.int16; break;
		case 4: output = var.data.int32; break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}

	return output;
}

unsigned long get_uint(unsigned long offset, unsigned long size) {
	unsigned long output = 0;

	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) throw RubyFlightError(FSUIPC_ERR_DATA);
	PreparedVar& var = it->second;
	switch(var.size) {
		case 1: output = var.data.uint8; break;
		case 2: output = var.data.uint16; break;
		case 4: output = var.data.uint32; break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}

	return output;
}

double get_real(unsigned long offset) {
	double output = 0.0;

	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) throw RubyFlightError(FSUIPC_ERR_DATA);
  return it->second.data.real;
}

string get_string(unsigned long offset, unsigned long size) {
	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) throw RubyFlightError(FSUIPC_ERR_DATA);	
	return it->second.data.str;
}

/**
 * Writing Functions
 */

 void set_int(unsigned long offset, unsigned long size, signed long value) {
	switch(size) {
		case 1: { INT8	data = value; do_write(offset, size, &data); } break;
		case 2: { INT16 data = value; do_write(offset, size, &data); } break;
		case 4: { INT32 data = value; do_write(offset, size, &data); } break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}
}

void set_uint(unsigned long offset, unsigned long size, unsigned long value) {
	switch(size) {
		case 1: { UINT8  data = value; do_write(offset, size, &data); } break;
		case 2: { UINT16 data = value; do_write(offset, size, &data); } break;
		case 4: { UINT32 data = value; do_write(offset, size, &data); } break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}
}

void set_real(unsigned long offset, double value) {
	do_write(offset, 8, &value);
}

void set_string(unsigned long offset, unsigned long size, const std::string& value) {
	do_write(offset, min(min(size, value.length() + 1), 128), (void*)value.c_str());
}
