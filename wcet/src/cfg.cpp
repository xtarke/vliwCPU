/*
 * cfg.cpp
 *
 *  Created on: May 15, 2013
 *      Author: xtarke
 */

#include "cfg.h"
#include <iostream>
#include <fstream>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <cerrno>
#include <string>
#include <cstring>
#include <cstdlib>

#include <algorithm>    // std::find

#include "logger.h"

linker::ELF_object* basic_block::elf_object = NULL;
uint8_t* basic_block::binary_image = NULL;

void basic_block::set_elf_object(linker::ELF_object* obj){
    elf_object = obj;
}

linker::ELF_object* basic_block::get_elf_object(){
    return elf_object;
}

void basic_block::set_binary_image(uint8_t* obj){
    binary_image = obj;
}

basic_block::basic_block(int id_ = UNDEF, uint32_t ini_addr_ = 0, uint32_t end_addr_ = 0) :
id(id_), ini_addr(ini_addr_), end_addr(end_addr_) {
    loop_id = UNDEF;
    tarjan_index = UNDEF;
    tarjan_llink = UNDEF;
    memory_stalls = 0;
    search_state = basic_block::NOT_VISITED;
    prune_state = basic_block::PRUNE_NOT_VISITED;
    compiler_internal_id = 0;
    
    // Parse code bundles
    VLIW_bundle_parser::create_bundle_seq(bundles, (uint32_t*) get_elf_object()->get_text_section()->get_section(), ini_addr, end_addr);
    
    //set bundle cache info 
    my_cstate.set_bundle_cache_info(bundles);    
    
    // Create initial cache states
    my_cstate.create_state(bundles);     
    my_cstate_input.create_state(bundles);
    my_cstate_output.create_state(bundles);
    //LOG_NL << "BB: " << get_id() << " [" << get_ini_addr() << "," << get_end_addr() << "]" << endl;
    //my_cstate.print();
    
}

int basic_block::get_id() {
    return id;
}

unsigned basic_block::get_sucessor_flow_type(basic_block* bb_succ){
    
    std::map<int, unsigned>::iterator IT;
    
    IT = sucessor_flow_type.find(bb_succ->get_id());
    
    if(IT == sucessor_flow_type.end()){
        assert(false);
    }
    
    return IT->second;
}

void basic_block::add_sucessor(basic_block *sucessor) {
    sucessors.push_back(sucessor);
}

void basic_block::print_inst_cstate() {
    my_cstate.print();
}

void basic_block::print_input_rmb_cstate() {
    input_rmb_cstate.print();
}

void basic_block::print_output_rmb_cstate() {
    rmb_cstate.print();
}

void basic_block::print_must_cstate() {
    must_cstate.print();
}

void basic_block::print_input_lmb_cstate() {
    lmb_cstate.print();
}

void basic_block::print_output_lmb_cstate() {
    output_lmb_cstate.print();
}

void basic_block::clear_input_rmb_cstate() {
    input_rmb_cstate.clear();
}

void basic_block::clear_output_lmb_cstate() {
    output_lmb_cstate.clear();
}

bool basic_block::is_loop_header(cfg* parent_cfg) {
    int loop_index = get_loop_id();
    
    if (loop_index == UNDEF) {
        return false;
    } 
    loop* parent_loop = parent_cfg->get_loop(loop_index);

    return (parent_loop->root->get_id() == this->get_id());
}

bool basic_block::is_loop_sink(cfg* parent_cfg){
    
    int loop_index = get_loop_id();

    if (loop_index == UNDEF) {
        return false;
    }

    loop* parent_loop = parent_cfg->get_loop(loop_index);
    
    vector<basic_block*>::const_iterator IT;
    
    // for future...
    for(IT = parent_loop->loop_nodes.begin();
            IT != parent_loop->loop_nodes.end(); IT++){
        basic_block* bb = *IT;
        
        if(get_id() == bb->get_id() && get_id() != parent_loop->root->get_id()){
            //return true;
        }
    }
    //return false;
    
    return (parent_loop->sink->get_id() == this->get_id());    
}

void basic_block::predecessors_until(basic_block *my_bb, basic_block *until,
        set<basic_block*> *all_predecessors) {
    basic_block *pred;

    if (my_bb->get_id() != until->get_id()) {
        for (unsigned int i = 0; i < my_bb->predecessors.size(); i++) {
            pred = my_bb->predecessors[i];

            if (all_predecessors->find(pred) != all_predecessors->end())
                continue;

            all_predecessors->insert(pred);

            predecessors_until(pred, until, all_predecessors);
        }
    }
}

