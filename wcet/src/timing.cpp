/*
 * timing.cpp
 *
 *  Created on: Jun 3, 2013
 *      Author: xtarke
 */
#include "timing.h"
#include "cfg.h"
#include "instruction.h"
#include <vector>

void timing::get_basic_block_times() {
    vector<basic_block*>* bb_list = graph->get_bbs();

//     //add all basick block to the sim
//     for (unsigned int i = 0; i < bb_list->size(); i++) {
//         basic_block *bb = (*bb_list)[i];
// 
//      //   CORE->add_block(bb->get_id(), bb->get_ini_addr(), bb->get_end_addr());
//     }
// 
//     //sim all blocks
//    // CORE->sim();
// 
//   //  for (unsigned int i = 0; i < CORE->sim_datalist.size(); i++) {
//   //      basic_block *bb = (*bb_list)[i];
//        // sim_data *data = CORE->sim_datalist[i];
// 
//       //  bb->set_t(data->CPU_CORE->cycles);
//   //  }

}

void timing::no_cache_timing() {
    vector<basic_block*>* bb_list = graph->get_bbs();

    //add all basick block to the sim
    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];

        bb->set_cache_a_misses(0);
        bb->set_cache_f_misses(0);
        bb->set_cache_conflicts(0);

        unsigned int bb_time = bb->get_t();

        if (bb->predecessor_t.empty() == false ||
                bb->predecessor_t_fmiss.empty() == false) {
            cout << "Timing analysis already performed!" << endl;
            assert(false);
        }

        for (unsigned int j = 0; j < bb->predecessors.size(); j++) {
            basic_block *pred = bb->predecessors[j];


            bb->predecessor_t.insert(make_pair(pred, bb_time));
            bb->predecessor_t_fmiss.insert(make_pair(pred, bb_time));
        }

        if (bb->predecessors.size() == 0) {
            bb->predecessor_t.insert(make_pair(static_cast<basic_block*> (0), bb_time));
            bb->predecessor_t_fmiss.insert(make_pair(static_cast<basic_block*> (0), bb_time));
        }
    }
}

void timing::add_slow_mem_penalty() {
    vector<basic_block*>* bb_list = graph->get_bbs();

    //add all basick block to the sim
    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];

        unsigned int bb_time = bb->get_t();

        if (bb_time == 0) {
            cout << "get_basic_block_times must be executed first!" << endl;
            assert(false);
        }

        //all ld/st instructions that access the slow memory increments the
        //basic block time. 
        //cout << bb->get_id() << ": " << bb->get_memory_stalls() << endl;

        bb_time = bb_time + bb->get_memory_stalls();// * (CORE->umem_access_cycles);
        bb->set_t(bb_time);
    }
}

