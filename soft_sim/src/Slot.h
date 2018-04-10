/* 
 * File:   Slot.h
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 14:08
 */

#ifndef SLOT_H
#define	SLOT_H

#include <stdint.h>


struct ula_ouput_ {
    int32_t ula_result;
    uint32_t pred_result;  
};

typedef struct ula_ouput_ ula_ouput; 

class Slot {
public:
    Slot();
          
    //debug info and control flow address computation
    uint32_t pc = 0;
    uint32_t op_raw_data = 0;    
    unsigned char bundle_size = 0;
    unsigned char ops = 0;
    
    //register addresses
    uint32_t src1 = 0;
    uint32_t src2 = 0;
    uint32_t dest = 0;
    uint32_t scond = 0;
    uint32_t bcond = 0;
    uint32_t bdest = 0;
    //register values
    uint32_t src1_val = 0;
    uint32_t src2_val = 0;    
    uint32_t scond_val = 0;        
    uint32_t bcond_val = 0;
    //immediates
    uint32_t isrc2 = 0;    //9-bit (short)
    int32_t Imm = 0;       //32-bit (long)
    int32_t btarg = 0;    //ctrflow 22-bit
    
    //full predication
    uint32_t f_pred_val = 0;
        
    //ula control
    uint32_t ula_code = 0;
    ula_ouput ula_result;    
    bool ula_src_sel = 0; //0 for src2, 1 for immediate
    
    //Memory ctrl
    bool mem_rd = 0;
    bool mem_wr = 0;
    unsigned char mem_byteen = 0;
    bool mem_sigext = 0;   
    
    uint32_t mem_addr = 0;
    int32_t mem_result = 0;
    
    // Write back
    unsigned char write_back_mux = 0;
    bool reg_wr = false;
    bool pred_wr = false;

    // control flow control
    unsigned char ctrl_flow_mux = 0;
    unsigned char ctrl_flow_type = 0;    
    bool ctrl_flow = 0;
    bool preload = false;
    
    //halt    
    bool halt = 0;
    
    
private:

};

#endif	/* SLOT_H */

