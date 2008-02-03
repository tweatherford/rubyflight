#include <windows.h>
#include "RubyFlight_PreparedVar.h"

PreparedVar::PreparedVar(unsigned long _offset, unsigned long _size, FSType _type) :
	offset(_offset), size(_size), type(_type)
{
	data.uint32 = 0;
	if (type == FS_STRING) data.str = new char[size + 1];
}

PreparedVar::PreparedVar(const PreparedVar& other) :
	offset(other.offset), size(other.size), type(other.type), data(other.data)
{
	if (type == FS_STRING) { data.str = new char[size + 1]; memcpy(data.str, other.data.str, size); }
}

PreparedVar::~PreparedVar(void) {
	if (type == FS_STRING) delete data.str;
}

void* PreparedVar::ptr(void) {
	switch(type) {
		case FS_UINT:
			switch(size) {
				case 1: return &data.uint8; break;
				case 2: return &data.uint16; break;
				case 4: return &data.uint32; break;
			}
		break;
		case FS_INT:
			switch(size) {
				case 1: return &data.int8; break;
				case 2: return &data.int16; break;
				case 4: return &data.int32; break;
			}
		case FS_REAL: return &data.real; break;
		case FS_STRING: return data.str; break;
	}
	throw -1;
}
