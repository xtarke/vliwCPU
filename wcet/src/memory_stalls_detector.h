/* 
 * File:   memory_stalls_detector.h
 * Author: andreu
 *
 * Created on July 12, 2013, 11:56 AM
 */

#include "cfg.h"

#ifndef MEMORY_STALLS_DETECTOR_H
#define	MEMORY_STALLS_DETECTOR_H

class memory_stalls_detector {
public:
    memory_stalls_detector(cfg* p_cfg);
    virtual ~memory_stalls_detector();
    void detect();
private:
    cfg* program_cfg;
    void detect_bb_memory_stalls(basic_block* bb);
//     void detect_bb_load_stall(basic_block* bb, instrunction* instr);
//     void detect_bb_store_stall(basic_block*, instrunction* instr);
};

#endif	/* MEMORY_STALLS_DETECTOR_H */

