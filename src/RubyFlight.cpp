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
 * Easy access to read/write
 */
void doRead(unsigned long offset, unsigned long size, void* data) {
	DWORD error_code = 0;
	if (!FSUIPC_Read(offset, size, data, &error_code)) throw RubyFlightError(error_code);
	if (!FSUIPC_Process(&error_code)) throw RubyFlightError(error_code);
}

void doWrite(unsigned long offset, unsigned long size, void* data) {
	DWORD error_code = 0;
	if (!FSUIPC_Write(offset, size, data, &error_code)) throw RubyFlightError(error_code);
	if (!FSUIPC_Process(&error_code)) throw RubyFlightError(error_code);
}

/**
 * Reading functions
 */

signed long getInt(unsigned long offset, unsigned long size) {

	signed long output = 0;

	switch(size) {
		case 1: { INT8	data = 0; doRead(offset, size, &data); output = data; } break;
		case 2: { INT16 data = 0; doRead(offset, size, &data); output = data; } break;
		case 4: { INT32 data = 0; doRead(offset, size, &data); output = data; } break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}

	return output;
}

unsigned long getUInt(unsigned long offset, unsigned long size) {
	unsigned long output = 0;

	switch(size) {
		case 1: { UINT8  data = 0;  doRead(offset, size, &data); output = data; } break;
		case 2: { UINT16 data = 0; doRead(offset, size, &data); output = data; } break;
		case 4: { UINT32 data = 0; doRead(offset, size, &data); output = data; } break;
		default: throw RubyFlightError(FSUIPC_ERR_DATA); break;
	}

	return output;
}

double getReal(unsigned long offset) {
	double output = 0.0;
	doRead(offset, 8, &output);
	return output;
}

string getString(unsigned long offset, unsigned long size) {
	char buf[256];
	doRead(offset, size, buf);
	buf[255] = '\0';
	return buf;
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