void timing::add_cache_miss_penalty() {
    vector<basic_block*>* bb_list = graph->get_bbs();
    
       
    //1o Pass: basic timing and cache accounting for all basic blocks
    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];
       
	int a_misses = 0;
        int f_misses = 0;
        int conflicts = 0;

        unsigned int bb_time = bb->get_t();
        unsigned int bb_time_f_miss = 0;

        if (bb->predecessor_t.empty() == false ||
                bb->predecessor_t_fmiss.empty() == false) {
            cout << "Timing analysis already performed!" << endl;
            assert(false);
        }

        for (unsigned int j = 0; j < bb->predecessors.size(); j++) {
            basic_block *pred = bb->predecessors[j];

            bb->predecessor_t.insert(make_pair(pred, 0));
            bb->predecessor_t_fmiss.insert(make_pair(pred, 0));
        }

        if (bb->predecessors.size() == 0) {
            bb->predecessor_t.insert(make_pair(static_cast<basic_block*> (0), 0));
            bb->predecessor_t_fmiss.insert(make_pair(static_cast<basic_block*> (0), 0));
        }

        
        //could removed later
        for (unsigned int j = 0; j < bb->bundles.size(); j++) {
            VLIW_bundle* bundle = bb->bundles[j];

            assert(bundle->prediction != 0);

            if (bundle->prediction == A_MISS)
                a_misses++;
		
            if (bundle->prediction == F_MISS) {
                f_misses++;
            }

            //if instruction is classified as a conflict
            if (bundle->prediction == CONFLICT) {
                conflicts++;
                conflict_timing(bb, bundle, &bb->predecessor_t);
            }
        }
        
        //cout << a_misses << " " << bb->a_misses_b_index.size() << endl;
        assert(a_misses == bb->a_misses_b_index.size() && "Error in cache analysis");
	assert(f_misses == bb->f_misses_b_index.size() && "Error in cache analysis");
	assert(conflicts == bb->conflict_b_index.size() && "Error in cache analysis");
        

        bb->set_cache_a_misses(a_misses);
        bb->set_cache_f_misses(f_misses);
        bb->set_cache_conflicts(conflicts);
        
	
	//If there are more than 1 a_misses, a_misses * bb->my_cstate.get_penalty() is too pessimistic due pipeline behavior.
	//Please see waveforms/cache_slow_bundle.ps and waveforms/cache_fast_bundle: cache stall timing varies in function of the bundle length
	//plus interlock and muticyle instructions
	if (a_misses > 1)
	{
	  LOG << "Multiple a_misses" << endl; 
	  bb_time = bb_time + a_misses * bb->my_cstate.get_penalty();
	  
	  pipeline_analisys *base_t = new pipeline_analisys(graph); 	
	  
	  for (unsigned int k = 2; k < bb->a_misses_b_index.size(); k++)
	  {
	    unsigned int base_timing = base_t->range_instruc_timing(bb->bundles, bb->a_misses_b_index[k-1], bb->a_misses_b_index[k]);// + 2; 
	    //remove 2 cycles due init and init2 fetch stages
	    
	    if (base_timing > bb->my_cstate.get_penalty()){
	      LOG << "\tWARNING: bb_time = bb_time - bb->my_cstate.get_penalty() + base_timing not totally validated" << endl;	 
	      bb_time = bb_time - bb->my_cstate.get_penalty() + base_timing;	      
	    }
	    else
	    {
	      bb_time = bb_time - base_timing;	       
	    }
	  }
	  delete base_t;	  
	  
	}
	else
	  bb_time = bb_time + a_misses * bb->my_cstate.get_penalty();
	
	
	if (f_misses > 1)
	{
	  LOG << "Multiple f_misses" << endl; 
	  //assert(0 && "Not implemented");
	  
	  if (bb->is_loop_header(graph)) {
	      bb_time_f_miss = bb_time; 
	      
	      update_time_f_miss_loop_header(bb, &bb->predecessor_t_fmiss,
		      f_misses * bb->my_cstate.get_penalty());
	  } else
	  {
	    bb_time_f_miss = bb_time + f_misses * bb->my_cstate.get_penalty();
	    
	    uint32_t removed = 0;
	    
	    pipeline_analisys *base_t = new pipeline_analisys(graph);  
	    for (unsigned int k = 2; k < bb->f_misses_b_index.size(); k++)
	    {
	      unsigned int base_timing = base_t->range_instruc_timing(bb->bundles, bb->f_misses_b_index[k-1], bb->f_misses_b_index[k]); 
	      	      
	      if (base_timing > bb->my_cstate.get_penalty()){
		//TODO: it has to be validated
		LOG << "\tWARNING: base_timing > bb->my_cstate.get_penalty() not totally validated" << endl;	 
		bb_time_f_miss = bb_time_f_miss - bb->my_cstate.get_penalty() + base_timing;		
	      }
	      else
	      {		
		removed += base_timing;		
		bb_time_f_miss = bb_time_f_miss - base_timing;	       
	      }
	    }
	    LOG << "\tcompensating: " << removed << " cycles" << endl;	    
	    delete base_t;	  
	      
	  }	  
	}
	else
	{
	  if (bb->is_loop_header(graph)) {
	      bb_time_f_miss = bb_time; 
	      
	      update_time_f_miss_loop_header(bb, &bb->predecessor_t_fmiss,
		      f_misses * bb->my_cstate.get_penalty());
	  } else
	      bb_time_f_miss = bb_time + f_misses * bb->my_cstate.get_penalty();
	
	}

        update_time_map(bb_time, &bb->predecessor_t);
        update_time_map(bb_time_f_miss, &bb->predecessor_t_fmiss);


//#ifdef DEBUG
        LOG << bb->get_id() << " ["<< bb->get_ini_addr() << "," << bb->get_end_addr() << "]"<< "\tt_no_cache: " << bb->get_t() << "\t\ta_misses: " << a_misses <<
                "\tf_misses: " << f_misses << "\tf_conflicts: " << conflicts <<
                "\tpenalty: " << bb->my_cstate.get_penalty() << endl;
	
        map <basic_block*, unsigned int>::iterator IT;
        for (IT = bb->predecessor_t.begin(); IT != bb->predecessor_t.end(); IT++) {
            if (IT->first == 0)
                LOG << "\t\ttime: " << IT->second << endl;
            else
                LOG << "\t\tPred: " << IT->first->get_id() << " time: " << IT->second << endl;
        }
        LOG << "\t\t----- F_MISS:" << endl;
        for (IT = bb->predecessor_t_fmiss.begin(); IT != bb->predecessor_t_fmiss.end(); IT++) {
            if (IT->first == 0)
                LOG << "\t\ttime: " << IT->second << endl;
            else
                LOG << "\t\tPred: " << IT->first->get_id() << " time: " << IT->second << endl;
        }
        LOG << "-------------------------" << endl;
