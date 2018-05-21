/*
 * File:   instrunction.h
 * Author: xtarke
 *
 * Created on March 01, 2013
 */

#ifndef INSTRUNCTIONS_H
#define	INSTRUNCTIONS_H

#include "sizes.h"

//normal arithmetic, R type instruction
#define NORM_ARIT 0x0

#define ADD 0x20	//no overflow
#define ADDU 0x21
#define AND 0x24
#define DIV 0x1a	// signed
#define DIVU 0x1b	// signed, equal DIV
#define MFHI 0x10
#define MFLO 0x12
#define MULT 0x18
#define MULTU 0x19
#define NOR 0x27
#define XOR 0x26
#define OR 0x25
#define SLT 0x2a	//set less than
#define SLTU 0x2b	//set less than
#define SLL 0x0
#define SLLV 0x4
#define SRL 0x2
#define SRLV  0x6
#define SRA 0x3
#define SRAV 0x7
#define SUB 0x22
#define SUBU 0x23

//special arithmetic
#define SPEC_ARIT 0x1c
//MUL requires 0xc1 as opcode and 0x2 as function
#define MUL 0x2

#define ADDI 0x8
#define ADDIU 0x9
#define ANDI 0xC
#define ORI 0xD
#define XORI 0xE
#define SLTI 0xA
#define SLTIU 0xB

#define LW 0x23
#define LB 0x20
#define LBU 0x24
#define LHU 0x25
#define LH 0x21

#define SB 0x28
#define SH 0x29
#define SW 0x2B

#define LUI 0x0f

#define J 0x2
#define JAL 0x3
#define JR 0x8
#define JALR 0x9

//predicates
#define CMPEQ 0x32		//RD(P) = RS == RT
#define CMPEQI 0x32		//RT(P) = RS == Im
#define CMPGE  0x33 	//RD(P) = RS >= RT 	(signed)
#define CMPGEI 0x33 	//RT(P) = RS >= Im	(signed)
#define CMPGEU 0x34  	//RD(P) = RS >= RT	(unsigned)
#define CMPGEUI 0x34 	//RT(P) = RS >= Im	(unsigned)
#define CMPGT 0x35		//RD(P) = RS > RT	(signed)
#define CMPGTI 0x35		//RT(P) = RS > Im	(signed)
#define CMPGTU 0x36		//RD(P) = RS > RT	(unsigned)
#define CMPGTUI 0x36	//RT(P) = RS > Im	(unsigned)
#define CMPLE  0x37		//RD(P) = RS <= RT 	(signed)
#define CMPLEI 0x37		//RT(P) = RS <= Im	(signed)
#define CMPLEU 0x38		//RD(P) = RS <= RT 	(unsigned)
#define CMPLEUI 0x38	//RT(P) = RS <= Im	(unsigned)
#define CMPLT 0x39		//RD(P) = RS < RT 	(signed)
#define CMPLTI 0x39		//RT(P) = RS < Im	(signed)
#define CMPLTU 0x3a		//RD(P) = RS < RT 	(unsigned)
#define CMPLTUI 0x3a	//RT(P) = RS < Im	(unsigned)
#define CMPNE  0x3b		//RD(P) = RS != RT
#define CMPNEI 0x3b		//RT(P) = RS != Im
//pedicates logic
#define NANDL 0x3c		//RD(P) = !(RS(P) && RT(P))
#define NORL  0x3d		//RD(P) = !(RS(P) || RT(P))
#define ORL 0x3e		//RD(P) = RS(P) || RT(P)
#define CMOV  0x3f 		//RD = RS, if RT(P) == 1
#define XORL 0x2f               //RD(P) = RS(P) XOR RT(P)
#define ANDL 0x30               //RD(P) = RS(P) && RT(P)

//predicate mov
#define PMOV 0x31

//branches
#define BR  0x4
#define BRF  0x5

#define HLT 0x3f


#endif


