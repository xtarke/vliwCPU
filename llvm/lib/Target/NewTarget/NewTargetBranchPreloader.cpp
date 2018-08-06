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
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/DebugInfo.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include <iomanip>
#include "NewTargetCFGGen.h"

#include <iostream>
#include <list>

using namespace llvm;

static cl::
opt<bool> EnableBranchPreload("enable-newtarget-branchpreload",
        cl::Hidden, cl::ZeroOrMore, cl::init(false),
        cl::desc("Enable branch target preload"));


namespace {

    class BranchPreloader : public MachineFunctionPass {
    public:

        enum InsertMode {
            IN_BUNDLE,
            CREATE_BULDLE,
            ALONE
        };

        static char ID; // Class identification, replacement for typeinfo

        MachineBranchProbabilityInfo *MBPI;

        explicit BranchPreloader(const TargetInstrInfo *tii)
        : MachineFunctionPass(ID), TII(tii) {
        }

        virtual const char *getPassName() const {
            return "Branch target preloader pass";
        }

        virtual void getAnalysisUsage(AnalysisUsage &AU) const {
            AU.setPreservesCFG();
            AU.addRequired<MachineDominatorTree>();
            AU.addPreserved<MachineDominatorTree>();
            AU.addRequired<MachineLoopInfo>();
            AU.addPreserved<MachineLoopInfo>();
            AU.addRequired<MachineBranchProbabilityInfo>();
            AU.addPreserved<MachineBranchProbabilityInfo>();
            MachineFunctionPass::getAnalysisUsage(AU);
        }

        virtual bool runOnMachineFunction(MachineFunction &MF);
        void runOnMachineBasicBlock(MachineBasicBlock &MBB);
    private:
        const TargetInstrInfo *TII;
    };
    char BranchPreloader::ID = 0;
}

//INITIALIZE_PASS_DEPENDENCY(MachineDominatorTree)
//INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)


bool BranchPreloader::runOnMachineFunction(MachineFunction &MF) {

    MBPI = &getAnalysis<MachineBranchProbabilityInfo>();

    //checkDiamondStructure(MF);

    for (MachineFunction::iterator FI = MF.begin(), FE = MF.end();
            FI != FE; ++FI) {
        runOnMachineBasicBlock(*FI);
    }
    return false;
}

static unsigned getSize(MachineBasicBlock::iterator IT) {
    unsigned count = 0;
    MachineBasicBlock::instr_iterator I = IT.getInstrIterator();

    // a solo instruction
    if (!I->isBundledWithSucc()) {
        return 1;
    }
    // a bundle
    while (I->isBundledWithSucc()) {
        ++I;
        if (!I->isDebugValue()) {
            count++;
        }
    }
    return count;
}

static void buildNopOrPreload(const TargetInstrInfo *TII, MachineBasicBlock* MBB,
        MachineBasicBlock* MBBTarget, MachineBasicBlock::iterator &Iter,
        unsigned mode) {

    MachineInstrBuilder MB;

    if (MBBTarget != NULL) {
        //std::cout << "preload\n";
        MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::PRELD)).addMBB(MBBTarget);
    } else {
        //std::cout << "nop\n";
        MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::ADDi), NewTarget::ZERO).addReg(NewTarget::ZERO).addImm(0);
    }

    switch (mode) {
        case BranchPreloader::IN_BUNDLE:
        {
            MIBundleBuilder(Iter).append(MB);
            break;
        }
        case BranchPreloader::CREATE_BULDLE:
        {
            MIBundleBuilder(Iter).append(MB);
            finalizeBundle(*MBB, Iter.getInstrIterator());
            break;
        }
        case BranchPreloader::ALONE:
        {
            MBB->insert(Iter, MB);
            break;
        }
    }
}

void BranchPreloader::runOnMachineBasicBlock(MachineBasicBlock &MBB) {

    MachineBasicBlock::iterator PrevMI = MBB.end();
    MachineBasicBlock::iterator PrevPrevMI = MBB.end();
    MachineBasicBlock* MBBTarget = NULL;


    for (MachineBasicBlock::iterator MI = MBB.begin(), ME = MBB.end();
            MI != ME; ++MI) {

        if (MI->isBundle()) {
            MachineBasicBlock::instr_iterator MII = MI.getInstrIterator();
            const MachineInstr *MInst;
            ++MII;
            while (MII != MBB.end() && MII->isInsideBundle()) {
                MInst = MII;
                if (MInst->isConditionalBranch()) {
                    // get address
                    MBBTarget = MInst->getOperand(1).getMBB();
                    //MInst->dump();
                    break;
                }
                ++MII;
            }
        } else {

            if (MI->isConditionalBranch()) {
                // get address
                //MI->dump();
                MBBTarget = MI->getOperand(1).getMBB();
                break;
            }
        }
        PrevPrevMI = PrevMI;
        PrevMI = MI;
    }

    MBB.getParent()->RenumberBlocks();

    // we can preload this branch
    if (MBBTarget) {

        //std::cout << "enabled: " << EnableBranchPreload << "\n";
        
        if(!EnableBranchPreload){
            MBBTarget = NULL;
        }
      
        if (EnableBranchPreload && MBBTarget != MBPI->getHotSucc(&MBB)) {
            MBBTarget = NULL;
        }

        //if(MBBTarget == NULL){
        //    return;
       // }

        if (PrevPrevMI != MBB.end()) {

            if (PrevPrevMI->isBundle()) {

                if (getSize(PrevPrevMI) < 4) {
                    buildNopOrPreload(TII, &MBB, MBBTarget, PrevPrevMI, BranchPreloader::IN_BUNDLE);

                } else {
                    std::cout << "este branch pode sofrer preload mas não tem espaço no bundle \n";
                }

            } else {
                buildNopOrPreload(TII, &MBB, MBBTarget, PrevPrevMI, BranchPreloader::CREATE_BULDLE);
            }

        } else {
            MachineBasicBlock::iterator Iter = MBB.instr_begin();
            buildNopOrPreload(TII, &MBB, MBBTarget, Iter, BranchPreloader::ALONE);
        }
    }
}

FunctionPass * llvm::createNewTargetBranchPreloader(const TargetInstrInfo * TII) {
    return new BranchPreloader(TII);

}
