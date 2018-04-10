/* 
 * File:   CPU.h
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 09:35
 */

#ifndef CPU_H
#define	CPU_H

#include "Fetch.h"
#include "Memory.h"
#include "Regist.h"
#include "Control.h"
#include "Slot.h"
#include "Decoder.h"
#include "ImmSolve.h"
#include "Execute.h"
#include "Rom.h"
#include "WriteBack.h"
#include "Cache.h"
#include "Interlock.h"
#include <stdint.h>

using namespace std;

class CPU {
public:
    CPU();
    ~CPU();
    
    void CPU_run();
    void load_rom(uint32_t *memory_array, int size_words);
    void load_spram(uint32_t *memory_array, int size_words);
    
    unsigned long int get_cycles() {return cycles;};
    unsigned long int get_ops() {return operations;};
                
    Rom rom;
    SPram spram;   
   
    
private:
   std::ofstream file;
   
   unsigned long int cycles = 6;
   unsigned long int cache_misses = 0;
   unsigned long int operations = 0;
   unsigned long int instructions = 0;
   
   uint32_t *fetch_buffer;
   
   uint32_t PC;
   
   Cache *cache;
   Regist *reg;
   Fetch *fetch;
   Control ct;
   Decoder *dec;
   Memory *mem;
   Slot slots[4];
   Slot prev_slots[4];
   Execute execution;
    
   Interlock interlock;
   ImmSolve solver;    
};

#endif	/* CPU_H */