basic_block* basic_block::get_inloop_predecessors(cfg* parent_cfg, vector<basic_block*>* inlopp_pred) {

    basic_block* main_pred = NULL;
    vector<basic_block*>::const_iterator IT;
    vector<basic_block*>* block_loop_nodes;

    assert(this->is_loop_header(parent_cfg));

    block_loop_nodes = &parent_cfg->get_loop(get_loop_id())->loop_nodes;

    for (IT = predecessors.begin(); IT != predecessors.end(); IT++) {
        basic_block* bb1 = *IT;
        vector<basic_block*>::const_iterator IT2;
        bool is_main = true;

        for (IT2 = block_loop_nodes->begin(); IT2 != block_loop_nodes->end(); IT2++) {
            basic_block* bb2 = *IT2;
            if (bb1->get_id() == bb2->get_id()) {
                is_main = false;
            }
        }

        if (is_main) {
            //cout << "%%%%%%%% " << bb1->get_id() << "\n";
            main_pred = bb1;
        }
    }

    //cout << "$$$$$$$ " << main_pred->get_id() << "\n";
    assert(main_pred);

    for (IT = predecessors.begin(); IT != predecessors.end(); IT++) {
        basic_block* bb = *IT;
        vector<basic_block*>::const_iterator IT2;

        if (bb->get_id() != main_pred->get_id()) {
            inlopp_pred->push_back(bb);
        }
    }

    assert(!inlopp_pred->empty());

    return main_pred;
}

// void basic_block::print_instrunctions() {
//     for (unsigned int i = 0; i < instructions.size(); i++) {
//         instrunction *inst = instructions[i];
// 
//         LOG_NL << "[" << inst->addrress << "] " <<
//                 "Line: " << inst->line <<
//                 " BLK: " << inst->blk_off <<
//                 " TAG: " << inst->tag <<
//                 " Pred: " << inst->prediction << endl;
//     }
// }

void basic_block::add_predecessor(basic_block *precessor) {
    predecessors.push_back(precessor);
}

void basic_block::print_info() {
    cout << "id: " << id << endl;
    cout << "loop: " << loop_id << endl;
    cout << "init_addr: " << ini_addr << endl;
    cout << "end_addr: " << end_addr << endl;
    cout << "cache_always_misses: " << cache_always_misses << endl;
    cout << "cache_first_misses: " << cache_first_misses << endl;
    cout << "sucessors: ";
    for (unsigned int i = 0; i < sucessors.size(); i++)
        cout << sucessors[i]->get_id() << " ";
    cout << endl;
    cout << "predecessors: ";
    for (unsigned int i = 0; i < predecessors.size(); i++)
        cout << predecessors[i]->get_id() << " ";
    cout << endl;
}

void basic_block::print_usefull_cstate() {
    usef_cstate.print();
}

void cfg::print_inst_cstate() {
    LOG << "Basic_block cache state: " << endl;
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        LOG << "id[" << bb->get_id() << "]: " << endl;
        bb->print_inst_cstate();
    }
}

void cfg::print_input_rmb_cstate() {
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        LOG << "id[" << bb->get_id() << "]: " << endl;
        bb->print_input_rmb_cstate();
    }
}

void cfg::print_output_rmb_cstate() {
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        LOG << "id[" << bb->get_id() << "]: " << endl;
        bb->print_output_rmb_cstate();
    }
}

void cfg::print_must_cstate() {
    LOG << endl;
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        LOG_NL << "id[" << bb->get_id() << "]: " << endl;
        bb->print_must_cstate();
    }
}

void cfg::print_output_lmb_cstate() {
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        cout << "id[" << bb->get_id() << "]: " << endl;
        bb->print_output_lmb_cstate();
    }
}

void cfg::print_input_lmb_cstate() {
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        cout << "id[" << bb->get_id() << "]: " << endl;
        bb->print_input_lmb_cstate();
    }
}

void cfg::print_usefull_cstate() {
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        cout << "id[" << bb->get_id() << "]: " << endl;
        bb->print_usefull_cstate();

    }
}

void cfg::print_bb_inst() {
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        LOG << "id: " << bb->get_id() << "[" <<
                bb->get_ini_addr() << "," << bb->get_end_addr() << "]" << endl;
//         bb->print_instrunctions();
    }
}

