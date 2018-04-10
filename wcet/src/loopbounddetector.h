/*
 * loopbounddetector.h
 *
 *  Created on: May 28, 2013
 *      Author: andreu
 */

#ifndef LOOPBOUNDDETECTOR_H_
#define LOOPBOUNDDETECTOR_H_

#include "cfg.h"

class loop_bound_detector {
protected:
	cfg* program_cfg;

public:
	loop_bound_detector(cfg* cfg_){program_cfg = cfg_;}

	virtual ~loop_bound_detector(){};
	virtual void analyze_loops() = 0;

	void detect_bounds();
};

#endif /* LOOPBOUNDDETECTOR_H_ */
