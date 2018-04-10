/* 
 * File:   ipet_mathprog.cpp
 * Author: andreu
 * 
 * Created on June 24, 2013, 5:39 PM
 */

#include "ipet_mathprog.h"
#include "cfg.h"
#include "logger.h"
#include <cassert>

using namespace std;

ipet_mathprog::ipet_mathprog(cfg* program_cfg_) : ipet(program_cfg_) {

    problem_file.open("problem-ipet.mod", std::ofstream::out | std::ofstream::trunc);

    if (!problem_file) {
        std::cerr << std::strerror(errno) << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }
}

ipet_mathprog::~ipet_mathprog() {

    //ilp cleanup
    problem_file.close();
}

void ipet_mathprog::print_vars() {
    // all vars are created, so we must print on the problem file

    problem_file << "# variables" << endl << endl;

    list<ipet_var*>::const_iterator IT_var;

    for (IT_var = all_edges_list.begin();
            IT_var != all_edges_list.end();
            IT_var++) {
        ipet_var* var = *IT_var;
        
        if(var->is_entry_edge || var->is_exit_edge){
            problem_file << "var " << *var->var_name << "=1, integer;" << endl;
        } else {
            problem_file << "var " << *var->var_name << ">=0, integer;" << endl;
        }
        
       
    }
}

void ipet_mathprog::create_objective() {

    // objective takes the following pattern:
    // maximize wcet: dstart0*1 + d8_1*1 + d0_2*1 + d1_2*1 +
    //d2_3*1 + d5_4*1 + d3_5*1 + d4_5*1 + d5_6*1 + d8_7*1 +
    //d6_8*1 + d7_8*1 + d2_9*1;

    //ie, the multiplication of each incoming edge (on a bb) by the
    // block time.

    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::const_iterator IT;

    problem_file << endl << "# objetive (compensating a pipeline with length 5)" << endl << endl;

    problem_file << "maximize wcet: ";

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        vector<basic_block*>* pred = &bb->predecessors;

        list<ipet_var*>* var_list = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator IT_var;

        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;

            if (!actual_var->is_exit_edge) {

                problem_file << actual_var->var_name->c_str() << "*";

                // f_miss edges takes more time
                //if (actual_var->is_fmiss) {
                //    problem_file << actual_var->time;
                //} else {
                //    problem_file << actual_var->time;
                //}
                problem_file << actual_var->time;

                // dont compensate pipeline for the last basic block
                if (!actual_var->to_bb->sucessors.empty()) {
                    
                    problem_file << " - " << actual_var->var_name->c_str() << "*" << actual_var->delta;
                }

            }

            // the 4 lines below detects the necessity of inserting the + operator
            list<ipet_var*>::const_iterator IT_temp = IT_var;
            IT_temp++;
            if (!actual_var->is_exit_edge && actual_var != var_list->back() && !(*IT_temp)->is_exit_edge) {
                problem_file << " + ";
            }
        }

        if (bb != bbs->back()) {
            problem_file << " + ";
        }

    }
    problem_file << ";" << endl;
}

void ipet_mathprog::finalize_problem() {

    // if we must run glpk from command line
    problem_file << endl << "solve;" << endl;
    problem_file << "display wcet;" << endl;
    problem_file << "end;" << endl;
}

void ipet_mathprog::extract_loop_constraints() {

    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::iterator IT;
   

    // the first constraints must limit the execution of the basic blocks.
    // the sum of the incoming edges must be less or equal than the loop
    // bound of the bb (field x)

    problem_file << endl << "# program sequence constraints (limiting loops) <2>" << endl << endl;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        loop_bounds* lb = bb->get_loop_bounds();
        bool found_entry = false;
        vector<basic_block*>* pred = &bb->predecessors;
        vector<basic_block*>* suc = &bb->sucessors;
	
	if(pred->empty() && suc->empty()) continue;
	
        problem_file << "s.t. " << "x" << bb->get_id() << ": ";
	

        list<ipet_var*>* var_list = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator IT_var;

    
        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;

            if(actual_var->is_entry_edge){
                found_entry = true;
            }
            
            problem_file << actual_var->var_name->c_str();

            if (actual_var != var_list->back()) {
                problem_file << " + ";
            }
        }

        if(found_entry){
            problem_file << " = " << 1;
        } else {
            problem_file << " <= " << lb->get_real_x();
        }
        problem_file << ";" << endl;

    }
}

