/* 
 * File:   pipeline_analisys.cpp
 * Author: andreu
 * 
 * Created on 15 de Setembro de 2014, 18:29
 */

#include "pipeline_analisys.h"

// #define DEBUG

#define MAX(a,b) ((a) > (b) ? (a) : (b))

struct instruction_stall VLIW_stalls[] = {
    {VLIW_instruction::MULT, 3},
    {VLIW_instruction::DIV, 19},
    {VLIW_instruction::LOAD, 2},
    {VLIW_instruction::STORE, 2}
};

struct ctrl_flow_stall VLIW_ctrl_flow_stalls[] = {
    {VLIW_instruction::CALL, 4},	// to compensate delta
    {VLIW_instruction::GOTO, 4},	// to compensate delta
    {VLIW_instruction::BRANCH, 4}	// to compensate delta
};


struct data_hazard VLIW_hazards[] = {
  {VLIW_instruction::ALU, VLIW_instruction::BRANCH, 1},
  {VLIW_instruction::LOAD, VLIW_instruction::GOTO, 1},
//   {VLIW_instruction::MULT, VLIW_instruction::STORE, 0},
//   {VLIW_instruction::LOAD, VLIW_instruction::MULT, 0},
//   {VLIW_instruction::STORE, VLIW_instruction::MULT, 0}  
  //{VLIW_instruction::LOAD, VLIW_instruction::ALU, 2}    
};

void pipeline_analisys::analize() {

    //multipath t[0] is for predication = 0
    //multipath t[1] is for predication = 1
    uint32_t t[2];
    bool f_pred = false;
    vector<basic_block*>* blocks = graph->get_bbs();
    vector<basic_block*>::iterator IT;
    
    t[0] = 0;
    t[1] = 0;  
    
    LOG << "Pipeline analysis: " << endl;
       
    
    for (IT = blocks->begin(); IT != blocks->end(); IT++) {
        basic_block* bb = *IT;
	vector<VLIW_bundle*>::iterator ITb;	
	t[0] = 0;
	t[1] = 0;
	
	LOG << "" << endl;
        LOG << "BB: " << bb->get_id() << " [" << bb->get_ini_addr() << "," << bb->get_end_addr() << "]" << "\n";	
	LOG << "B_size:" << bb->bundles.size()  << "\n";;	
	
	
// 	if (bb->get_id() == 16)
// 	{
// 	  bb->set_t_ins(PIPELINE_LENGHT - 1 + 4 + 2 + 2);	  
// 	  bb->set_t(PIPELINE_LENGHT - 1 + 4 + 2 + 2);
// 	  LOG << "BB ins_t is: " << bb->get_t() << endl; 
// 	  continue;	  
// 	}
	
	
#ifdef DEBUG
	cout << "" << endl;
        cout << "BB: " << bb->get_id() << " [" << bb->get_ini_addr() << "," << bb->get_end_addr() << "]" << "\n";	
	cout  << "B_size:" << bb->bundles.size()  << "\n";;	
	
	
	for (ITb = bb->bundles.begin(); ITb != bb->bundles.end(); ITb++) {
	  VLIW_bundle* bundleA = *ITb;  
	  
	  std::vector<VLIW_instruction*>::const_iterator ITme;
	  
	  cout << endl;
	  cout << bundleA->address << endl;	  
	  
	  for (ITme = bundleA->instructions.begin(); ITme != bundleA->instructions.end(); ITme++)
	  {
	    VLIW_instruction* inst1 = *ITme;
	    
	    cout << endl;
	    cout << "Opcode: " << inst1->opcode;	    
	    cout << " Type: " << inst1->type;
	    cout << " input: " << inst1->input_regs.size();
	    cout << " ouput: " << inst1->output_regs.size() << endl;	    
	  }  
	}
#endif
	
        for (ITb = bb->bundles.begin(); ITb != bb->bundles.end(); ITb++) {
            VLIW_bundle* bundleA = *ITb;
	    
	    //cout << bundleA->instructions.size() << endl;
	    assert(bundleA->instructions.size() <= 4);
	    
	    uint32_t t_multicyle[2];
	    uint32_t t_ctrl_flow = 0;
	    
	    t_multicyle[0] = 0;
	    t_multicyle[1] = 0;
	    
	    if (bundleA->has_instruction_type(VLIW_instruction::PRED_ON))
	    {
	      LOG << " ======= Full predication mode activated @ " << bundleA->address  << "\n";
	      f_pred = true;
	    }
	       
	    
            for (int i = 0; i < sizeof (VLIW_stalls) / sizeof (struct instruction_stall); i++) {
                struct instruction_stall* stall = &VLIW_stalls[i];
                unsigned bit_30 = 0;
		
		if (bundleA->has_instruction_type_path(stall->type, &bit_30)) {
		 
		  LOG << i <<" ======= Muticyle op detected @ " << bundleA->address << " type " << stall->type << " bit_30 " << bit_30 << "\n";
		   
		  if (stall->stalls > t_multicyle[bit_30])
		  {   
		    t_multicyle[bit_30] = stall->stalls;
		  }
                }
            }
            
            for (int i = 0; i < sizeof (VLIW_ctrl_flow_stalls) / sizeof (struct ctrl_flow_stall); i++) {
                struct ctrl_flow_stall* stall = &VLIW_ctrl_flow_stalls[i];
                if (bundleA->has_instruction_type(stall->type)) {
		 
		  LOG << i <<" ======= Control flow op detected @ " << bundleA->address << " type " << stall->type << "\n";
		   
		  if (stall->stalls > t_ctrl_flow)
		  {   
		    t_ctrl_flow = stall->stalls;
		  }
                }
            }
                  
	    LOG << "\tadded[p0]: " << t_multicyle[0] << endl;
	    LOG << "\tadded[p1]: " << t_multicyle[1] << endl;
	    LOG << "\tadded: " << t_ctrl_flow << endl;
            
	    t[0] += t_ctrl_flow;
	    t[1] += t_ctrl_flow;    
	    
            t[0] += t_multicyle[0];
	    t[1] += t_multicyle[1];            

            vector<VLIW_bundle*>::iterator ITbb = ITb;
            ITbb++;
            if (ITbb != bb->bundles.end()) {
                VLIW_bundle* bundleB = *ITbb;
		
		 uint32_t t_hazard = 0;
		 
// 		 if (bundleA->instructions[0]->type == VLIW_instruction::GOTO)
// 		 {  
// 		   LOG << "GOTO: " << bundleA->instructions[0]->input_regs[0] << endl;
// 		   
// 		   
// 		 }
                
                for (int i = 0; i < sizeof (VLIW_hazards) / sizeof (struct data_hazard); i++) {
                    struct data_hazard* hazard = &VLIW_hazards[i];
                    	    
		    if (bundleA->check_relation(hazard->first_type, hazard->second_type, bundleB)) {
                      LOG << "================= hazard detected @ " << bundleA->address  << " : from type " << hazard->first_type << " to " << hazard->second_type << "\n";		      
		      
		      if (f_pred == true) LOG << "==== Warning hazard detected inside predicated bundles" << "\n";
		      
			if (hazard->stalls > t_hazard)
			{
			  LOG << "\tadded: " << hazard->stalls << endl;
			  t_hazard = hazard->stalls;				  
			}
                    }
                }                
                t[0] += t_hazard;
		t[1] += t_hazard;
            }
            
            if (bundleA->has_instruction_type(VLIW_instruction::PRED_OFF))
	    {
	      LOG << " ======= Full predication mode disable @ " << bundleA->address << "\n";
	      f_pred = false;
	    }
            
        }

        if (t[0] != t[1])
	  LOG << " ======= Paths t[0]: " << t[0] << " t[1]: " << t[1] << "\n";
        
        
	//Basic instruction timing: interlock and multicycle, no cache, no pipelining latency
	bb->set_t_ins(MAX(t[0],t[1]) + bb->bundles.size());
	
	LOG << "BB ins_t is: " << MAX(t[0],t[1]) + bb->bundles.size() << endl;
	
	// Basic Block basic timing
	// pipeline latency plus number of bundles
	// t_BB = PIPE_LENGHT + n_bundles - 1	
	t[0] += PIPELINE_LENGHT + bb->bundles.size() - 1;
	t[1] += PIPELINE_LENGHT + bb->bundles.size() - 1;
	
	//t += bb->bundles.size();
		
	LOG << "BB time is: " << MAX(t[0],t[1]) << endl;
		
	bb->set_t(MAX(t[0],t[1]));	
    }
}

