#include "Rom.h"

Rom::Rom()
{

}

void Rom::load_data(uint32_t *memory_array, int size_words)
{
  assert(size_words <= ROM_SIZE_WORDS);
  
  
  for (int i = 0; i < size_words; i++)
    data[i] = memory_array[i];
  
}

void Rom::dump()
{
   for (int i = 0; i < ROM_SIZE_WORDS; i++)
    std::cout << "[" << std::dec << i << "] : "<< std::hex << data[i] << std::dec << "\n";
  
}

