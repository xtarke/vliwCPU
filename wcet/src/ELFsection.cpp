/*
 * ELFsection.cpp
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#include "ELFsection.h"
#include <iostream>
#include <cstring>

using namespace linker;

uint32_t ELF_section::get_word(unsigned int index) {
    uint32_t* sec_data = (uint32_t*) (section);
    uint32_t position = index - (section_fpos / sizeof (uint32_t));

    return sec_data[position];
}

void ELF_section::append(ELF_section* other_section) {


    uint32_t new_sec_size = get_section_size() + other_section->get_section_size();
    uint32_t old_sec_size = get_section_size();


    // copy text section
    if (!get_section() && other_section->was_found()) {
        set_as_found();
        set_section(new unsigned char[other_section->get_section_size()]);
        set_section_size(other_section->get_section_size());
        set_section_index(other_section->get_section_index());
        memcpy(get_section(), other_section->get_section(), other_section->get_section_size());
    } else if (other_section->was_found()) {
        uint8_t* new_section = new uint8_t[new_sec_size];
        memcpy(new_section, get_section(), old_sec_size);
        memcpy(&new_section[old_sec_size], other_section->get_section(), old_sec_size);
        set_section_size(new_sec_size);
        delete get_section();
        set_section(new_section);
    }
}

void ELF_section::expand(uint32_t amount) {
    uint32_t new_sec_size = get_section_size() + amount;
    uint32_t old_sec_size = get_section_size();

    uint8_t* new_section = new uint8_t[new_sec_size];
    memcpy(new_section, get_section(), old_sec_size);
    set_section_size(new_sec_size);
    delete[] get_section();
    set_section(new_section);
}

void ELF_section_relocation::fixup_after_append(uint32_t start_reloc, uint32_t sec_shift, uint32_t st_shift) {

    int n_relocs = get_n_relocs();
    Elf32_Rela* relocs = get_relocs();

    for (int i = start_reloc; i < n_relocs; i++) {

        Elf32_Rela* reloc = &relocs[i];

        //fixup symbol
        uint32_t sym = ELF32_R_SYM(reloc->r_info) + st_shift;
        uint32_t type = ELF32_R_TYPE(reloc->r_info);
        reloc->r_info = ELF32_R_INFO(sym, type);

        // fixup offset
        reloc->r_offset += sec_shift;
    }
}