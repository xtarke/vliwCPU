/* 
 * File:   Regist.cpp
 * Author: bpibic
 * 
 * Created on 8 de Janeiro de 2015, 09:47
 */

#include "Regist.h"
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "Decoder.h"

#define F_PRED_BANK_ADDRESS 4

#define BIT_30 (1 << 30) 

#define DEBUG

using namespace std;


Regist::Regist(std::ofstream *file_) {      
  memset(reg, 0, sizeof(reg));
  file = file_;  
}


int32_t Regist::get_value(int32_t pos){
    
  return reg[pos];
}

void Regist::set_value(int32_t data,int32_t pos){
    reg[pos] = data;
}

bool Regist::get_pvalue(int32_t pos){  
    return preg[pos];
}

void Regist::set_pvalue(bool data, int32_t pos){
    
  assert(pos < 8);
  
  preg[pos] = data;
}

void Regist::dump()
{
	cout << "Register contents:" << endl;
        cout << dec;
        
	for (int i = 0; i < 64; i++)
	{
		if (i % 4 == 0 && i != 0)
		  cout << endl;

		cout << "R[" << i << "] = " << reg[i] << " \t";
	}

	cout << endl;
}

void Regist::GetRegValue(Slot *slots){
    
    unsigned src1, src2, bcond, scond;
     
    for (int i = 0; i < 4 ; i++){    
      
      //predecode
      src1 = slots[i].op_raw_data & 0x0000003F;
      src2 = (slots[i].op_raw_data >> 6) & 0x0000003F;
      bcond = (slots[i].op_raw_data >> 23) & 0x00000007;
      scond = (slots[i].op_raw_data >> 21) & 0x00000007;
              
      assert(src1 < 64);
      assert(src2 < 64);      
      assert(bcond < 8);            
      assert(scond < 8);
      
      slots[i].src1_val = reg[src1];
      slots[i].src2_val = reg[src2];
      
      slots[i].bcond_val = preg[bcond];
      slots[i].scond_val = preg[scond];
      
//       if (slots[i].op_raw_data & BIT_30)
	slots[i].f_pred_val = preg[F_PRED_BANK_ADDRESS];
    }
}


void Regist::write_back(Slot *slots)
{
  int32_t reg_val = 0;

  for (int i = 0; i < 4 ; i++)
  {
    assert(slots[i].dest < 64);    
    
    if (slots[i].dest != 0 && slots[i].reg_wr == true)
    {
      switch (slots[i].write_back_mux)
      {
	case Decoder::ALU_FT:
	   reg_val = slots[i].ula_result.ula_result;
	   break;
	case Decoder::MEM_FT:
	    reg_val = slots[i].mem_result;
	    break;
	case Decoder::CALL_FT:
	  reg_val = slots[i].pc + slots[i].bundle_size;
	  break;  
	default:
	  assert(1 && "Invalid write back source"); 
	  break;
      }                  
      set_value(reg_val, slots[i].dest);           

    #ifdef DEBUG
    *file << "Write Back S" << i << " : [r" <<  dec << slots[i].dest << "] : " <<  dec << reg_val << endl;  
    #endif
    
    }
    
    if (slots[i].pred_wr == true)
    {
      switch (slots[i].write_back_mux)
      {
	case Decoder::ALU_FT:
	   reg_val = slots[i].ula_result.pred_result;
	   break;	
	default:
	  assert(1 && "Invalid write back source"); 
	  break;
      } 

      #ifdef DEBUG      
      *file << "Write Back S" << i << " : [br" << slots[i].bdest << "] : " << (bool)reg_val << endl;
      #endif
      
      set_pvalue((bool)reg_val, slots[i].bdest);           
      
    }   
    
    
  }
  
//   cout << endl;
  
}


