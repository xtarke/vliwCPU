/* 
 * File:   CPU.cpp
 * Author: bpibic
 * 
 * Created on 8 de Janeiro de 2015, 09:35
 */

#include "CPU.h"
#include "Slot.h"
#include "Decoder.h"

#include <iostream>
#include <fstream>
#include <stdio.h>     
#include <stdlib.h>    
#include <sstream>
#include <stdio.h>
#include <string.h>
#include "logger.h"

#define MAX(a,b) ((a) > (b) ? (a) : (b))

CPU::CPU() {
  PC = 0;   
    
  file.open("soft_sim.s");
    
  if (!file.good()) {
      cout << "ABORT<Decoder>: Undefined input file" << endl;
      LOG << "ABORT: Invalid mif file" << endl;
      exit(EXIT_FAILURE);      
  }  
  
  cache = new Cache(&rom);
  fetch = new Fetch(cache->get_words_per_block());
  mem = new Memory(&rom, &spram);  
  dec = new Decoder(&file);
  reg = new Regist(&file);
  
  fetch_buffer = new uint32_t[cache->get_words_per_block()];
  
}

CPU::~CPU()
{
  file.close();
  delete cache;
  delete fetch;
  delete mem;
  delete dec;
  delete reg;
  delete fetch_buffer;  
}


void CPU::load_rom(uint32_t *memory_array, int size_words)
{
  rom.load_data(memory_array, size_words);  
}

void CPU::load_spram(uint32_t *memory_array, int size_words)
{
  spram.load_data(memory_array, size_words);  
}

void CPU::CPU_run(){ 

  bool halt = false;
  bool preld = false;
  bool cache_reset = true;
  
  unsigned int cache_time = 0;
  unsigned int mem_time = 0;
  unsigned int alu_time = 0;
  unsigned int multicycle = 0;
  unsigned int hazard = 0;
  int c_miss_compensation = 0;  
  unsigned int pipeline_time = 0;
      
  //cycles = 0;
  
  while(halt == false){        
    
    cycles++;   
    
    cache_time = cache->fetch(PC, fetch_buffer);
    
    //there is a miss
    if (cache_time > 0)
    { 
      cache_misses++;
      
      //file << "pipeline_time: " << (cycles - pipeline_time) << endl;
      //file << "cache_reset: " << cache_reset << endl;            
      c_miss_compensation = cycles - pipeline_time;
            
      //cache timing compensation: instruction execution and cache transaction to next
      //address occurs in parallel in the real hardware (VHDL)
      if (cache_reset == false)
      {
	// fetch resync modeling (when cache is faster than pipeline execution
	if (c_miss_compensation >= cache->get_pure_penalty())
        {	  
	  c_miss_compensation = cache->get_pure_penalty() - c_miss_compensation;	  
 	  //file << "c_miss_compensation: " << c_miss_compensation << endl; 
        }
        
        //file << "c_miss_compensation: " << c_miss_compensation << endl; 
		
	cycles += cache_time - c_miss_compensation;
	//file << "cache miss is: " << std::dec << cache_time - c_miss_compensation << endl;
      }
      else      
	cycles += cache_time;
      
      
      cache_reset = false;
    }
    
    //fetch 
    PC += fetch->bundle_decode(slots, fetch_buffer, PC);      
    
    //decode   
    solver.SolveImm(slots);
    reg->GetRegValue(slots);
    dec->Decode(slots);
    
    
    file << std::dec << operations << endl;
    
    operations += slots[0].ops;
    instructions++;
       
    //preload detection, preload resets only at branches
    (preld == false) ? (preld = (slots[0].preload || slots[1].preload || slots[2].preload || slots[3].preload)) : (preld);
    
    //execute
    alu_time = execution.execute(slots);
    mem_time = mem->execute(slots);
    
//     if (mem_time != 0)
// 	file << "Mem: " << std::dec << mem_time << endl;
//     if (alu_time != 0)
// 	file << "Alu: " << std::dec << alu_time << endl;
   
    //add multicycle instructions timing    
    multicycle = MAX(mem_time, alu_time);
    cycles += multicycle;
    
    //check hazards
    cycles += interlock.check(slots, prev_slots);
    
//     file << "hazard: " << interlock.check(slots, prev_slots) << endl;
    
    //write back
    reg->write_back(slots);
    halt = slots[0].halt;
    
    //control flow write back
    if (slots[0].ctrl_flow == true)
    {     
      switch (slots[0].ctrl_flow_mux)
      {
	case Decoder::BTARG_TARGET:
	  
	  switch (slots[0].ctrl_flow_type){
	    case Decoder::DIRECT:
	       PC = slots[0].pc + slots[0].btarg;	       
	       fetch->load_pc(PC);
	       cache_reset = true;
	       cycles += 4; 	              
	       break;
	       
	    case Decoder::CONDIT_TRUE:	      
	      //if takes branch
	      if (slots[0].bcond_val == 1) {
		PC = slots[0].pc + slots[0].btarg;
		fetch->load_pc(PC);
		cache_reset = true;
		(preld == false) ? (cycles += 4) : (cycles += 1);
	      }
	      else
	      {
		(preld == true) ? (cycles += 6) : (cycles += 0);
	      
	      
	      if (slots[1].bcond_val == 1) {
		PC = slots[1].pc + slots[1].btarg;
		fetch->load_pc(PC);
		cache_reset = true;
		(preld == false) ? (cycles += 4) : (cycles += 1);
	      }
	      else{
		(preld == true) ? (cycles += 6) : (cycles += 0);
	      
	      if (slots[2].bcond_val == 1) {
		PC = slots[2].pc + slots[2].btarg;
		fetch->load_pc(PC);
		cache_reset = true;
		(preld == false) ? (cycles += 4) : (cycles += 1);
	      }
	      else
		(preld == true) ? (cycles += 6) : (cycles += 0);
	      }
	      }
	      
	      //resets preload
	      preld = false;	      
	      break;	      
	      
	    case Decoder::CONDIT_FALSE:
	            
	      //if takes branch
	      if (slots[0].bcond_val == 0) {
		PC = slots[0].pc + slots[0].btarg;
		fetch->load_pc(PC);
		cache_reset = true;
		(preld == false) ? (cycles += 4) : (cycles += 1);
	      }
	      else
		(preld == true) ? (cycles += 6) : (cycles += 0);
		
	      //resets preload
	      preld = false;
	      break;
	  };
	  break;
	case Decoder::REG_TARGET:
	  PC = slots[0].src1_val;
	  fetch->load_pc(PC);
	  cache_reset = true;
	  cycles += 4;   
	  break;
	
	default:
	  assert(0 && "Invalid control flow target");
	  break;
      }     
    }
    
    //there is a miss, register time stamp
    if (cache_time > 0)
    {
     pipeline_time = cycles;
//      file << "time_stamp: "<< std::dec << pipeline_time << endl;        
    }
          
    //copy old slot for interlock modeling
    memcpy(prev_slots, slots, sizeof(slots));
      
//     file << "Cycles: " << std::dec << cycles << endl;
    
    multicycle = 0;      
  }
  
  LOG << "Total cache misses: " << cache_misses << endl;
  LOG << "Total operations: " << operations << endl;
  LOG << "Total instruction: " << instructions << endl;
  LOG << "Cycles: " << cycles << endl;
  LOG << "ILP: " << ((float) operations / cycles) << endl;
  
}