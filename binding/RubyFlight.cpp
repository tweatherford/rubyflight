#include <windows.h>
#include <iostream>
#include <string>
#include "FSUIPC_User.h"
#include "RubyFlightError.h"
using namespace std;

typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef signed char INT8;
typedef signed short INT16;

#include "RubyFlight_PreparedVar.h"

/**
 * Local Vars
 */
map<unsigned long, PreparedVar> prepared_vars;

/**
 * Connect / Disconnect
 */
void fsConnect(void) {
	DWORD error_code = 0;
	if (!FSUIPC_Open(SIM_FS2K4, &error_code)) throw RubyFlightError(error_code);
}

void fsDisconnect(void) {
	FSUIPC_Close();
}

/**
 * Easy access to read/write
 */
void doProcess(void) {
	DWORD error_code = 0;
	if (!FSUIPC_Process(&error_code)) throw RubyFlightError(error_code);
}
	
void doRead(unsigned long offset, unsigned long size, void* data) {
	DWORD error_code = 0;
	if (!FSUIPC_Read(offset, size, data, &error_code)) throw RubyFlightError(error_code);
	doProcess();
}

void doWrite(unsigned long offset, unsigned long size, void* data, bool no_process = false) {
	DWORD error_code = 0;
	if (!FSUIPC_Write(offset, size, data, &error_code)) throw RubyFlightError(error_code);
	doProcess();	
}

void prepareRead(unsigned long offset, unsigned long size, FSType type) {
	PreparedVar var(offset, size, type);
	prepared_vars[offset] = var;
	doRead(offset, size, vat.ptr(), true);
}

void unprepareRead(unsigned long offset) {
	var_it it = prepared_vars.find(offset);
	if (it != prepared_vars.end()) prepared_vars.erase(it);
}

/**
 * Reading functions
 */

signed long getInt(unsigned long offset, unsigned long size) {
	signed long output = 0;
	
	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) {
		switch(size) {
			case 1: { INT8	data = 0; doRead(offset, size, &data); output = data; } break;
			case 2: { INT16 data = 0; doRead(offset, size, &data); output = data; } break;
			case 4: { INT32 data = 0; doRead(offset, size, &data); output = data; } break;
			default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
		}
	}
	else {
		PreparedVar& var = it->second;
		switch(var.size) {
			case 1: { INT8	data = 0; output = var.data.int8; } break;
			case 2: { INT16 data = 0; output = var.data.int16; } break;
			case 4: { INT32 data = 0; output = var.data.int32; } break;
			default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
		}
	}

	return output;
}

unsigned long getUInt(unsigned long offset, unsigned long size) {
	unsigned long output = 0;

	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) {
		switch(size) {
			case 1: { UINT8  data = 0; doRead(offset, size, &data); output = data; } break;
			case 2: { UINT16 data = 0; doRead(offset, size, &data); output = data; } break;
			case 4: { UINT32 data = 0; doRead(offset, size, &data); output = data; } break;
			default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
		}
	}
	else {
		PreparedVar& var = it->second;
		switch(var.size) {
			case 1: { UINT8	data = 0; output = var.data.uint8; } break;
			case 2: { UINT16 data = 0; output = var.data.uint16; } break;
			case 4: { UINT32 data = 0; output = var.data.uint32; } break;
			default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
		}		
	}

	return output;
}

double getReal(unsigned long offset) {
	double output = 0.0;
	
	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) doRead(offset, 8, &output);
	else { output = it->second.data.real; }
	return output;
}

string getString(unsigned long offset, unsigned long size) {
	var_it it = prepared_vars.find(offset);
	if (it == prepared_vars.end()) {
		char buf[256];
		doRead(offset, size, buf);
		buf[255] = '\0';
		return buf;
	}
	else return it->second.str;
}

/**
 * Writing Functions
 */

 void setInt(unsigned long offset, unsigned long size, signed long value) {
	switch(size) {
		case 1: { INT8	data = value; doWrite(offset, size, &data); } break;
		case 2: { INT16 data = value; doWrite(offset, size, &data); } break;
		case 4: { INT32 data = value; doWrite(offset, size, &data); } break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}
}

void setUInt(unsigned long offset, unsigned long size, unsigned long value) {
	switch(size) {
		case 1: { UINT8  data = value; doWrite(offset, size, &data); } break;
		case 2: { UINT16 data = value; doWrite(offset, size, &data); } break;
		case 4: { UINT32 data = value; doWrite(offset, size, &data); } break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}
}

void setReal(unsigned long offset, double value) {
	doWrite(offset, 8, &value);
}

void setString(unsigned long offset, unsigned long size, const std::string& value) {
	doWrite(offset, min(min(size, value.length() + 1), 128), (void*)value.c_str());
}
