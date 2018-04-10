/* 
 * File:   ipet_lpsolve.cpp
 * Author: andreu
 * 
 * Created on June 24, 2013, 7:20 PM
 */

#include "ipet_lpsolve.h"
#include "cfg.h"
#include <cassert>

using namespace std;

ipet_lpsolve::ipet_lpsolve(cfg* program_cfg_) : ipet_mathprog(program_cfg_) {
    lp = NULL;
}

ipet_lpsolve::~ipet_lpsolve() {

    delete_lp(lp);
}

void ipet_lpsolve::retrieve_vars() {

    REAL *variables;
    
    list<ipet_var*>::const_iterator IT_var;
    int col = 0;
    
    variables = new REAL[get_Ncolumns(lp)];
    get_variables(lp, variables);

    for (IT_var = all_edges_list.begin();
            IT_var != all_edges_list.end();
            IT_var++) {
        ipet_var* var = *IT_var;
        uint32_t var_val;
        double test;
        
        test = variables[col++];
        var_val = lround(test);
        
        var->count = var_val;

    }
    
    delete[] variables;
}



void ipet_lpsolve::solve_ilp() {

    lp = read_XLI((char*) "../lib/libxli_MathProg", (char*) "problem-ipet.mod", NULL, (char*) "", FULL);
    
    int solution = get_status(lp);
      
    solve(lp);
    
    return;
}

uint32_t ipet_lpsolve::get_wcet() {
    return (uint32_t) lround(get_objective(lp));
}

const char* ipet_lpsolve::get_backend_name() {
    return "LP_SOLVE";
}