void cfg::identify_loops() {
    //search for loops in whole program
    bool deteced = tarjan(*this);

    map <int, int> nested_loop_map;
    cfg *loop_cfg;

    //mark all detected loops as an outside loop
    for (unsigned int i = 0; i < loop_list.size(); i++)
        loop_list[i]->outside = true;

    if (deteced == true) {
        //check nesting for all detected loops
        //and add them to the cfg loop list
        vector<loop*>::iterator IT = loop_list.begin();

        while (IT != loop_list.end()) {

            loop *loop_item = *IT;
            loop_item->nested_analize = true;
            int parent = loop_item->id;

            loop_cfg = new_cfg_from_loop(*loop_item);
            deteced = tarjan(*loop_cfg);

            //print_loop_info();

            //tarjan added a new loop
            //correct the iterator and remap the pointers
            if (deteced == true) {
                vector<loop*>::iterator last_ana_IT;
                IT = loop_list.begin();

                //cout << "Parent: " << parent << endl;

                while (IT != loop_list.end()) {
                    loop_item = *IT;
                    if (loop_item->nested_analize == true) {
                        IT++;
                        last_ana_IT = IT;
                    } else {
                        loop_pointer_remap(*loop_item);
                        if (loop_item->outside == false && loop_item->parent == UNDEF) {
                            loop_item->parent = parent;
                            nested_loop_map.insert(make_pair(loop_item->id, parent));
                        }
                        IT++;
                    }
                }
                IT = last_ana_IT;
                delete loop_cfg;
            } else {
                delete loop_cfg;
                IT++;
            }
        }
    }
       
    print_loop_info();
    
    //remove "loops" with the same header:  
    vector<loop*>::iterator IT = loop_list.begin();

    while (IT != loop_list.end()) {
        loop *out_side_loop_item = *IT;
	// cout << "out_side: " << out_side_loop_item->id << endl;
        vector<loop*>::iterator inner_it = IT;
        inner_it++;
        while (inner_it != loop_list.end()) {
            loop *inner_loop_item = *inner_it;
	    //cout << "\tchecking : " << inner_loop_item->id << endl;

            if (out_side_loop_item->root == inner_loop_item->root &&
                    out_side_loop_item->id != inner_loop_item->id) {
               
// 	        cout << "\t\tremoving: " << inner_loop_item->id << endl;
                loop *loop_item = *inner_it;
                int parent_loop_id = loop_item->parent;
	    
// 	        cout << "parent_loop_id: " << parent_loop_id << endl;
                
                while (search_loop_id(parent_loop_id) == false)             {
                    map <int, int>::iterator IT = nested_loop_map.find(parent_loop_id);
                    parent_loop_id = IT->second;
                }
                
                vector<basic_block*>::iterator bb_it;

                for (bb_it = loop_item->loop_nodes.begin();
                        bb_it != loop_item->loop_nodes.end(); bb_it++)
                    (*bb_it)->set_loop_id(parent_loop_id);
		
		//fix child loop id
		vector<loop*>::iterator IT_chid_list = loop_list.begin();
		while (IT_chid_list != loop_list.end()) {
		   loop *loop = *IT_chid_list;  
		  	
		   
		   //cout << "loop: " << loop->id << "   :   " << loop->parent << endl;
		  //cout << "inner_loop_item->id: " <<inner_loop_item->id << endl;
		   
		   
		  if (loop->parent == inner_loop_item->id)  {
		    loop->parent =  parent_loop_id;	  
// 		    cout << "new parent: " << parent_loop_id << endl;
		  }
		    
		  IT_chid_list++;
		}
		
                loop_list.erase(inner_it);
                IT = loop_list.begin();
                inner_it = IT;
                inner_it++;
            } else
                inner_it++;
        }

        IT++;
    }
    

    IT = loop_list.begin();
    
    //fix maps
    while (IT != loop_list.end()) {
       loop *loop = *IT;  
       map <int, int>::iterator IT_l = nested_loop_map.find(loop->id);
       
      //cout << loop->id << endl;
      //cout << loop->root->get_id() << "  :  " << loop->root->get_loop_id() << endl;
      
       vector<basic_block*>::iterator bb_it;

       for (bb_it = loop->loop_nodes.begin(); bb_it != loop->loop_nodes.end(); bb_it++)
	(*bb_it)->set_loop_id(loop->id);                          
	//cout << loop->root->get_id() << "  :  " << loop->root->get_loop_id() << endl;              
	IT++;    
	
     }

  
    //print_loop_info();
    
    //make predecessors_in_loop set
    if (loop_list.empty() == false) {
        for (unsigned int i = 0; i < bb_list.size(); i++) {
            basic_block *bb = bb_list[i];
            basic_block *loop_header;

            if (bb->get_loop_id() != UNDEF) {
                int my_loop = bb->get_loop_id();

                loop_header = loop_list[my_loop]->root;

                bb->predecessors_until(bb, loop_header, &bb->predecessors_in_loop);
            }

//                        set<basic_block*>::iterator it;
//            
//                        cout << "BB:" << bb->get_id() << endl;
//                        for (it = bb->predecessors_in_loop.begin(); it != bb->predecessors_in_loop.end();
//                                it++) 
//                        {
//                            basic_block *bb_in = *it;
//                            cout << "\t" << bb_in->get_id() << endl;
//                        }
        }
    }
    
    for(IT = loop_list.begin(); IT != loop_list.end(); IT++){
        loop* l = *IT;
        l->identify_sinks();
    }
    
   // print_loop_info();

    
//     exit(-1);
}

