/*
 * simplelbd.cpp
 *
 *  Created on: May 28, 2013
 *      Author: andreu
 */

#include "simplelbd.h"


simple_lbd::~simple_lbd() {
	// TODO Auto-generated destructor stub
}

void simple_lbd::analyze_loops(){

	vector<loop*>* loops = program_cfg->get_loops();
	vector<loop*>::const_iterator IT;
	for(IT = loops->begin(); IT != loops->end(); IT++){
		loop* actual_loop = *IT;
		int bound;

		std::cout << "Loop: " << actual_loop->id << endl;
		std::cout << "Type the bound: ";
		scanf("%d", &bound);

		actual_loop->bound = bound;
	}

}

