/* 
 * File:   pipeline_analisys.h
 * Author: andreu
 *
 * Created on 15 de Setembro de 2014, 18:29
 */

#ifndef PIPELINE_ANALISYS_H
#define	PIPELINE_ANALISYS_H

#include "cfg.h"
#include "logger.h"

// Should come from a processor configuration file
#define PIPELINE_LENGHT 5

using namespace std;

struct instruction_stall{
    unsigned type;
    unsigned stalls;
};

struct ctrl_flow_stall {
    unsigned type;
    unsigned stalls;
};


struct data_hazard{
    unsigned first_type;
    unsigned second_type;
    unsigned stalls;
};

class pipeline_analisys {
public:
    void analize();
    void log();
    
    pipeline_analisys(cfg* graph_): graph(graph_) {};
    
    uint32_t range_instruc_timing(vector<VLIW_bundle*> bundles, unsigned int from, unsigned int to);
private:

    cfg *graph;
};

#endif	/* PIPELINE_ANALISYS_H */

