/* 
 * File:   loopbound_reader.cpp
 * Author: andreu
 * 
 * Created on June 27, 2013, 2:42 PM
 */

#include "loopbound_reader.h"
#include <string>
#include <sstream>

loopbound_reader::~loopbound_reader() {
}

void loopbound_reader::analyze_loops() {

    string line;
    ifstream file(filename);
    if(!file){
        std::cout << "Error, loop bound file not found\n";
        assert(false);
        exit(EXIT_FAILURE);
    }
      
    vector<loop*>* loops = program_cfg->get_loops();
    vector<loop*>::const_iterator IT;
    for (IT = loops->begin(); IT != loops->end(); IT++) {
        loop* actual_loop = *IT;
        int bound;
        
        getline(file,line);
        stringstream(line) >> bound;

        actual_loop->bound = bound;
    }
}