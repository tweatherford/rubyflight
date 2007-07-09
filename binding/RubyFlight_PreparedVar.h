#ifndef __RUBYFLIGHT_PREPARED_H__
#define __RUBYFLIGHT_PREPARED_H__

class PreparedVar {
	public:
		PreparedVar(unsigned long offset, unsigned long size, FSType type);
	  PreparedVar(const PreparedVar& other);	
		~PreparedVar(void);
	
		void* ptr(void);

	private:
		PreparedVar(void);
	
	  unsigned long offset;
	  unsigned long size;
	  DataType type;
	  
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
};

typedef map<unsigned long, PreparedVar>::iterator var_it;

#endif
