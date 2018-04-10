/* 
 * File:   automatic_lbd.h
 * Author: andreu
 *
 * Created on 22 de Outubro de 2014, 12:48
 */

#ifndef AUTOMATIC_LBD_H
#define	AUTOMATIC_LBD_H

#include "loopbounddetector.h"
#include "ELFobject.h"

class automatic_lbd : public loop_bound_detector {
public:

    automatic_lbd(cfg* program_cfg_, linker::ELF_object* obj) :
        loop_bound_detector(program_cfg_),  object(obj){
    }

    virtual ~automatic_lbd(); 

    virtual void analyze_loops();
private:
    linker::ELF_object* object;

};

#endif	/* AUTOMATIC_LBD_H */

