/*
 * simplelbd.h
 *
 *  Created on: May 28, 2013
 *      Author: andreu
 */

#ifndef SIMPLELBD_H_
#define SIMPLELBD_H_

#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <cerrno>
#include "loopbounddetector.h"
#include "cfg.h"

class simple_lbd: public loop_bound_detector {
public:
	simple_lbd(cfg* program_cfg_): loop_bound_detector(program_cfg_){}

	virtual ~simple_lbd();

	virtual void analyze_loops();
};

#endif /* SIMPLELBD_H_ */
