/*
 * boot.h
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#ifndef BOOT_H_
#define BOOT_H_

//#define PREFERED_STACK (SCRATCHPAD_BEGIN + SCRATCHPAD_SIZE_BYTES - 4)


namespace linker {

    typedef struct boot_instr_range {
        // start code
        uint32_t start_first_instr;
        uint32_t start_last_instr;
        //halt code
        uint32_t end_first_instr;
        uint32_t end_last_instr;
    } boot_instr_range;


    extern unsigned int get_prefered_stack();
    extern unsigned int get_boot_code_size(uint32_t stack);
    extern unsigned int get_program_alignment();
    extern void write_boot_code(unsigned char* image, uint32_t entry, uint32_t stack);
    extern boot_instr_range* get_boot_instr_range(uint32_t stack);

} /* namespace linker */
#endif /* BOOT_H_ */
