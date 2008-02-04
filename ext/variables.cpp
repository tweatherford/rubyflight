#include <windows.h>
#include "FSUIPC_User.h"
#include "variables.h"

Variable::Variable(unsigned long _offset, unsigned long _size, FSType _type) :
	offset(_offset), size(_size), type(_type)
{
	data.uint32 = 0;
	if (type == FS_STRING) data.str = new char[size + 1];
}

Variable::Variable(const Variable& other) :
	offset(other.offset), size(other.size), type(other.type), data(other.data)
{
	if (type == FS_STRING) {
		data.str = new char[size + 1]; memcpy(data.str, other.data.str, size);
		data.str[size] = '\0';
	}
}

Variable::~Variable(void) {
	if (type == FS_STRING) delete data.str;
}

void* Variable::ptr(void) {
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

void Variable::prepare(void) {
	DWORD error_code = 0;
	if (!FSUIPC_Read(offset, size, ptr(), &error_code)) rb_raise(rb_eRuntimeError, "FSUIPC returned error code %i", error_code);
}
