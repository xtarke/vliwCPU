/* 
 * File:   cache_analisys.cpp
 * Author: xtarke
 * 
 * Created on June 17, 2013, 7:32 PM
 */

#include "cache_analisys.h"
#include "cfg.h"
#include "logger.h"

//cache_analisys::cache_analisys() {
//}
//
//cache_analisys::cache_analisys(const cache_analisys& orig) {
//}

//cache_analisys::~cache_analisys() {
//}

void cache_analysis::analize() {
    calc_rmb_cstate();
    calc_lmb_cstate();

    classify_instr();
}

void cache_analysis::calc_must_cstate() {
    vector<basic_block*>* bb_list = graph->get_bbs();
    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];

        //cout << bb->get_id() << ": " << endl;

        for (unsigned int j = 0; j < bb->my_cstate.get_cache_blocks(); j++) {
            //cout << "\t" << bb->rmb_cstate.get_references_size(j) << endl;

            //            if (bb->rmb_cstate.get_references_size(j) == 1
            //                    && bb->my_cstate_output.get_references_size(j) == 0) {
            if (bb->rmb_cstate.get_references_size(j) == 1) {
                set<uint32_t> *cb;
                set<uint32_t>::iterator it;
                bool is_must = false;

                if (bb->my_cstate_output.get_references_size(j) == 1) {
                    cb = bb->rmb_cstate.get_line_set(j);
                    it = cb->begin();

                    bb->must_cstate.add_tag(*it, j);
                }

                if (bb->my_cstate_output.get_references_size(j) == 0) {
                    cb = bb->rmb_cstate.get_line_set(j);
                    it = cb->begin();
                    is_must = is_always_accessed(graph, bb, *it, j);

//                                        cout << "\tChecking: " << j << "," << *it << " :: " <<
//                                                is_must << endl;

                    if (is_must)
                        bb->must_cstate.add_tag(*it, j);
                }
            }
        }
    }

}

void cache_analysis::log() {
    vector<basic_block*>* bb_list = graph->get_bbs();

    //all basic blocks
    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];

        assert(bb->get_t() != 0 && "Basic Block time cannot be 0!");

        //all instructions
        for (unsigned int j = 0; j < bb->bundles.size(); j++) {
            VLIW_bundle* bundle = bb->bundles[j];

            if (bundle->prediction == A_MISS)
                LOG << "Miss @: " << bb->get_ini_addr() + j << "\tA_MISS (" << bb->get_id() << ")" << endl;
            if (bundle->prediction == F_MISS)
                LOG << "Miss @: " << bb->get_ini_addr() + j << "\tF_MISS (" << bb->get_id() << ")" << endl;
            if (bundle->prediction == CONFLICT) {
                for (unsigned int k = 0; k < bb->predecessors.size(); k++) {
                    basic_block *pred = bb->predecessors[k];
                    map <basic_block*, unsigned int>::iterator IT;

                    IT = bb->predecessor_t.find(pred);
                    if (IT->second > bb->get_t())
                        LOG << "Miss @: " << bb->get_ini_addr() + j << "\tC_MISS (" << bb->get_id() << ")" << endl;

                    IT = bb->predecessor_t_fmiss.find(pred);
                    if (IT->second > bb->get_t())
                        LOG << "Miss @: " << bb->get_ini_addr() + j << "\tC_f_MISS (" << bb->get_id() << ") " << endl;
                }
            }
        }
    }

}

void cache_analysis::calc_rmb_cstate() {
    vector<basic_block*>* bb_list = graph->get_bbs();

    bool change = true;

    while (change) {
        change = false;

        for (unsigned int i = 0; i < bb_list->size(); i++) {
            basic_block *bb = (*bb_list)[i];

            //cout << "Analyzing bb: " << bb->get_id() << endl;

            bb->clear_input_rmb_cstate();

            for (unsigned int j = 0; j < bb->predecessors.size(); j++) {
                basic_block *pred = bb->predecessors[j];

                //cout << "\t pred: " << pred->get_id() << endl;;

                copy_cstate(&pred->rmb_cstate, &bb->input_rmb_cstate);
            }

            cache_state *temp = new cache_state;

            copy_cstate(&bb->my_cstate_output, temp);
            copy_cstate(&bb->input_rmb_cstate, temp);

            change = change | make_output_cstate(temp, &bb->rmb_cstate, &bb->my_cstate_output);

            delete(temp);
        }
    }
}

