/* 
 * File:   Memory.cpp
 * Author: bpibic
 * 
 * Created on 8 de Janeiro de 2015, 09:46
 */

#include "Memory.h"
#include "Decoder.h"
#include <iostream>
#include  <iomanip>

#define HEX_8F uppercase << setfill('0') << setw(8) << hex

using namespace std;

Memory::Memory(Rom *_rom, SPram *_spram){
  rom = _rom;
  spram = _spram;
  
  file.open("sp-sim.txt");  
}

Memory::~Memory()
{
  file.close();  
}

unsigned int Memory::execute(Slot* slots)
{
  uint32_t addr = 0;
  bool sigext = false;
  unsigned char mem_byteen = 0;
  unsigned int time = 0;
  unsigned int ins_time = 0;
  
  int32_t mem_data = 0;
  
  for (int i = 0; i < 4 ; i++){
    
    addr = slots[i].Imm + slots[i].src1_val;
    sigext = slots[i].mem_sigext;
    mem_byteen = slots[i].mem_byteen;
    
    if (slots[i].mem_wr == true)
    {
      if (i > 1)
	assert(0 && "Slot[2] and Slots[3] do not support memory operations");      
    
	mem_wr(addr, sigext, mem_byteen, slots[i].src2_val, &ins_time);
        
        (ins_time > time) ? (time = ins_time) : (time);
      
	if (i == 0)
	  file << "sp_a_wr: " << dec << ((addr >> 2) & SPRAM_MASK) << " : " <<  HEX_8F << slots[i].src2_val << endl;
	
	if (i == 1)
	  file << "sp_b_wr: " << dec << ((addr >> 2) & SPRAM_MASK) << " : " <<  HEX_8F << slots[i].src2_val << endl;
      
      
//           cout << "Write @ " << hex << addr << " : " << slots[i].src2_val <<  " sigext: " << sigext << " mem_byteen: " <<  (int32_t)slots[i].mem_byteen << endl;     
      
    }
    
    
    if (slots[i].mem_rd == true)
    {  
      if (i > 1)
	assert(0 && "Slot[2] and Slots[3] do not support memory operations");      
      
     	mem_data = mem_rd(addr, sigext, mem_byteen, &ins_time);
        (ins_time > time) ? (time = ins_time) : (time);
          
	slots[i].mem_result = mem_data;
      
//   	cout << "Read @ " << hex << addr << " : " << mem_data <<  " sigext: " << sigext << " mem_byteen: " <<  (int32_t)slots[i].mem_byteen << endl;    
      
	if (i == 0)
	  file << "sp_a_rd: " << dec << ((addr >> 2) & SPRAM_MASK) << " : " <<  HEX_8F << mem_data << endl;
	
	if (i == 1)
	  file << "sp_b_rd: " << dec <<((addr >> 2) & SPRAM_MASK) << " : " <<  HEX_8F <<mem_data << endl;
      
      
    }   
  }
  
//   cout << "MEM Added: " << time << endl;
  
  return time;  
}

