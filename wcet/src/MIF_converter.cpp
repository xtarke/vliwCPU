/* 
 * File:   MIF_converter.cpp
 * Author: andreu
 * 
 * Created on 15 de Julho de 2014, 15:54
 */

#include "MIF_converter.h"
#include "Configs.h"
#include <iostream>
#include <fstream>
#include <iomanip>
#include <assert.h>
#include "ELFobject.h"
#include "ELFlinker.h"

MIF_converter::MIF_converter(linker::ELF_object* obj) {
    object = obj;
    
}

MIF_converter::MIF_converter(const MIF_converter& orig) {
}

MIF_converter::~MIF_converter() {
}

static void write_section(uint32_t& index, std::ofstream& mif_file, uint32_t* buffer, uint32_t size) {



    for (int i = 0; i < size; i++) {
        mif_file << "" << std::dec << index << "\t" << ":" << "\t"
                << std::hex
                << std::setw(8) << std::setfill('0')
                << std::uppercase
                << buffer[i] << ";\n";

        //     std::cout << "" << std::hex
        // << std::setw(8) << std::setfill('0')
        // << std::uppercase
        // << buffer[i] << ";\n";

        index++;
    }
}

void MIF_converter::dump_to_file(const char* filename) {

    std::ofstream mif_file;
    uint32_t memory_size;
    uint32_t* buffer;
    uint32_t size;
    uint32_t total_size = 0;


    mif_file.open(filename);
    memory_size = object->calculate_size() / sizeof (uint32_t);

    mif_file << "WIDTH = 32;\n";
    mif_file << "DEPTH = " << ROM_WORDS << ";\n\n";

    mif_file << "ADDRESS_RADIX=UNS;\n";
    mif_file << "DATA_RADIX=HEX;\n\n";

    mif_file << "CONTENT BEGIN\n";



    //write text section
    size = object->get_text_section()->get_section_size() / sizeof (uint32_t);
    buffer = (uint32_t*) object->get_text_section()->get_section();
    write_section(total_size, mif_file, buffer, size);
    
    //write internal section
    size = object->get_internal_section()->get_section_size() / sizeof (uint32_t);
    buffer = (uint32_t*) object->get_internal_section()->get_section();
    write_section(total_size, mif_file, buffer, size);

    //printf("rodata %d \n", object->get_rodata_section()->get_section_size());

    //write rodata section (if present)
    if (object->get_rodata_section()->was_found()) {
        size = object->get_rodata_section()->get_section_size() / sizeof (uint32_t);
        buffer = (uint32_t*) object->get_rodata_section()->get_section();
        write_section(total_size, mif_file, buffer, size);
    }

    //printf("rodata_cst4 %d \n", object->get_rodata_cst4_section()->get_section_size());

    //write rodata cst4 section (if present)
    if (object->get_rodata_cst4_section()->was_found()) {
        size = object->get_rodata_cst4_section()->get_section_size() / sizeof (uint32_t);
        buffer = (uint32_t*) object->get_rodata_cst4_section()->get_section();
        write_section(total_size, mif_file, buffer, size);
    }

    //printf("data %d \n", object->get_data_section()->get_section_size());

    //write data section
    size = object->get_data_section()->get_section_size() / sizeof (uint32_t);
    buffer = (uint32_t*) object->get_data_section()->get_section();
    write_section(total_size, mif_file, buffer, size);

    if (INITIALIZE_BSS) {
        //write bss section (if present)
        if (object->get_bss_section()->was_found()) {
            size = object->get_bss_section()->get_section_size() / sizeof (uint32_t);
            buffer = (uint32_t*) object->get_bss_section()->get_section();
            write_section(total_size, mif_file, buffer, size);
        }
    }

    //printf("bss %d \n", object->get_bss_section()->get_section_size());

    if (total_size > ROM_WORDS - 1) {
        printf("Binary program exceeds the available ROM\n");
        exit(EXIT_FAILURE);
    }

    mif_file << "[" << std::dec << total_size << ".." << ROM_WORDS - 1 << "]\t:\tFFFFFFFF;\n";

    mif_file << "END;\n";
}

void MIF_converter::dump_data_to_file(const char* filename) {

    std::ofstream mif_file;
    uint32_t memory_size;
    uint32_t* buffer;
    uint32_t size;
    uint32_t total_size = 0;


    mif_file.open(filename);
    memory_size = object->calculate_data_size() / sizeof (uint32_t);

    mif_file << "WIDTH = 32;\n";
    mif_file << "DEPTH = " << SCRATCHPAD_WORDS << ";\n\n";

    mif_file << "ADDRESS_RADIX=UNS;\n";
    mif_file << "DATA_RADIX=HEX;\n\n";

    mif_file << "CONTENT BEGIN\n";

    //printf("rodata %d \n", object->get_rodata_section()->get_section_size());

    //write rodata section (if present)
    if (object->get_rodata_section()->was_found()) {
        size = object->get_rodata_section()->get_section_size() / sizeof (uint32_t);
        buffer = (uint32_t*) object->get_rodata_section()->get_section();
        write_section(total_size, mif_file, buffer, size);
        //std::cout << "rodata: " << object->get_rodata_section()->get_section_size() << "\n";
    }

    //printf("rodata_cst4 %d \n", object->get_rodata_cst4_section()->get_section_size());

    //write rodata cst4 section (if present)
    if (object->get_rodata_cst4_section()->was_found()) {
        size = object->get_rodata_cst4_section()->get_section_size() / sizeof (uint32_t);
        buffer = (uint32_t*) object->get_rodata_cst4_section()->get_section();
        write_section(total_size, mif_file, buffer, size);
        //std::cout << "rodata2: " << object->get_rodata_cst4_section()->get_section_size() << "\n";
    }

    //printf("data %d \n", object->get_data_section()->get_section_size());

    //write data section
    size = object->get_data_section()->get_section_size() / sizeof (uint32_t);
    buffer = (uint32_t*) object->get_data_section()->get_section();
    write_section(total_size, mif_file, buffer, size);
    //std::cout << "data: " << object->get_data_section()->get_section_size() << "\n";

    if (INITIALIZE_BSS) {
        //write bss section (if present)
        if (object->get_bss_section()->was_found()) {
            size = object->get_bss_section()->get_section_size() / sizeof (uint32_t);
            buffer = (uint32_t*) object->get_bss_section()->get_section();
            write_section(total_size, mif_file, buffer, size);
        }
    }

    //std::cout << ">>>>>>>> " << total_size << "\n";
    //printf("bss %d \n", object->get_bss_section()->get_section_size());

    if (total_size > ROM_WORDS - 1) {
        printf("Binary program exceeds the available ROM(%d), need: %d\n", ROM_WORDS - 1, total_size);
        exit(EXIT_FAILURE);
    }

    mif_file << "[" << std::dec << total_size << ".." << SCRATCHPAD_WORDS - 1 << "]\t:\t00000000;\n";

    mif_file << "END;\n";
    
    
    if (memory_size > SCRATCHPAD_WORDS - 1) {
        printf("Data memory exceeds the available SP_RAM(%d), need: %d\n", SCRATCHPAD_WORDS - 1, memory_size);
        //exit(EXIT_FAILURE);
    }
     
    //std::cout << "ROM is:" << total_size << " words" << "\n";
    //std::cout << "SPRAM is:" << memory_size << " words" << "\n";
     
    
    //exit(-1);
    
    //if(memory_size > SPRAM){
    //    while(1);
    //}
}