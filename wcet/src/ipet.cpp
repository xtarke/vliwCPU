/*
 * ipet.cpp
 *
 *  Created on: May 27, 2013
 *      Author: andreu
 */

#include "ipet.h"
#include "cfg.h"
#include <cassert>
#include <chrono>
#include <iomanip>      // std::setprecision
#include <sstream>

using namespace std;

uint32_t ipet::get_transfer_count(basic_block* from, basic_block* to){
    list<ipet_var*>* my_vars;
    list<ipet_var*>::const_iterator IT;
    uint32_t count = 0;
    
    my_vars = get_bb_vars(from, bb_out_edges_list);
    
    for(IT = my_vars->begin(); IT != my_vars->end(); IT++){
        if((*IT)->to_bb == to){
            count += (*IT)->count;
        }
    }
    
    return count;
}

// utility function to get the list of vars representing edges of blocks

list<ipet_var*>* ipet::get_bb_vars(basic_block* bb, map<basic_block*, list<ipet_var*>*> &my_map) {

    map<basic_block*, list<ipet_var*>*>::const_iterator IT;
    IT = my_map.find(bb);

    assert(IT != my_map.end());

    return IT->second;
}

// utility function to get the number of edges of blocks

int ipet::get_bb_n_vars(basic_block* bb, map<basic_block*, list<ipet_var*>*> &my_map) {

    map<basic_block*, list<ipet_var*>*>::const_iterator IT;
    IT = my_map.find(bb);

    assert(IT != my_map.end());

    return IT->second->size();
}

// method for dump the information about basic blocks and its edges (flows)

void ipet::dump() {
    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::iterator IT;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;

        cout << "basic block: " << bb->get_id() << "\n";
        cout << "\tin: ";

        list<ipet_var*>* var_list = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator IT_var;

        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;
            cout << actual_var->var_name->c_str() << " ";
        }
        cout << "\n";
        cout << "\tout: ";

        list<ipet_var*>* var_list2 = get_bb_vars(bb, bb_out_edges_list);
        list<ipet_var*>::const_iterator IT_var2;

        for (IT_var2 = var_list2->begin(); IT_var2 != var_list2->end(); ++IT_var2) {
            ipet_var* actual_var = *IT_var2;
            cout << actual_var->var_name->c_str() << " ";
        }
        cout << "\n";
    }
}

ipet::ipet(cfg* program_cfg_) {
    program_cfg = program_cfg_;

    vector<basic_block*>::const_iterator IT;
    vector<basic_block*>* bbs = program_cfg->get_bbs();

    //allocation of lists to store variable representing edges
    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        list<ipet_var*>* new_list_in = new list<ipet_var*>();
        bb_in_edges_list[bb] = new_list_in;
        list<ipet_var*>* new_list_out = new list<ipet_var*>();
        bb_out_edges_list[bb] = new_list_out;
    }

    solver_time = 0;
}

ipet::~ipet() {

    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::iterator IT;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;

        list<ipet_var*>* var_list;
        list<ipet_var*>::const_iterator IT_var;

        var_list = get_bb_vars(bb, bb_out_edges_list);

        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;
            // is this point we only release the exit edge/var
            if (actual_var->is_exit_edge) {
                delete actual_var->var_name;
                delete actual_var;
            }
        }
        var_list->clear();
        delete var_list;

        var_list = get_bb_vars(bb, bb_in_edges_list);

        // release all edges/var and strings
        for (IT_var = var_list->begin(); IT_var != var_list->end(); ++IT_var) {
            ipet_var* actual_var = *IT_var;
            delete actual_var->var_name;
            delete actual_var;
        }
        var_list->clear();
        delete var_list;
    }
    bb_out_edges_list.clear();
    bb_in_edges_list.clear();
}

static bool is_entry_loop(basic_block* bb, basic_block* bb_pred, cfg* program_cfg) {

    //loop* the_loop = (*program_cfg->get_loops())[bb->get_loop_id()];
    loop* the_loop = program_cfg->get_loop(bb->get_loop_id());
    vector<basic_block*>::const_iterator ITloop;
    vector<basic_block*>* loop_vector = &the_loop->loop_nodes;

    for (ITloop = loop_vector->begin(); ITloop != loop_vector->end(); ITloop++) {

        if (*ITloop == bb_pred) {
            return false;
        }
    }
    return true;
}

static bool is_in_loop(basic_block* bb, basic_block* bb_pred, cfg* program_cfg) {

    //loop* the_loop = (*program_cfg->get_loops())[bb_pred->get_loop_id()];
    loop* the_loop = program_cfg->get_loop(bb_pred->get_loop_id());
    vector<basic_block*>::const_iterator ITloop;
    vector<basic_block*>* loop_vector = &the_loop->loop_nodes;

    for (ITloop = loop_vector->begin(); ITloop != loop_vector->end(); ITloop++) {
        
        if (*ITloop == bb) {
            return true;
        }
    }
    return false;
}