int32_t Memory::mem_rd(uint32_t addr, bool sigext, unsigned char mem_byteen, unsigned int *time)
{
  int32_t data = 0;
  uint32_t byte = (addr & 0x3) << 3;
  
     
  if (addr < CODE_END)
  {
    *time = 4;
    data = rom->get_value(addr >> 2);
    
  }else if (addr >= SPRAM_INI & addr < SPRAM_END)
  { 
    *time = 2;
    data = spram->get_value((addr >> 2) & SPRAM_MASK);      
  }
  else
  {
    cout << "addr: " << hex << addr << endl;
    assert(0 && "Invalid Memory Addr");
  }
  
  switch(mem_byteen){
    case Decoder::WORD_ACC:
      break;
    
    case Decoder::HWORD_ACC:            
      assert( !(((addr & 0x3) == 1) || ((addr & 0x3) == 3)) && "Misalignment memory access");         
      data = (data >> byte) & 0xFFFF;           
      //signal extension        
      ((sigext == true) && ((data & (1 << 15))) ? (data = data | 0xFFFF0000) : data);      
      
//       cout << "sigext: " << dec << sigext << endl;
//       cout << "neg: " << hex << (data & (1 << 15)) << endl;
//       cout << "addr: " << hex << ((addr >> 2) & SPRAM_MASK) << endl;
//       cout << "byte: " << dec << byte << endl;
//       cout << "data: " << dec << data << endl;
      break;
    case Decoder::BYTE_ACC:
      //cout << "half_word: " << half_word << endl;
      data = (data >> byte) & 0xFF;     
      
      //signal extension        
      ((sigext == true) && ((data & (1 << 7))) ? (data = data | 0xFFFFFF00) : data);      

//       cout << "sigext: " << dec << sigext << endl;
//       cout << "neg: " << hex << (data & (1 << 7)) << endl;
//       cout << "addr: " << dec << ((addr >> 2) & SPRAM_MASK) << endl;
//       cout << "byte: " << dec << byte << endl;
//       cout << "data: " << dec << data << endl;      
      break;
  }
  
  //cout << "data: " << hex << data << dec << endl;
  
  
  
  return data;  
}

void Memory::mem_wr(uint32_t addr, bool sigext, unsigned char mem_byteen, int32_t data, unsigned int *time)
{  
  int32_t rd_data = 0;
  uint32_t wr_data = data;
  uint32_t byte = (addr & 0x3) << 3;
  
  
  if (addr >= SPRAM_INI & addr < SPRAM_END)
  {
    *time = 2;
    
    switch(mem_byteen){
      case Decoder::WORD_ACC:
	wr_data = data;   
	break;
      case Decoder::HWORD_ACC:
	  assert( !(((addr & 0x3) == 1) || ((addr & 0x3) == 3)) && "Misalignment memory access");
	  	  
	 rd_data = spram->get_value((addr >> 2) & SPRAM_MASK);	 
	 rd_data = rd_data & ~(0xFFFF << byte);
	 wr_data = (wr_data & 0xFFFF) << byte;	 
	 wr_data = wr_data | rd_data;
	
// 	cout << "addr: " << hex << ((addr >> 2) & SPRAM_MASK) << endl;
// 	cout << "byte: " << dec << byte << endl;
// 	cout << "data_masked: " << hex << rd_data << endl;
// 	cout << "wr_data: " << hex << wr_data << endl;	
// 	 
// 	 
// 	 assert(0);
	 
	break;
      
      case Decoder::BYTE_ACC:
	 rd_data = spram->get_value((addr >> 2) & SPRAM_MASK);
	 rd_data = rd_data & ~(0xff << byte);
	 wr_data = (wr_data & 0xFF) << byte;	 
	 wr_data = wr_data | rd_data;
		
// 	cout << "addr: " << hex << addr << endl;
// 	cout << "byte: " << dec << byte << endl;
// 	cout << "data_masked: " << hex << rd_data << endl;
// 	cout << "wr_data: " << hex << wr_data << endl;	
	
	break;
      
    }
    
    spram->set_value((addr >> 2) & SPRAM_MASK, wr_data);  
    
  }
  else
  {
    cout <<  hex << "[" << addr << "] = " << data << endl;
    assert(0 && "Writing to invalid address");
  }  
}


void Memory::set_value(uint32_t valor, int posicao){
//     data[posicao] = valor;
    
}

uint32_t Memory::get_value(int posicao){
//     return data[posicao];  
}

void Memory::LoadMemory(Slot *slots){
    for (int i = 0; i<4 ; i++){
//         slots[i].mem_pre_ld = data[(slots[i].src1_val + slots[i].src2_val)/4];
//         slots[i].mem_byt_slct = ((slots[i].src1_val + slots[i].src2_val)%4);
    }
}