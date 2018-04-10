#ifndef MIFREAD_H
#define MIFREAD_H


#include <fstream>
#include <string>
#include <iostream>
#include "logger.h"
#include "Memory.h"
#include "logger.h"

using namespace std;

class MifRead
{
private:
   std::ifstream file;
  
public:
    MifRead(const char* filename);
    
    bool parse(uint32_t* memory_array, int size_words, uint32_t fill);
    
    ~MifRead();
    
};

#endif // MIFREAD_H
