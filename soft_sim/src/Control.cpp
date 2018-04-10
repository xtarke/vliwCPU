/* 
 * File:   Control.cpp
 * Author: bpibic
 * 
 * Created on 8 de Janeiro de 2015, 10:54
 */

#include "Control.h"
#include "Fetch.h"
#include "MEMCodeName.h"

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <stdint.h>

using namespace std;

Control::Control() {
    
}

void Control::GetData(Slot *slots){
//     for(int i = 0 ; i<4 ; i++){
//         
//         if(slots[i].format == 0){ //Formato 00 ULA
//             
//             slots[i].ula = 1;
//             slots[i].ula_code = slots[i].opcode;
//             slots[i].ula_src1 = slots[i].src1_val;
//             
//             if(slots[i].M0 == 0){
//                 
//                 if (slots[i].M1 == 0){ 
//                     slots[i].ula_src2 = slots[i].src2_val;
//                     slots[i].ula_dest = slots[i].dest;
//                 }
//                 else{
//                     slots[i].ula_src2 =  slots[i].Imm;
//                     slots[i].ula_dest = slots[i].idest;   
//                 }
//             }
//             else{
//                 
//                 if (slots[i].M1 == 0){
//                     slots[i].ula_src2 = slots[i].src2_val;
//                     
//                     if(slots[i].b25 == 0){
//                         slots[i].ula_dest = slots[i].dest;
//                         
//                     }
//                     else{
//                         slots[i].ula_dest = slots[i].bdest;
//                         
//                     }
//                 }
//                 else{
//                     slots[i].ula_src2 = slots[i].Imm;
//                     
//                     if(slots[i].b25 == 0){
//                         slots[i].ula_dest = slots[i].idest;
//                         
//                     }
//                     else{
//                         slots[i].ula_dest = slots[i].ibdest;
//                         
//                     }
//                 }  
//             }
//         }
//         if(slots[i].format == 2){ //Formato 10 Memoria
//             slots[i].mem = 1;
//             slots[i].mem_src1 = slots[i].src1_val;
//             slots[i].mem_src2 = slots[i].Imm;
//               
//             if(slots[i].mem_code == STW || slots[i].mem_code == STB || slots[i].mem_code == STH){
//                 slots[i].mem_st = 1;
//                 slots[i].mem_ld = 0;
//                 
//                 slots[i].mem_dest = slots[i].src2_val;
//                 
//             }
//             else{
//                 slots[i].mem_ld = 1;
//                 slots[i].mem_st = 0;
//                 
//                 slots[i].mem_dest = slots[i].idest;
//             }
//         }
//     }
}