//#endif
        		bb->set_t(bb_time);
        		bb->set_t_fmiss(bb_time_f_miss);
    }
    
    LOG << endl;
      
    LOG << "Phase 2 beginning, compensating fallthrough edges:" << endl;
    
     //2o Pass: remove unnecessary pessimism due fall trough execution blocks
    for (unsigned int i = 0; i < bb_list->size(); i++) {
        basic_block *bb = (*bb_list)[i];
	
	LOG << bb->get_id() << " ["<< bb->get_ini_addr() << "," << bb->get_end_addr() << "]" << endl;
	
	
	 for (unsigned int j = 0; j < bb->predecessors.size(); j++) {
            basic_block *pred = bb->predecessors[j];

           
	    std::map<int, unsigned>::iterator it;
	    it = pred->sucessor_flow_type.find(bb->get_id());
	    	    
	    // if edge is a pure fall through
	    if (it->second == basic_block::PURE_FALLTHROUGH)
	    {
	     	      
	      LOG << "Pure fall through from : " << pred->get_id() << endl;
	      
	      if (bb->bundles[0]->prediction == A_MISS)
	      {
		LOG << "\tDetected a_miss" << endl;	      
	      }      
	    }
	    
	    if (it->second == basic_block::CONDITIONAL_FALLTHROUGH || it->second == basic_block::CONDITIONAL_FALLTHROUGH_PRELOAD)
	    {
	      LOG << "Cond fall through from : " << pred->get_id() << endl;
	    
	      //always miss treatment
	      if (bb->bundles[0]->prediction == A_MISS)
	      {
		LOG << "\tDetected an a_miss" << endl;
		LOG << "\tPredecessor has " << pred->bundles.size() << " bundles and " << pred->get_number_instructions() << " instructions" << endl;
		
		
		//if predecessor has less or equal 8 instructions (1 cache line)
		//simple compensation: remove predecessor execution time from cache miss penalty
		//actual basic block time is: pipeline time + cache misses 
		
		
		if (pred->get_number_instructions() > 8)
		  LOG << "\tWARNING: must be validated" << endl;
		
		
		//if (pred->get_number_instructions() <= 8)
		//{
		  //Adjusting cache miss time
		  pipeline_analisys *base_t = new pipeline_analisys(graph);
				
		  //predecessor execution time without cache misses
		  unsigned int base_timing = base_t->range_instruc_timing(pred->bundles, 0, pred->bundles.size()) + 2; 
		
		  if (it->second == basic_block::CONDITIONAL_FALLTHROUGH_PRELOAD)
		  {
		      LOG << "This is a fallthrough preload, decreasing compensation" << endl;
		      base_timing = base_timing - 2;
		  }
		  
		  
		  LOG << "\tRemoving " << base_timing <<  " cycles due predecessor execution time" << endl;
		  
		  if (base_timing > bb->my_cstate.get_penalty())
		  {
		    LOG << "predecessor execution is more than cache misss penalty, removing only cache miss penalty" << endl;
		    base_timing = bb->my_cstate.get_penalty();
		  }
		  
		  map <basic_block*, unsigned int>::iterator map_it; 		  
 		  map_it = bb->predecessor_t.find(pred);		  
		  LOG << "\tOld time from " << map_it->first->get_id() << " was " << map_it->second << " now is " << map_it->second - base_timing << endl;		  
		  map_it->second = map_it->second - base_timing;		  		  
		  assert(map_it->second - base_timing >= 0);		 
		//}
		//else
// 		{		  
// 		  assert(bb->get_ini_addr() % bb->my_cstate.get_line_size() == 0 && "half cache lines not implemented yet"); // half line not implemented yet
// 		 
// 		  //target address is: 
// 		  uint32_t addr = bb->get_ini_addr() -  bb->my_cstate.get_line_size();
// 		  LOG << "\ttarget pred address is: " << addr << endl;
// 		  
// 		  //search correct bundle
// 		  vector<VLIW_bundle*>::iterator ITb;  
// 		  int b_offset = 0;
//  		  for (ITb = pred->bundles.begin(); ITb != pred->bundles.end(); ITb++) {
//  		    VLIW_bundle* bundle = *ITb;  
// 		    
// // 		    LOG << bundle->address << endl;
// 		    
// 		    if (addr >= bundle->address && addr <= bundle->address + bundle->instructions.size())
// 		    {			
// 		      b_offset++;
// 		      LOG << "\ttarget bundle_offset is : " << b_offset << endl;
// 		      break;
// 		    }
// 		    
// 		    b_offset++;    
//  		  }
//  		  
//  		  assert(b_offset < pred->bundles.size());
//  		  	  
// 		  //get execution time from last cache line		  
// 		  pipeline_analisys *base_t = new pipeline_analisys(graph);
// 				
// 		  //predecessor execution time without cache misses
// 		  unsigned int base_timing = base_t->range_instruc_timing(pred->bundles, b_offset, pred->bundles.size()) + 2;
// 		  LOG << "\tRemoving " << base_timing <<  " cycles due predecessor execution time" << endl;
// 		  
// 		  if (base_timing > bb->my_cstate.get_penalty())
// 		  {
// 		    LOG << "predecessor execution is more than cache misss penalty, removing only cache miss penalty" << endl;
// 		    base_timing = bb->my_cstate.get_penalty();
// 		  }
// 		  
// 		  map <basic_block*, unsigned int>::iterator map_it; 		  
//  		  map_it = bb->predecessor_t.find(pred);		  
// 		  LOG << "\tOld time from " << map_it->first->get_id() << " was " << map_it->second << " now is " << map_it->second - base_timing << endl;		  
// 		  map_it->second = map_it->second - base_timing;		  		  
// 		  assert(map_it->second - base_timing >= 0);		 
// 		  
// 		  
// 		}
	      }
	      
	      //first miss treatment
	      if (bb->bundles[0]->prediction == F_MISS)
	      {
		LOG << "\tDetected a f_miss" << endl;
		
		//Adjusting cache miss time
		pipeline_analisys *base_t = new pipeline_analisys(graph);
		
		
		if (pred->get_number_instructions() <= 8) 
		{
		  unsigned int base_timing = base_t->range_instruc_timing(pred->bundles, 0, pred->bundles.size()) + 2; 
		  
		  LOG << "\tcompensating: " << base_timing << endl;
		  
 		  map <basic_block*, unsigned int>::iterator map_it;
 		  
 		  map_it = bb->predecessor_t_fmiss.find(pred);
		  
		  LOG << "\tOld time from " << map_it->first->get_id() << " was " << map_it->second << " now is " << map_it->second - base_timing << endl;
		  
		  map_it->second = map_it->second - base_timing;		  
		}		 
		else
		{
		  LOG << "bb: " << bb->get_id() << endl;
		  //assert(0 && "Not implemented");
		}
	      }	      
	    }
	    
        }	
    }
    
    
}