static bool vector_contains_bb(vector<basic_block*>* bbs, basic_block* bb){
    
    vector<basic_block*>::const_iterator IT;
    
    for(IT = bbs->begin(); IT != bbs->end(); IT++){
        basic_block* bb2 = *IT;
        if(bb2->get_id() == bb->get_id()){
            return true;
        }
    }    
    return false;
}

void loop::identify_sinks(){
    
    vector<basic_block*>::const_iterator IT;
    
    for(IT = loop_nodes.begin(); IT != loop_nodes.end(); IT++){
        basic_block* bb = *IT;
        vector<basic_block*>* suc;
        vector<basic_block*>::const_iterator IT_2;
        suc = &bb->sucessors;
        
        for(IT_2 = suc->begin(); IT_2 != suc->end(); IT_2++){
            basic_block* bb2 = *IT_2;
            if(!vector_contains_bb(&loop_nodes, bb2)){
                sink_bbs.push_back(bb);
                after_node = bb2;
                // only sink and root are actually used by ipet
                sink = bb;
                //return;
            }
        }
    }
    
    // this is not user yet, but may be necessary for future complex ipet
    // loop constraints.
    for(IT = root->predecessors.begin(); IT != root->predecessors.end(); IT++){
        basic_block* bb = *IT;
        if(!vector_contains_bb(&loop_nodes, bb)){
            before_node = bb;
        }
    }
    
    //search before node;
    
    
    return;
}

bool cfg::search_loop_id (int id)
{
      vector<loop*>::iterator IT;
      
      for (IT=loop_list.begin(); IT != loop_list.end(); IT++)
      {
          loop *loop_item = *IT;
          
          if (loop_item->id == id)
              return true;
      }
      
      return false;
}

cfg* cfg::new_cfg_from_loop(loop &loop_item) {
    cfg *new_cfg = new cfg;
    map <basic_block*, basic_block*> copy_map;

    basic_block *loop_root = loop_item.root;

    assert(loop_root != NULL);

    //copy basic blocks to a new CFG
    for (unsigned int i = 0; i < loop_item.loop_nodes.size(); i++) {
        basic_block *source_bb = loop_item.loop_nodes[i];
        basic_block *new_bb = new basic_block;

        *new_bb = *source_bb;
        new_cfg->add_bb(new_bb);

        if (source_bb == loop_root)
            new_cfg->set_root(new_bb);

        copy_map.insert(make_pair(source_bb, new_bb));
    }

    //bool outside_edge = false;
    int n_to_root_edge = 0;

    //rearrange successors and predecessor list
    for (unsigned int i = 0; i < new_cfg->bb_list.size(); i++) {
        basic_block *bb = new_cfg->bb_list[i];

        //		//detect outside edge
        //		if (bb->sucessors.size() > 1)
        //		{
        //			if (copy_map.find(bb->sucessors[0]) == copy_map.end() ||
        //					copy_map.find(bb->sucessors[1]) == copy_map.end())
        //				outside_edge = true;
        //		}

        vector<basic_block*>::iterator IT = bb->sucessors.begin();

        while (IT != bb->sucessors.end()) {
            basic_block *suc = *IT;

            map <basic_block*, basic_block*>::iterator IT_map;
            IT_map = copy_map.find(suc);

            if (IT_map == copy_map.end()) {
                //remove outside loop sucessors
                IT = bb->sucessors.erase(IT);
            } else if (suc->get_id() == loop_root->get_id() && n_to_root_edge == 0) {
                //remove ONE node to root edge
                n_to_root_edge++;
                IT = bb->sucessors.erase(IT);
            } else {
                *IT = IT_map->second;
                IT++;
            }
        }

        IT = bb->predecessors.begin();

        while (IT != bb->predecessors.end()) {
            basic_block *pred = *IT;

            map <basic_block*, basic_block*>::iterator IT_map;
            IT_map = copy_map.find(pred);

            if (IT_map == copy_map.end())
                IT = bb->predecessors.erase(IT);
            else {
                *IT = IT_map->second;
                IT++;
            }
        }
    }

    //at the the of the successors cleanup, at least on edge has to be removed
    //to disconnect a strong connected component
    assert(n_to_root_edge != 0 && n_to_root_edge < 2);

    return new_cfg;
}

void cfg::add_bb(basic_block *bb) {
    map <int, basic_block*>::iterator IT = bb_id_map.find(bb->get_id());

    assert(IT == bb_id_map.end());

    bb_id_map.insert(make_pair(bb->get_id(), bb));
    bb_list.push_back(bb);
}