// returns basic instruction timing: interlock and multicycle, no cache, no pipelining latency 
// between consecutive instruction bundles until bundle to is reached
uint32_t pipeline_analisys::range_instruc_timing(vector<VLIW_bundle*> bundles, unsigned int from, unsigned int to) {
    
  //cout << "range_instruc_timing: " << from << " " << to << endl;
  
  uint32_t t[2];
  
  t[0] = 0;
  t[1] = 0;
  
  for (unsigned i = from; i < to; i++) {
    VLIW_bundle* bundleA = bundles.at(i);
    
//     LOG << "\tAddr: " << bundleA->address << endl;
    
    //Muticyle detection only if i is not last bundle    
    if (i+1 != to)
    {
    
      uint32_t t_multicyle[2];
      t_multicyle[0] = 0;
      t_multicyle[1] = 0;
	      
       for (int i = 0; i < sizeof (VLIW_stalls) / sizeof (struct instruction_stall); i++) {
                struct instruction_stall* stall = &VLIW_stalls[i];
                unsigned bit_30 = 0;
		
		if (bundleA->has_instruction_type_path(stall->type, &bit_30)) {
		 
		  LOG << i <<" ======= Muticyle op detected @ " << bundleA->address << " type " << stall->type << " bit_30 " << bit_30 << "\n";
		   
		  if (stall->stalls > t_multicyle[bit_30])
		  {   
		    t_multicyle[bit_30] = stall->stalls;
		  }
                }
       }
            
      
      t[0] += t_multicyle[0];
      t[1] += t_multicyle[1];    
    
    }
    
    // Interlock detection        
    if (i + 1 != bundles.size()) {
	VLIW_bundle* bundleB = bundles.at(i+1);
	
	uint32_t t_hazard = 0;
	
	for (int j = 0; j < sizeof (VLIW_hazards) / sizeof (struct data_hazard); j++) {
	    struct data_hazard* hazard = &VLIW_hazards[j];
		    
	    if (bundleA->check_relation(hazard->first_type, hazard->second_type, bundleB)) {
		if (hazard->stalls > t_hazard)
		  t_hazard = hazard->stalls;		
	    }
	}                
	t[0] += t_hazard;
	t[1] += t_hazard;                
    }    
    
    t[0]++;
    t[1]++;
    
    
//     LOG << "\t\tt is : " << t << endl;     
  
  }
  
  return MAX(t[0],t[1]);  
  
}