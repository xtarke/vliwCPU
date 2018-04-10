/* 
 * File:   MemOperation.cpp
 * Author: bpibic
 * 
 * Created on 19 de Janeiro de 2015, 16:57
 */

#include "MemOperation.h"
#include "MEMCodeName.h"


MemOperation::MemOperation() {

}

void MemOperation::MemUse(Slot *slots){
//     uint32_t aux;
//     switch(slots[0].mem_code){
//         case LDW :
//             slots[0].mem_result = slots[0].mem_pre_ld;
//             break;
//             
//         case LDH :
//             if(slots[0].mem_byt_slct < 2){
//                 aux = (slots[0].mem_pre_ld & 0x0000ffff);
//             }
//             else{
//                 aux = (slots[0].mem_pre_ld >> 16);
//             }
//             if ((aux >> 15) == 1){
//                 slots[0].mem_result = (aux | 0xffff0000);
//             }
//             else{
//                 slots[0].mem_result = aux;
//             }
//             break;
//             
//         case LDHU :
//             if(slots[0].mem_byt_slct < 2){
//                 aux = (slots[0].mem_pre_ld & 0x0000ffff);
//             }
//             else{
//                 aux = (slots[0].mem_pre_ld >> 16);
//             }
//             slots[0].mem_result = aux;
//             break;
//             
//         case LDB :
//             if(slots[0].mem_byt_slct == 0){
//                 aux = (slots[0].mem_pre_ld & 0x000000ff);
//             }
//             if(slots[0].mem_byt_slct == 1){
//                 aux = ((slots[0].mem_pre_ld >> 8) & 0x000000ff);
//             }
//             if(slots[0].mem_byt_slct == 2){
//                 aux = ((slots[0].mem_pre_ld >> 16) & 0x000000ff);
//             }
//             if(slots[0].mem_byt_slct == 3){
//                 aux = ((slots[0].mem_pre_ld >> 24) & 0x000000ff);
//             }
//             if ((aux >> 7) == 1){
//                 slots[0].mem_result = (aux | 0xffffff00);
//             }
//             else{
//                 slots[0].mem_result = aux;
//             }
//             break;
//             
//         case LDBU :
//             if(slots[0].mem_byt_slct == 0){
//                 aux = (slots[0].mem_pre_ld & 0x000000ff);
//             }
//             if(slots[0].mem_byt_slct == 1){
//                 aux = ((slots[0].mem_pre_ld >> 8) & 0x000000ff);
//             }
//             if(slots[0].mem_byt_slct == 2){
//                 aux = ((slots[0].mem_pre_ld >> 16) & 0x000000ff);
//             }
//             if(slots[0].mem_byt_slct == 3){
//                 aux = ((slots[0].mem_pre_ld >> 24) & 0x000000ff);
//             }
//             slots[0].mem_result = aux;
//             break;
//             
//         case STW :
//             slots[0].mem_result = slots[0].mem_dest; // isso aqui ta feio da uma olhada depois
//             break;
//             
//         case STH :
//             if(slots[0].mem_byt_slct < 2){
//                 aux = (slots[0].mem_dest & 0x0000ffff);
//             }
//             else{
//                 aux = (slots[0].mem_dest & 0xffff0000);
//             }
//             slots[0].mem_result = aux;
//             break;
//             
//         case STB :
//             if(slots[0].mem_byt_slct == 0){
//                 aux = (slots[0].mem_dest & 0x000000ff);
//             }
//             if(slots[0].mem_byt_slct == 1){
//                 aux = (slots[0].mem_dest & 0x0000ff00);
//             }
//             if(slots[0].mem_byt_slct == 2){
//                 aux = (slots[0].mem_dest & 0x00ff0000);
//             }
//             if(slots[0].mem_byt_slct == 3){
//                 aux = (slots[0].mem_dest & 0xff000000);
//             }
//             slots[0].mem_result = aux;
//             break;
//     }
    
}