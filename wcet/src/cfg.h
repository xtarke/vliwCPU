/*
 * cfg.h
 *
 *  Created on: May 15, 2013
 *      Author: xtarke
 */

#ifndef CFG_H_
#define CFG_H_

#include <sys/types.h>
#include <stdint.h>
#include <iostream>
#include <vector>
#include <map>
#include "cache.h"
#include "instruction.h"
//#include "sim_library.h"
#include "boot.h"
#include "ELFobject.h"
#include "ELFsection.h"

using namespace std;

#define UNDEF -1

class cfg;
//class ELF_object;

class loop_bounds {
private:
    // worst-case outer loop bound
    uint32_t outer_x;
    // worst-case loop bound of a basic block
    uint32_t real_x;
    // worst-case loop bound of the inner loop of a basic block
    uint32_t inner_x;
public:

    uint32_t get_real_x() {
        return real_x;
    }

    void set_real_x(uint32_t x_) {
        real_x = x_;
    }

    uint32_t get_outer_x() {
        return outer_x;
    }

    void set_outer_x(uint32_t outer_x_) {
        outer_x = outer_x_;
    }

    uint32_t get_inner_x() {
        return inner_x;
    }

    void set_inner_x(uint32_t inner_x_) {
        inner_x = inner_x_;
    }

};

class basic_block{
    friend class cfg;
private:
    int id;
    uint32_t ini_addr;
    uint32_t end_addr;
    int32_t raw_loop_bound;

    uint32_t t; //basic block base time: interlock and multicycle instructions plus pipelining latency
    uint32_t t_ins; //instruction base time: interlock and multicycle, no cache, no pipelining latency

    uint32_t t_fmiss;

    int memory_stalls;

    // object that stores all loop bounds of the basic block
    loop_bounds bounds;

    // worst case count;
    uint32_t wcc;

    int tarjan_index;
    int tarjan_llink;

    int loop_id;

    int cache_always_misses;
    int cache_first_misses;
    int cache_conflicts;

    uint64_t compiler_internal_id;

    uint32_t search_state;
    uint32_t prune_state;

    static linker::ELF_object* elf_object;
    static uint8_t* binary_image;

public:

    enum SucessorType {
        PURE_FALLTHROUGH = 0,
        CONDITIONAL_FALLTHROUGH,
        CONDITIONAL_FALLTHROUGH_PRELOAD, // 6
        CONDITIONAL,
        CONDITIONAL_PRELOAD, // 1 cycle
        JUMP,
        CALL,
        RET
    };

    enum {
        NOT_VISITED = 0,
        VISITED_FOUND,
        VISITED_NOT_FOUND,
        LOOP_HEADER_WAITING
    };

    enum {
        PRUNE_NOT_VISITED = 0,
        PRUNE_VISITED
    };


    vector<basic_block*> predecessors;
    vector<basic_block*> sucessors;
    map <int, unsigned> sucessor_flow_type;
    //vector<instrunction*> instructions;
    set<basic_block*> predecessors_in_loop; //set of all predecessors until the loop header, empty if loop is UNDEF

    cache_state my_cstate; //all cache memory references accessed by this basic block
    cache_state my_cstate_output; //output state of the cache (last referenced blocks)
    cache_state my_cstate_input; //input state of the cache (first referenced blocks)

    cache_state input_rmb_cstate;
    cache_state rmb_cstate; //output state of the cache after bb is executed, MAY analysis
    cache_state must_cstate; //cache blocks that MUST be in the cache

    cache_state lmb_cstate;
    cache_state output_lmb_cstate;

    cache_state usef_cstate; //intersection of LMB_cstate and RMB_cstate

    map <basic_block*, unsigned int> predecessor_t;
    map <basic_block*, unsigned int> predecessor_t_fmiss;

    vector<unsigned int> a_misses_b_index; //bundle vector index where an always miss occurs
    vector<unsigned int> f_misses_b_index; //bundle vector index where a f_miss miss occurs
    vector<unsigned int> conflict_b_index; //bundle vector index where a conflict occurs    

    vector<VLIW_bundle*> bundles;

    unsigned get_sucessor_flow_type(basic_block* bb_succ);

    static void set_elf_object(linker::ELF_object* obj);
    static linker::ELF_object* get_elf_object();
    static void set_binary_image(uint8_t* obj);

    uint32_t get_edge_time(basic_block* from);
    uint32_t get_edge_ftime(basic_block* from);

    uint32_t get_search_state() {
        return search_state;
    }

    void set_search_state(uint32_t state) {
        search_state = state;
    }

    uint32_t get_prune_state() {
        return prune_state;
    }

    void set_prune_state(uint32_t state) {
        prune_state = state;
    }

    void print_info();
    void print_inst_cstate();
    void print_input_rmb_cstate();
    void print_output_rmb_cstate();
    void print_input_lmb_cstate();
    void print_output_lmb_cstate();
    void print_must_cstate();

    void print_usefull_cstate();

    void print_instrunctions();

