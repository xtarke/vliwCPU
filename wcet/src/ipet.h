/*
 * ipet.h
 *
 *  Created on: May 27, 2013
 *      Author: andreu
 */

#ifndef IPET_H_
#define IPET_H_

#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <cerrno>
#include <vector>
#include <map>
#include <list>
#include <stdint.h>

#include "cfg.h"

class cfg;
class basic_block;

// a ipet_var represents an ilp var, which representas an edge of the cfg
class ipet_var {
public:
    std::string* var_name;
    // the flow of this edge cause a first miss
    bool is_fmiss;
    // is the first edge of the cfg (entry point)
    bool is_entry_edge;
    // is the exid edge of the cfg
    bool is_exit_edge;
    // is loop entry point
    bool is_loop_entry_point;
    // in_loop from header
    bool in_loop_from_header;
    // the count of this var/edge calculated by ipet/solver
    int count;
    //from basic block (source)
    basic_block* from_bb;
    // to basic block (sink)
    basic_block* to_bb;
    // edge inducted time
    uint32_t time;
    // delta
    int32_t delta;
    // bound
    uint32_t bound;

    ipet_var(std::string* str, bool fmiss, bool entry, bool exit, bool entry_loop, bool ilfh,
                basic_block* from, basic_block* to, uint32_t time_, int32_t delta_, uint32_t bound_) {
        var_name = str;
        is_fmiss = fmiss;
        is_entry_edge = entry;
        is_exit_edge = exit;
        is_loop_entry_point = entry_loop;
        in_loop_from_header = ilfh;
        count = 0;
        from_bb = from;
        to_bb = to;
        time = time_;
        delta = delta_;
        bound = bound_;
    }
    // a virtual edge/var is the entry edge or the sink edge of the cfg.
    bool is_virtual(){return (from_bb == NULL) || (to_bb == NULL);}
};

class ipet {
private:

    double solver_time;
    
    // ipet variable creation
    void create_variables();
    // create vars that represents edges which not cause first miss
    void create_normal_vars(basic_block* bb, std::vector<basic_block*>* pred);
    // create vars that represents edges which cause first miss
    void create_fmiss_vars(basic_block* bb, std::vector<basic_block*>* pred);

    //utilities
    char* get_flow_edge_name(basic_block* from, basic_block* to);
    char* get_flow_edge_name(basic_block* from, basic_block* to, const char* suffix);
    char* get_entry_edge_name(basic_block* bb);
    char* get_exit_edge_name(basic_block* bb);
    void dump();
    
    // program constraints
    void extract_all_constraints();
     // we store edge info as ipet/ilp vars
    void store_edge_info(basic_block* from, basic_block* to, char* edge_name, 
        bool is_fmiss, bool entry, bool exit, uint32_t time, uint32_t bound);
    // propagate ipet information through cfg (for posterior analysis)
    void update_cfg();
    
protected:
    
    std::list<ipet_var*>* get_bb_vars(basic_block* bb, std::map<basic_block*, std::list<ipet_var*>*> &my_map);
    int get_bb_n_vars(basic_block* bb, std::map<basic_block*, std::list<ipet_var*>*> &my_map);
    
    // print vars
    virtual void print_vars() = 0;
    // retrieve vars from solver
    virtual void retrieve_vars() = 0;
    // create objective (maximization problem)
    virtual void create_objective() = 0;
    // do finalization related tasks (terminate problem file)
    virtual void finalize_problem() = 0;
    // loop limitation
    virtual void extract_loop_constraints() = 0;
    // instruction cache related constraints
    virtual void extract_cache_constraints() = 0;
    // flow conserving constraints
    virtual void extract_flow_conserv_constraints() = 0;
    // autoloop constraints
    virtual void extract_autoloop_constraints() = 0;
    // invoke ilp library to solve the problem
    virtual void solve_ilp() = 0;
    // get the wcet value
    virtual uint32_t get_wcet() = 0;
    // back end name, one backend  for each solver
    virtual const char* get_backend_name() = 0;

    // input edges of a determined basic block
    std::map<basic_block*, std::list<ipet_var*>*> bb_in_edges_list;
    // output edges of a determined basic block
    std::map<basic_block*, std::list<ipet_var*>*> bb_out_edges_list;
    // list of all edges
    // this is used to the declaration on the problem file and
    // to retrieve de information of of the solver.
    std::list<ipet_var*> all_edges_list;
    
    cfg* program_cfg;
    char out_temp[20];
    
public:
    ipet(cfg* program_cfg);
    virtual ~ipet();

    void calculate_wcet();
    void dump_wcet_cfg(const char* filename);
    uint32_t get_transfer_count(basic_block* from, basic_block* to);
};

#endif /* IPET_H_ */
