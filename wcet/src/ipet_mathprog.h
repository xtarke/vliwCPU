/* 
 * File:   ipet_mathprog.h
 * Author: andreu
 *
 * Created on June 24, 2013, 5:39 PM
 */

#ifndef IPET_MATHPROG_H
#define	IPET_MATHPROG_H

#include "ipet.h"
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
#include <glpk.h>
#include <stdint.h>

class cfg;
class basic_block;

class ipet_mathprog: public ipet{
public:
    ipet_mathprog(cfg* program_cfg);
    virtual ~ipet_mathprog();
private:
    
    // print vars
    virtual void print_vars();
    // create objective (maximization problem)
    virtual void create_objective();
    // do finalization related tasks (terminate problem file)
    virtual void finalize_problem();
    // loop limitation
    virtual void extract_loop_constraints();
    // instruction cache related constraints
    virtual void extract_cache_constraints();
    // flow conserving constraints
    virtual void extract_flow_conserv_constraints();
    // autoloop constraints
    virtual void extract_autoloop_constraints();

protected:
    std::ofstream problem_file;
};

#endif	/* IPET_MATHPROG_H */

