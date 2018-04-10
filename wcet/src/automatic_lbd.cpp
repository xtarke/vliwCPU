/* 
 * File:   automatic_lbd.cpp
 * Author: andreu
 * 
 * Created on 22 de Outubro de 2014, 12:48
 */

#include <algorithm>

#include "automatic_lbd.h"
#include "logger.h"

#include "simplelbd.h"

automatic_lbd::~automatic_lbd() {

}

void automatic_lbd::analyze_loops() {

    vector<loop*>* loops = program_cfg->get_loops();
    vector<loop*>::const_iterator IT;
    for (IT = loops->begin(); IT != loops->end(); IT++) {
        loop* actual_loop = *IT;
        int bound;
        
        basic_block* bb = actual_loop->root;

        bound = bb->get_raw_loop_bound();

        if (bound == ~0) {
            std::cout << "id: " << bb->get_id() << "\n"; 
            std::cout << "Undefined loop bound dor BB " << bb->get_id() << " define it: ";
            puts("aqui");
            scanf("%d", &bound);
        } else if(bound == 0xCACACACA){
            //scanf("%d", &bound);
            bound = object->calculate_data_size() / sizeof (uint32_t);
//             std::cout << "load_data_to_ram loop bound calculated: " << bound << "\n";
        } else {
            bound -= 1; // this value refers to the loop header, which executes twice.
//             std::cout << "Automatically detected loop bound: " << bound << "\n";
        }

        actual_loop->bound = bound;
    }

}

