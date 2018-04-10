#ifndef HEXREAD_H
#define HEXREAD_H

#include <fstream>
#include <string>
#include <iostream>
#include "Memory.h"

using namespace std;

class HexRead
{
private:
   std::ifstream file;
  
public:
    HexRead(const char* filename);
    
    bool parse(uint32_t *memory_array, int size_words);
    
    ~HexRead();
    
};

#endif // HEXREAD_H
