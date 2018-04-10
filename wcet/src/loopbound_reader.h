/* 
 * File:   loopbound_reader.h
 * Author: andreu
 *
 * Created on June 27, 2013, 2:42 PM
 */

#ifndef LOOPBOUND_READER_H
#define	LOOPBOUND_READER_H

#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <cerrno>
#include "loopbounddetector.h"
#include "cfg.h"

class loopbound_reader: public loop_bound_detector {
public:
    loopbound_reader(cfg* program_cfg_, const char* file, linker::ELF_object* obj): 
    loop_bound_detector(program_cfg_), object(obj){
    filename = file;}
    
    virtual ~loopbound_reader();
    
    virtual void analyze_loops();
private:
    const char* filename;
    linker::ELF_object* object;
};

#endif	/* LOOPBOUND_READER_H */

