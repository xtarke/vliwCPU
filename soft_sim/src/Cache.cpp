#include "Cache.h"
#include <assert.h>
#include <string.h>

#include <iostream>

Cache::Cache(Rom *rom_)
{
    cache_blocks = 32;	//blocks or lines
    words_per_block = 8;
    //cache_penalty = 23;
    //cache_penalty = 14;
    cache_penalty = 15;
    
    cache_pure_stall_time = 13;

    bk_offset_size = 3;
    bk_offset_ini = 0;
    bk_offset_end = bk_offset_ini + bk_offset_size -1;

    index_size = 5;		// bits to index the lines log2(CACHE_BLOCKS)
    index_ini = bk_offset_end + 1;
    index_end = index_ini + index_size -1;

    tag_ini = index_end + 1;

    cache_size = cache_blocks * words_per_block;

    assert(cache_blocks > 0);   
    cache_data = new cache_line[cache_blocks];
    
    
    for (int i = 0; i < cache_blocks; i++)
    {
      cache_data[i].tag = false;
      cache_data[i].tag = 0;
      
      cache_data[i].data = new uint32_t[words_per_block];
      memset(cache_data->data, 0, sizeof(cache_data->data));      
    }
    
    rom = rom_;
    
    file.open("cache-log.txt");    
}

Cache::~Cache()
{
  file.close();
  
  for (int i = 0; i < cache_blocks; i++)
    delete cache_data[i].data;
  
  delete cache_data; 
}

unsigned int Cache::fetch(uint32_t pc, uint32_t *data)
{
   uint32_t base_mem_addr;
   uint32_t addr_tag;
   uint32_t index;
        
   long unsigned int time = 0;
   
   index = get_line(pc);
   addr_tag = get_tag(pc);
   base_mem_addr = pc & ~0x7;   
   
   assert(index < cache_blocks);
      
   file << "addr: " << pc << " tag: " << addr_tag << " index " << index << " base mem: " << base_mem_addr << endl;

   assert(pc < rom->get_size());
   
   if (cache_data[index].v_bit == false || (addr_tag != cache_data[index].tag))
   {
     cache_data[index].v_bit = true;
     cache_data[index].tag = addr_tag;
     
     //copy data
     for (int i = 0; i < words_per_block; i++)     
       cache_data[index].data[i] = rom->get_value(base_mem_addr + i);     
     
     file << "\t Miss!" << endl;
     
     time = cache_penalty;
   }
      
   memcpy(data, cache_data[index].data, words_per_block*sizeof(uint32_t));
   
     
   return time;
}


uint32_t Cache::get_tag(uint32_t address) {
    uint32_t mask = 0xFFFFFFFF;
    uint32_t tag;

    //create tag mask and compute
    mask = mask << tag_ini;
    tag = (address & mask) >> tag_ini;

    return tag;

}

uint32_t Cache::get_line(uint32_t address) {
    uint32_t mask_1 = 0xFFFFFFFF;
    uint32_t mask_2 = 0xFFFFFFFF;
    uint32_t mask_f = 0xFFFFFFFF;
    uint32_t index;

    //create index mask and compute
    mask_1 = mask_1 << index_ini;
    mask_2 = ~(mask_2 << (index_ini + index_size));
    mask_f = mask_1 & mask_2;
    index = (address & mask_f) >> index_ini;

    return index;
}