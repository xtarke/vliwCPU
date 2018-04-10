/*
 * ELFobject.h
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#ifndef ELFOBJECT_H_
#define ELFOBJECT_H_

#include <iostream>
#include <fstream>
#include <cerrno>
#include <string>
#include <cstring>
#include <cstdlib>
#include "ELFsection.h"

namespace linker {

    struct string_tab {
        char* tab = NULL;
        uint32_t size = 0;

        void append(string_tab* other);

        void set_size(uint32_t size_) {
            size = size_;
        };

        uint32_t get_size() {
            return size;
        };

        char* get_string(uint32_t index) {
            return &tab[index];
        };

        char* get_tab() {
            return tab;
        };

        void set_tab(char* tab_) {
            tab = tab_;
        };
    };

    class ELF_object {
    private:
        std::ifstream elf_file;
        //headers
        Elf32_Ehdr elf_header;
        Elf32_Shdr* section_headers;
        Elf32_Phdr* program_headers;

        //symbol table
        Elf32_Sym* symbol_table;
        uint32_t n_symbols;

        //strings of symbols and sections
        //char* shstrtab;
        ///har* strtab;
        string_tab shstrtab;
        string_tab strtab;

        //text section
        ELF_section text_section;

        //internal section
        ELF_section internal_section;

        //data section
        ELF_section data_section;

        //rodata section
        ELF_section rodata_section;

        //bss section
        ELF_section bss_section;

        //rodata.cst4 section
        ELF_section rodata_cst4_section;

        //relocation records
        Elf32_Rela* relocs;
        uint32_t n_relocs;

        //relocations of text section
        ELF_section_relocation rel_text_section;

        //relocation of rodata section
        ELF_section_relocation rel_rodata_section;

    public:
        ELF_object(const char* file_name);
        ELF_object();
        ~ELF_object();

        void load_section(const char* section_name, ELF_section& section, unsigned type);
        ELF_section* search_section(Elf32_Sym* sym);
        uint32_t search_main_entry();
        uint32_t get_addr_Elf32_Sym(Elf32_Sym* sym);

        Elf32_Sym* get_symbol_table() {
            return symbol_table;
        }

        uint32_t get_n_symbols() {
            return n_symbols;
        }

        ELF_section* get_text_section() {
            return &text_section;
        }

        ELF_section* get_internal_section() {
            return &internal_section;
        }

        ELF_section* get_data_section() {
            return &data_section;
        }

        ELF_section* get_rodata_section() {
            return &rodata_section;
        }

        ELF_section* get_rodata_cst4_section() {
            return &rodata_cst4_section;
        }

        ELF_section* get_bss_section() {
            return &bss_section;
        }

        ELF_section_relocation* get_rel_text_section() {
            return &rel_text_section;
        }

        ELF_section_relocation* get_rel_rodata_section() {
            return &rel_rodata_section;
        }

        char* get_string_from_strtab(int index) {
            return strtab.get_string(index);
        }
        
        void dump_functions(const char* filename);

        void append_object(ELF_object* obj);

        uint32_t calculate_size();

        uint32_t calculate_data_size();

        //Elf32_Rel* get_relocs() {
        //    return relocs;
        //}

        //uint32_t get_n_relocs() {
        //    return n_relocs;
        //}
    };

} /* namespace linker */
#endif /* ELFOBJECT_H_ */