void cfg::dump_cfg(const char *filename, char* program_name) {
    ofstream file;

    file.open(filename);
    assert(file.is_open() != 0);
    assert(program_name != NULL);


    file << "digraph G {\n"
            "\tlabel = \"" << program_name <<
            "\" splines=true overlap=false\n" << endl;

    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        file << "\t\"" << bb->get_id() << "\""; //bb id
        file << " [ label = \"" << bb->get_id() << " [" << bb->get_ini_addr() << ",";
        file << bb->get_end_addr() << "] \" style = \"filled, solid\" shape = \"";
        if (bb->is_loop_header(this))
            file << "octagon\"]" << endl;
        else
            file << "box\"]" << endl;
    }
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        for (unsigned int j = 0; j < bb->sucessors.size(); j++) {
            basic_block *suc = bb->sucessors[j];

            file << "\t" << bb->get_id() << " -> " << suc->get_id() << endl;
        }
    }

    file << "}" << endl;

    file.close();

    std::stringstream out;
    std::string file_name = filename;

    out << "dot -Tps " << filename << " -o "
            << file_name.replace(file_name.size() - 4, 4, ".pdf");

    system(out.str().c_str());

}

void cfg::dump_cfg_cache(const char *filename, char* program_name) {
    ofstream file;

    file.open(filename);
    assert(file.is_open() != 0);
    assert(program_name != NULL);


    file << "digraph G {\n"
            "\tlabel = \"" << program_name <<
            "\" splines=true overlap=false\n" << endl;

    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        file << "\t\"" << bb->get_id() << "\""; //bb id
        file << " [ label = \"" << bb->get_id() << " [" << bb->get_ini_addr() << ",";
        file << bb->get_end_addr() << "]\\n";
        //cache
        for (unsigned int j = 0; j < bb->my_cstate_output.get_cache_blocks(); j++) {
            set<uint32_t> *cb = bb->my_cstate_output.get_line_set(j);
            set<uint32_t>::iterator it;

            if (cb->empty())
                continue;

            file << "l[" << j << "]=";

            for (it = cb->begin(); it != cb->end(); it++) {
                file << *it << "\\n";

            }

        }
        file << "\\n";
        file << "t=" << bb->get_t() << "\\n";
        file << "c_am=" << bb->get_cache_a_misses() << "\\n";
        file << "c_fm=" << bb->get_cache_f_misses() << "\\n";
        file << "c_cm=" << bb->get_cache_conflicts() << "\\n";

        file << "\" style = \"filled, solid\" shape = \"";


        if (bb->is_loop_header(this))
            file << "octagon\"]" << endl;
        else
            file << "box\"]" << endl;
    }
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        for (unsigned int j = 0; j < bb->sucessors.size(); j++) {
            basic_block *suc = bb->sucessors[j];

            file << "\t" << bb->get_id() << " -> " << suc->get_id() << endl;
        }
    }

    file << "}" << endl;

    file.close();

    std::stringstream out;
    std::string file_name = filename;

    out << "dot -Tpdf " << filename << " -o "
            << file_name.replace(file_name.size() - 4, 4, ".pdf");

    system(out.str().c_str());
}

//function strongconnect(v)
//  // Set the depth index for v to the smallest unused index
//  v.index := index
//  v.lowlink := index
//  index := index + 1
//  S.push(v)
//
//  // Consider successors of v
//  for each (v, w) in E do
//    if (w.index is undefined) then
//      // Successor w has not yet been visited; recurse on it
//      strongconnect(w)
//      v.lowlink := min(v.lowlink, w.lowlink)

//    else if (w is in S) then
//      // Successor w is in stack S and hence in the current SCC
//      v.lowlink := min(v.lowlink, w.index)
//    end if
//  repeat
//
//  // If v is a root node, pop the stack and generate an SCC
//  if (v.lowlink = v.index) then
//    start a new strongly connected component
//    repeat
//      w := S.pop()
//      add w to current strongly connected component
//    until (w = v)
//    output the current strongly connected component
//  end if
//end function

