#ifndef __RUBYFLIGHT_H__
#define __RUBYFLIGHT_H__

#include <string>

void fs_connect(void);
void fs_disconnect(void);

enum FSType { FS_UINT, FS_INT, FS_REAL, FS_STRING };
void prepare_read(unsigned long offset, unsigned long size, FSType type);
void unprepare_read(unsigned long offset);
void process(void);

signed long get_int(unsigned long offset, unsigned long size);
unsigned long get_uint(unsigned long offset, unsigned long size);
double get_real(unsigned long offset);
std::string get_string(unsigned long offset, unsigned long size);

void set_int(unsigned long offset, unsigned long size, signed long value);
void set_uint(unsigned long offset, unsigned long size, unsigned long value);
void set_real(unsigned long offset, double value);
void set_string(unsigned long offset, unsigned long size, const std::string& value);

#endif