    int get_id();
    void clear_input_rmb_cstate();
    void clear_output_lmb_cstate();
    void add_sucessor(basic_block *sucessor);
    void add_predecessor(basic_block *sucessor);

    bool has_first_miss() {
        return cache_first_misses > 0;
    }

    bool has_conflict() {
        return cache_conflicts > 0;
    }

    uint32_t get_ini_addr();
    uint32_t get_end_addr();

    unsigned int get_number_instructions();


    int get_loop_id();
    void set_loop_id(int id);

    int get_tarjan_index();
    void set_tarjan_index(int index);

    int get_tarjan_llink();
    void set_tarjan_llink(int index);

    uint64_t get_compiler_internal_id() {
        return compiler_internal_id;
    }

    void set_compiler_internal_id(uint64_t id) {
        compiler_internal_id = id;
    }

    int get_cache_conflicts() {
        return cache_conflicts;
    }

    void set_cache_conflicts(int conflicts) {
        cache_conflicts = conflicts;
    }

    int get_cache_a_misses() {
        return cache_always_misses;
    }

    void set_raw_loop_bound(int lb) {
        raw_loop_bound = lb;
    }

    int get_raw_loop_bound() {
        return raw_loop_bound;
    }

    void set_cache_a_misses(int misses) {
        cache_always_misses = misses;
    }

    int get_cache_f_misses() {
        return cache_first_misses;
    }

    void set_cache_f_misses(int misses) {
        cache_first_misses = misses;
    }

    uint32_t get_t_fmiss() {
        return t_fmiss;
    }

    void set_t_fmiss(uint32_t t_) {
        t_fmiss = t_;
    }

    uint32_t get_t() {
        return t;
    }

    uint32_t get_t_ins() {
        return t_ins;
    }

    void set_t(uint32_t t_) {
        t = t_;
    }

    void set_t_ins(uint32_t t_) {
        t_ins = t_;
    }

    loop_bounds* get_loop_bounds() {
        return &bounds;
    }

    uint32_t get_wcc() {
        return wcc;
    }

    void set_wcc(uint32_t wcc_) {
        wcc = wcc_;
    }

    void inc_memory_stalls() {
        memory_stalls++;
    }

    int get_memory_stalls() {
        return memory_stalls;
    }

    void set_ini_addr(uint32_t ini_addr_) {
        ini_addr = ini_addr_;
    }

    void set_end_addr(uint32_t end_addr_) {
        end_addr = end_addr_;
    }

    bool is_loop_header(cfg* parent_cfg);

    bool is_loop_sink(cfg* parent_cfg);

    basic_block* get_inloop_predecessors(cfg* parent_cfg, vector<basic_block*>* inlopp_pred);

    void predecessors_until(basic_block *my_bb, basic_block *until,
            set<basic_block*> *all_predecessors);

    bool operator==(basic_block* bb) {
        return (bb->get_id() == id);
    }

    bool operator!=(basic_block* bb) {
        return (bb->get_id() != id);
    }

    basic_block(int id, uint32_t, uint32_t);

    ~basic_block() {
        //         for (unsigned int i = 0; i < instructions.size(); i++) {
        //             instrunction *inst = instructions[i];
        //             delete(inst);
        //         }
        while (!bundles.empty()) {
            VLIW_bundle* bundle = bundles.back();
            bundles.pop_back();
            delete bundle;
        }

    }

    // Copy constructor

    basic_block(const basic_block& bb_source) {
        // shallow copy
        id = bb_source.id;
        ini_addr = bb_source.ini_addr;
        end_addr = bb_source.end_addr;
        tarjan_index = UNDEF;
        tarjan_llink = UNDEF;
        loop_id = UNDEF;

        //Successors and predecessors are copied, but they have
        //to rearranged if this copy is used in another CFG
        predecessors = bb_source.predecessors;
        sucessors = bb_source.sucessors;
        sucessor_flow_type = bb_source.sucessor_flow_type;

        compiler_internal_id = bb_source.compiler_internal_id;
        // instructions.clear();

        my_cstate.clear();
        input_rmb_cstate.clear();
        rmb_cstate.clear();
    }

    // Assignment operator

    basic_block& operator=(const basic_block& bb_source) {
        // check for self-assignment
        if (this == &bb_source)
            return *this;

        // shallow copy
        id = bb_source.id;
        ini_addr = bb_source.ini_addr;
        end_addr = bb_source.end_addr;
        tarjan_index = UNDEF;
        tarjan_llink = UNDEF;
        loop_id = UNDEF;

        //Successors and predecessors are copied, but they have
        //to rearranged if this copy is used in another CFG
        predecessors = bb_source.predecessors;
        sucessors = bb_source.sucessors;
        sucessor_flow_type = bb_source.sucessor_flow_type;
        //instructions.clear();

        my_cstate.clear();
        input_rmb_cstate.clear();
        rmb_cstate.clear();

        //copy_map.insert(make_pair(&bb_source, this));

        return *this;
    }
};

class loop {
public:
    int id;
    bool nested_analize;
    basic_block *root;
    basic_block *sink;

