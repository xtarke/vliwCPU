/* 
 * File:   cache_analisys.h
 * Author: xtarke
 *
 * Created on June 17, 2013, 7:32 PM
 */

#ifndef CACHE_ANALISYS_H
#define	CACHE_ANALISYS_H

#include <set>

using namespace std;

//class cpu_sim;
class cfg;
class basic_block;
// class instrunction;
class cache_state;

class cache_analysis {
public:
//    cache_analisys();
//    cache_analisys(const cache_analisys& orig);
//    virtual ~cache_analisys();
    
    cache_analysis(cfg &graph_) : graph(&graph_) {   }

    void analize();
    void log();
    

private:
    //cpu_sim *CORE;
    cfg *graph;
    
    void calc_rmb_cstate();
    void calc_lmb_cstate();
    void calc_must_cstate();

    bool copy_cstate(cache_state* cs_source, cache_state * cs_dest);
    bool make_output_cstate(cache_state* cs_source, cache_state* output_cstate,
            cache_state* inst_cstate);
    
    bool search_f_miss_loop_header(basic_block *bb, int tag, int c_line);
    bool search_for_false_hits(basic_block *bb, int tag, int c_line);
    bool search_cache_conflicts(int loop_id, int tag, int c_line);
    bool search_input_out_side_node(basic_block *bb, int tag, int c_line);
    bool check_for_nested_loop_liveness(basic_block *bb, int tag, int c_line);
    bool predecessor_out_rmb_search_tag(basic_block *bb, int tag, int c_line);
    bool search_must_cset(basic_block *bb, int tag, int c_line);
    
    int get_loop_parent (int loop_id);
    basic_block* get_loop_root(int loop_id);
    
    void calc_usef_cstate();
    
    void classify_instr();
    
    bool is_always_accessed(cfg* parent_cfg, basic_block* bb, int tag, int c_line);
    bool is_always_accessed_impl(cfg* parent_cfg, basic_block* bb, int tag, int c_line);
    
    bool is_always_accessed_inside_loop(cfg* parent_cfg, basic_block* bb, int tag, int c_line, int stop_loop_id);
    
};

#endif	/* CACHE_ANALISYS_H */

