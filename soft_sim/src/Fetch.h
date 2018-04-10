/* 
 * File:   Fetch.h
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 09:33
 */

#ifndef FETCH_H
#define	FETCH_H

#include <stdint.h>
#include "Rom.h"
#include "Slot.h"

//number of words per cache line
#define CACHE_BLOCK_SIZE 8

class Fetch {
public:
    Fetch(int fetch_bufer_size_) {fetch_bufer_size = fetch_bufer_size_; } ;
    
    uint32_t bundle_decode(Slot* slots, uint32_t* buffer, uint32_t PC);    
    void load_pc(uint32_t PC);

    
    
private:
  int fetch_bufer_size = 0;  
  int buffer_index = 0;
};

#endif	/* FETCH_H */

