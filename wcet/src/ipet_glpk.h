/* 
 * File:   ipet_glpk.h
 * Author: andreu
 *
 * Created on June 12, 2013, 3:07 PM
 */

#ifndef IPET_GLPK_H
#define	IPET_GLPK_H

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

class cfg;
class basic_block;

class ipet_glpk: public ipet_mathprog{
public:
    ipet_glpk(cfg* program_cfg);
    virtual ~ipet_glpk();
private:
    
    glp_iocp parm;
    glp_prob *mip;
    glp_tran *tran;
    
    
    // retrieve vars from solver
    virtual void retrieve_vars();
    // invoke ilp library to solve the problem
    virtual void solve_ilp();
    // get the wcet value
    virtual uint32_t get_wcet();
    // back end name, one backend  for each solver
    virtual const char* get_backend_name();
};

#endif	/* IPET_GLPK_H */

