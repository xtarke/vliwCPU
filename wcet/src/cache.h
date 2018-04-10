/*
 * cache.h
 *
 *  Created on: May 15, 2013
 *      Author: xtarke
 */

#ifndef CACHE_H_
#define CACHE_H_

#include <sys/types.h>
#include <stdint.h>
#include <vector>
#include <set>
#include <iostream>
#include <assert.h>
#include "instruction.h"

using namespace std;

class cache_state {
private:
    set<uint32_t> *cb; //number of lines, possible tag in each line

    //vector<uint32_t> cb[4];		//number of lines, possible tag in each line

    
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
    
    uint32_t cache_penalty;
    

public:

    void print();
    void clear();
    void clear_index(unsigned int index);
    void add_reference(uint32_t address);
    void add_input_reference(uint32_t address);
    void add_output_reference(uint32_t address);
    bool add_tag(uint32_t tag, unsigned int index);

    bool is_empty(unsigned int index);
    bool search_tag(uint32_t tag, unsigned int index);

    int get_references_size(unsigned int index);

    uint32_t get_tag(uint32_t address);
    uint32_t get_line(uint32_t address);
    uint32_t get_blk_offset(uint32_t address);
    
    uint32_t get_size() {return cache_size;};
    uint32_t get_penalty() {return cache_penalty;};
    
    uint32_t get_line_size() {return words_per_block;};
    
    uint32_t get_cache_blocks();
    

    set<uint32_t> *get_line_set(int index);

    bool compare_sets(set<uint32_t> *cb_1, set<uint32_t> *cb_2);

    void set_intersec(set<uint32_t> *new_set, set<uint32_t> *cb_1, set<uint32_t> *cb_2);

    void create_state(std::vector<VLIW_bundle*> &bundles);
    void set_bundle_cache_info(std::vector<VLIW_bundle*> &bundles);

    cache_state() {
        cache_blocks = 32;	//blocks or lines
	words_per_block = 8;
        //cache_penalty = 23;
	//cache_penalty = 14;
	cache_penalty = 15;
		
	
        bk_offset_size = 3;
        bk_offset_ini = 0;
        bk_offset_end = bk_offset_ini + bk_offset_size -1;

        index_size = 5;		// bits to index the lines log2(CACHE_BLOCKS)
        index_ini = bk_offset_end + 1;
        index_end = index_ini + index_size -1;

        tag_ini = index_end + 1;
	
	cache_size = cache_blocks * words_per_block;
	

        assert(cache_blocks > 0);

        cb = new set<uint32_t> [cache_blocks];
    }

    ~cache_state() {
        delete[] cb;
    }
};




#endif /* CACHE_H_ */
