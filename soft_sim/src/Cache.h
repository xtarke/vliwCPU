#ifndef CACHE_H
#define CACHE_H

#include <stdint.h>
#include <iostream>
#include <fstream>
#include "Rom.h"

using namespace std;

//Cache timing model
class Cache
{
public:
  Cache(Rom *rom_);
  ~Cache();
  
  unsigned int fetch(uint32_t pc, uint32_t *data);
  int get_words_per_block() {return words_per_block; };
  int get_latency() {return cache_penalty; };
  int get_pure_penalty() {return cache_pure_stall_time; };
    
private:
  
   struct cache_line
   {
    bool v_bit;    
    uint32_t tag;
    uint32_t *data;    
   };  
   
   
   uint32_t cache_size;		//size in WORDS
    
   uint32_t index_size;
   uint32_t index_ini;
   uint32_t index_end;

   uint32_t tag_ini;

   uint32_t bk_offset_size;
   uint32_t bk_offset_ini;
   uint32_t bk_offset_end;

   uint32_t cache_blocks;
   
   uint32_t words_per_block;
    
   uint32_t cache_penalty;		// total cache latency considering all transactions
   uint32_t cache_pure_stall_time;	// only cache stall time
   
   cache_line *cache_data;
   
   Rom *rom;
   
   uint32_t get_line(uint32_t address);
   uint32_t get_tag(uint32_t address);
   
   ofstream file;
   
};

#endif // CACHE_H