void cfg::tarjan_strong_connect(basic_block* bb, int &index,
        vector<basic_block*> &S) {
    bb->set_tarjan_index(index);
    bb->set_tarjan_llink(index);
    index++;

    S.push_back(bb);

    // Consider successors of bb
    for (unsigned int j = 0; j < bb->sucessors.size(); j++) {
        basic_block *sucessor = bb->sucessors[j];

        if (sucessor->get_tarjan_index() == UNDEF) {
            tarjan_strong_connect(sucessor, index, S);
            bb->set_tarjan_llink(min(bb->get_tarjan_llink(), sucessor->get_tarjan_llink()));
        } else if (search_vector(sucessor, S))
            bb->set_tarjan_llink(min(bb->get_tarjan_llink(), sucessor->get_tarjan_index()));

    }

    // If bb is a root node, pop the stack and generate an SCC
    if (bb->get_tarjan_llink() == bb->get_tarjan_index()) {
        basic_block *pop_bb;

        loop *new_loop = new loop;
        new_loop->id = loop_list.size();
        new_loop->nested_analize = false;

        do {
            pop_bb = S[S.size() - 1];
            pop_bb->set_loop_id(new_loop->id);

            new_loop->loop_nodes.push_back(pop_bb);

            S.pop_back();

        } while (pop_bb != bb);

        if (new_loop->loop_nodes.size() == 1) {
            delete(new_loop);
            pop_bb->set_loop_id(UNDEF);
        } else {
            new_loop->root = pop_bb;
            loop_list.push_back(new_loop);
        }

    }
}

bool cfg::search_vector(basic_block* bb, vector<basic_block*> &S) {
    for (unsigned int i = 0; i < S.size(); i++) {
        basic_block *list_bb = S[i];

        if (bb == list_bb)
            return true;
    }

    return false;
}

void cfg::print_bb_info() {
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        bb->print_info();
        cout << endl;
    }

}

void cfg::print_loop_info() {
    for (unsigned int i = 0; i < loop_list.size(); i++) {
        loop *loop_p = loop_list[i];

        LOG << "loop[" << loop_p->id << "]" << "(" << loop_p->root->get_id() << ")"
                << " par: " << loop_p->parent << " : ";

        for (unsigned int j = 0; j < loop_p->loop_nodes.size(); j++) {
            basic_block *bb = loop_p->loop_nodes[j];
            LOG_NL << bb->get_id() << " ";
        }
        LOG_NL << endl;
    }

}

//	algorithm tarjan is
//	  input: graph G = (V, E)
//	  output: set of strongly connected components (sets of vertices)
//
//	  index := 0
//	  S := empty
//	  for each v in V do
//	    if (v.index is undefined) then
//	      strongconnect(v)
//	    end if
//	  repeat

bool cfg::tarjan(cfg & graph) {
    int index = 0;

    vector<basic_block*> S;

    unsigned int n_loops = loop_list.size();

    for (unsigned int i = 0; i < graph.bb_list.size(); i++) {
        //begin with cfg_root
        assert(graph.root != 0);
        tarjan_strong_connect(graph.root, index, S);

        basic_block *bb = graph.bb_list[i];

        if (bb->get_tarjan_index() == UNDEF)
            tarjan_strong_connect(bb, index, S);
    }

    if (n_loops < loop_list.size())
        return true;

    return false;
}

void cfg::clear_search_states(){
    
    for (unsigned int i = 0; i < bb_list.size(); i++) {
        basic_block *bb = bb_list[i];

        bb->set_search_state(basic_block::NOT_VISITED);
    }
}

int basic_block::get_tarjan_index() {
    return tarjan_index;
}

void basic_block::set_tarjan_index(int index) {
    tarjan_index = index;
}

int basic_block::get_tarjan_llink() {
    return tarjan_llink;
}

int basic_block::get_loop_id() {
    return loop_id;
}

void basic_block::set_loop_id(int id) {
    loop_id = id;
}

uint32_t basic_block::get_ini_addr() {
    return ini_addr;
}

uint32_t basic_block::get_end_addr() {
    return end_addr;
}

void basic_block::set_tarjan_llink(int index) {
    tarjan_llink = index;
}

void cfg::set_root(basic_block * bb) {
    root = bb;
}

void cfg::loop_pointer_remap(loop & loop_item) {
    vector<basic_block*>::iterator IT = loop_item.loop_nodes.begin();

    while (IT != loop_item.loop_nodes.end()) {
        basic_block *bb = *IT;

        map <int, basic_block*>::iterator map_IT = bb_id_map.find(bb->get_id());

        assert(map_IT != bb_id_map.end());

        if (bb == loop_item.root)
            loop_item.root = map_IT->second;

        map_IT->second->set_loop_id(bb->get_loop_id());
        *IT = map_IT->second;


        IT++;
    }
}

