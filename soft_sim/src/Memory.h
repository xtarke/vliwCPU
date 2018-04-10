/* 
 * File:   Memory.h
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 09:46
 */

#ifndef MEMORY_H
#define	MEMORY_H
#include <sys/types.h>
#include <stdint.h>
#include <iostream>
#include <fstream>
#include "Slot.h"
#include "Rom.h"
#include "SPram.h"

//
#define MEMORY_SIZE_WORDS 2048 + 2048 + 1024

#define CODE_INI 0x0
#define CODE_END 0x3FFFFFFF

#define SPRAM_INI 0x40000000
#define SPRAM_END 0x40002000
#define SPRAM_MASK (0x2000 >> 2) -1



class Memory {
public:
    Memory(Rom *_rom, SPram *_spram);
    ~Memory();
    
    unsigned int execute(Slot* slots);
    
    void set_value(uint32_t valor, int posicao);
    uint32_t get_value(int posicao);
    void LoadMemory(Slot *slots);
    
private:
    
  Rom *rom;
  SPram *spram;
  int32_t mem_rd(uint32_t addr, bool sigext, unsigned char mem_byteen,  unsigned int *time);
  void mem_wr(uint32_t addr, bool sigext, unsigned char mem_byteen, int32_t data, unsigned int* time);
  
  ofstream file;  

};

#endif	/* MEMORY_H */
