/*
 * ELFlinker.cpp
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#include "ELFlinker.h"
#include "ELFobject.h"
#include "Configs.h"
#include "lpsolve/lp_lib.h"
#include <cassert>

struct LDF {
    const char* name;
    uint32_t* value_ptr;
};

static struct LDF LDF_definitions[] = {
    {"LNK_start_data_before", 0},
    {"LNK_start_data_after", 0},
    {"LNK_size_data", 0},
    {"LNK_stack_pointer_addr", 0}
};

using namespace linker;

static void fixup_R_32(uint32_t* inst, uint32_t value, int32_t addend) {

    //std::cout << "[value_r32]: " << (std::dec) << *inst << "\n";

    //std::cout << "========fixup_R_32\n";
    uint32_t addr;

    addr = *inst + value + addend;
    // workaroud to to map bytes into words
    *inst = addr >> 2;
}

static void fixup_R_PC23CALL(uint32_t* inst, uint32_t instr_addr, uint32_t value) {

    int32_t offset = INST_ADDR_IMM(*inst);
    int32_t new_inst_addr = instr_addr >> 2;
    int32_t new_value = (value >> 2);
    //uint32_t relative_addr = new_value - new_inst_addr - offset;	// old CPU fetch version
    uint32_t relative_addr = new_value - new_inst_addr;

    //std::cout << "relative addr: " << relative_addr << "\n";
    //std::cout << "offset: " << offset << "\n";
    //std::cout << "addr: " << new_inst_addr << "\n";
    //std::cout << "value: " << value << "\n";

    //std::cout << "[value]: " << value << "\n";

    uint32_t new_inst = (INST_CLEAR_ADDR(*inst) | INST_ADDR_IMM(relative_addr));

    *inst = new_inst;
}

static void fixup_R_IMM9(uint32_t* inst, uint32_t value, int32_t addend) {

    value += addend;
    
    uint32_t value9 = GET_IMM9(value);

    uint32_t new_inst = (*inst | INST_IMM(value9));

    //std::cout << "[value9]: " << value << "\n";

    *inst |= new_inst;

}

static void fixup_R_IMM23(uint32_t* inst, uint32_t value, int32_t addend) {
    
    value += addend;

    uint32_t value23 = GET_IMM23(value);
    uint32_t new_inst = (*inst | INST_IMMEXT(value23));

    //std::cout << "[value23]: " << value << "\n";
    
    *inst |= new_inst;
}

void fixup(int type, uint32_t* inst, uint32_t instr_addr, uint32_t value, int32_t addend) {

    //printf("Fixing value 0x%x\n", value);

    switch (type) {
        case R_PC23GOTO:
            break;
        case R_PC23CALL:
            fixup_R_PC23CALL(inst, instr_addr, value);
            break;
        case R_IMM9:
            fixup_R_IMM9(inst, value, addend);
            break;
        case R_IMM23:
            fixup_R_IMM23(inst, value, addend);
            break;
        case R_32:
            fixup_R_32(inst, value, addend);
            break;
        case R_PC23PRELOAD:
            break;

        default:
            printf("Unknown reloc type\n");
            assert(false);
            //exit(-1);
            break;
    }
}

ELF_linker::ELF_linker(ELF_object* object, uint32_t initial_offset_) {
    source_object = object;
    target_object = new ELF_object();
    target_object->append_object(object);
    initial_offset = initial_offset_;
    //source_object = new ELF_object();
}

/*
 * Layout taht linker imposes:
 * ----------------------------------
 * text section
 * ----------------------------------
 * rodata section (if present)
 * ----------------------------------
 * rodata cst4 section (if present)
 * ----------------------------------
 * data section
 * ----------------------------------
 * bss section (if present)
 * ----------------------------------
 */