void cache_analysis::calc_lmb_cstate() {
    vector<basic_block*>* bb_list = graph->get_bbs();

    bool change = true;

    while (change) {
        change = false;

        for (unsigned int i = 0; i < bb_list->size(); i++) {
            basic_block *bb = (*bb_list)[i];

            //cout << "Analyzing bb: " << bb->get_id() << endl;

            bb->clear_output_lmb_cstate();

            for (unsigned int j = 0; j < bb->sucessors.size(); j++) {
                basic_block *suc = bb->sucessors[j];

                //cout << "\t pred: " << suc->get_id() << endl;

                copy_cstate(&suc->lmb_cstate, &bb->output_lmb_cstate);
            }

            cache_state *temp = new cache_state;

            copy_cstate(&bb->my_cstate_input, temp);
            copy_cstate(&bb->output_lmb_cstate, temp);

            change = change | make_output_cstate(temp, &bb->lmb_cstate, &bb->my_cstate_input);

            delete(temp);
        }
    }
}

bool cache_analysis::make_output_cstate(cache_state* cs_source, cache_state* output_cstate,
        cache_state* inst_cstate) {
    bool added = false;

    for (unsigned int i = 0; i < cs_source->get_cache_blocks(); i++) {
        //output cache state depends what basic block accecess
        //do not add a referece if inst_cstate uses it

        if (inst_cstate->is_empty(i)) {
            set<uint32_t> *cb = cs_source->get_line_set(i);
            set<uint32_t>::iterator it;

            for (it = cb->begin(); it != cb->end(); it++) {
                uint32_t tag = *it;
                added = added | output_cstate->add_tag(tag, i);
            }
        } else {
            if (output_cstate->is_empty(i))
                added = true;

            output_cstate->clear_index(i);

            set<uint32_t> *cb = inst_cstate->get_line_set(i);
            set<uint32_t>::iterator it;

            for (it = cb->begin(); it != cb->end(); it++) {
                uint32_t tag = *it;
                output_cstate->add_tag(tag, i);
            }
        }
    }

    return added;
}

void cache_analysis::calc_usef_cstate() {

    vector<basic_block*>* bb_list = graph->get_bbs();

    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];

        unsigned int cache_line_size = bb->my_cstate.get_cache_blocks();

        for (unsigned int i = 0; i < cache_line_size; i++) {
            set<uint32_t> *rmb_cb = bb->rmb_cstate.get_line_set(i);
            set<uint32_t>::iterator it;

            for (it = rmb_cb->begin(); it != rmb_cb->end(); it++) {
                uint32_t tag = *it;

                if (bb->lmb_cstate.search_tag(tag, i))
                    bb->usef_cstate.add_tag(tag, i);
            }
        }

    }
}

bool cache_analysis::copy_cstate(cache_state* cs_source, cache_state * cs_dest) {
    bool added = false;

    for (unsigned int i = 0; i < cs_source->get_cache_blocks(); i++) {
        set<uint32_t> *cb = cs_source->get_line_set(i);
        set<uint32_t>::iterator it;

        for (it = cb->begin(); it != cb->end(); it++) {
            uint32_t tag = *it;
            added = added | cs_dest->add_tag(tag, i);
        }
    }

    return added;
}

