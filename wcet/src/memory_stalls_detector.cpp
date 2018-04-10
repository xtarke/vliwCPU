/* 
 * File:   memory_stalls_detector.cpp
 * Author: andreu
 * 
 * Created on July 12, 2013, 11:56 AM
 */

#include "memory_stalls_detector.h"
#include <vector>
#include "logger.h"

memory_stalls_detector::memory_stalls_detector(cfg* p_cfg) {
    program_cfg = p_cfg;
}

memory_stalls_detector::~memory_stalls_detector() {
    
}

void memory_stalls_detector::detect() {

    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::const_iterator IT;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
//         detect_bb_memory_stalls(bb);
    }
}

// void memory_stalls_detector::detect_bb_memory_stalls(basic_block* bb){
//     
//     vector<instrunction*>* insts;
//     vector<instrunction*>::const_iterator IT;
//     
//     insts = &bb->instructions;
//     
//     for(IT = insts->begin(); IT != insts->end(); IT++){
//         instrunction* instr = *IT;
//         if(instr->is_load_instr()){
//             detect_bb_load_stall(bb, instr);
//         } else if(instr->is_store_instr()){
//             detect_bb_store_stall(bb, instr);
//         }
//     }
// }
// 
// void memory_stalls_detector::detect_bb_load_stall(basic_block* bb, instrunction* instr){
//     
//     if(instr->get_rs() != SP_REGISTER){
//         LOG_L << "-detected memory load from RAM @: "  << instr->addrress << endl;
//         bb->inc_memory_stalls();
//     }
// }
// 
// void memory_stalls_detector::detect_bb_store_stall(basic_block* bb, instrunction* instr){
//        
//     if(instr->get_rs() != SP_REGISTER){
//         LOG_L << "-detected memory store to RAM @: " << instr->addrress << endl;
//         bb->inc_memory_stalls();
//     }
// }