    // this fields are not used yet, but may be useful
    vector<basic_block*> sink_bbs;
    basic_block *before_node;
    basic_block *after_node;

    int parent;
    vector<basic_block*> loop_nodes;
    int bound;
    bool outside;

    loop() {
        id = UNDEF;
        nested_analize = false;
        outside = false;
        root = 0;
        sink = 0;
        parent = UNDEF;
        bound = 1;
    }
    void identify_sinks();
};

class bb_specs {
public:
    int bb_id;

    //basic block ids to add and remove from bb successor list
    vector<int> succ_to_remove;
    vector<int> succ_to_add;

    map <int, unsigned> new_flow_type;

    uint32_t ini_addr;
    uint32_t end_addr;
};

class cfg_specs {
public:
    int id;

    vector<bb_specs*> bbs_to_modify;
    vector<int> bbs_to_remove;

    bool ignore_succ(int my_id, int succ_id);
    bb_specs* modify_bb(int my_id);

    cfg_specs() {

    }
};

class cfg {
private:
    basic_block *root;
    vector<basic_block*> bb_list;
    vector<loop*> loop_list;

    map <int, basic_block*> bb_id_map;

    uint32_t wcet;

    bool search_vector(basic_block *bb, vector<basic_block*> &S);

    //loop detection:
    //https://en.wikipedia.org/wiki/Tarjan%27s_strongly_connected_components_algorithm
    bool tarjan(cfg &graph);
    void tarjan_strong_connect(basic_block *bb, int &index, vector<basic_block*> &S);

    cfg* new_cfg_from_loop(loop &loop_item);

    void loop_pointer_remap(loop &loop_item);
    bool search_loop_id(int id);

public:

    cfg() {
        set_root(NULL);
        wcet = 0;
    }
    cfg(const char* filename, cfg_specs *new_cfg_specs);

    //	 	void calc_rmb_cstate(); 	//cache data flow analysis of all basic blocks
    //                void calc_lmb_cstate(); 	//cache data flow analysis of all basic blocks	 	
    //                void calc_usef_cstate();        //intersection of RMB and LMB sets
    //                
    //                void classify_instr();	//miss/hit classification for all CFG instructions

    void identify_loops();

    vector<loop*>* get_loops() {
        return &loop_list;
    }
    
    void clear(){
        loop_list.clear();
        std::vector<basic_block*>::iterator IT;
        for(IT = bb_list.begin(); IT != bb_list.end(); IT++){
            basic_block* bb = *IT;
            bb->loop_id = UNDEF;
            bb->rmb_cstate.clear();
            bb->input_rmb_cstate.clear();
            bb->must_cstate.clear();
            bb->lmb_cstate.clear();
            bb->output_lmb_cstate.clear();
            bb->usef_cstate.clear();
            bb->predecessor_t.clear();
            bb->predecessor_t_fmiss.clear();
            bb->a_misses_b_index.clear();
            bb->f_misses_b_index.clear();
            bb->conflict_b_index.clear();
            bb->t = 0;
            bb->t_ins = 0;
            bb->t_fmiss = 0;
            bb->wcc = 0;
            bb->tarjan_index = UNDEF;
            bb->tarjan_llink = UNDEF;
            bb->predecessors_in_loop.clear();
        }
    }

    loop* get_loop(int i) {

        int j = 0;
        bool found = false;

        for (j = 0; j < loop_list.size(); j++)
            if (loop_list[j]->id == i) {
                found = true;
                break;
            }
        if (found)
            return loop_list[j];
        else
            assert(0 && "Error in loop index");

    }

    void dump_cfg(const char *filename, char* program_name);
    void dump_cfg_cache(const char *filename, char* program_name);
    void dump_cfg_raw(const char *filename);
    void print_bb_inst();
    void print_bb_info();
    void print_inst_cstate();

    void print_input_rmb_cstate();
    void print_output_rmb_cstate();
    void print_output_lmb_cstate();
    void print_input_lmb_cstate();
    void print_must_cstate();

    void print_usefull_cstate();

    void print_loop_info();

    int get_n_edges();

    void add_bb(basic_block *bb);
    void set_root(basic_block *bb);

    void set_wcet(uint32_t wcet_) {
        wcet = wcet_;
    }

    uint32_t get_wcet() {
        return wcet;
    }

    int get_n_bb() {
        return bb_list.size();
    }

    vector<basic_block*>* get_bbs() {
        return &bb_list;
    }

    basic_block* get_root();


    void clear_search_states();
    //destructor

    ~cfg() {
        //delete all basic blocks
        for (unsigned int i = 0; i < bb_list.size(); i++) {
            basic_block *bb = bb_list[i];

            delete bb;
        }

        for (unsigned int i = 0; i < loop_list.size(); i++) {
            loop *loop_item = loop_list[i];
            delete loop_item;
        }
    }


    //	 	cfg(basic_block *bb_root_) :  bb_root(bb_root_)
    // 	 	{
    //	 		bb_list.push_back(bb_root);
    //			n_bb = 1;
    // 	 	}
};







#endif /* CFG_H_ */
