
#include "NewTarget.h"
#include "NewTargetInstrInfo.h"
#include "NewTargetMachine.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/CodeGen/MachineBranchProbabilityInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "iostream"

using namespace llvm;

namespace {
	typedef MachineBasicBlock::iterator Iter;
	typedef MachineBasicBlock::reverse_iterator ReverseIter;
	typedef SmallDenseMap<MachineBasicBlock*, MachineInstr*, 2> BB2BrMap;


class Filler : public MachineFunctionPass {
public:
  Filler(TargetMachine &tm)
    : MachineFunctionPass(ID), TII(tm.getInstrInfo()) { }

  virtual const char *getPassName() const {
    return "Mips Delay Slot Filler";
  }

  bool runOnMachineFunction(MachineFunction &F) {
    bool Changed = false;
    for (MachineFunction::iterator FI = F.begin(), FE = F.end();
         FI != FE; ++FI)
      Changed |= runOnMachineBasicBlock(*FI);
    return Changed;
  }

  void getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<MachineBranchProbabilityInfo>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

private:
  bool runOnMachineBasicBlock(MachineBasicBlock &MBB);
  const TargetInstrInfo *TII;

  static char ID;
};
char Filler::ID = 0;
}

static bool hasUnoccupiedSlot(const MachineInstr *MI) {
  return MI->hasDelaySlot() && !MI->isBundledWithSucc();
}

/// runOnMachineBasicBlock - Fill in delay slots for the given basic block.
/// We assume there is only one delay slot per delayed instruction.
bool Filler::runOnMachineBasicBlock(MachineBasicBlock &MBB) {
  bool Changed = false;

  for (Iter I = MBB.begin(); I != MBB.end(); ++I) {

	  if(hasUnoccupiedSlot(&*I)){
		  //std::cout << "delay slot found\n";
		  BuildMI(MBB, llvm::next(I), I->getDebugLoc(), TII->get(NewTarget::NOP));
		  MIBundleBuilder(MBB, I, llvm::next(llvm::next(I)));
	  }

  }
  return Changed;
}



/// createMipsDelaySlotFillerPass - Returns a pass that fills in delay
/// slots in Mips MachineFunctions
FunctionPass *llvm::createNewTargetDelaySlotFillerPass(NewTargetMachine &tm) {
  return new Filler(tm);
}
