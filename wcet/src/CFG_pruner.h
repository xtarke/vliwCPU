/* 
 * File:   CFG_pruner.h
 * Author: andreu
 *
 * Created on 23 de Outubro de 2015, 13:54
 */

#ifndef CFG_PRUNER_H
#define	CFG_PRUNER_H

#include "cfg.h"
#include "ipet.h"


class CFG_pruner {
public:
    CFG_pruner(cfg* flow_graph, ipet* ipet_analysis);
    virtual ~CFG_pruner();
    
    void prune();
private:
    cfg* flow_graph;
    ipet* ipet_analysis;
    void recursive_prune(basic_block* parent, basic_block* bb);
    void remove_unused_edges();
};

#endif	/* CFG_PRUNER_H */

