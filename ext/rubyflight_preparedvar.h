#ifndef __RUBYFLIGHT_PREPARED_H__
#define __RUBYFLIGHT_PREPARED_H__

#include <map>
#include "rubyflight.h"

typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef signed char INT8;
typedef signed short INT16;

class PreparedVar {
	public:
		PreparedVar(unsigned long offset, unsigned long size, FSType type);
		PreparedVar(const PreparedVar& other);
		~PreparedVar(void);

		void* ptr(void);

		unsigned long offset;
		unsigned long size;
		FSType type;

		union {
			INT8 int8;
			INT16 int16;
			INT32 int32;
			UINT8 uint8;
			UINT16 uint16;
			UINT32 uint32;
			double real;
			char* str;
		} data;

	private:
	  PreparedVar(void);
};

typedef std::map<unsigned long, PreparedVar>::iterator var_it;

#endif
