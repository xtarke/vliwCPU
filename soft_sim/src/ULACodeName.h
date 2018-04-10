/*
 * File:   ULACodeName.h
 * Author: bpibic
 *
 * Created on 19 de Janeiro de 2015, 16:35
 */

#ifndef ULACODENAME_H
#define	ULACODENAME_H

enum alu_functions
{
    ALU_IDLE  = 0b000000,
    ALU_ADD  = 0b000001,
    ALU_SUB  = 0b000010,
    ALU_SHL  = 0b000011,
    ALU_SHR  = 0b000100,
    ALU_SHRU  = 0b000101,
    ALU_SH1ADD  = 0b000110,
    ALU_SH2ADD  = 0b000111,
    ALU_SH3ADD  = 0b001000,
    ALU_SH4ADD  = 0b001001,

    ALU_AND  = 0b001010,
    ALU_ANDC  = 0b001011,

    ALU_OR  = 0b001100,
    ALU_ORC  = 0b001101,

    ALU_XOR  = 0b001110,

    ALU_MAX  = 0b001111,
    ALU_MAXU  = 0b010000,
    ALU_MIN  = 0b010001,
    ALU_MINU  = 0b010010,

    ALU_SXTB  = 0b010011,
    ALU_SXTH  = 0b010100,
    ALU_ZXTB  = 0b010101,
    ALU_ZXTH  = 0b010110,

    ALU_ADDCG  = 0b010111,	//-- LSB must be 1
    ALU_SUBCG  = 0b111110,	//-- LSB must be 0


    //-- compare functions
    ALU_CMPEQ  = 0b011000,
    ALU_CMPGE  = 0b011001,
    ALU_CMPGEU  = 0b011010,
    ALU_CMPGT  = 0b011011,
    ALU_CMPGTU  = 0b011100,
    ALU_CMPLE  = 0b011101,
    ALU_CMPLEU  = 0b011110,
    ALU_CMPLT  = 0b011111,
    ALU_CMPLTU  = 0b100000,
    ALU_CMPNE  = 0b100001,
    ALU_NANDL = 0b100010,
    ALU_NORL = 0b100011,
    ALU_ORL = 0b100100,
    ALU_ANDL = 0b100101,

    //-- selects
    ALU_SLCT = 0b100111,
    ALU_SLCTF  = 0b101000,

    //-- mul
    ALU_MULL  = 0b101001,
    ALU_MULL64H = 0b101010,
    ALU_MULL64HU = 0b101011,
    ALU_DIVQ  = 0b101111,
    ALU_DIVR = 0b110000,
    ALU_DIVQU = 0b110001,
    ALU_DIVRU = 0b110010
  
};



#endif	/* ULACODENAME_H */

