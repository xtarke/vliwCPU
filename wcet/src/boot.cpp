/*
 * boot.cpp
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#include <sys/syscall.h>
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <elf.h>
#include <string.h>
#include <sys/types.h>
#include "boot.h"
//#include "sim_library.h"
#include "ELFlinker.h"

using namespace linker;


#define JAL_INDEX 1

/*boot loader using a immediate to load stack pointer*/
static uint32_t boot_code_lower[] = {
		//addiu $sp, $zero, 1
		0x241d0000,
		//jal LABEL
		0x0c000000,
		// Nop
		0x00000000,
		//halt
		0xFC000000
		//LABEL: # .text code starts here
};

uint32_t start_boot_code_lower_fi = 0;
uint32_t start_boot_code_lower_li = 2;

uint32_t end_boot_code_lower_fi = 3;
uint32_t end_boot_code_lower_li = 3;

/*boot loader using stack pointer stored in rom*/
static uint32_t boot_code_higher[] = {
		//lw $sp, 3($zero)
		0x8c1d000C,
		//jal LABEL
		0x0c000000,
		// Nop
		0x00000000,
		//halt
		0xFC000000,
		//STACK_POINTER
		0x00000000
		//LABEL: # .text code starts here
};

uint32_t start_boot_code_higher_fi = 0;
uint32_t start_boot_code_higher_li = 2;

uint32_t end_boot_code_higher_fi = 3;
uint32_t end_boot_code_higher_li = 3;

enum stack_position{
	LOWER_STACK = 0,
	HIGHER_STACK
};

/*selected boot code for the binary*/
static uint32_t* selected_boot_code = NULL;
static unsigned int selected_boot_code_size = 0;

/*boot code to adjust stack and call code*/
static unsigned int boot_adj_stack_indexes[] = {0, 4};
static unsigned int boot_code_size[] = {4, 5};

static const uint32_t stack_frontier = 0xFFFF;

unsigned int linker::get_boot_code_size(uint32_t stack_pointer){

	if(stack_pointer < stack_frontier){
		return boot_code_size[LOWER_STACK] * sizeof(uint32_t);
	}

	return boot_code_size[HIGHER_STACK] * sizeof(uint32_t);
}

void linker::write_boot_code(unsigned char* image, uint32_t main_address, uint32_t stack_pointer){
#if defined(DEBUG) 
	printf("Adjusting stack...\n");
#endif
	/*first of all, adjust stack pointer (sp)*/

	/*load stack pointer using immediate value*/
	if(stack_pointer < stack_frontier){
		uint16_t* immediate = NULL;
		immediate = (uint16_t*) &boot_code_lower[boot_adj_stack_indexes[LOWER_STACK]];
		*immediate = (uint16_t) stack_pointer;

		selected_boot_code = boot_code_lower;
		selected_boot_code_size = boot_code_size[LOWER_STACK];
#if defined(DEBUG) 
		printf("\tBoot stack instr: 0x%08X\n", boot_code_lower[boot_adj_stack_indexes[LOWER_STACK]]);
#endif
	/*load stack pointer using data stored in rom*/
	} else {
		uint32_t* stack_data = &boot_code_higher[boot_adj_stack_indexes[HIGHER_STACK]];
		*stack_data = stack_pointer;

		selected_boot_code = boot_code_higher;
		selected_boot_code_size = boot_code_size[HIGHER_STACK];
#if defined(DEBUG) 
		printf("\tBoot stack will be loaded from ROM\n");
#endif                
	}

	/*now, we need to locate the main function and jump to it*/
#if defined(DEBUG) 
	printf("Adjusting entry point (main)...\n");
	printf("\tMain addr: 0x%08X\n", main_address);
#endif
	main_address >>=2;

	//main_address += selected_boot_code_size;
#if defined(DEBUG)           
	printf("\tCorrected main addr: 0x%08X\n", main_address);
#endif  
	uint32_t* jal_instr = &selected_boot_code[JAL_INDEX];

	if(main_address & ADDR_26_ERASE_MASK){
            assert(false && "Error: main address no reachable from boot code");
	}

	*jal_instr |= main_address;
#if defined(DEBUG) 
	printf("\tCorrected jal instr: 0x%08X\n", *jal_instr);
#endif
	memcpy(image, selected_boot_code, selected_boot_code_size*sizeof(uint32_t));

}

unsigned int linker::get_program_alignment(){
    //return 4*4;
    //cpu_info info;
    
    //return info.get_cache_block_size()*4;
    //return 4*4;
    return 16;
}

boot_instr_range* linker::get_boot_instr_range(uint32_t stack_pointer){
    
    boot_instr_range* boot_range = new boot_instr_range();
    
    if(stack_pointer < stack_frontier){
        boot_range->start_first_instr = start_boot_code_lower_fi;
        boot_range->start_last_instr  =start_boot_code_lower_li;
        
        boot_range->end_first_instr = end_boot_code_lower_fi;
        boot_range->end_last_instr  = end_boot_code_lower_li;        
    } else {
        boot_range->start_first_instr = start_boot_code_higher_fi;
        boot_range->start_last_instr  =start_boot_code_higher_li;
        
        boot_range->end_first_instr = end_boot_code_higher_fi;
        boot_range->end_last_instr  = end_boot_code_higher_li;          
    }
    
    return boot_range;
}

//(SCRATCHPAD_BEGIN + SCRATCHPAD_SIZE_BYTES - 4)
unsigned int linker::get_prefered_stack(){
   // cpu_info info;
    
    //return info.get_rom_size()*sizeof(uint32_t) + 
    //        info.get_ram_size()*sizeof(uint32_t) +
     //       info.get_scratchpad_size()*sizeof(uint32_t) - 4;
    return 0x40000100;
}