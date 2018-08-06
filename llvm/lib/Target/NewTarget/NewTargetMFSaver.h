/*
 * NewTargetMFSaver.cpp
 *
 *  Created on: Mar 14, 2014
 *      Author: andreu
 */

#ifndef NEWTARGETMFSAVER_H_
#define NEWTARGETMFSAVER_H_

#include "NewTargetSubtarget.h"
#include "llvm/ADT/ilist.h"
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/CodeGen/MachineBasicBlock.h>
#include <llvm/CodeGen/MachineFunction.h>
#include "llvm/Support/Allocator.h"
#include "llvm/Support/ArrayRecycler.h"
#include <set>
#include <list>
#include <map>

namespace llvm {
	
	
class MachineFunctionSaver{
	

public:	
	
	MachineFunctionSaver(MachineFunction* MF_);
	
	void commitMachineFunction(MachineFunction* MF_);
	void rollbackMachineFunction(MachineFunction* MF_);
		
private:

	MachineFunction* MF;
	typedef ilist<MachineBasicBlock> BasicBlockListType;
	std::list<MachineBasicBlock*> BasicBlocks;
	//std::vector<MachineBasicBlock*> MBBNumbering;
		
}; // end class MachineFunctionSaver	

} // end namespace llvm

#endif
