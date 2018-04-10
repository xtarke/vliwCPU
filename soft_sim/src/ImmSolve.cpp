/*
 * File:   ImmSolve.cpp
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 15:41
 */

#include "ImmSolve.h"

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <stdint.h>

#define BIT_20 (1 << 20) 

using namespace std;

ImmSolve::ImmSolve() {
}

void ImmSolve::SolveImm(Slot *slots) {
    for (int i = 0; i<4 ; i++) {

	//short immediate
	slots[i].isrc2 = ((slots[i].op_raw_data >> 12) & 0x1FF);


        if (i == 0) { // nao pode ter imml
            if(((slots[0].op_raw_data >> 23) & 0x0000007f) == 0x0000002a) {
                cout << "Atempt to use IMML on the first SLOT" << endl;
                exit(1);
            }
            else {
                if(((slots[1].op_raw_data >> 23) & 0x0000007f) == 0x0000002a) { // imml de 32 bits
                    slots[0].Imm = int32_t((slots[1].op_raw_data  << 9) | slots[0].isrc2);
                }
                else {
//                     if (((slots[0].isrc2 >> 8) & 0x00000001) == 1) { // sem extensao
//                         slots[0].Imm = int32_t(slots[0].isrc2 | 0xfffffe00 );
//                     }
//                     else {   
// 		      
// 		      
//                         slots[0].Imm = int32_t(slots[0].isrc2);
		    if (slots[0].op_raw_data & BIT_20)
		      slots[0].Imm = slots[0].isrc2 | ~0x1FF;
		    else
		      slots[0].Imm = slots[0].isrc2;
		  
                    }
                }            
        }

        if (i == 1) {
            int control = 0;
            if(((slots[2].op_raw_data >> 23) & 0x0000007f) == 0x0000002a) { // imml 32 bits
                slots[1].Imm = int32_t((slots[2].op_raw_data  << 9) | slots[1].isrc2);
                control ++;
            }
            if(((slots[0].op_raw_data >> 23) & 0x0000007f) == 0x0000002b) { // immr 32 bits
                if (control == 1) {
                    cout << "Imediate overload by both sides" << endl;
                    exit(1);
                }
                else {
                    slots[1].Imm = int32_t((slots[0].op_raw_data  << 9) | slots[1].isrc2);
                }
            }
            if((((slots[0].op_raw_data >> 23) & 0x0000007f) != 0x0000002b) && (((slots[2].op_raw_data >> 23) & 0x0000007f) != 0x0000002a)) {
                        
	      if (slots[1].op_raw_data & BIT_20)
	            slots[1].Imm = slots[1].isrc2 | ~0x1FF;
	      else
	           slots[1].Imm = slots[1].isrc2;
            }


        }

        if (i == 2) {
            int control = 0;
            if(((slots[3].op_raw_data >> 23) & 0x0000007f) == 0x0000002a) { // imml 32 bits
                slots[2].Imm = int32_t((slots[3].op_raw_data  << 9) | slots[2].isrc2);
                control ++;
            }
            if(((slots[1].op_raw_data >> 23) & 0x0000007f) == 0x0000002b) { // immr 32 bits
                if (control == 1) {
                    cout << "Imediate overload by both sides" << endl;
                    exit(1);
                }
                else {
                    slots[2].Imm = int32_t((slots[1].op_raw_data  << 9) | slots[2].isrc2);
                }
            }
            if((((slots[1].op_raw_data >> 23) & 0x0000007f) != 0x0000002b) && (((slots[3].op_raw_data >> 23) & 0x0000007f) != 0x0000002a)) {
              if (slots[2].op_raw_data & BIT_20)
	            slots[2].Imm = slots[2].isrc2 | ~0x1FF;
	      else
	           slots[2].Imm = slots[2].isrc2;
            }
        }

        if (i == 3) { // nao pode ter immr
            if(((slots[3].op_raw_data >> 23) & 0x0000007f) == 0x0000002b) {
                cout << "Atempt to use IMMR on the last SLOT" << endl;
                exit(1);
            }
            else {
                if(((slots[2].op_raw_data >> 23) & 0x0000007f) == 0x0000002b) { // immr de 32 bits
                    slots[3].Imm = int32_t((slots[2].op_raw_data  << 9) | slots[3].isrc2);
                }
                else {
                  if (slots[3].op_raw_data & BIT_20)
	            slots[3].Imm = slots[3].isrc2 | ~0x1FF;
		  else
	           slots[3].Imm = slots[3].isrc2;
                }
            }
        }
    }
}

