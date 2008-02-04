#ifndef __RUBYFLIGHT_VARS_H__
#define __RUBYFLIGHT_VARS_H__

#include <map>
#include <ruby.h>

typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef signed char INT8;
typedef signed short INT16;

enum FSType { FS_UINT, FS_INT, FS_REAL, FS_STRING };

class Variable {
	public:
		Variable(unsigned long offset, unsigned long size, FSType type);
		Variable(const Variable& other);
		~Variable(void);

		void prepare(void);
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
	  Variable(void);
};

typedef std::map<ID, Variable>::iterator var_it;
typedef std::map<ID, Variable>::const_iterator const_var_it;



#endif
