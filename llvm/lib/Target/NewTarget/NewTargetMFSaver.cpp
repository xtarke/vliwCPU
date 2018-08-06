
#include "NewTargetMFSaver.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Target/TargetRegisterInfo.h"

#include <iostream>

using namespace llvm;


MachineFunctionSaver::MachineFunctionSaver(MachineFunction* MF_){
	MF = MF_;
	std::map<const MachineBasicBlock*, MachineBasicBlock*> MBBMap;
	
	BasicBlockListType::const_iterator IT;
	
	for(IT = MF->begin(); IT != MF->end(); IT++){
		const MachineBasicBlock* MBBOrig = &(*IT);
		MachineBasicBlock* MBBNew;
		
		// create new basic block
		MBBNew = MF->CreateMachineBasicBlock(MBBOrig->getBasicBlock());
		
		// map to correlate
		MBBMap.insert(std::pair<const MachineBasicBlock*, MachineBasicBlock*>(MBBOrig, MBBNew));
		
		// push to the list
		BasicBlocks.push_back(MBBNew);
		
		// copy machine instructions
		ilist<MachineInstr>::const_iterator ITInst;
		for(ITInst = MBBOrig->instr_begin(); ITInst != MBBOrig->instr_end(); ITInst++){
			const MachineInstr* MIOrig = &(*ITInst);
			MachineInstr* MINew = MF->CloneMachineInstr(MIOrig);
			MBBNew->push_back(MINew);
			
			// fixup bundles
			if(MIOrig->isBundledWithPred()){
				MINew->bundleWithPred();
			}
				
		}	
		
		//copy livein
		std::vector<unsigned>::const_iterator ITLivein;
		for(ITLivein = MBBOrig->livein_begin(); ITLivein != MBBOrig->livein_end(); ITLivein++){
			const unsigned LiveinReg = *ITLivein;
			MBBNew->addLiveIn(LiveinReg);
		}
		
		// other fields
		MBBNew->setAlignment(MBBOrig->getAlignment());	
		MBBNew->setIsLandingPad(MBBOrig->isLandingPad());
		MBBNew->setNumber(MBBOrig->getNumber());

                //std::cout << "===================Old basic block:\n";
                //MBBOrig->dump();
                //std::cout << "*******************New basic block:\n";        
                //MBBNew->dump();
	}

	for(IT = MF->begin(); IT != MF->end(); IT++){
		const MachineBasicBlock* MBBOrig = &(*IT);
		std::map<const MachineBasicBlock*, MachineBasicBlock*>::const_iterator ITMBB;
		
		ITMBB= MBBMap.find(MBBOrig);
		
		MachineBasicBlock* MBBNew = ITMBB->second;
		
		// populate successors
		std::vector<MachineBasicBlock *>::const_iterator ITsuc;
		for(ITsuc = MBBOrig->succ_begin(); ITsuc != MBBOrig->succ_end(); ITsuc++){
			const MachineBasicBlock* MBBSucOrig = *ITsuc;
			MachineBasicBlock* MBBSucNew;
			ITMBB= MBBMap.find(MBBSucOrig);
			
			MBBSucNew = ITMBB->second;
			
			// 0 is the branch probability info, is this correct?
			// addSuccessor also corrects predecessors of sucessors
			MBBNew->addSuccessor(MBBSucNew, 0);
			
			// this bunch of code was copied from MachineBasicBlock.cpp
			MachineBasicBlock::instr_iterator I = MBBNew->instr_end();
			while (I != MBBNew->instr_begin()) {
				--I;
				//this should be commented because we have branch delay slot
				//if (!I->isTerminator()) break;
	
				// Scan the operands of this machine instruction, replacing any uses of Old
				// with New.
				for (unsigned i = 0, e = I->getNumOperands(); i != e; ++i){
					if(I->getOperand(i).isMBB()){
					}	
					
					if (I->getOperand(i).isMBB() && I->getOperand(i).getMBB() == MBBSucOrig){
						I->getOperand(i).setMBB(MBBSucNew);
					}	
				}		
			}
		}
	}
}	 

void MachineFunctionSaver::commitMachineFunction(MachineFunction* MF_){
	
	if(MF_ != MF){
		llvm_unreachable("trying to commit diferent function");
	}

	while(!BasicBlocks.empty()){
		std::list<MachineBasicBlock*>::iterator IT = BasicBlocks.begin();
		MachineBasicBlock* MBB = (*IT);
		BasicBlocks.erase(IT);
		
		MachineBasicBlock::instr_iterator ITInst;
                

                while(MBB->size() > 0){
                    MachineInstr* MI = &(*MBB->instr_begin());
                    MBB->remove_instr(MI);               
                    MF->DeleteMachineInstr(MI);
                }
		
		//for(ITInst = MBB->instr_begin(); ITInst != MBB->instr_end(); ITInst++){
               //     std::cout << ".";
		//	MachineInstr* MI = &(*ITInst);
		//	MF->DeleteMachineInstr(MI);
		//}	
		MF->DeleteMachineBasicBlock(MBB);	
	}			
}	

void MachineFunctionSaver::rollbackMachineFunction(MachineFunction* MF_){
	
	if(MF_ != MF){
		llvm_unreachable("trying to rollback diferent functions");
	}	
	
	BasicBlockListType::iterator IT;

	// a little hack
	while(!MF->empty()){
		BasicBlockListType::iterator IT = MF->begin();
		MachineBasicBlock* MBB = &(*IT);
		
		while(!MBB->empty()){
			MachineBasicBlock::instr_iterator MBBI = MBB->instr_begin();
			MachineInstr* Instr = &(*MBBI);
			MBB->remove_instr(MBBI);
		}	
		//MBB->dump();
		MF->erase(IT);
	}	
	//another hack to erase numbers
	MF->RenumberBlocks();
	
	// add blocks....
	
	while(!BasicBlocks.empty()){
		std::list<MachineBasicBlock*>::iterator IT = BasicBlocks.begin();
		MachineBasicBlock* MBB = (*IT);
		BasicBlocks.erase(IT);
		
		MachineRegisterInfo &MRI = MF->getRegInfo();
		MachineBasicBlock::const_instr_iterator ITInst;
		
		for(ITInst = MBB->instr_begin(); ITInst != MBB->instr_end(); ITInst++){
			const MachineInstr* MI = &(*ITInst);
			
			// this remove reg operands from register info
			MachineInstr::const_mop_iterator ITMop;
			for(ITMop = MI->operands_begin(); ITMop != MI->operands_end(); ITMop++){
				const MachineOperand* MO = &(*ITMop);
				
				if(MO->getType() == MachineOperand::MO_Register){
					MRI.removeRegOperandFromUseList((MachineOperand*)MO);
				}	
			}	
		}		
		MF->push_back(MBB);
	}	
}	