void ELF_linker::define_section_addresses(uint32_t initial_offset) {

    uint32_t next_pos;
    bool failure = false;

    //=============================================================
    //
    // =================== General Text Section ===================
    //
    //=============================================================

    //target_object->get_text_section()->set_section_fpos(get_rom_begin() + initial_offset);
    target_object->get_text_section()->set_section_fpos(0);

    //std::cout << "Text start: " << target_object->get_text_section()->get_section_fpos();
    //std::cout << "\nText end: " << target_object->get_text_section()->get_section_fpos() +
    //        target_object->get_text_section()->get_section_size() << "\n";

    next_pos = target_object->get_text_section()->get_section_fpos() +
            target_object->get_text_section()->get_section_size();
    
    
    target_object->get_internal_section()->set_section_fpos(next_pos);
    next_pos += target_object->get_internal_section()->get_section_size();


    uint32_t general_text_size = 0;
    general_text_size += target_object->get_text_section()->get_section_size() +
            target_object->get_internal_section()->get_section_size();

    if (general_text_size > get_rom_size_bytes()) {
        std::cerr << "Error: No Enough space in image to support all text section\n";
        std::cerr << "\ttext section words: " <<
                (target_object->get_text_section()->get_section_size() + initial_offset) / 4 << "\n";
        std::cerr << "\trodata.cst4 section words: " <<
                (target_object->get_rodata_cst4_section()->get_section_size()) / 4 << "\n";
        std::cerr << "\tROM total words: " << get_rom_size_bytes() / 4 << "\n";

        //exit(EXIT_FAILURE);
        failure = true;
    }

    //=============================================================
    //
    // =================== General Data Section ===================
    //
    //=============================================================

    next_pos = get_ram_begin();

    // rodata section comes after data section
    if (target_object->get_rodata_section()->was_found()) {
        target_object->get_rodata_section()->set_section_fpos(next_pos);

        next_pos += target_object->get_rodata_section()->get_section_size();

        //std::cout << "Rodata start: " << (std::hex) << target_object->get_rodata_section()->get_section_fpos();
        // std::cout << "\nRodata end: " << target_object->get_rodata_section()->get_section_fpos() +
        //        target_object->get_rodata_section()->get_section_size() << "\n";
    }

    if (target_object->get_rodata_cst4_section()->was_found()) {

        target_object->get_rodata_cst4_section()->set_section_fpos(next_pos);
        next_pos += target_object->get_rodata_cst4_section()->get_section_size();
        //std::cout << "Rodata1 start: " << target_object->get_rodata_cst4_section()->get_section_fpos();
        // std::cout << "\nRodata end: " << target_object->get_rodata_cst4_section()->get_section_fpos() +
        //        target_object->get_rodata_cst4_section()->get_section_size() << "\n";

    }

    target_object->get_data_section()->set_section_fpos(next_pos);

    //std::cout << "Data start: " << target_object->get_data_section()->get_section_fpos();
    //std::cout << "\nData end: " << target_object->get_data_section()->get_section_fpos() +
    //        target_object->get_data_section()->get_section_size() << "\n";

    next_pos += target_object->get_data_section()->get_section_size();

    // bss section comes after data section
    if (target_object->get_bss_section()->was_found()) {
        target_object->get_bss_section()->set_section_fpos(next_pos);

        next_pos += target_object->get_bss_section()->get_section_size();
    }

    uint32_t general_data_size = 0;

    general_data_size += target_object->get_data_section()->get_section_size();
    general_data_size += target_object->get_bss_section()->get_section_size();

    if (general_data_size > get_ram_size_bytes()) {

        std::cerr << "Error: No Enough space in image to support all data sections\n";
        std::cerr << "\tdata section words: " <<
                target_object->get_data_section()->get_section_size() / 4 << "\n";
        std::cerr << "\trodata section words: " <<
                target_object->get_rodata_section()->get_section_size() / 4 << "\n";
        std::cerr << "\tbss section words: " <<
                target_object->get_bss_section()->get_section_size() / 4 << "\n";
        std::cerr << "\tRAM total words: " << get_ram_size_bytes() / 4 << "\n";

        //exit(EXIT_FAILURE);
        failure = true;
    }

    if (failure) {
        exit(EXIT_FAILURE);
    }
}