void ipet_mathprog::extract_cache_constraints() {

    // cache constraints forces the flow to pass one time on the f_miss edges.
    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::const_iterator IT;

    problem_file << endl << "# program cache constraints " << endl << endl;
    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        loop_bounds* lb = bb->get_loop_bounds();
        vector<basic_block*>* pred = &bb->predecessors;
        vector<basic_block*>* suc = &bb->sucessors;

        if (!bb->has_first_miss()) {
            continue;
        }
        
        ///----------
        
        list<ipet_var*> var_list_fmiss;
        
        list<ipet_var*>* var_list = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator IT_var;

        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;
        
            if (actual_var->is_fmiss) {
                var_list_fmiss.push_back(actual_var);
            }
        }
            
        ///---------

        bool is_header = bb->is_loop_header(program_cfg);
        uint32_t bound;
        
        problem_file << "s.t. " << "xcache" << bb->get_id() << ": ";
        
        for (IT_var = var_list_fmiss.begin(); IT_var != var_list_fmiss.end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;
            
            if(actual_var != var_list_fmiss.front()){
                 problem_file << " + ";
            }
            
            problem_file << actual_var->var_name->c_str();

            if(is_header){
                  bound = actual_var->bound;
            }
        }

        if(is_header){
            problem_file << " <= " << bound;
        } else {
            problem_file << " <= " << (lb->get_outer_x());
        }
        
        problem_file << ";" << endl;

    }
}

void ipet_mathprog::extract_flow_conserv_constraints() {
    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::const_iterator IT;
    // the following constraints are used to conserve the flow of the program.
    // the sum of the incoming edges less outgoing edges must be equal to zero.
    // every flow that enter a bb must exit.

    problem_file << endl << "# program sequence constraints (flow conservation) <2>" << endl << endl;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        vector<basic_block*>* pred = &bb->predecessors;
        vector<basic_block*>* suc = &bb->sucessors;

	if(pred->empty() && suc->empty()) continue;
	
        problem_file << "s.t. " << "xc" << bb->get_id() << ": ";

        list<ipet_var*>* var_list = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator IT_var;

        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;
            if (actual_var != var_list->front()) {
                problem_file << " + ";
            }
            problem_file << actual_var->var_name->c_str();
        }


        list<ipet_var*>* var_list2 = get_bb_vars(bb, bb_out_edges_list);
        list<ipet_var*>::const_iterator IT_var2;

        for (IT_var2 = var_list2->begin(); IT_var2 != var_list2->end(); ++IT_var2) {
            ipet_var* actual_var = *IT_var2;
            problem_file << " - " << actual_var->var_name->c_str();
        }


        problem_file << " = " << 0;
        problem_file << ";" << endl;

    }
}

void ipet_mathprog::extract_autoloop_constraints() {
    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::const_iterator IT;
    // a loop header may induce inviable paths

    problem_file << endl << "# program autoloop constraints" << endl << endl;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        loop_bounds* lb = bb->get_loop_bounds();
        
        if (!bb->is_loop_header(program_cfg)) {
            continue;
        }
        problem_file << "s.t. " << "xal" << bb->get_id() << ": ";

        list<ipet_var*>* var_list = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator IT_var;

        int in_loop_vars = 0;

        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;

            if (actual_var->is_loop_entry_point) {
                in_loop_vars++;
            }
        }

        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;

            if (actual_var->is_loop_entry_point) {
                // this is a constraint do eliminate optimism in loops with
                // where de exit is out of the header.
                if(actual_var->to_bb->is_loop_sink(program_cfg)){
                    //puts("aqui1");
                    problem_file << actual_var->var_name->c_str() << "*" << lb->get_inner_x();
                } else {
                    // account one more to inner x: the exit edge is not the header.
                    //puts("aqui2");
                    
                    //if()
                    
                    //std::cout << "id: " << bb->get_id() << "\n";
                    // line of hell
		    LOG << "Line of hell" << endl;
                    //problem_file << actual_var->var_name->c_str() << "*" << lb->get_inner_x()+1;
                    problem_file << actual_var->var_name->c_str() << "*" << lb->get_inner_x();
                }
                

                if (--in_loop_vars > 0) {
                    problem_file << " + ";
                }
            }
        }

        var_list = get_bb_vars(bb, bb_out_edges_list);
        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;
            if(!actual_var->in_loop_from_header){           
                continue;
            }
            //std::cout << "<<< " << actual_var->var_name->c_str() << "\n";
            problem_file << " - ";
            
            problem_file << actual_var->var_name->c_str();

        }

        problem_file << " = 0;" << endl;
    }
}

