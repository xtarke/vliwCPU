#ifndef ROM_H
#define ROM_H

#include <stdint.h>
#include <assert.h>
#include <iostream>


#define ROM_SIZE_WORDS 16384

class Rom
{
private:
   uint32_t data[ROM_SIZE_WORDS];
  
public:
    Rom();
    void load_data(uint32_t *memory_array, int size_words);
    void dump();
    
    uint32_t get_size() {return ROM_SIZE_WORDS; };    
    uint32_t get_value(int word_addr){assert(word_addr < ROM_SIZE_WORDS); return data[word_addr]; }
};

#endif // ROM_H