void cache_analysis::classify_instr() {

    int x = 0;
  
    vector<basic_block*>* bb_list = graph->get_bbs();

    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];
        cache_state *input_rmb_cs = &bb->input_rmb_cstate;
        cache_state *live_cs = &bb->output_lmb_cstate;
        cache_state *usef_cs = &bb->usef_cstate;	

        for (unsigned int j = 0; j < bb->bundles.size(); j++) {
            VLIW_bundle* bundle = bb->bundles[j];
            uint32_t tag = bundle->tag;
            uint32_t blk_off = bundle->blk_off;
            uint32_t line = bundle->line;

            //internal compulsory misses are always miss:
            //internal instruction conflicting with another internal instruction
            if (bb->bundles.size() > bb->my_cstate.get_size()) {
                if (bb->my_cstate.get_references_size(line) > 1) {
                    if (blk_off == 0 || j == 0)
		    {
                        bundle->prediction = A_MISS;
			bb->a_misses_b_index.push_back(j);		      
		    }
                    else
                        bundle->prediction = A_HIT;
                    continue;
                }
            }

            //if my tag is not in the input cache state
            if (input_rmb_cs->search_tag(tag, line) == false) {
                //first instruction of the cache line is a miss
                //miss if the first instruction of the basic is not cache aligned
                if (blk_off == 0 || j == 0)
		{
                    bundle->prediction = A_MISS;
		    bb->a_misses_b_index.push_back(j);
		}
                else
                    bundle->prediction = A_HIT;
            } else {
                //first bb instruction or first block of cache line               
                if (blk_off == 0 || j == 0) {

                    set<uint32_t> *rmb_cb = input_rmb_cs->get_line_set(line);
                    set<uint32_t> *live_cb = live_cs->get_line_set(line);

                    ////////////////////////////////////
                    ///////////////////////////////////
                    //      outside loops     /////////
                    ////////////////////////////////////
                    //the most simple case, two blocks in the input and two predecessors, no loop
                    if (input_rmb_cs->get_references_size(line) >= 1 &&
                            bb->predecessors.size() > 1 &&
                            bb->get_loop_id() == UNDEF) {
                        bundle->prediction = CONFLICT;
			bb->conflict_b_index.push_back(j);
                        //                    } else if (input_rmb_cs->get_references_size(line) == 1 &&
                        //                            bb->predecessors.size() > 1 &&
                        //                            bb->get_loop_id() == UNDEF) {
                        //                        ins->prediction = A_HIT;
                        /////////////////////////////////////////
                        //second simple case, one predecessor, lot of references in my line
                    } else if (input_rmb_cs->get_references_size(line) > 1 &&
                            bb->predecessors.size() == 1 &&
                            bb->get_loop_id() == UNDEF) {
                        bundle->prediction = A_MISS;
			bb->a_misses_b_index.push_back(j);
                        /////////////////////////////////////////
                        //third simple case, one predecessor, one references in my line      
                    } else if (input_rmb_cs->get_references_size(line) == 1 &&
                            bb->predecessors.size() == 1 &&
                            search_must_cset(bb, tag, line) &&
                            bb->get_loop_id() == UNDEF) {
                        bundle->prediction = A_HIT;

                        ////////////////////////////////////
                        ///////////////////////////////////
                        //      inside loops     /////////
                        ////////////////////////////////////
                    } else if (bb->is_loop_header(graph)) {
//                         if (search_f_miss_loop_header(bb, tag, line) == false &&
//                                 check_for_nested_loop_liveness(bb, tag, line) &&
//                                 search_input_out_side_node(bb, tag, line) == true){
 			  if (bb->must_cstate.search_tag(tag,line) && (bb->must_cstate.get_references_size(line) == 1)){
                           
// 			  cout << "BB_loop f_miss:" << bb->get_id() << endl;
// 			  
// 			  cout << "\t tag: " << tag << " Line:" << line << endl;
// 			  cout << "\tsearch_f_miss_loop_header(bb, tag, line)" << search_f_miss_loop_header(bb, tag, line) << endl;
// 			  cout << "\tcheck_for_nested_loop_liveness(bb, tag, line)" << check_for_nested_loop_liveness(bb, tag, line) << endl;
// 			  cout << "\tsearch_input_out_side_node(bb, tag, line)" << search_input_out_side_node(bb, tag, line) << endl;
			
			  
			  bb->get_loop_id();			  
			  loop* my_loop = graph->get_loop(bb->get_loop_id());
			  
			  //check if it is a nested loop
			  if (my_loop->parent != UNDEF){			  
			    basic_block *out_loop;
			    vector<basic_block*> in_loop_pred;

			    out_loop = bb->get_inloop_predecessors(graph, &in_loop_pred);
						  
			    graph->clear_search_states();
			   			   
// 			    cout << "my_loop->parent: " << my_loop->parent << endl;
			    
			    if (is_always_accessed_inside_loop(graph,out_loop,tag,line, my_loop->parent))  {
// 				cout << "is_always_accessed_inside_loop: true" << endl;
				bundle->prediction = A_HIT;				
			    } 
			    else 
			    {
			      bundle->prediction = F_MISS;
			      bb->f_misses_b_index.push_back(j);      
// 			      cout << "is_always_accessed_inside_loop: FALSE" << endl;
			    }
			  }
			  else
			  {
			    bundle->prediction = F_MISS;
			    bb->f_misses_b_index.push_back(j);				    
			  }
			  			
			}
                        else
			{
			  
// 			  cout << "BB_loop conflict:" << bb->get_id() << endl;
// 			  
// 			  cout << "\t tag: " << tag << " Line:" << line << endl;
// 			  cout << "\tsearch_f_miss_loop_header(bb, tag, line)" << search_f_miss_loop_header(bb, tag, line) << endl;
// 			  cout << "\tcheck_for_nested_loop_liveness(bb, tag, line)" << check_for_nested_loop_liveness(bb, tag, line) << endl;
// 			  cout << "\tsearch_input_out_side_node(bb, tag, line)" << search_input_out_side_node(bb, tag, line) << endl;			
			  
                          bundle->prediction = CONFLICT;
			  bb->conflict_b_index.push_back(j);
			}
                    }//conflict inside a loop
                        /////////////////////////////////////////
                    else if (input_rmb_cs->get_references_size(line) > 1 &&
                            bb->predecessors.size() > 1 &&
                            bb->get_loop_id() != UNDEF &&
                            predecessor_out_rmb_search_tag(bb, tag, line) == false) {
                        bundle->prediction = CONFLICT;
			bb->conflict_b_index.push_back(j);
                        /////////////////////////////////////////
                    } else if (bb->get_loop_id() != UNDEF &&
                            input_rmb_cs->get_references_size(line) == 1 &&
                            bb->predecessors.size() == 1) {

                        if (search_for_false_hits(bb, tag, line) && search_must_cset(bb, tag, line))
                            bundle->prediction = A_HIT;
                        else
			{
                            bundle->prediction = F_MISS;
			    bb->f_misses_b_index.push_back(j);
			}
		    }
		    /* Added debuging fibcall bechmark *
		    * particular loop structure       */ 		     
		    else if (bb->get_loop_id() != UNDEF &&
                            input_rmb_cs->get_references_size(line) == 1 &&
                            bb->predecessors.size() > 1) {

                        if (search_for_false_hits(bb, tag, line) && search_must_cset(bb, tag, line))
                            bundle->prediction = A_HIT;
                        else
			{
                            bundle->prediction = F_MISS;
			    bb->f_misses_b_index.push_back(j);
			}			

                        /////////////////////////////////////////
                    } else if (bb->get_loop_id() != UNDEF &&
                            input_rmb_cs->get_references_size(line) > 1 &&
                            bb->predecessors.size() == 1 &&
                            bb->predecessors[0]->get_loop_id() != bb->get_loop_id()) {
                      
// 		      cout << "--------------" << endl;
// 		      
// 		      cout << "BB: " << bb->get_id() << endl;
// 		      cout << bundle->address << endl;
// 		      cout << "ref_size:" <<  input_rmb_cs->get_references_size(line) << endl;
// 		      		      
// 		      cout << "blk:" <<  bundle->blk_off << endl;
// 		      cout << "line:" << bundle->line << endl;
// 		    
// 		      cout << "pred loop id: " << bb->predecessors[0]->get_loop_id() << endl;
// 		      cout << "my loop id: " << bb->get_loop_id() << endl;
// 		      
// 		      cout << "get loop parent: " <<  get_loop_parent(bb->predecessors[0]->get_loop_id());
// 		      
// 		      cout << "--------------" << endl;
		    
		      //check if pred loop is child of my loop
		      if (bb->get_loop_id() == get_loop_parent(bb->predecessors[0]->get_loop_id())) {			
			 if (search_for_false_hits(bb, tag, line) && search_must_cset(bb, tag, line))
                            bundle->prediction = A_MISS;
                        else
			{
                            bundle->prediction = F_MISS;
			    bb->f_misses_b_index.push_back(j);
			    
// 			    cout << "--------------" << endl;
//  		      
// 			    cout << "BB: " << bb->get_id() << endl;
// 			    
// 			    cout << "--------------" << endl;
			    
			}
			
		      } else {     		      
			bundle->prediction = A_MISS;
			bb->a_misses_b_index.push_back(j);
		      }

                    } else if (bb->get_loop_id() != UNDEF &&
                            input_rmb_cs->get_references_size(line) > 1 &&
                            search_cache_conflicts(bb->get_loop_id(), tag, line) == false) {
                        bundle->prediction = F_MISS;
			bb->f_misses_b_index.push_back(j);			
		    
//                    } else if (bb->get_loop_id() != UNDEF &&
//                            input_rmb_cs->get_references_size(line) > 1 &&
//                            check_for_nested_loop_liveness(bb, tag, line)) {
//                        ins->prediction = F_MISS;
                    } else if (bb->get_loop_id() != UNDEF &&
                            input_rmb_cs->get_references_size(line) == 1 &&
                            predecessor_out_rmb_search_tag(bb, tag, line) == true &&
                            search_must_cset(bb, tag, line)) {
                        bundle->prediction = A_HIT;
                    } else
		    {
                        bundle->prediction = A_MISS;
			bb->a_misses_b_index.push_back(j);
		    }


                } else
                    bundle->prediction = A_HIT;
            }
        }
    }
}

