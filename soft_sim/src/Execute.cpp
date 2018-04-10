/* 
 * File:   Execute.cpp
 * Author: bpibic
 * 
 * Created on 13 de Janeiro de 2015, 15:52
 */

#include "ULACodeName.h"
#include "Execute.h"

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <stdint.h>

using namespace std;

Execute::Execute() {
}

unsigned int Execute::execute(Slot* slots){
    
  unsigned int time = 0;
  
  for (int i = 0; i < 4 ; i++) {
        slots[i].ula_result =   ula.Exec(slots[i].ula_code, slots[i].src1_val, slots[i].src2_val, slots[i].Imm, slots[i].ula_src_sel, slots[i].scond_val);
	
	if (slots[i].ula_code == ALU_MULL ||
	    slots[i].ula_code == ALU_MULL64H ||
	    slots[i].ula_code == ALU_MULL64HU)
	{	  
	  if (time < 3)
	    time = 3;   
	};

	if (slots[i].ula_code == ALU_DIVQ ||
	    slots[i].ula_code == ALU_DIVRU ||
	    slots[i].ula_code == ALU_DIVR ||
	    slots[i].ula_code == ALU_DIVQU)
	{	  
	  if (time < 19)
	    time = 19;   
	};	   
    }
//   cout << "Added: " << time << endl;
  return time;    
}


