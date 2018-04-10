#include "Interlock.h"
#include "Decoder.h"

/* Interlock penalty detection:
 * 
 * ALU followed branch (predication register file)
 * Memory(load) followed by goto (to register addr)
 *
 * Modeled as VHDL 		                     */

unsigned int Interlock::check(Slot* exec_slot, Slot* old_slot)
{
  unsigned int time = 0;
    
  //if execution is a branch (branch is always @ slot [0])
  if (exec_slot[0].ctrl_flow == true && (exec_slot[0].ctrl_flow_type == Decoder::CONDIT_FALSE || exec_slot[0].ctrl_flow_type == Decoder::CONDIT_TRUE))
  {
    //test all previous instructions   
    for(int i = 0; i < 4; i++)
    {
	if (old_slot[i].bdest == exec_slot[0].bcond && old_slot[i].pred_wr == true)
	  time =  1;
    }      
  }
  
  //if execution is a goto r (always @ slot [0])
  if (exec_slot[0].ctrl_flow == true && (exec_slot[0].ctrl_flow_mux == Decoder::REG_TARGET))
  {
    //test all previous instructions   
    for(int i = 0; i < 4; i++)
    {
	if (old_slot[i].dest == exec_slot[0].src1 && old_slot[i].mem_rd == true)
	  time = 1;
    }      
  }

  //cout << "Added " << time << endl;
  
  return time;
  
}
