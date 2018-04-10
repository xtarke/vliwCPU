/*
 * loopbounddetector.cpp
 *
 *  Created on: May 28, 2013
 *      Author: andreu
 */

#include "loopbounddetector.h"

void loop_bound_detector::detect_bounds(){

	analyze_loops();

	vector<basic_block*>* bbs = program_cfg->get_bbs();
	vector<basic_block*>::const_iterator IT;

	vector<loop*>* loops = program_cfg->get_loops();

	for(IT = bbs->begin(); IT != bbs->end(); ++IT){
		basic_block* bb = *IT;
                loop_bounds* bounds = bb->get_loop_bounds();

		int bound = 1;
                int bound2 = 1;
                int bound3 = 1;
		bool is_loop_header = false;

		int loop_id = bb->get_loop_id();
                
                if(loop_id != UNDEF){
                    //loop* actual_loop = (*loops)[loop_id];
		    loop* actual_loop = program_cfg->get_loop(loop_id);
                    bound3 = actual_loop->bound;
                }
                
		while(loop_id != UNDEF){
			//loop* actual_loop = (*loops)[loop_id];
			loop* actual_loop = program_cfg->get_loop(loop_id);

			// root or header execute twice in a loop
			if(actual_loop->root->get_id() == bb->get_id()){
				is_loop_header = true;
				bound *= (actual_loop->bound + 1);
			} else if(actual_loop->sink->get_id() == bb->get_id()){
				is_loop_header = true;
				bound *= (actual_loop->bound + 1);
			} else{
				bound *= actual_loop->bound;
			}
                        
                        if(bb->get_loop_id() != loop_id){
                            bound2*= actual_loop->bound;
                        }    
                        
                        //bound3*= actual_loop->bound;
                        
			loop_id = actual_loop->parent;
                        
		}

		bounds->set_real_x(bound);
                bounds->set_outer_x(bound2);
                bounds->set_inner_x(bound3);
	}     
}


