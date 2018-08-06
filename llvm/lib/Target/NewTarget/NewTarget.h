/*
 * NewTarget.h
 *
 *  Created on: Mar 6, 2013
 *      Author: andreu
 */

#ifndef NEWTARGET_H_
#define NEWTARGET_H_

#include "MCTargetDesc/NewTargetMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"
#include <llvm/CodeGen/MachineFunction.h>
#include <map>
#include <set>

namespace llvm {
  class NewTargetMachine;
  class FunctionPass;
  class ModulePass;
  class LoopPass;

  extern Target TheNewTarget;
  FunctionPass *createNewTargetISelDag(NewTargetMachine &TM);
  FunctionPass *createNewTargetDelaySlotFillerPass(NewTargetMachine &TM);
  FunctionPass *createNewTargetCFGExtractor(NewTargetMachine &TM);
  ModulePass *createProfileBBOrderExtractor();
  FunctionPass *createRTOptimizer(NewTargetMachine &TM);
  FunctionPass *createNewTargetPacketizer();
  FunctionPass *createNewTargetBundleAligner(NewTargetMachine &TM, const TargetInstrInfo *TII);
  Pass *createLoopBoundExtractor();
  FunctionPass *createRecursionDepthExtractor();
  FunctionPass *createNewTargetBranchPreloader(const TargetInstrInfo *TII);
  FunctionPass *createNewTargetPredicatedPathMerger(const TargetInstrInfo *TII);
  FunctionPass *createProfileAuthorizationExtractor();

  
  extern std::map<const BasicBlock*, bool> IsLoopBoundExact;
  extern std::map<const BasicBlock*, int> LoopBounds;
  extern std::map<const Function*, int> RecursionDepths;
  extern std::set<MachineBasicBlock*> NotPredictedMBBs;
  extern std::set<BasicBlock*> AllowedToUseProfileInfo;

} // end namespace llvm;


#endif /* NEWTARGET_H_ */
