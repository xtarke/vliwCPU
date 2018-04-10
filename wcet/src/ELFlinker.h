/*
 * ELFlinker.h
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#ifndef ELFLINKER_H_
#define ELFLINKER_H_

#include <elf.h>
#include <sys/types.h>
#include <iostream>
#include <fstream>
#include <cerrno>
#include <string>
#include <cstring>
#include <cstdlib>
#include <cstdint>

#include "ELFsection.h"
//#include "sim_library.h"
//#include "ELFsection.h"


/*Instructions masks*/
#define ADDR_26_ERASE_MASK 0xF8000000
#define OP_MASK 0xFC000000
#define OP_LEFT_SHIFT 26

/*Some opcodes*/
#define OP_JUMP 0x2
#define OP_JAL 0x3

/*Relocations masks*/
#define R26_MASK 0x03FFFFFF
#define HILO16_MASK 0x0000FFFF

#define IMM9 0x000001FF
#define IMM23 ~(IMM9)

#define GET_IMM9(x) (x & IMM9)
#define GET_IMM23(x) ((x & IMM23) >> 9)

#define INST_IMM(x) (x << 12)
#define INST_IMMEXT(x) (x)
#define INST_ADDR_IMM(x) (x & 0x007FFFFF)
#define INST_CLEAR_ADDR(x) (x & ~0x007FFFFF)
/*
 *
 * == Memory Layout ==
 *
 */

/*sizes in words*/
#define ROM_WORDS 16384
#define RAM_WORDS 2048*2 // updated
#define SCRATCHPAD_WORDS 2048*2 // updated

/*sizes in bytes*/
#define ROM_SIZE_BYTES (ROM_WORDS * sizeof(uint32_t))
#define RAM_SIZE_BYTES (RAM_WORDS * sizeof(uint32_t))
#define SCRATCHPAD_SIZE_BYTES (SCRATCHPAD_WORDS * sizeof(uint32_t))

/*positions*/
#define ROM_BEGIN 0x00000000
#define RAM_BEGIN (ROM_BEGIN + ROM_SIZE_BYTES)
#define SCRATCHPAD_BEGIN (RAM_BEGIN + RAM_SIZE_BYTES)

namespace linker {
    




enum relocs{
		R_NONE = 0,
                R_PC23GOTO,  
                R_PC23CALL,  
                R_IMM9,
                R_IMM23,
                R_32,
                R_PC23PRELOAD
};


class ELF_object;
class ELF_section;

class ELF_linker {
private:
	ELF_object* target_object;
        ELF_object* source_object;
	uint32_t initial_offset;
        void resolve_relocs_helper(Elf32_Rela* relocs, unsigned int n_relocs, 
                                ELF_section* section);
        //cpu_info cpuinfo;
        
       
        uint32_t get_rom_size_bytes(){return ROM_SIZE_BYTES;}
        uint32_t get_ram_size_bytes(){return RAM_SIZE_BYTES;}
        uint32_t get_ram_scratchpad_bytes(){return SCRATCHPAD_SIZE_BYTES;}
        
        uint32_t get_rom_begin(){return 0x00000000;}
        //uint32_t get_ram_begin(){return 0x80000000;}
        uint32_t get_ram_begin(){return 0x40000000;}
        uint32_t get_scratchpad_begin(){return 0x40000000;}
        

public:
	ELF_linker(ELF_object* object, uint32_t initial_offset_);

	void define_section_addresses(uint32_t initial_offset);
	void resolve_relocs();
	void link();
	uint32_t search_main_entry();
	uint32_t get_image_size();
	uint8_t* convert_object_to_image();
        //void write_text_section_to_mif(const char* filename);
        void pre_process_bss();
        void pre_process_ldf_vars();
        void post_process_ldf_vars();
        
        ELF_object* get_result();
};

} /* namespace linker */
#endif /* ELFLINKER_H_ */
