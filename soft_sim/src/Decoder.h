/* 
 * File:   Decodify.h
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 14:25
 */

#ifndef DECODIFY_H
#define	DECODIFY_H

#include "Slot.h"
#include <iostream>
#include <fstream>
#include <string>

#define SP_REGISTER 12
#define RA_REGISTER 63

#define R26_MASK 0x03FFFFFF
#define FUNC_MASK 0x0000003F

#define STOP_BIT 0x80000000
#define BIT_30 (1 << 30) 
#define BIT_29 (1 << 29) 
#define BIT_28 (1 << 28)
#define BIT_27 (1 << 27)
#define BIT_26 (1 << 26)
#define BIT_25 (1 << 25)
#define BIT_23 (1 << 23) 
#define BIT_22 (1 << 22) 

using namespace std;


class Decoder {
public:
    Decoder(ofstream* file_);
    void Decode(Slot *slots); 
    
    enum write_back_dest {
        ALU_FT = 1,
        MEM_FT,
        CALL_FT
	
    };
    
    enum ctrl_flow_mux 
    {
      REG_TARGET = 0,
      BTARG_TARGET      
    };
    
    enum ctrl_flow_type
    {
      DIRECT = 0,
      CONDIT_TRUE,
      CONDIT_FALSE      
    };
    
    enum mem_byteen
    {
	WORD_ACC = 0,
	HWORD_ACC = 1,
	BYTE_ACC = 2    
    };
    
    
private:
    
    
    enum alu_src_sel {
      SEL_SRC2 = 0,
      SEL_IMM = 1      
    };
    
    
    //instruction format "00", intR
    enum alu_opcodes 
    {
	 ADD_OP = 0b00000,
	 SUB_OP = 0b00001,
	
	 SHL_OP = 0b00010,
	 SHR_OP = 0b00011,
	 SHRU_OP = 0b00100,
	
	 SH1ADD_OP = 0b00101,
	 SH2ADD_OP = 0b00110,
	 SH3ADD_OP = 0b00111,
	 SH4ADD_OP = 0b01000,
	
	 AND_OP	 = 0b01001,
	 ANDC_OP = 0b01010,	
	 OR_OP = 0b01011,
	 ORC_OP	 = 0b01100,	
	 XOR_OP	 = 0b01101,
	
	 MAX_OP	 = 0b10000,
	 MAXU_OP = 0b10001,
	 MIN_OP	= 0b10010,
	 MINU_OP= 0b10011,
	
	 MULL_OP  = 0b10101,
		
	 DIVRU_OP = 0b11100,
	 DIVQU_OP = 0b11101,
	
	 DIVR_OP = 0b11110,
	 DIVQ_OP = 0b11111,
	 
	 MONADIC_OP = 0b01110,
	 SXTB_OP = 0b000000000,
	 SXTH_OP  = 0b000000001,
	 ZXTH_OP = 0b000000011,
	 ZXTB_OP  = 0b000000101,
    };
    
    //instruction format "10", memory
     enum mem_opcodes{
        LDW_OP = 0b00000,
        LDH_OP = 0b00010,
        LDHU_OP = 0b00100,
        LDB_OP = 0b00110,
        LDBU_OP = 0b01000,        
        STW_OP = 0b01010,
        STH_OP = 0b01011,
        STB_OP = 0b01100
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
       
     // compare and mull64 class
     enum compare_opcodes {     
     	CMPEQ_OP = 0b0000,
	CMPNE_OP = 0b0001,
	CMPGE_OP = 0b0010,
	CMPGEU_OP = 0b0011,
	CMPGT_OP = 0b0100,
	CMPGTU_OP = 0b0101,
	CMPLE_OP = 0b0110,
	CMPLEU_OP = 0b0111,
	CMPLT_OP = 0b1000,
	CMPLTU_OP = 0b1001,	
	ANDL_OP = 0b1010,
	NANDL_OP = 0b1011,
	ORL_OP 	= 0b1100,
	NORL_OP = 0b1101,	
	MUL64HU_OP  = 0b1110,
	MUL64H_OP = 0b1111,
     }; 
     
     enum flow_opcodes
     {
       ICALL_OP =  0b00000,
       CALL_OP = 0b00001,
       IGOTO_OP = 0b00011,
       GOTO_OP = 0b0010,
       PRELD = 0b1110   
     };
   
   std::ofstream *file;
   bool par_on_off = false;
   
   int inst_parse(Slot* slot);
};

#endif	/* DECODIFY_H */