void ELF_linker::resolve_relocs() {

    Elf32_Rela* relocs;
    unsigned int n_relocs;
    uint32_t* section_ptr;

    // text data is obrigatory
    assert(target_object->get_text_section()->was_found());

    // text relocs
    relocs = target_object->get_rel_text_section()->get_relocs();
    n_relocs = target_object->get_rel_text_section()->get_n_relocs();
    section_ptr = (uint32_t*) target_object->get_text_section()->get_section();
    resolve_relocs_helper(relocs, n_relocs, target_object->get_text_section());

    // reloc rodata section, if any
    if (target_object->get_rel_rodata_section()->was_found()) {
        relocs = target_object->get_rel_rodata_section()->get_relocs();
        n_relocs = target_object->get_rel_rodata_section()->get_n_relocs();
        section_ptr = (uint32_t*) target_object->get_rodata_section()->get_section();
        resolve_relocs_helper(relocs, n_relocs, target_object->get_rodata_section());
    }

}

void ELF_linker::resolve_relocs_helper(Elf32_Rela* relocs,
        unsigned int n_relocs,
        ELF_section* section) {

    uint32_t* section_ptr;
    uint32_t section_size = section->get_section_size();
    section_ptr = (uint32_t*) section->get_section();
    for (unsigned int i = 0; i < n_relocs; i++) {

        //puts("");
        Elf32_Rela* reloc = &relocs[i];
        //std::cout << "simbolo: " << ELF32_R_SYM(reloc->r_info) << "\n";
        Elf32_Sym* sym = &target_object->get_symbol_table()[ELF32_R_SYM(reloc->r_info)];
        uint32_t addr = target_object->get_addr_Elf32_Sym(sym);
        unsigned int type = ELF32_R_TYPE(reloc->r_info);
        //std::cout << "Addr: " << addr << "\n";
        //std::cout << "Name: " << target_object->get_string_from_strtab(sym->st_name) << "\n";
        //std::cout << "Offset: " << reloc->r_offset << "\n";
        //std::cout << "Value: " << sym->st_value << "\n";
        //std::cout << "Pointer: " << sym << "\n";
        assert(reloc->r_offset < section_size);
        fixup(type,
                &section_ptr[reloc->r_offset / sizeof (uint32_t)],
                reloc->r_offset + section->get_section_fpos(),
                addr, reloc->r_addend);
    }
}

void ELF_linker::link() {

    pre_process_ldf_vars();
    pre_process_bss();
    define_section_addresses(initial_offset);
    post_process_ldf_vars();
    resolve_relocs();
}

uint32_t ELF_linker::get_image_size() {
    //return obj->data_section.section_size + obj->text_section.section_size;
    return get_rom_size_bytes() + get_ram_size_bytes();
}

uint8_t* ELF_linker::convert_object_to_image() {

    uint8_t* image = NULL;
    uint32_t size_image = get_image_size();

    image = (uint8_t*) calloc(size_image, 1);

    if (!image) {
        perror("Final image allocation");
    }

    /*copy text section*/
    memcpy(&image[target_object->get_text_section()->get_section_fpos()],
            target_object->get_text_section()->get_section(),
            target_object->get_text_section()->get_section_size());

    /*copy rodata section*/
    if (target_object->get_rodata_section()->was_found()) {
        memcpy(&image[target_object->get_rodata_section()->get_section_fpos()],
                target_object->get_rodata_section()->get_section(),
                target_object->get_rodata_section()->get_section_size());
    }

    /*copy rodata.cst4 section*/
    if (target_object->get_rodata_cst4_section()->was_found()) {
        memcpy(&image[target_object->get_rodata_cst4_section()->get_section_fpos()],
                target_object->get_rodata_cst4_section()->get_section(),
                target_object->get_rodata_cst4_section()->get_section_size());
    }

    /*copy data section*/
    if (target_object->get_data_section()->was_found()) {
        memcpy(&image[target_object->get_data_section()->get_section_fpos()],
                target_object->get_data_section()->get_section(),
                target_object->get_data_section()->get_section_size());
    }

    /*copy bss section*/
    if (target_object->get_bss_section()->was_found()) {
        memcpy(&image[target_object->get_bss_section()->get_section_fpos()],
                target_object->get_bss_section()->get_section(),
                target_object->get_bss_section()->get_section_size());
    }


    return image;
}

