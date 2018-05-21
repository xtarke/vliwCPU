/*
 * File:   sizes.h
 * Author: xtarke
 *
 * Created on July 20, 2012, 16:22 PM
 */

#ifndef SIZES_H
#define	SIZES_H

//Memory definitions, number of words
#define ROM_SIZE 2048
#define ROM_INI 0
#define ROM_END (ROM_SIZE - 1)

#define RAM_SIZE 2048
#define RAM_INI ROM_SIZE
#define RAM_END (RAM_INI + RAM_SIZE -1)

#define IMAGE_SIZE ROM_SIZE + RAM_SIZE + 1 // (1 word to cache config info)

#define SCRATCHPAD_SIZE 1024
#define SCRATCHPAD_INI ROM_SIZE + RAM_SIZE
#define SCRATCHPAD_END  (SCRATCHPAD_INI + SCRATCHPAD_SIZE - 1)

#define MEMORY_SIZE_WORDS ROM_SIZE + RAM_SIZE + SCRATCHPAD_SIZE

#define ADDR_SIZE 32
#define RAM_ADDR_SIZE 32
#define WORD_SIZE 32
#define ALUOPS 6

#define N_REGISTERS 32
#define N_ADDR_REGISTER 5

#define OPCODE_SIZE 6
#define OPCODE_INI (WORD_SIZE - 1)
#define OPCODE_END  (WORD_SIZE - OPCODE_SIZE)

#define REG_ADDR_SIZE 5

#define JTARGET_SIZE 26
#define JTARGET_INI (WORD_SIZE - OPCODE_SIZE - 1)
#define JTARGET_END 0

#define RS_INI (WORD_SIZE - OPCODE_SIZE - 1)
#define RS_END (WORD_SIZE - OPCODE_SIZE - REG_ADDR_SIZE)

#define RT_INI (WORD_SIZE - OPCODE_SIZE - REG_ADDR_SIZE - 1)
#define RT_END (WORD_SIZE - OPCODE_SIZE - 2*REG_ADDR_SIZE)

#define RD_INI (WORD_SIZE - OPCODE_SIZE - 2*REG_ADDR_SIZE - 1)
#define RD_END (WORD_SIZE - OPCODE_SIZE - 3*REG_ADDR_SIZE)

#define SHAMT_SIZE 5
#define SHAMT_INI (WORD_SIZE - OPCODE_SIZE - 3*REG_ADDR_SIZE - 1)
#define SHAMT_END (WORD_SIZE - OPCODE_SIZE - 3*REG_ADDR_SIZE - SHAMT_SIZE)

#define FUNCT_SIZE 6
#define FUNCT_INI (WORD_SIZE - OPCODE_SIZE - 3*REG_ADDR_SIZE - SHAMT_SIZE - 1)
#define FUNCT_END 0

#define IMEDIATE_SIZE 16
#define IMEDIATE_INI (WORD_SIZE - IMEDIATE_SIZE - 1)
#define IMEDIATE_END 0

#define ADDRESS_SIZE 26
#define ADDRESS_INI (ADDRESS_SIZE - 1)
#define ADDRESS_END 0

#define INIT_RESET_TIME 20
#define CPU_CYCLE_TIME 20
#define MEM_CYCLE_TIME 40

////////////////// cache parameters /////////////////////////////////
#define CACHE_BLOCKS 16           //blocks or lines
#define BLOCK_SIZE 16	//number of words per block

/////////////////////////////////////////////////////////////////////

template <int N>
struct Log2Floor
{
    static const int VALUE = Log2Floor<N / 2>::VALUE + 1;  // floor(log_2(n))
};

// Base cases.
template <> struct Log2Floor<1> { static const int VALUE = 0; };
template <> struct Log2Floor<0> { static const int VALUE = 0; };

#endif


