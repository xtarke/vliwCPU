/* 
 * File:   boundary_hazard_detector.h
 * Author: andreu
 *
 * Created on July 11, 2013, 7:30 AM
 */

#ifndef BOUNDARY_HAZARD_DETECTOR_H
#define	BOUNDARY_HAZARD_DETECTOR_H

#include "cfg.h"


class boundary_hazard_detector {
public:
 
    boundary_hazard_detector(cfg* p_cfg);
    virtual ~boundary_hazard_detector();
    void detect();
private:
    cfg* program_cfg;
    bool has_hazard(basic_block* from, basic_block* to);
};

#endif	/* BOUNDARY_HAZARD_DETECTOR_H */

