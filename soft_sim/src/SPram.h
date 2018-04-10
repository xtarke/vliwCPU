#ifndef SPRAM_H
#define SPRAM_H

#include <stdint.h>
#include <assert.h>
#include <iostream>

#define SPRAM_SIZE_WORDS 2048


using namespace std;

class SPram
{
public:
  void dump();
  void load_data(uint32_t *memory_array, int size_words);
  
  int32_t get_value(int word_addr){assert(word_addr < SPRAM_SIZE_WORDS); return data[word_addr]; };
  
  void set_value(int word_addr, int32_t _data){ assert(word_addr < SPRAM_SIZE_WORDS); data[word_addr] = _data;};

  void file_dump();
  
private:  
  int32_t data[SPRAM_SIZE_WORDS];
  
  
};

#endif // SPRAM_H