// When there is a HIT inside a loop, cache analysis has to check state of the 
// predecessors until loop_header
// returns true, if a cache tag should classified as A_HIT

bool cache_analysis::search_for_false_hits(basic_block *bb, int tag, int c_line) {

    assert(bb->get_loop_id() != UNDEF);
    assert(bb->is_loop_header(graph) != true);

    set<basic_block*>::iterator it;

    bool found = false;

    for (it = bb->predecessors_in_loop.begin(); it != bb->predecessors_in_loop.end(); it++) {
        basic_block *pred = *it;

        found = found | pred->my_cstate_output.search_tag(tag, c_line);

        if (pred->is_loop_header(graph)) {
            //            found = found | pred->my_cstate_output.search_tag(tag, c_line);
            //
            //            for (unsigned int i = 0; i < pred->predecessors.size(); i++) {
            //                basic_block *outside = pred->predecessors[i];
            //                if (outside->get_loop_id() != pred->get_loop_id())
            //                    found = found | outside->rmb_cstate.search_tag(tag, c_line);
            //            }            
            found = found | search_f_miss_loop_header(pred, tag, c_line);
        }

        //cout << "Found: " << found << " pred: " << pred->get_id() << endl;
    }

    return found;
}

bool cache_analysis::search_must_cset(basic_block *bb, int tag, int c_line) {
    bool found = true;

    // search if my cache block is a MUST classification in all my predecessors
    for (unsigned int i = 0; i < bb->predecessors.size(); i++) {
        basic_block *pred = bb->predecessors[i];

        found = found & pred->must_cstate.search_tag(tag, c_line);
    }

    return found;
}