void ipet::store_edge_info(basic_block* from, basic_block* to, char* edge_name,
        bool is_fmiss, bool entry, bool exit, uint32_t time, uint32_t bound) {


    string* str = new string(edge_name);
    bool is_loop_entry_point = false;
    bool in_loop_from_header = false;
    //int32_t delta = 0;
    int32_t delta = 4;
    
    

    if (to != NULL && from != NULL) {
        if (to->is_loop_header(program_cfg)) {
            is_loop_entry_point = is_entry_loop(to, from, program_cfg);
            if(from->is_loop_header(program_cfg)){
                in_loop_from_header = is_in_loop(to, from, program_cfg);
            }
        } else if (from->is_loop_header(program_cfg)) {
            in_loop_from_header = is_in_loop(to, from, program_cfg);
        }
        unsigned type = from->get_sucessor_flow_type(to);
        if(type == basic_block::CONDITIONAL_FALLTHROUGH){
// 	  cout << "CONDITIONAL_FALLTHROUGH from: " << from->get_id() << " to: " << to->get_id() << endl;
            //delta = 4;
	  delta = 8;
        } else if (type == basic_block::CONDITIONAL_PRELOAD){
            //delta = 3;
	    delta = 7;
	    
// 	    cout << "CONDITIONAL_PRELOAD from: " << from->get_id() << " to: " << to->get_id() << endl;
	    
        } else if (type == basic_block::CONDITIONAL_FALLTHROUGH_PRELOAD){
	  //cout << "CONDITIONAL_FALLTHROUGH_PRELOAD from: " << from->get_id() << " to: " << to->get_id() << endl;
          //delta = -1;
	  delta = 2;
        }
    }
    
   
    //unsigned type = from->get_sucessor_flow_type(to);

    ipet_var* var = new ipet_var(str, is_fmiss, entry, exit, is_loop_entry_point,
            in_loop_from_header, from, to, time, delta ,bound);

    list<ipet_var*>* var_list;
    map<basic_block*, list<ipet_var*>*>::const_iterator IT;

    if (to) { // to NULL implies exit edge
        IT = bb_in_edges_list.find(to);
        var_list = IT->second;
        var_list->push_back(var);
    }
    if (from) { // from NULL implies entry edge
        IT = bb_out_edges_list.find(from);
        var_list = IT->second;
        var_list->push_back(var);
    }

    all_edges_list.push_back(var);
}

void ipet::create_fmiss_vars(basic_block* bb, std::vector<basic_block*>* pred) {

    char* edge_name;

    if (bb->is_loop_header(program_cfg)) {
        vector<basic_block*> inloop_preds;
        basic_block* main_pred;

        main_pred = bb->get_inloop_predecessors(program_cfg, &inloop_preds);

        // loop header first miss -> lfm;
        // the first miss must pass in the edge/var
        edge_name = get_flow_edge_name(main_pred, bb, "lfm");
        //problem_file << "var " << edge_name << ">=0;" << endl;
        store_edge_info(main_pred, bb, edge_name, true, false, false,
                bb->get_edge_ftime(main_pred), main_pred->get_loop_bounds()->get_outer_x());

        // loop header posterior hits -> lh;
        edge_name = get_flow_edge_name(main_pred, bb, "lh");
        //problem_file << "var " << edge_name << ">=0;" << endl;
        store_edge_info(main_pred, bb, edge_name, false, false, false, bb->get_edge_time(main_pred), 0);

        vector<basic_block*>::iterator IT;
        for (IT = inloop_preds.begin(); IT != inloop_preds.end(); IT++) {
            basic_block* pred_bb = *IT;
            // loop header always hit -> lah 
            // the other flows that came from other edges only
            // causes hits.
            edge_name = get_flow_edge_name(pred_bb, bb, "lah");
            //problem_file << "var " << edge_name << ">=0;" << endl;
            store_edge_info(pred_bb, bb, edge_name, false, false, false, bb->get_edge_time(pred_bb), 0);
        }

    } else {
        // if the block is not a loop header, every incoming (actually one (*) ) edge can
        // cause a first miss. We must split all edges vars.
        // (*) we check this restriction here
        //assert(bb->predecessors.size() == 1);

        vector<basic_block*>::const_iterator IT;
        for (IT = pred->begin(); IT != pred->end(); IT++) {
            basic_block* pred_bb = *IT;
            // node first miss -> fm;
            // the first flow passes here
            edge_name = get_flow_edge_name(pred_bb, bb, "fm");
            //problem_file << "var " << edge_name << ">=0;" << endl;
            store_edge_info(pred_bb, bb, edge_name, true, false, false, bb->get_edge_ftime(pred_bb), 0);

            // node hit -> h;
            // the remaining flows passes here.
            edge_name = get_flow_edge_name(pred_bb, bb, "h");
            //problem_file << "var " << edge_name << ">=0;" << endl;
            store_edge_info(pred_bb, bb, edge_name, false, false, false, bb->get_edge_time(pred_bb), 0);
        }
    }
}

