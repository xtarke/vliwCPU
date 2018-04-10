/* 
 * File:   ipet_lpsolve.h
 * Author: andreu
 *
 * Created on June 24, 2013, 7:20 PM
 */

#ifndef IPET_LPSOLVE_H
#define	IPET_LPSOLVE_H

#include "ipet.h"
#include "ipet_mathprog.h"
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
#include "lpsolve/lp_lib.h"

class cfg;
class basic_block;

class ipet_lpsolve: public ipet_mathprog{
public:
    ipet_lpsolve(cfg* program_cfg);
    virtual ~ipet_lpsolve();
private:
    
    lprec *lp;
    
    // retrieve vars from solver
    virtual void retrieve_vars();
    // invoke ilp library to solve the problem
    virtual void solve_ilp();
    // get the wcet value
    virtual uint32_t get_wcet();
    // back end name, one backend  for each solver
    virtual const char* get_backend_name();
};

#endif	/* IPET_LPSOLVE_H */