basic_block * cfg::get_root() {
    return root;
}
void cfg::dump_cfg_raw(const char *filename){   

    ofstream file;
    
    file.open(filename);
    
    if (!file) {
        cerr << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    } 
    
    uint32_t n_nodes = get_n_bb();
    
    file.write((char*) &n_nodes, sizeof (uint32_t));
    file.write((char*) &wcet, sizeof (uint32_t));
    for (uint32_t i = 0; i < n_nodes; i++) {
        
        basic_block* bb = bb_list[i];
        
        uint32_t node_index = bb->get_id();
        uint32_t node_n_succ = bb->sucessors.size();
        uint32_t node_fi = bb->get_ini_addr();
        uint32_t node_li = bb->get_end_addr();
        uint32_t loop_bound = bb->get_raw_loop_bound();
        uint64_t node_compiler_internal_id = bb->get_compiler_internal_id();
        uint32_t node_count = bb->get_wcc();
        
        
        file.write((char*) &node_index, sizeof (uint32_t));
        file.write((char*) &node_n_succ, sizeof (uint32_t));
        file.write((char*) &node_fi, sizeof (uint32_t));
        file.write((char*) &node_li, sizeof (uint32_t));
        file.write((char*) &loop_bound, sizeof (int32_t)); //
        file.write((char*) &node_compiler_internal_id, sizeof (uint64_t));
        file.write((char*) &node_count, sizeof (uint32_t));

    }   
    
    for (uint32_t i = 0; i < n_nodes; i++) {
        
        basic_block* bb = bb_list[i];
        
        for (unsigned int i = 0; i < bb->sucessors.size(); i++) {
            uint32_t succ_index;
            basic_block* bb_succ = bb->sucessors[i];
            succ_index = bb_succ->get_id();

            file.write((char*) &succ_index, sizeof (uint32_t));
        }
        
    } 
}

cfg::cfg(const char* filename, cfg_specs* new_cfg_specs) {


    ifstream file;
    uint32_t n_nodes;
    uint32_t wcet;

    file.open(filename);

    if (!file) {
        cerr << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }

    //reading the number of nodes
    if (!file.read((char*) &n_nodes, sizeof (uint32_t))) {
        std::cerr << std::strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }
        //reading the number of nodes
    if (!file.read((char*) &wcet, sizeof (uint32_t))) {
        std::cerr << std::strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }
    //std::cout << "nodes: " << n_nodes << "\n";
    //std::cout << "wcet: " << wcet << "\n";

    for (uint32_t i = 0; i < n_nodes; i++) {
        uint32_t node_index;
        uint32_t node_n_succ;
        uint32_t node_fi;
        uint32_t node_li;
        int32_t loop_bound;
        uint64_t node_compiler_internal_id;
        uint32_t count;
        
        file.read((char*) &node_index, sizeof (uint32_t));
        file.read((char*) &node_n_succ, sizeof (uint32_t));
        file.read((char*) &node_fi, sizeof (uint32_t));
        file.read((char*) &node_li, sizeof (uint32_t));
        file.read((char*) &loop_bound, sizeof (int32_t));
        
        file.read((char*) &node_compiler_internal_id, sizeof (uint64_t));
        file.read((char*) &count, sizeof (uint32_t));

        //node_fi += initial_offset / 4;
        //node_li += initial_offset / 4;

        //std::cout << "\nbasic block index: " << node_index << "\n";
        //std::cout << "----loop bound: " << loop_bound << "\n";
	
	
	bb_specs* mods = new_cfg_specs->modify_bb(node_index);   
	
	if (mods != NULL){
	  LOG << "Modifying bb ini and end addresses : " << node_index << " via CFG/CODE specsc class" << endl;
	  node_fi = mods->ini_addr;
	  node_li = mods->end_addr;
	}
	
        
        basic_block* bb = new basic_block(node_index, node_fi, node_li);
        bb->set_raw_loop_bound(loop_bound);
        bb->set_compiler_internal_id(node_compiler_internal_id);
        bb->sucessors.reserve(node_n_succ);        

        uint32_t succ_index = 0;
        while (succ_index < node_n_succ) {	 
	    bb->sucessors.push_back(NULL);
            succ_index++;
        }

       // VLIW_bundle_parser::create_bundle_seq(NULL, 0, 0);
        //bb_list.push_back(bb);
        
        add_bb(bb);
    }

    for (vector<basic_block*>::const_iterator IT = bb_list.begin();
            IT != bb_list.end(); ++IT) {
        basic_block* bb = *IT;
        
        for (unsigned int i = 0; i < bb->sucessors.size(); i++) {
             uint32_t succ_index;
            unsigned type;
            basic_block* bb_succ;

            file.read((char*) &succ_index, sizeof (uint32_t));
            file.read((char*) &type, sizeof (unsigned));
            bb_succ = bb_list[succ_index];

            bb->sucessors[i] = bb_succ;

            bb_succ->predecessors.push_back(bb);
            //std::cout << "sucessor: " << bb_succ->get_id() << "\n";
            bb->sucessor_flow_type.insert(make_pair(bb_succ->get_id(), type));
        }
    } 
    
    if (new_cfg_specs)
    {    
      for (vector<basic_block*>::const_iterator IT = bb_list.begin();
	      IT != bb_list.end(); ++IT) {
	  basic_block* bb = *IT;
	    
	  bb_specs* mods = new_cfg_specs->modify_bb(bb->get_id());      
          
      
	  if (mods != NULL) {
	    LOG << "Modifying bb sucessors and predecessors : " << bb->get_id() << " via CFG/CODE specsc class" << endl;

	    // remove sucessors
	    for (int i = 0; i < mods->succ_to_remove.size(); i++)  { 
	      for (int j=0; j < bb->sucessors.size(); j++)  {
		basic_block* suc = bb->sucessors[j];
		
		if (suc->get_id() == mods->succ_to_remove[i])		{
		  LOG << "\t Removing sucessor: " << suc->get_id() << endl;  
		 
		  bb->sucessors.erase(bb->sucessors.begin() + j);		 
		  vector<basic_block*>::iterator pred_it;
		  pred_it = find (suc->predecessors.begin(), suc->predecessors.end(), bb);
		  
		  if (pred_it != suc->predecessors.end())  {
// 		    std::cout << "Element found in myvector: " << *pred_it << '\n';
		    suc->predecessors.erase(pred_it);
		  }
		  else  {
// 		    std::cout << "Element not found in myvector\n";
		  }
		  
		  break;
		  
		}		
	      }
	    }
	    
	   //change flow type 
	   for (int j=0; j < bb->sucessors.size(); j++){
	    basic_block* suc = bb->sucessors[j];

	    map<int, unsigned>::iterator cur_map;
	    map<int, unsigned>::iterator new_map;
	    
	    cur_map = bb->sucessor_flow_type.find(suc->get_id());	    
	    new_map = mods->new_flow_type.find(suc->get_id());

	    if (new_map != mods->new_flow_type.end()){	      
	      if (cur_map != bb->sucessor_flow_type.end()) {
		bb->sucessor_flow_type.erase (cur_map);     
		bb->sucessor_flow_type.insert(make_pair(new_map->first, new_map->second));
	      }
	   }
	 }
	 	    
	 // add sucessors
	for (int j = 0; j < mods->succ_to_add.size(); j++) {        
	      if (mods->succ_to_add[j] < bb_list.size()){
		basic_block *suc = bb_list[mods->succ_to_add[j]];		
		bb->sucessors.push_back(suc);		
		suc->predecessors.push_back(bb);		
		bb->sucessor_flow_type.insert(make_pair(suc->get_id(), 0));		
	      }
	      else
		assert(0 && "Invalid sucessor node");      
	      
	    }	    
	  }       
      }    
    }
    
   
    //assert(cfg_entry == 1 && "Fatal: Reading a CFG file with wrong number of entries.");
    //assert(cfg_exit == 1 && "Fatal: Reading a CFG file with with wrong number of entries.");

    set_root(bb_list.front());
    set_wcet(0);
}

