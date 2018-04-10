/* 
 * File:   Fetch.cpp
 * Author: bpibic
 * 
 * Created on 8 de Janeiro de 2015, 09:33
 */

#include "Fetch.h"
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <stdint.h>

using namespace std;


void Fetch::load_pc(uint32_t PC)
{
    buffer_index = PC & 0x7;
}

uint32_t Fetch::bundle_decode(Slot* slots, uint32_t *buffer, uint32_t PC){
  int i = 0;
  int j = 0;
  int bundle_size = 1;
  
  //detect stop bits
  i = buffer_index;
  while ((buffer[i] >> 31) == 0 && bundle_size < fetch_bufer_size)
  {
    bundle_size++; 
    i++;
  }
     
  //check cache alignment and bundle decoding
  if (bundle_size > 4)
  {      
    cout << "ABORT: check bundle cache alignment" << endl;
    exit(EXIT_FAILURE);      
  }
  
  
  for (i = 0; i < 4; i++)
  {
    if (i < bundle_size)
    {
      slots[i].op_raw_data = buffer[buffer_index + i];
      slots[i].bundle_size = bundle_size; 
      slots[i].pc = PC;
    }
    else
    {
      slots[i].pc = 0;
      slots[i].op_raw_data = 0;          
    }        
  }
  
  //circular buffer index
  buffer_index += bundle_size;
  buffer_index = buffer_index & 0x7;  

  return bundle_size;     
}