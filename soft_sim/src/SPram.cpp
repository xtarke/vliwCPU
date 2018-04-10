#include "SPram.h"
#include <assert.h>
#include <iostream>
#include <fstream>
#include  <iomanip>

#define HEX_8F setfill('0') << setw(8) << hex

void SPram::load_data(uint32_t *memory_array, int size_words)
{
  assert(size_words <= SPRAM_SIZE_WORDS);
  
  
  for (int i = 0; i < size_words; i++)
    data[i] = memory_array[i];
  
}

void SPram::dump()
{
   for (int i = 0; i < SPRAM_SIZE_WORDS; i++)
    std::cout << "[" << std::dec << i << "] : "<< std::hex << data[i] << std::dec << "\n";
  
}

void SPram::file_dump() {
    int i;
    ofstream file;

    file.open("sp-w.txt");
    
    file << "CPU SP_RAM contents: " << endl;

    for (i = 0; i < SPRAM_SIZE_WORDS; i++) {
        if (i % 4 == 0 && i != 0)
            file << endl;
        file << "[" << dec << i << "]" << " : " << HEX_8F << data[i] << " \t\t";
    }
    file << endl;
    
    file.close();

}