bool cache_analysis::search_f_miss_loop_header(basic_block *bb, int tag, int c_line) {
    vector<basic_block*> in_loop_pred;
    
    set<basic_block*> out_loop_pred;
    basic_block *out_loop;

    int loop_entry_id = bb->get_loop_id();
    int parent = get_loop_parent(loop_entry_id);

    out_loop = bb->get_inloop_predecessors(graph, &in_loop_pred);
    out_loop_pred.insert(out_loop);
 
    while (parent != UNDEF) {
        basic_block *root = get_loop_root(parent);
        //        cout << "P: " << parent << endl;

        out_loop_pred.insert(root);
        out_loop = root->get_inloop_predecessors(graph, &in_loop_pred);
        out_loop_pred.insert(out_loop);
        loop_entry_id = parent;

        parent = get_loop_parent(parent);
    }

//     cout << "\t loop_entry: " << loop_entry_id << endl;

    //construct the test set
    set<basic_block*>::iterator it;
    for (it = out_loop->predecessors_in_loop.begin();
            it != out_loop->predecessors_in_loop.end(); it++) {
        basic_block *pred = *it;
        out_loop_pred.insert(pred);
    
//         cout << "\t Test set: " << pred->get_id() << endl;
    
    }

    bool found = false;

    //cout << "search_f_miss_loop_header: " << loop_entry_id << endl;
    //    for (it = out_loop_pred.begin(); it != out_loop_pred.end(); it++)
    //    {
    //        basic_block *pred_in_loop = *it;
    //        
    //        cout << "\t " << pred_in_loop->get_id() << endl;
    //        
    //    }

    for (it = out_loop_pred.begin(); it != out_loop_pred.end(); it++) {
        basic_block *pred_in_loop = *it;

        //        if (pred_in_loop->is_loop_header(graph) &&
        //                pred_in_loop->get_loop_id() == loop_entry_id) {
        //
        //            for (unsigned int i = 0; i < pred_in_loop->predecessors.size(); i++) {
        //                basic_block *pred = pred_in_loop->predecessors[i];
        //
        //                if (pred->get_loop_id() != pred_in_loop->get_loop_id()) {
        //                    found = found | pred->rmb_cstate.search_tag(tag, c_line);
        //
        //                    //cout << "\t" << pred->get_id() << ": " << pred->rmb_cstate.search_tag(tag, c_line) << endl;
        //                }
        //            }
        //
        //        }
	
// 	 cout << "\t Test set: " << pred_in_loop->get_id() << endl;
	
        if (pred_in_loop->get_loop_id() == UNDEF) {
            found = found | pred_in_loop->rmb_cstate.search_tag(tag, c_line);
        } else {

            found = found | pred_in_loop->my_cstate_output.search_tag(tag, c_line);
        }

        //cout << "\t" << pred_in_loop->get_id() << ":" << "l[" << c_line << "]=" << tag << " -> " << found << endl;
    }

    //    bool conflict = false;
    //    
    //    //if my cache_blocks is not found, check if there is a conflict
    //    if (found == false) {
    //        
    //       set<basic_block*>::iterator it;
    //        
    //        for (it = out_loop_pred.begin(); it != out_loop_pred.end(); it++) {
    //            basic_block *pred_in_loop = *it;
    //            set<uint32_t> *cb;
    //            set<uint32_t>::iterator cb_it;
    //            
    //            if (pred_in_loop->get_loop_id() == loop_entry_id) {
    //                //my_cstate has only one tag
    //                cb = pred_in_loop->my_cstate.get_line_set(c_line);
    //                
    //                for (cb_it = cb->begin(); cb_it != cb->end(); cb_it++)
    //                {
    //                    uint32_t pred_tag = *cb_it;
    //                    
    //                    if (pred_tag != tag)
    //                    {
    //                        conflict = true;
    //                        break;
    //                    }
    //                }
    //            }
    //
    //        }
    //    }
    //
    //    cout << "\t conf: " << conflict << endl;

//     cout << "search_f_miss_loop_header: " << found << endl;
    
    return found; // | conflict;
}