uint32_t ELF_linker::search_main_entry() {
    return target_object->search_main_entry();
}

void ELF_linker::pre_process_bss() {
    Elf32_Sym* symbol_table;
    uint32_t n_symbols;
    ELF_section* bss_section;
    uint32_t bss_final_size = 0;

    symbol_table = target_object->get_symbol_table();
    n_symbols = target_object->get_n_symbols();
    bss_section = target_object->get_bss_section();

    bss_final_size = bss_section->get_section_size();
    // std::cout << "bss size: " << bss_section->get_section_index() << "\n";

    for (int i = 0; i < n_symbols; i++) {
        Elf32_Sym* sym = &symbol_table[i];
        char* symbol_name;

        symbol_name = target_object->get_string_from_strtab(sym->st_name);

        //puts(symbol_name);

        //std::cout << "section: " << sym->st_shndx << "\n";

        if (sym->st_shndx == SHN_COMMON || (sym->st_shndx == SHN_UNDEF && ELF32_ST_TYPE(sym->st_info) == STT_OBJECT)) {

            symbol_name = target_object->get_string_from_strtab(sym->st_name);

            //puts(symbol_name);

            //std::cout << "value: " << sym->st_value << "\n";
            //std::cout << "size: " << sym->st_size << "\n";
            
            
            uint32_t rounded_size = sym->st_value;
            
            while((rounded_size % 4) != 0){
                rounded_size+=1;
            }
            

            while ((bss_final_size % rounded_size) != 0) {
                bss_final_size += 4;
            }

            
            sym->st_value = bss_final_size;
            sym->st_shndx = bss_section->get_section_index();


            bss_final_size += rounded_size;
            
        } else if (sym->st_shndx == bss_section->get_section_index() &&
                ELF32_ST_TYPE(sym->st_info) != STT_SECTION) {
            symbol_name = target_object->get_string_from_strtab(sym->st_name);

            //puts(symbol_name);

            sym->st_value = bss_final_size;
            sym->st_shndx = bss_section->get_section_index();

            bss_final_size += sym->st_size;
        }


    }

    uint8_t* data = bss_section->get_section();

    if (data) {
        delete[] data;
    }

    bss_section->set_section_size(bss_final_size);
    bss_section->set_section(new uint8_t[bss_final_size]);
    memset(bss_section->get_section(), 0, bss_final_size * sizeof (uint8_t));

    //std::cout << "Bss final size: " << bss_final_size << "\n";

    //assert(false && "Done");
}

/*
void ELF_linker::write_text_section_to_mif(const char* filename){
    
    std::ofstream mif_file;
   
    mif_file.open(filename);
    
    if (!mif_file) {
        std::cerr << std::strerror(errno) << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }
    
    mif_file << "DEPTH = 1024;\n";
    mif_file << "WIDTH  = 32;\n";
}
 */

ELF_object* ELF_linker::get_result() {
    return target_object;
}

// find data that must be defined by the linker, and put it on rodata section

