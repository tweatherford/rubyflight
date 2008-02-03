#ifndef __RUBYFLIGHT_H__
#define __RUBYFLIGHT_H__

#include <string>

void fsConnect(void);
void fsDisconnect(void);

enum FSType { FS_UINT, FS_INT, FS_REAL, FS_STRING };
void prepareRead(unsigned long offset, unsigned long size, FSType type);
void unprepareRead(unsigned long offset);
void doProcess(void);

signed long getInt(unsigned long offset, unsigned long size);
unsigned long getUInt(unsigned long offset, unsigned long size);
double getReal(unsigned long offset);
std::string getString(unsigned long offset, unsigned long size);

void setInt(unsigned long offset, unsigned long size, signed long value);
void setUInt(unsigned long offset, unsigned long size, unsigned long value);
void setReal(unsigned long offset, double value);
void setString(unsigned long offset, unsigned long size, const std::string& value);

#endif