// int cache_analysis::get_loop_parent(int loop_id) {
//     vector<loop*>* loop_list = graph->get_loops();
// 
//     assert(loop_id < loop_list->size());
// 
//     return (*loop_list)[loop_id]->parent;
// }

int cache_analysis::get_loop_parent(int loop_id) {
    loop* loop = graph->get_loop(loop_id);

    //assert(loop_id < loop_list->size());

    return loop->parent;
}

basic_block* cache_analysis::get_loop_root(int loop_id) {
   /* depracated since loop-ids do not follow array index anymore *
    vector<loop*>* loop_list = graph->get_loops();
    assert(loop_id < loop_list->size());
    return (*loop_list)[loop_id]->root; */
   
    loop* my_loop = graph->get_loop(loop_id);
    
    return my_loop->root;   
}

//search if a input node of a loop header contents my cache reference

bool cache_analysis::search_input_out_side_node(basic_block *bb, int tag, int c_line) {
    vector<basic_block*> in_loop_pred;
    basic_block* out_loop_pred;

    assert(bb->is_loop_header(graph));

    out_loop_pred = bb->get_inloop_predecessors(graph, &in_loop_pred);

    assert(out_loop_pred != 0);

    return out_loop_pred->rmb_cstate.search_tag(tag, c_line);
}

bool cache_analysis::search_cache_conflicts(int loop_id, int tag, int c_line) {
    
    /* depracated since loop-ids do not follow array index anymore *
    vector<loop*>* loop_list = graph->get_loops();
    std::cout << "" << loop_id<< " " << loop_list->size() << "\n";
    assert(loop_id < loop_list->size()); 
        
    for (IT = (*loop_list)[loop_id]->loop_nodes.begin(); IT != (*loop_list)[loop_id]->loop_nodes.end(); IT++) {    
    *******************************************/
    
    loop* my_loop = graph->get_loop(loop_id);     
    vector<basic_block*>::iterator IT;
    

    for (IT = my_loop->loop_nodes.begin(); IT != my_loop->loop_nodes.end(); IT++) {
        basic_block *bb = *IT;

        bool found = bb->my_cstate_output.search_tag(tag, c_line);
        unsigned int size = bb->my_cstate_output.get_references_size(c_line);

        //if tag is not found and some other block is referenced: conflict
        if (found == false && size > 0)
            return true;

    }

    return false;
}