void ipet::create_normal_vars(basic_block* bb, vector<basic_block*>* pred) {

    char* edge_name;
    // normal edges don't cause first miss.
    // the approach is straightforward.
    //declare all variables representing edges,
    //ex: var d8_1>=0; -> edge from bb 8 to bb 1.
    vector<basic_block*>::const_iterator IT2;
    for (IT2 = pred->begin(); IT2 != pred->end(); IT2++) {
        bool entry_loop = false;
        bool from_loop_header = false;

        basic_block* bb_pred = *IT2;
        edge_name = get_flow_edge_name(bb_pred, bb);
        //problem_file << "var " << edge_name << ">=0;" << endl;
        // tricky part
        if (bb->is_loop_header(program_cfg)) {
            entry_loop = is_entry_loop(bb, bb_pred, program_cfg);
        } else if (bb_pred->is_loop_header(program_cfg)) {
            from_loop_header = is_in_loop(bb, bb_pred, program_cfg);
        }
        store_edge_info(bb_pred, bb, edge_name, false, false, false, bb->get_edge_time(bb_pred), 0);
    }
}

void ipet::create_variables() {

    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::const_iterator IT;

    //problem_file << "# variables" << endl << endl;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        vector<basic_block*>* suc = &bb->sucessors;
        vector<basic_block*>* pred = &bb->predecessors;
	
	if(pred->empty() && suc->empty()) continue;

        // first edge - an imaginary edge to the entry point
        // this must be handled manually.
        // var dstart0>=0;
        if (pred->empty()) {
            char* start_name = get_entry_edge_name(bb);
            store_edge_info(NULL, bb, start_name, false, true, false, bb->get_edge_time(NULL), 0);
            //problem_file << "var " << start_name << ">=0;" << endl;
        } else {
            if (bb->has_first_miss()) {
                //assert(!bb->has_conflict());
                create_fmiss_vars(bb, pred);
            } else {
                create_normal_vars(bb, pred);
            }
        }
        // last edge - an imaginary edge out of the last basic block
        // this also must be handled manually
        if (suc->empty()) {
            char* exit_name = get_exit_edge_name(bb);
            // last edge is t = 0
            store_edge_info(bb, NULL, exit_name, false, false, true, 0, 0);
            //problem_file << "var " << exit_name << ">=0;" << endl;
        }
    }

}

void ipet::extract_all_constraints() {
    extract_loop_constraints();
    extract_flow_conserv_constraints();
    extract_cache_constraints();
    extract_autoloop_constraints();
}

void ipet::calculate_wcet() {

    chrono::steady_clock::time_point t1;
    chrono::steady_clock::time_point t2;
    chrono::duration<double> time_spam;

    create_variables();
    print_vars();
    create_objective();
    extract_all_constraints();
    finalize_problem();

    t1 = chrono::steady_clock::now();

    solve_ilp();

    t2 = chrono::steady_clock::now();

    time_spam = chrono::duration_cast < chrono::duration<double >> (t2 - t1);

    solver_time = time_spam.count();

    retrieve_vars();
    update_cfg();
    //dump();

    return;
}

void ipet::update_cfg() {

    uint32_t wcet;
    int col = 1;

    wcet = get_wcet();
    program_cfg->set_wcet(wcet);
#if defined(DEBUG)   
    std::cout << "WCET: " << wcet << endl;
#endif
    vector<basic_block*>* bbs = program_cfg->get_bbs();
    vector<basic_block*>::iterator IT;

    for (IT = bbs->begin(); IT != bbs->end(); ++IT) {
        basic_block* bb = *IT;
        uint32_t count = 0;

        list<ipet_var*>* bb_in_vars = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator IT_var;

        for (IT_var = bb_in_vars->begin();
                IT_var != bb_in_vars->end();
                IT_var++) {
            ipet_var* actual_var = *IT_var;
            count += actual_var->count;
        }

        bb->set_wcc(count);
#if defined(DEBUG)          
        std::cout << "bb " << bb->get_id() << " has count " << bb->get_wcc() << endl;
#endif
    }

}