void timing::update_time_map(unsigned int t, map <basic_block*, unsigned int> *time_map) {
    map <basic_block*, unsigned int>::iterator IT;

    for (IT = time_map->begin(); IT != time_map->end(); IT++) {
        IT->second = IT->second + t;
    }
}

void timing::conflict_timing(basic_block *bb, VLIW_bundle* bundle, map <basic_block*,
        unsigned int> *time_map) {
    uint32_t tag = bundle->tag;
    uint32_t c_line = bundle->line;

    assert(bb->predecessors.size() > 1);

    map <basic_block*, unsigned int>::iterator IT;

    for (unsigned int i = 0; i < bb->predecessors.size(); i++) {
        basic_block *pred = bb->predecessors[i];
        cache_state *pre_rmb_cs = &pred->rmb_cstate;

        IT = time_map->find(pred);
        assert(IT != time_map->end());

        if (pre_rmb_cs->search_tag(tag, c_line) == false) {
            IT->second = IT->second + bb->my_cstate.get_penalty();
        } else {
            if (pre_rmb_cs->get_references_size(c_line) > 1) {
                IT->second = IT->second + bb->my_cstate.get_penalty();
            }
            if (pre_rmb_cs->get_references_size(c_line) == 1 &&
                    pred->must_cstate.search_tag(tag, c_line) == false)
                IT->second = IT->second + bb->my_cstate.get_penalty();
        }
    }
}

void timing::update_time_f_miss_loop_header(basic_block *bb,
        map <basic_block*, unsigned int> *time_map, unsigned int t) {
    vector<basic_block*> in_loop;
    map <basic_block*, unsigned int>::iterator IT;
    unsigned int conflict_t = 0;

    assert(bb->is_loop_header(graph));

    //get the node outside the loop
    basic_block* pred_out = bb->get_inloop_predecessors(graph, &in_loop);

    //get the conflict timing of this node
    IT = bb->predecessor_t.find(pred_out);
    assert(IT != bb->predecessor_t.end());
    conflict_t = IT->second;

    //update the f-miss MAP
    IT = time_map->find(pred_out);
    assert(IT != time_map->end());

    IT->second = IT->second + t + conflict_t;
}


