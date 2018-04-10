/* 
 * File:   CFG_pruner.cpp
 * Author: andreu
 * 
 * Created on 23 de Outubro de 2015, 13:54
 */

#include <list>

#include "CFG_pruner.h"
#include "ipet.h"

CFG_pruner::CFG_pruner(cfg* _cfg, ipet* _ipet_analysis) {
    flow_graph = _cfg;
    ipet_analysis = _ipet_analysis;
}

CFG_pruner::~CFG_pruner() {
}

void CFG_pruner::prune() {

    basic_block* root = flow_graph->get_root();
    recursive_prune(NULL, root);
    remove_unused_edges();
}

void CFG_pruner::remove_unused_edges() {
    std::vector<basic_block*>* basic_blocks;
    std::vector<basic_block*>::iterator IT, IT2, IT3;

    basic_blocks = flow_graph->get_bbs();

    
    for (IT = basic_blocks->begin(); IT != basic_blocks->end(); IT++) {
        basic_block* bb = *IT;
        
        IT2 = bb->sucessors.begin();
        
        while (IT2 != bb->sucessors.end()) {
            basic_block* succ = *IT2;
            uint32_t count = ipet_analysis->get_transfer_count(bb, succ);
            if(count == 0){
                std::cout << "from: " << bb->get_id() << " to: " << succ->get_id() << " count: " << count << "\n"; 
                bb->sucessors.erase(IT2);
                for (IT3 = succ->predecessors.begin(); IT3 != succ->predecessors.end(); IT3++) {
                    basic_block* pred = *IT3;
                    if(bb == pred){
                        succ->predecessors.erase(IT3);
                        break;
                    }
                }
            } else {
                ++IT2;
            }
        }
    }
}    

    void CFG_pruner::recursive_prune(basic_block* parent, basic_block * bb) {

        bool should_remove = false;
        std::vector<basic_block*>::iterator IT;

        if (bb->get_prune_state() == basic_block::PRUNE_VISITED) {
            return;
        } else {
            bb->set_prune_state(basic_block::PRUNE_VISITED);
        }

        if (bb->get_wcc() == 0) {
            should_remove = true;
        }

        std::list<basic_block*> blocks;

        for (IT = bb->sucessors.begin(); IT != bb->sucessors.end(); IT++) {
            basic_block* succ = *IT;
            //if(succ != NULL){
            //    recursive_prune(bb, succ);
            //}
            blocks.push_back(succ);
        }

        while (!blocks.empty()) {
            basic_block* succ = blocks.front();
            blocks.pop_front();
            recursive_prune(bb, succ);
        }


        if (should_remove) {
            for (IT = bb->sucessors.begin(); IT != bb->sucessors.end(); IT++) {
                basic_block* succ = *IT;
                std::vector<basic_block*>::iterator to_remove = succ->predecessors.end();
                for (to_remove = succ->predecessors.begin(); to_remove != succ->predecessors.end(); to_remove++) {
                    if (bb == *to_remove) {
                        break;
                    }
                }
                if (to_remove != succ->predecessors.end()) {
                    succ->predecessors.erase(to_remove);
                }
            }
            bb->sucessors.clear();
            for (IT = bb->predecessors.begin(); IT != bb->predecessors.end(); IT++) {
                basic_block* pred = *IT;
                std::vector<basic_block*>::iterator to_remove = pred->sucessors.end();
                for (to_remove = pred->sucessors.begin(); to_remove != pred->sucessors.end(); to_remove++) {
                    if (bb == *to_remove) {
                        break;
                    }
                }
                if (to_remove != pred->sucessors.end()) {
                    pred->sucessors.erase(to_remove);
                }
            }

            bb->predecessors.clear();

            for (IT = flow_graph->get_bbs()->begin(); IT != flow_graph->get_bbs()->end(); IT++) {
                if (bb == *IT) {
                    break;
                }
            }
            (flow_graph->get_bbs())->erase(IT);
        }
    }