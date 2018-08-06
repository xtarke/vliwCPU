/*
 * NewTargetWCETEstimator.h
 *
 *  Created on: Mar 11, 2014
 *      Author: andreu
 */ 
 
#ifndef NEWTARGETWCETESTIMATOR_H_
#define NEWTARGETWCETESTIMATOR_H_

#include "NewTargetSubtarget.h"
#include "NewTargetMachine.h"
#include "NewTargetAsmPrinter.h"
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/CodeGen/MachineBasicBlock.h>
#include <set>
#include <map>

namespace llvm {
	
	// to handle sets of blasic blocks that are on the wcep of a function
	typedef std::set<MachineBasicBlock*> MBBSet;
        typedef ilist<MachineBasicBlock> BasicBlockListType;
	
class NewTargetWCETEstimator {
	
	NewTargetMachine &TM;
	
	// a module that the wcet corresponds
	Module& M;
	
	// wcet value calculated
	uint32_t WCET;
	
	MachineModuleInfo* MMI_;
	GCModuleInfo* MI_;

	
public:
	NewTargetWCETEstimator(NewTargetMachine &tm, Module& M, 
				MachineModuleInfo* mmi, GCModuleInfo* mi) : TM(tm), M(M), WCET(0), MMI_(mmi), MI_(mi) {} 
	
	void runAnalyzer();
	unsigned getWCET();
	
	MBBSet* getMFWorstCaseMBBSet(MachineFunction& MF);
        MBBSet* getMWorstCaseMBBSet();
	bool isInWCEP(MachineBasicBlock *MBB);
	bool isWCEPInvariant(MachineBasicBlock* MBB);
        uint32_t getMBBWCC(MachineBasicBlock* MBB);
		
	// Map between Function and Machine Function
    // we need a pass to populate this map
	//static std::map<const Function*, MachineFunction*> FToMFMap;
	
	std::map<const MachineBasicBlock*, unsigned> MBBFreq;
	std::set<const MachineBasicBlock*> InvMBBs;
	
private:
	void retrieveInvariantBlocks();
	void generateFakeELF(const char* filename, bool binary);
	void generateCFG(const char* CFGfilename, const char* DOTfilename);
	void invokeAnalyzer(const char* name);
	void retriveWCETData();
	bool initializeAsmPrinter(NewTargetAsmPrinter* asmPrinter);
	bool finalizeAsmPrinter(NewTargetAsmPrinter* asmPrinter);
	void prepareFreqCounters();
	void clearFreqCounters();
};	
	
} // end namespace llvm	

#endif

