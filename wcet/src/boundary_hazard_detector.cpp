/* 
 * File:   boundary_hazard_detector.cpp
 * Author: andreu/renan
 * 
 * Created on July 11, 2013, 7:30 AM
 */

#include "boundary_hazard_detector.h"
#include <vector>
#include <sstream>
//#include <sim_library.h>

int LW =0, LB = 0, LH = 0, LBU = 0, SB = 0, SH = 0, SW = 0, LHU = 0;

boundary_hazard_detector::boundary_hazard_detector(cfg* p_cfg) {
    program_cfg = p_cfg;
}

boundary_hazard_detector::~boundary_hazard_detector() {
}

// bool boundary_hazard_detector::has_hazard(basic_block* from, basic_block* to) {
// 
//     instrunction *from_instr, *to_instr;
// 
//     from_instr = from->instructions.back();
//     to_instr = to->instructions.front();
// 
//     //cout << "from: " << from_instr->addrress << "," << from_instr->get_opcode() << 
//     //        " to: " << to_instr->addrress << "," << to_instr->get_opcode() << endl;
//     
//     
//     //if last instruction of a bb is a load
//     if (from_instr->get_opcode() == LW ||
//             from_instr->get_opcode() == LB ||
//             from_instr->get_opcode() == LH ||
//             from_instr->get_opcode() == LBU ||
//             from_instr->get_opcode() == LHU) {
// 
//         if (to_instr->get_opcode() == SB ||
//                 to_instr->get_opcode() == SH ||
//                 to_instr->get_opcode() == SW) {
// 
//             if (from_instr->get_rt() == to_instr->get_rs()) {
//                 std::stringstream out;
//                 std::string msg;
// 
//                 out << "Hazard detection detected @(pc) = " <<
//                         from_instr->addrress << "/" << to_instr->addrress;
//                 msg = out.str();
// 
//                 assert(false && msg.c_str());
// 
//             }
// 
//         } else if (from_instr->get_rt() == to_instr->get_rs() ||
//                 from_instr->get_rt() == to_instr->get_rt()) {
//             std::stringstream out;
//             std::string msg;
//             out << "Hazard detection detected @(pc) = " <<
//                     from_instr->addrress << "/" << to_instr->addrress;
//             msg = out.str();
// 
//             assert(false && msg.c_str());
//         }
// 
//         return true;
//     }
// 
//     return false;
// }

void boundary_hazard_detector::detect() {

    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::const_iterator IT;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;

        vector<basic_block*>* suc = &bb->sucessors;
        vector<basic_block*>::const_iterator IT_suc;

        for (IT_suc = suc->begin(); IT_suc != suc->end(); ++IT_suc) {
            basic_block* bb_suc = *IT_suc;

//             if (has_hazard(bb, bb_suc)) {
//                 bb_suc->set_t(bb_suc->get_t() + 1);
//             }
        }
    }
}
