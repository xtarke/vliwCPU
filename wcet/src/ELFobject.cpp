/*
 * ELFobject.cpp
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#include "ELFobject.h"
#include <cassert>
#include <map>
#include <utility>  
#include <iomanip>

using namespace linker;

void string_tab::append(string_tab* other) {

    uint32_t old_size = get_size();
    uint32_t new_size = get_size() + other->get_size();

    char* new_tab = new char[new_size];
    memcpy(new_tab, tab, old_size);
    memcpy(&new_tab[old_size], other->get_tab(), other->get_size());

    delete tab;
    tab = new_tab;
    size = new_size;
}

ELF_object::ELF_object() {
    section_headers = NULL;
    program_headers = NULL;
    symbol_table = NULL;
    n_symbols = 0;
    relocs = NULL;
    n_relocs = 0;
}

ELF_object::ELF_object(const char* file_name) {

    Elf32_Shdr* header = NULL;

    assert(file_name);

    elf_file.open(file_name);

    if (!elf_file) {
        std::cerr << std::strerror(errno) << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }

    //reading elf header
    if (!elf_file.read((char*) &elf_header, sizeof (Elf32_Ehdr))) {
        std::cerr << std::strerror(errno) << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }

    unsigned char* mag = elf_header.e_ident;

    if (mag[EI_MAG0] != ELFMAG0 &&
            mag[EI_MAG1] != ELFMAG1 &&
            mag[EI_MAG2] != ELFMAG2 &&
            mag[EI_MAG3] != ELFMAG3) {
        std::cerr << "Error: invalid elf file!" << std::endl;
        exit(EXIT_FAILURE);
    }
    // our target do not have an official machine type, so we use EM_NONE instead
    if (elf_header.e_machine != EM_NONE) {
        std::cerr << "Error: invalid elf object!" << std::endl;
        exit(EXIT_FAILURE);
    }

    if (mag[EI_CLASS] != ELFCLASS32) {
        std::cerr << "Error: invalid elf class (expected 32 bits, but 64 found)!" << std::endl;
        exit(EXIT_FAILURE);
    }

    if (mag[EI_DATA] != ELFDATA2LSB) {
        std::cerr << "Error: invalid elf endianess (expected little endian)!" << std::endl;
        exit(EXIT_FAILURE);
    }

    // our target do not have an official machine type, so we use EM_NONE instead
    if (elf_header.e_machine != EM_NONE) {
        std::cerr << "Error: invalid elf object!" << std::endl;
        exit(EXIT_FAILURE);
    }

    //reading program headers
    program_headers = new Elf32_Phdr[elf_header.e_phnum];
    elf_file.seekg(elf_header.e_phoff);
    if (!elf_file.read((char*) program_headers, sizeof (Elf32_Phdr) * elf_header.e_phnum)) {
        // ok, most elfs dont hahe this
        std::cerr << "Reading program headers no found" << std::endl;
    }

    //reading section headers
    section_headers = new Elf32_Shdr[elf_header.e_shnum];
    elf_file.seekg(elf_header.e_shoff);
    if (!elf_file.read((char*) section_headers, sizeof (Elf32_Shdr) * elf_header.e_shnum)) {
        std::cerr << "Reading section headers" << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }


    //read table of sections name
    header = &section_headers[elf_header.e_shstrndx];
    shstrtab.set_size(header->sh_size);
    shstrtab.set_tab(new char[header->sh_size]);
    elf_file.seekg(header->sh_offset);
    if (!elf_file.read(shstrtab.get_tab(), header->sh_size)) {
        std::cerr << "Reading shstrtab" << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }
    // read syntab
    for (int i = 0; i < elf_header.e_shnum; i++) {
        header = &section_headers[i];
        if (strcmp(shstrtab.get_string(header->sh_name), ".symtab") == 0) {
            n_symbols = header->sh_size / sizeof (Elf32_Sym);
            symbol_table = (Elf32_Sym*) new char[header->sh_size];
            elf_file.seekg(header->sh_offset);
            if (!elf_file.read((char*) symbol_table, header->sh_size)) {
                std::cerr << "Reading .syntab" << std::endl;
                assert(false);
                exit(EXIT_FAILURE);
            }
            break;
        }
    }


    // reading .strtab
    for (int i = 0; i < elf_header.e_shnum; i++) {
        header = &section_headers[i];
        if (strcmp(shstrtab.get_string(header->sh_name), ".strtab") == 0) {
            strtab.set_size(header->sh_size);
            strtab.set_tab(new char[header->sh_size]);
            elf_file.seekg(header->sh_offset);
            if (!elf_file.read(strtab.get_tab(), header->sh_size)) {
                std::cerr << "Reading .strtab" << std::endl;
                assert(false);
                exit(EXIT_FAILURE);
            }
            break;
        }
    }

    //load text section
    load_section(".text", text_section, SHT_PROGBITS);
    assert(text_section.was_found());

    //load data section
    load_section(".data", data_section, SHT_PROGBITS);
    assert(data_section.was_found());

    //load rodata section
    load_section(".rodata", rodata_section, SHT_PROGBITS);
    //std::cout << ".rodata loaded size: " << get_rodata_section()->get_section_size() << "\n";

    //load rodata.cst4 section
    load_section(".rodata.cst4", rodata_cst4_section, SHT_PROGBITS);

    //load bbs section
    load_section(".bss", bss_section, SHT_NOBITS);

    // load rel.text section
    load_section(".rela.text", rel_text_section, SHT_RELA);
    //assert(rel_text_section.was_found());

    // load rel.rodata section, if any
    load_section(".rela.rodata", rel_rodata_section, SHT_RELA);
}

ELF_object::~ELF_object() {

    delete[] program_headers;
    delete[] section_headers;
    delete[] shstrtab.get_tab();
    delete[] strtab.get_tab();
    delete[] relocs;
}

void ELF_object::load_section(const char* section_name, ELF_section& section, unsigned type) {

    Elf32_Shdr* header = NULL;

    for (int i = 0; i < elf_header.e_shnum; i++) {
        header = &section_headers[i];
        if (strcmp(shstrtab.get_string(header->sh_name), section_name) == 0) {
            section.set_as_found();
            section.set_section(new unsigned char[header->sh_size]);
            section.set_section_size((uint32_t) header->sh_size);
            section.set_section_index(i);

            if (header->sh_type != type) {
                std::cerr << "Section: " << section_name << " has an incorrect type." << std::endl;
                exit(EXIT_FAILURE);
            }

            elf_file.seekg(header->sh_offset);
            if (!elf_file.read((char*) section.get_section(), header->sh_size)) {
                std::cerr << "Cannot read section:" << section_name << std::endl;
                assert(false);
                exit(EXIT_FAILURE);
            }
            break;
        }
    }
}

ELF_section* ELF_object::search_section(Elf32_Sym* sym) {

    if (sym->st_shndx == text_section.get_section_index()) {
        return &text_section;
    } else if (sym->st_shndx == data_section.get_section_index()) {
        return &data_section;
    } else if (sym->st_shndx == rodata_section.get_section_index()) {
        return &rodata_section;
    } else if (sym->st_shndx == bss_section.get_section_index()) {
        return &bss_section;
    } else if (sym->st_shndx == rodata_cst4_section.get_section_index()) {
        return &rodata_cst4_section;
    } else if (sym->st_shndx == internal_section.get_section_index()) {
        return &internal_section;
    } else {

        std::cerr << "Error section not found: " << sym->st_shndx << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }
}

uint32_t ELF_object::get_addr_Elf32_Sym(Elf32_Sym* sym) {

    //std::cout << "type: " << ELF32_ST_TYPE(sym->st_info) << "\n";

    if (ELF32_ST_TYPE(sym->st_info) == STT_NOTYPE) {
        std::cout << "Symbol " << get_string_from_strtab(sym->st_name) << " not found!\n";
        std::cout << "Cannot link! Missing Symbols!\n";
        exit(-1);
    }

    ELF_section* section = search_section(sym);
    //printf("0x%08x -- 0x%08x\n", sym->st_value, section->get_section_fpos());
    //puts(&strtab[sym->st_name]);
    //std::cout << "section fpos: " << section->get_section_fpos() << "\n";
    return sym->st_value + section->get_section_fpos();
}

uint32_t ELF_object::search_main_entry() {

    Elf32_Sym* symb;

    for (unsigned int i = 0; i < n_symbols; i++) {
        symb = &symbol_table[i];
        if (ELF32_ST_TYPE(symb->st_info) == STT_FUNC) {
            if (strcmp(strtab.get_string(symb->st_name), "main") == 0) {

                return get_addr_Elf32_Sym(symb);
            }
        }
    }
    return 0x1;
}

void ELF_object::append_object(ELF_object* obj) {

    uint32_t new_n_sym = n_symbols + obj->get_n_symbols();
    uint32_t old_n_sym = n_symbols;

    std::map<Elf32_Section, Elf32_Section> section_map;

    if (!symbol_table) {
        n_symbols = obj->n_symbols;
        symbol_table = new Elf32_Sym[n_symbols];
        memcpy(symbol_table, obj->symbol_table, sizeof (Elf32_Sym) * n_symbols);
    } else {
        n_symbols = new_n_sym;
        Elf32_Sym* new_symbol_table = new Elf32_Sym[new_n_sym];
        memcpy(new_symbol_table, symbol_table, sizeof (Elf32_Sym) * old_n_sym);
        memcpy(&new_symbol_table[old_n_sym], obj->symbol_table, sizeof (Elf32_Sym) * obj->n_symbols);
    }

    uint32_t new_text_size = get_text_section()->get_section_size() + obj->get_text_section()->get_section_size();
    uint32_t old_text_size = get_text_section()->get_section_size();

    // append text section
    get_text_section()->append(obj->get_text_section());
    section_map.insert(std::make_pair(obj->get_text_section()->get_section_index(),
            get_text_section()->get_section_index()));


    uint32_t new_data_size = get_data_section()->get_section_size() + obj->get_data_section()->get_section_size();
    uint32_t old_data_size = get_data_section()->get_section_size();

    //append data section
    get_data_section()->append(obj->get_data_section());
    section_map.insert(std::make_pair(obj->get_data_section()->get_section_index(),
            get_data_section()->get_section_index()));

    uint32_t new_rodata_size = get_rodata_section()->get_section_size() + obj->get_rodata_section()->get_section_size();
    uint32_t old_rodata_size = get_rodata_section()->get_section_size();

    //append rodata section
    get_rodata_section()->append(obj->get_rodata_section());
    section_map.insert(std::make_pair(obj->get_rodata_section()->get_section_index(),
            get_rodata_section()->get_section_index()));

    //std::cout << ".rodata final size: " << get_rodata_section()->get_section_size() << "\n";

    uint32_t new_rodata_cst4_size = get_rodata_cst4_section()->get_section_size() + obj->get_rodata_cst4_section()->get_section_size();
    uint32_t old_rodata_cst4_size = get_rodata_cst4_section()->get_section_size();

    //append rodata_cst4 section
    get_rodata_cst4_section()->append(obj->get_rodata_cst4_section());
    section_map.insert(std::make_pair(obj->get_rodata_cst4_section()->get_section_index(),
            get_rodata_cst4_section()->get_section_index()));

    uint32_t new_bss_size = get_bss_section()->get_section_size() + obj->get_bss_section()->get_section_size();
    uint32_t old_bss_size = get_bss_section()->get_section_size();

    //append bss section
    get_bss_section()->append(obj->get_bss_section());
    section_map.insert(std::make_pair(obj->get_bss_section()->get_section_index(),
            get_bss_section()->get_section_index()));

    uint32_t old_rel_text_size = get_rel_text_section()->get_section_size();
    uint32_t new_rel_text_size = get_rel_text_section()->get_section_size() +
            obj->get_rel_text_section()->get_section_size();

    // append rel.text section
    get_rel_text_section()->append(obj->get_rel_text_section());


    uint32_t old_rel_rodata_size = get_rel_rodata_section()->get_section_size();
    uint32_t new_rel_rodata_size = get_rel_rodata_section()->get_section_size() +
            obj->get_rel_rodata_section()->get_section_size();

    // append rel.rodata section, if any
    get_rel_rodata_section()->append(obj->get_rel_rodata_section());

    uint32_t old_shstrtab_size = shstrtab.get_size();

    // append shstrtab
    shstrtab.append(&obj->shstrtab);

    uint32_t old_strtab_size = strtab.size;

    // append strtab
    strtab.append(&obj->strtab);

    //fixup rel.text
    get_rel_text_section()->fixup_after_append(old_rel_text_size / sizeof (Elf32_Rel),
            old_text_size, old_n_sym);

    //fixup rel.rodata
    get_rel_rodata_section()->fixup_after_append(old_rel_rodata_size / sizeof (Elf32_Rel),
            old_text_size, old_n_sym);

    //fixup symbols
    for (int i = old_n_sym; i < new_n_sym; i++) {
        Elf32_Sym* sym = &symbol_table[i];
        uint32_t offset = 0;
        // fix name index in the strtab
        sym->st_info += old_strtab_size;

        std::map<Elf32_Section, Elf32_Section>::iterator IT;

        // update section index
        IT = section_map.find(sym->st_shndx);
        sym->st_shndx = IT->second;

        // fix st_value
        if (sym->st_shndx == text_section.get_section_index()) {
            offset = old_text_size;
        } else if (sym->st_shndx == data_section.get_section_index()) {
            offset = old_data_size;
        } else if (sym->st_shndx == rodata_section.get_section_index()) {
            offset = old_rodata_size;
        } else if (sym->st_shndx == bss_section.get_section_index()) {
            offset = old_bss_size;
        } else if (sym->st_shndx == rodata_cst4_section.get_section_index()) {
            offset = old_rodata_cst4_size;
        }
        sym->st_value += offset;
    }
    //std::cout << ".rodata final size2: " << get_rodata_section()->get_section_size() << "\n";
}

uint32_t ELF_object::calculate_size() {
    uint32_t size = 0;

    size += get_text_section()->get_section_size();
    size += get_data_section()->get_section_size();
    size += get_rodata_section()->get_section_size();
    size += get_rodata_cst4_section()->get_section_size();
    size += get_bss_section()->get_section_size();

    return size;
}

uint32_t ELF_object::calculate_data_size() {
    uint32_t size = 0;

    size += get_data_section()->get_section_size();
    size += get_rodata_section()->get_section_size();
    size += get_rodata_cst4_section()->get_section_size();
    size += get_bss_section()->get_section_size();

    return size;
}

void ELF_object::dump_functions(const char* filename) {

    Elf32_Sym* sym_tab = get_symbol_table();
    int n_symbols = get_n_symbols();
    std::ofstream func_file;
    int space = 30;
    
    func_file.open(filename);
    func_file << "[Function]\t\t[Dec. addr.]\t[Hexa. addr.]\n";

    for (int i = 0; i < n_symbols; i++) {

        Elf32_Sym* sym = &sym_tab[i];

        uint32_t type = ELF32_ST_TYPE(sym->st_info);
        if (type == STT_FUNC) {
            int strtab_index = sym->st_name;
            char* name = get_string_from_strtab(strtab_index);
            uint32_t addr = get_addr_Elf32_Sym(sym);
            int spaces = space = strlen(name);
            func_file << name << "\t\t";
            func_file << std::dec << addr << "\t0x" << std::setfill('0') << std::setw(8) << std::hex  << addr << "\n";
        }
    }
}