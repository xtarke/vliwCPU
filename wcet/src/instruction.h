/*
 * instruction.h
 *
 *  Created on: May 17, 2013
 *      Author: xtarke
 */

#include <vector>
#include <cstdint>

#ifndef INSTRUCTION_H_
#define INSTRUCTION_H_

//#include <sim_library.h>

//ooooooss sssttttt dddddaaa aaffffff

//11111100 00000000 00000000 00000000
#define OP_MASK 0xFC000000
#define OP_LEFT_SHIFT 26

//00000011 11100000 00000000 00000000
#define RS_MASK 0x03E00000
#define RS_LEFT_SHIFT 21

//00000000 00011111 00000000 00000000
#define RT_MASK 0x001F0000
#define RT_LEFT_SHIFT 16

//00000000 00000000 11111000 00000000
#define RD_MASK 0x0000F800
#define RD_LEFT_SHIFT 11

//stack pointer register
#define SP_REGISTER 29
#define RA_REGISTER 31


#define R26_MASK 0x03FFFFFF
#define FUNC_MASK 0x0000003F

#define STOP_BIT 0x80000000
#define BIT_30 (1 << 30)
#define BIT_29 (1 << 29) 
#define BIT_28 (1 << 28)
#define BIT_27 (1 << 27)
#define BIT_26 (1 << 26)
#define BIT_25 (1 << 25) 


enum cache_prediction {
    UNKNOWN = 0,
    A_MISS,
    A_HIT,
    F_MISS,
    CONFLICT,
    HALT
};

// class instrunction {
// public:
//     uint32_t addrress;
//     uint32_t tag;
//     uint32_t blk_off;
//     uint32_t line;
// 
//     cache_prediction prediction;
// 
//     uint32_t instr_data;
// 
//     uint32_t get_opcode() {
//         return (instr_data & OP_MASK) >> OP_LEFT_SHIFT;
//     }
// 
//     uint32_t get_rs() {
//         return (instr_data & RS_MASK) >> RS_LEFT_SHIFT;
//     }
// 
//     uint32_t get_rt() {
//         return (instr_data & RT_MASK) >> RT_LEFT_SHIFT;
//     }
// 
//     uint32_t get_rd() {
//         return (instr_data & RD_MASK) >> RD_LEFT_SHIFT;
//     }
// 
//     int16_t get_imm() {
//         return (int16_t) instr_data & 0x0000FFFF;
//     }
// 
//     uint32_t get_addr26() {
//         return instr_data & R26_MASK;
//     }
// 
//     uint32_t get_func() {
//         return instr_data & FUNC_MASK;
//     }
// 
//     bool is_load_instr() {
// 
//         /*
//         switch(get_opcode()){
//             case LW:
//                 return true;
//                 break;
//             case LB:
//                 return true;
//                 break;
//             case LBU:
//                 return true;
//                 break;
//             case LHU:
//                 return true;
//                 break;
//             case LH:
//                 return true;
//                 break;
//             default:
//                 return false;
//         }
//          */
//         return false;
//     }
// 
//     bool is_store_instr() {
//         /*
//         switch(get_opcode()){
//             case SW:
//                 return true;
//                 break;
//             case SB:
//                 return true;
//                 break;
//             case SH:
//                 return true;
//                 break;
//             default:
//                 return false;
//         }
//          */
//         return false;
//     }
// };

class VLIW_register {
public:

    enum reg_type {
        GENERAL,
        BRANCH
    };

    unsigned type;
    unsigned number;

    VLIW_register(unsigned number_, unsigned type_) : type(type_),
    number(number_) {
    };
};

class VLIW_instruction {
public:

    enum inst_type {
        ALU = 1,
        MULT, //2
        DIV, //3
        LOAD, //4
        STORE, //5
        BRANCH, //6
        CALL, //7
        IMM, //8
        SELECT, //9
        SPECIAL, //10
        PRELOAD, //11
        GOTO,
	PRED_ON,
	PRED_OFF
    };
    
    enum opcodes{
        LDW = 0b00000,
        LDH = 0b00010,
        LDHu = 0b00100,
        LDB = 0b00110,
        LDBu = 0b01000,
        
        STW = 0b01010,
        STH = 0b01011,
        STB = 0b01100,
	
	MUL32 = 0b01110,
	MUL64H = 0b01111,
	
	//ALU_MULLS = 0b10100,
	
	MULL_OP  = 0b10101,
	
	DIVRU_OP = 0b11100,
	DIVQU_OP = 0b11101,
	
	DIVR_OP = 0b11110,
	DIVQ_OP = 0b11111,
        
        CALLR_OP = 0b0000,
        ICALL_OP = 0b0001,
        GOTO_OP = 0b0010,
        IGOTO_OP = 0b0011,
        PRELD_OP = 0b1110
    };
    
     //instruction format "01", especial
     enum special_opcodes {
	SLCT_OP = 0b000,
	SLCTF_OP = 0b001,
	ADDCG_OP = 0b010,
	SUBCG_OP = 0b011,	
	IMM_OP = 0b101,
	
	PAR_ON_OP = 0b110,
	PAR_OFF_OP = 0b111
     };
    
    std::vector<VLIW_register*> input_regs;
    std::vector<VLIW_register*> output_regs;

    unsigned type;
    unsigned opcode;
    
    bool bit_30;

    VLIW_instruction(){};
    ~VLIW_instruction();
    
    bool is_this_type(unsigned type_) {
        return (type == type_);
    };
};

class VLIW_bundle {
public:
    
    uint32_t address;
    uint32_t tag;
    uint32_t blk_off;
    uint32_t line;    
    cache_prediction prediction;

    std::vector<VLIW_instruction*> instructions;

    bool check_relation(unsigned mytype, unsigned othertype, VLIW_bundle* another);
    
    bool has_instruction_type(unsigned mytype);
    bool has_instruction_type_path(unsigned mytype, unsigned *bit_30);

    static void create_bundle_seq(uint32_t *inst_buffer, unsigned fi, unsigned li);
    
    VLIW_bundle(uint32_t address_){
        address = address_;};
    ~VLIW_bundle();
};

namespace VLIW_bundle_parser {
    void create_bundle_seq(std::vector<VLIW_bundle*> &bundles, uint32_t *inst_buffer, unsigned fi, unsigned li);
}

#endif /* INSTRUCTION_H_ */