int cfg::get_n_edges() {
    int n = 0;

    for (vector<basic_block*>::const_iterator IT = bb_list.begin();
            IT != bb_list.end(); ++IT) {
        basic_block* bb = *IT;
        n += bb->sucessors.size();
    }
    return n;
}

uint32_t basic_block::get_edge_time(basic_block * from) {

    map <basic_block*, unsigned int>::iterator IT;

    IT = predecessor_t.find(from);

    assert(IT != predecessor_t.end());

    return IT->second;
}

uint32_t basic_block::get_edge_ftime(basic_block * from) {

    map <basic_block*, unsigned int>::iterator IT;

    IT = predecessor_t_fmiss.find(from);

    assert(IT != predecessor_t_fmiss.end());

    return IT->second;
}

unsigned int basic_block::get_number_instructions()
{
  unsigned int size = 0;  
  vector<VLIW_bundle*>::iterator ITb;	
     
  for (ITb = bundles.begin(); ITb != bundles.end(); ITb++) {
      VLIW_bundle* bundle = *ITb;
      
      size += bundle->instructions.size();	    
  }
  
  return size;  
}


bool cfg_specs::ignore_succ(int my_id, int succ_id)
{
    
  for (int i = 0; i < bbs_to_modify.size(); i++)
   {
     bb_specs *bb = bbs_to_modify[i];
     
     if (bb->bb_id == my_id)
     {
       
       cout << my_id << endl;
       
      vector<int>::iterator it;
      it = find (bb->succ_to_remove.begin(), bb->succ_to_remove.begin(), succ_id);          
      
      if (it != bb->succ_to_remove.end())
      {
	
	cout << *it << endl;
	
	return true;     
      }
     }
   }
   
   return false;
}


bb_specs* cfg_specs::modify_bb(int my_id)
{
    
  for (int i = 0; i < bbs_to_modify.size(); i++)
   {
     bb_specs *bb = bbs_to_modify[i];
     
     if (bb->bb_id == my_id)
      return bb;          
     
   }
   
   return NULL;
}