void ELF_linker::pre_process_ldf_vars() {
    Elf32_Sym* symbol_table;
    uint32_t n_symbols;
    ELF_section* internal_section;
    uint32_t index;
    uint8_t* section_buffer;

    symbol_table = target_object->get_symbol_table();
    n_symbols = target_object->get_n_symbols();

    /*
    rodata_section = target_object->get_rodata_section();

    if (!rodata_section->was_found()) {
        //puts("rodata não encontrada");
        rodata_section->set_section(new uint8_t[4 * sizeof (uint32_t)]);
        rodata_section->set_as_found();
        rodata_section->set_section_size(4 * sizeof (uint32_t));
        rodata_section->set_section_index(10);
        index = 0;
    } else {
        //puts("rodata encontrada");
        index = rodata_section->get_section_size();
        rodata_section->expand(sizeof (LDF_definitions)/sizeof(LDF) * sizeof (uint32_t));
    }

    section_buffer = rodata_section->get_section();
     */
    
    internal_section = target_object->get_internal_section();

    internal_section->set_section(new uint8_t[4 * sizeof (uint32_t)]);
    internal_section->set_as_found();
    internal_section->set_section_size(4 * sizeof (uint32_t));
    internal_section->set_section_index(10);
    
    section_buffer = internal_section->get_section();
    
    index = 0;
    
    for (int i = 0; i < n_symbols; i++) {
        Elf32_Sym* sym = &symbol_table[i];
        char* symbol_name;

        symbol_name = target_object->get_string_from_strtab(sym->st_name);

        //puts(symbol_name);

        if (sym->st_shndx == SHN_UNDEF) {

            // ok, we found a ldf symbol
            if (strncmp(symbol_name, "LNK", 3) == 0) {

                for (int i = 0; i < 4; i++) {
                    struct LDF* ldf = &LDF_definitions[i];
                    //puts(ldf->name);
                    if (strcmp(ldf->name, symbol_name) == 0) {

                        sym->st_shndx = internal_section->get_section_index();
                        sym->st_value = index;

                        ldf->value_ptr = (uint32_t*) & section_buffer[index];
                        //std::cout << "INDEX: " << index << "\n";

                        //printf("variavel: %s, pos %d, ponteiro ajuste %p\n",
                        //        symbol_name, index, ldf->value_ptr);

                        index += sizeof (uint32_t);
                        break;
                    }
                }
            }
        }
    }

    //std::cout << "Bss final size: " << bss_final_size << "\n";

    //assert(false && "Done");    

}

void ELF_linker::post_process_ldf_vars() {


    for (int i = 0; i < 4; i++) {
        struct LDF* ldf = &LDF_definitions[i];
        //puts(ldf->name);
        
        // this ldf var was not found in the target object
        if(ldf->value_ptr == NULL){
            continue;
        }

        if (strcmp(ldf->name, "LNK_start_data_before") == 0) {

            // data adderss before copy
            
            *ldf->value_ptr = target_object->get_text_section()->get_section_size() +
                    target_object->get_internal_section()->get_section_size() +
                    target_object->get_rodata_section()->get_section_size() +
                    target_object->get_rodata_cst4_section()->get_section_size();


        } else if (strcmp(ldf->name, "LNK_start_data_after") == 0) {

            *ldf->value_ptr = target_object->get_data_section()->get_section_fpos();

        } else if (strcmp(ldf->name, "LNK_size_data") == 0) {

            *ldf->value_ptr = target_object->get_data_section()->get_section_size();
            if (INITIALIZE_BSS) {
                *ldf->value_ptr += target_object->get_bss_section()->get_section_size();
            }

            if (target_object->get_rodata_section()->was_found()) {
                *ldf->value_ptr += target_object->get_rodata_section()->get_section_size();
            }

            if (target_object->get_rodata_cst4_section()->was_found()) {
                *ldf->value_ptr += target_object->get_rodata_cst4_section()->get_section_size();
            }

        } else if (strcmp(ldf->name, "LNK_stack_pointer_addr") == 0) {

            *ldf->value_ptr = get_scratchpad_begin() + get_ram_scratchpad_bytes();

        }
    }
}