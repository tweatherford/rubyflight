void fs_connect(void);
void fs_disconnect(void);

signed long getInt(unsigned long offset, unsigned long size);
unsigned long getUInt(unsigned long offset, unsigned long size);
double getReal(unsigned long offset);
std::string getString(unsigned long offset, unsigned long size);

void setInt(unsigned long offset, unsigned long size, signed long value);
void setUInt(unsigned long offset, unsigned long size, unsigned long value);
void setReal(unsigned long offset, double value);
void setString(unsigned long offset, unsigned long size, const std::string& value);