//search for cache block conflits in predecessor nodes to discard falses f-miss in loop headers
//bool cache_analysis::s

bool cache_analysis::check_for_nested_loop_liveness(basic_block *bb, int tag, int c_line) {
    set<uint32_t> *inter_set = new set<uint32_t>;

    bool ret = false;

    cache_state *input_rmb_cs = &bb->input_rmb_cstate;
    cache_state *output_lmb_cs = &bb->output_lmb_cstate;

    set<uint32_t> *rmb_cb = input_rmb_cs->get_line_set(c_line);
    set<uint32_t> *lmb_cb = output_lmb_cs->get_line_set(c_line);

    input_rmb_cs->set_intersec(inter_set, rmb_cb, lmb_cb);

    if (inter_set->find(tag) != inter_set->end() && inter_set->size() == 1)
        ret = true;
    else
        ret = false;

    delete inter_set;

    return ret;
}

//check is the intersection of RMBin and LMBout have a specific tag e only this tag 
//if true, this block should considered f_miss only: some basic block access its tag
//before him

bool cache_analysis::predecessor_out_rmb_search_tag(basic_block *bb, int tag, int c_line) {
    assert(bb != 0);
    assert(c_line < bb->my_cstate_output.get_cache_blocks());

    bool in = true;
    for (unsigned int i = 0; i < bb->predecessors.size(); i++) {
        basic_block *pre = bb->predecessors[i];

        in = in & pre->rmb_cstate.search_tag(tag, c_line);
    }

    return in;
}

bool cache_analysis::is_always_accessed(cfg* parent_cfg, basic_block* bb, int tag, int c_line) {

    bool always_accessed = true;

    parent_cfg->clear_search_states();

//    if (bb->is_loop_header(parent_cfg)) {
//        vector<basic_block*> bb_list;
//        basic_block* parent_bb;
//
//        parent_bb = bb->get_inloop_predecessors(parent_cfg, &bb_list);
//
//        always_accessed = is_always_accessed_impl(parent_cfg, parent_bb, tag, c_line);
//    } else {
//
//        vector<basic_block*>::const_iterator IT;
//        vector<basic_block*>* bb_list = &bb->predecessors;
//
//        for (IT = bb_list->begin(); IT != bb_list->end(); IT++) {
//            basic_block* bb_pred = *IT;
//            always_accessed &= is_always_accessed_impl(parent_cfg, bb_pred, tag, c_line);
//        }
//
//    }
    always_accessed = is_always_accessed_impl(parent_cfg, bb, tag, c_line);

    return always_accessed;
}

bool cache_analysis::is_always_accessed_impl(cfg* parent_cfg, basic_block* bb, int tag, int c_line) {

    bool always_accessed = true;
    
//     cout << "\tLooking in " << bb->get_id() << endl;
    
    switch (bb->get_search_state()) {

        case basic_block::NOT_VISITED:
        {

            if (bb->my_cstate_output.search_tag(tag, c_line)) {
                always_accessed = true;
                bb->set_search_state(basic_block::VISITED_FOUND);
                break;
            }

            if (bb->is_loop_header(parent_cfg)) {
                // search to root and finally in loop body
                vector<basic_block*>::const_iterator IT;
                vector<basic_block*> bb_list;
                basic_block* parent_bb;
		
		
// 		cout << "It is loop header:" << bb->get_id() << endl;

                parent_bb = bb->get_inloop_predecessors(parent_cfg, &bb_list);

                always_accessed = is_always_accessed_impl(parent_cfg, parent_bb, tag, c_line);

                if (always_accessed) {
                    always_accessed = true;
                    bb->set_search_state(basic_block::VISITED_FOUND);
                } else {
                    always_accessed = true;
                    bb->set_search_state(basic_block::LOOP_HEADER_WAITING);
                    for (IT = bb_list.begin(); IT != bb_list.end(); IT++) {
                        basic_block* bb_pred = *IT;
			always_accessed &= is_always_accessed_impl(parent_cfg, bb_pred, tag, c_line);
                    }
                    if (always_accessed) {
                        //always_accessed = true;
                        bb->set_search_state(basic_block::VISITED_FOUND);
                    } else {
                        //always_accessed = false;
                        bb->set_search_state(basic_block::VISITED_NOT_FOUND);
                    }
                }
            } else {

                if (bb->predecessors.empty()) {
                    always_accessed = false;
                    bb->set_search_state(basic_block::VISITED_NOT_FOUND);
                } else {
                    vector<basic_block*>::const_iterator IT;
                    vector<basic_block*>* bb_list = &bb->predecessors;
                    always_accessed = true;
		             
		    for (IT = bb_list->begin(); IT != bb_list->end(); IT++) {
                        basic_block* bb_pred = *IT;
			
			if (bb != bb_pred)			
			  always_accessed &= is_always_accessed_impl(parent_cfg, bb_pred, tag, c_line);
                    }
                    if (always_accessed) {
                        //always_accessed = true;
                        bb->set_search_state(basic_block::VISITED_FOUND);
                    } else {
                        //always_accessed = false;
                        bb->set_search_state(basic_block::VISITED_NOT_FOUND);
                    }
                }
            }
            break;
        }
        case basic_block::VISITED_FOUND:
        {
	  always_accessed = true;
            break;
        }
        case basic_block::VISITED_NOT_FOUND:
        {
            always_accessed = false;
            break;
        }
        case basic_block::LOOP_HEADER_WAITING:
        {
            always_accessed = false;
            break;
        }
    }

    return always_accessed;
}

