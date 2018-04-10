/* 
 * File:   ipet_glpk.cpp
 * Author: andreu
 * 
 * Created on June 12, 2013, 3:07 PM
 */

#include "ipet_glpk.h"
#include "cfg.h"
#include <cassert>
#include <math.h>

using namespace std;

ipet_glpk::ipet_glpk(cfg* program_cfg_) : ipet_mathprog(program_cfg_) {
    mip = NULL;
    tran = NULL;
}

ipet_glpk::~ipet_glpk() {

    //ilp cleanup
    problem_file.close();
    glp_mpl_free_wksp(tran);
    glp_delete_prob(mip);
}

void ipet_glpk::retrieve_vars() {

    list<ipet_var*>::const_iterator IT_var;
    int col = 1;

    for (IT_var = all_edges_list.begin();
            IT_var != all_edges_list.end();
            IT_var++) {
        ipet_var* var = *IT_var;
        uint32_t var_val;
        double temp;
        const char* col_name;
        const char* var_name;

        // get data form solver
        col_name = glp_get_col_name(mip, col);
        temp = glp_mip_col_val(mip, col++);

        var_name = var->var_name->c_str();

        // paranoid: we get the right val?
        assert(strcmp(var_name, col_name) == 0);

        var_val = lround(temp);
        
        //update val
        var->count = var_val;
    }
}



void ipet_glpk::solve_ilp() {

    int ret;

    // disable glpk output
    glp_term_out(GLP_OFF);

    glp_init_iocp(&parm);
    
    parm.presolve = GLP_ON;
    
    mip = glp_create_prob();
    tran = glp_mpl_alloc_wksp();
    ret = glp_mpl_read_model(tran, "problem-ipet.mod", 1);

    if (ret != 0) {
        std::cerr << "Error on translating model" << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }

    ret = glp_mpl_generate(tran, NULL);
    if (ret != 0) {
        std::cerr << "Error on generating model" << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }

    glp_mpl_build_prob(tran, mip);
    
    glp_write_lp(mip, NULL, "problem-ipet.clp");
    
    glp_simplex(mip, NULL);
    //glp_exact(mip, NULL);
    //lp_interior(mip, NULL);
    glp_intopt(mip, &parm);
    
    //glp_intopt(mip, NULL);
    ret = glp_mpl_postsolve(tran, mip, GLP_MIP);
    
    glp_print_mip(mip, "wcet_solution.txt");

    if (ret != 0) {
        std::cerr << "Error on postsolving model" << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }
    
    int solution = glp_get_status(mip);
    
    switch(solution){
        case GLP_INFEAS:
            std::cerr << "FATAL: Glpk solution is infeasible" << std::endl;
            exit(EXIT_FAILURE);
            break;
        case GLP_NOFEAS:
            std::cerr << "FATAL: Glpk problem has no feasible solution" << std::endl;
            exit(EXIT_FAILURE);
            break;
        case GLP_UNBND:
            std::cerr << "FATAL: Glpk problem has unbounded solution" << std::endl;
            exit(EXIT_FAILURE);
            break;
        case GLP_UNDEF:
            std::cerr << "FATAL: Glpk solution is undefined" << std::endl;
            exit(EXIT_FAILURE);
            break;
        default:
            break;
    }

    return;
}

uint32_t ipet_glpk::get_wcet() {
    return (uint32_t) lround(glp_mip_obj_val(mip));
}

const char* ipet_glpk::get_backend_name() {
    return "GLPK";
}