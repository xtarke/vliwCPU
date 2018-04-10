/*
 * timing.h
 *
 *  Created on: Jun 3, 2013
 *      Author: xtarke
 *
 *
 *      Basic block timing calculation
 */

#ifndef TIMING_H_
#define TIMING_H_

//#define DEBUG

#include <map>
#include "logger.h"
#include "pipeline_analisys.h"

using namespace std;

//class cpu_sim;
class cfg;
class basic_block;
class VLIW_bundle;


class timing {
private:    
    cfg *graph;

    void update_time_map(unsigned int t, map <basic_block*, unsigned int> *time_map);
    void conflict_timing(basic_block *bb, VLIW_bundle* bundle, map <basic_block*, unsigned int> *time_map);
    void update_time_f_miss_loop_header(basic_block *bb,
            map <basic_block*, unsigned int> *time_map, unsigned int t);

public:

    timing(cfg &graph_) : graph(&graph_) {
    }

    void get_basic_block_times();
    void add_cache_miss_penalty();
    void add_slow_mem_penalty();
    void no_cache_timing();



};



#endif /* TIMING_H_ */