char* ipet::get_flow_edge_name(basic_block* from, basic_block* to) {

    sprintf(out_temp, "d%d_%d", from->get_id(), to->get_id());
    return out_temp;
}

char* ipet::get_flow_edge_name(basic_block* from, basic_block* to, const char* suffix) {

    sprintf(out_temp, "d%d_%d%s", from->get_id(), to->get_id(), suffix);
    return out_temp;
}

char* ipet::get_entry_edge_name(basic_block* bb) {

    sprintf(out_temp, "dstart%d", bb->get_id());
    return out_temp;
}

char* ipet::get_exit_edge_name(basic_block* bb) {

    sprintf(out_temp, "dend%d", bb->get_id());
    return out_temp;
}

void ipet::dump_wcet_cfg(const char* filename) {

    ofstream wcet_cfg_file;
    std::list<ipet_var*>::const_iterator IT;
    vector<basic_block*>::iterator IT2;
    vector<basic_block*>* bbs = program_cfg->get_bbs();



    wcet_cfg_file.open(filename, std::ofstream::out | std::ofstream::trunc);

    if (!wcet_cfg_file) {
        std::cerr << std::strerror(errno) << std::endl;
        assert(false);
        exit(EXIT_FAILURE);
    }

    wcet_cfg_file << "digraph G {\n"
            "\t\tlabel = \"WCET CFG > " <<
            "wcet: " << get_wcet() << " cycles | "
            "backend: " << get_backend_name() << " | " <<
            "time: " << setprecision(3) << solver_time << " secs" <<
            "\" splines=true overlap=false" << endl;

    wcet_cfg_file << "\t\t\"start\" [ style = \"filled, bold\" ]" << endl;

    for (IT2 = bbs->begin(); IT2 != bbs->end(); ++IT2) {
        basic_block* bb = *IT2;
        int time = 0;
        double percent;
        const char* vertex_trace;
        const char* vertex_trace_shape;
        list<ipet_var*>* preds = get_bb_vars(bb, bb_in_edges_list);
        list<ipet_var*>::const_iterator ITpred;

        for (ITpred = preds->begin(); ITpred != preds->end(); ITpred++) {
            ipet_var* actual_var = *ITpred;
            time += actual_var->count * actual_var->time;
        }

        if (bb->is_loop_header(program_cfg)) {
            vertex_trace_shape = "octagon";
        } else {
            vertex_trace_shape = "box";
        }

        if (bb->sucessors.empty()) {
            vertex_trace = "bold";
        } else {
            vertex_trace = "solid";
        }

        percent = ((double) time / (double) get_wcet()) * 100.0;

        wcet_cfg_file << "\t\t\"" << bb->get_id() <<
                "\" [ label = \"bb: " << bb->get_id() << " [" << bb->get_ini_addr() << "," << bb->get_end_addr() << "]" <<
                "\\ntotal: " << time <<
                "(" << setprecision(3) << percent << "\%)"
                "\" style = \"filled," <<
                vertex_trace <<
                "\" shape = \"" <<
                vertex_trace_shape <<
                "\"]" << endl;
    }

    for (IT = all_edges_list.begin(); IT != all_edges_list.end(); IT++) {
        ipet_var* var = *IT;
        basic_block* from = var->from_bb;
        basic_block* to = var->to_bb;
        const char* edge_trace;

        if (var->is_fmiss && var->count == 0) {
            edge_trace = "style=bold,  color=grey";
        } else if (var->is_fmiss) {
            edge_trace = "style=bold";
        } else if (var->count == 0) {
            edge_trace = "style=dotted, color=grey";
        } else {
            edge_trace = "style=solid";
        }

        if (var->is_entry_edge) {
            wcet_cfg_file << "\t\t" << "start" <<
                    " -> " << to->get_id() <<
                    " [label=\"" <<
                    var->var_name->c_str() << "=" << var->count << "*" << var->time << "(" << (int32_t)var->delta << ")" <<
                    "\"" << edge_trace << "]" <<
                    endl;
        } else if (!var->is_exit_edge) {
            wcet_cfg_file << "\t\t" << from->get_id() <<
                    " -> " << to->get_id() <<
                    " [label=\"" <<
                    var->var_name->c_str() << "=" << var->count << "*" << var->time << "(" << (int32_t)var->delta << ")" <<
                    "\"" << edge_trace << "]" <<
                    endl;
        }

    }
    wcet_cfg_file << "}" << endl;

    wcet_cfg_file.close();

    std::stringstream out;
    std::string file_name = filename;

    out << "dot -Tpdf " << filename << " -o "
            << file_name.replace(file_name.size() - 4, 4, ".pdf");
    system(out.str().c_str());
}