bool cache_analysis::is_always_accessed_inside_loop(cfg* parent_cfg, basic_block* bb, int tag, int c_line, int stop_loop_id) {

    bool always_accessed = false;
    
//     cout << "\tLooking in " << bb->get_id() << " State " << bb->get_search_state() << endl;
    
    switch (bb->get_search_state()) {

        case basic_block::NOT_VISITED:
        {

            if (bb->my_cstate_output.search_tag(tag, c_line)) {
                always_accessed = true;
                bb->set_search_state(basic_block::VISITED_FOUND);
                break;
            }

            if (bb->is_loop_header(parent_cfg)) {	      
                //search to root and finally in loop body
                vector<basic_block*>::const_iterator IT;
                vector<basic_block*> bb_list;
                basic_block* parent_bb;

//  		cout << "It is loop header:" << bb->get_id() << endl;
		
		if (bb->get_loop_id() == stop_loop_id)
		  break;
		
		
		always_accessed = true;
		
                parent_bb = bb->get_inloop_predecessors(parent_cfg, &bb_list);
				
                always_accessed = is_always_accessed_inside_loop(parent_cfg, parent_bb, tag, c_line, stop_loop_id);

                if (always_accessed) {
                    always_accessed = true;
                    bb->set_search_state(basic_block::VISITED_FOUND);
                } else {
                    always_accessed = true;
                    bb->set_search_state(basic_block::LOOP_HEADER_WAITING);
                    for (IT = bb_list.begin(); IT != bb_list.end(); IT++) {
                        basic_block* bb_pred = *IT;
			always_accessed &= is_always_accessed_inside_loop(parent_cfg, bb_pred, tag, c_line, stop_loop_id);
                    }
                    if (always_accessed) {
                        //always_accessed = true;
                        bb->set_search_state(basic_block::VISITED_FOUND);
                    } else {
                        //always_accessed = false;
                        bb->set_search_state(basic_block::VISITED_NOT_FOUND);
                    }
                }
            } else {

                if (bb->predecessors.empty()) {
                    always_accessed = false;
                    bb->set_search_state(basic_block::VISITED_NOT_FOUND);
                } else {
                    vector<basic_block*>::const_iterator IT;
                    vector<basic_block*>* bb_list = &bb->predecessors;
                    always_accessed = true;
		             
		    for (IT = bb_list->begin(); IT != bb_list->end(); IT++) {
                        basic_block* bb_pred = *IT;
			
			if (bb != bb_pred)			
			  always_accessed &= is_always_accessed_inside_loop(parent_cfg, bb_pred, tag, c_line, stop_loop_id);
                    }
                    if (always_accessed) {
                        //always_accessed = true;
                        bb->set_search_state(basic_block::VISITED_FOUND);
                    } else {
                        //always_accessed = false;
                        bb->set_search_state(basic_block::VISITED_NOT_FOUND);
                    }
                }
            }
            break;
        }
        case basic_block::VISITED_FOUND:
        {
	  always_accessed = true;
            break;
        }
        case basic_block::VISITED_NOT_FOUND:
        {
            always_accessed = false;
            break;
        }
        case basic_block::LOOP_HEADER_WAITING:
        {
            always_accessed = false;
            break;
        }
    }

    return always_accessed;
}
