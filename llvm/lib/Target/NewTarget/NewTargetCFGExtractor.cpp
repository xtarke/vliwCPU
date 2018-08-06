
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
#include <iomanip>
#include "NewTargetCFGGen.h"

#include <iostream>
#include <list>

using namespace llvm;

namespace {

    // This class implements the Machine function pass.

    class ProfileBBOrderExtractor : public ModulePass {
    public:
        static char ID; // Class identification, replacement for typeinfo

        explicit ProfileBBOrderExtractor()
        : ModulePass(ID) {
        }

        virtual const char *getPassName() const {
            return "Profiling bb order extractor";
        }

        /// run - Load the profile information from the specified file.
        virtual bool runOnModule(Module &M);

    };

    char ProfileBBOrderExtractor::ID = 0;

    bool ProfileBBOrderExtractor::runOnModule(Module &M) {
        std::cout << "ProfileBBOrderExtractor::runOnModule\n";
//        unsigned order = 0;
        
//        profileOrder.clear();
//        profileBBcount = 0;
        
//        for (Module::iterator F = M.begin(), E = M.end(); F != E; ++F) {
//            if (F->isDeclaration()) continue;
//            for (Function::iterator BB = F->begin(), E = F->end(); BB != E; ++BB) {
//                BasicBlock* bb = &*BB;
//                //std::cout << "--> " << std::hex << bb << "\n";
//               profileOrder.insert(std::pair<BasicBlock*, unsigned>(bb, order++));
//                profileBBcount++;
//            }
//        }
        return false;
    }

    class CFGExtractor : public MachineFunctionPass {
    public:

        CFGExtractor(TargetMachine &tm)
        : MachineFunctionPass(ID), TII(tm.getInstrInfo()){
        }

        virtual const char *getPassName() const {
            return "NewTarget Control Flow Extractor";
        }

        bool doFinalization(Module &M);

        bool runOnMachineFunction(MachineFunction &F) {

			CFGGen.processMachineFunction(F);
                        //F.viewCFG();
            return false;
        }

        void getAnalysisUsage(AnalysisUsage &AU) const {
            AU.addRequired<MachineBranchProbabilityInfo>();
            MachineFunctionPass::getAnalysisUsage(AU);
        }

    private:

        //TargetMachine &TM;
        const TargetInstrInfo *TII;
        NewTargetCFGGen CFGGen;

        static char ID;

        std::list<class CFGFunction*> Functions;
    };
    char CFGExtractor::ID = 0;
}


/// runOnMachineBasicBlock




bool CFGExtractor::doFinalization(Module &M) {

    std::string Filename1;
    std::string Filename2;
    
    Filename1 = M.getModuleIdentifier() + ".dot";
    Filename2 = M.getModuleIdentifier() + ".cfg";
    
    CFGGen.dump(Filename2.c_str(), Filename1.c_str());
    
    
    return false;
}

/// createMipsDelaySlotFillerPass - Returns a pass that fills in delay
/// slots in Mips MachineFunctions

FunctionPass *llvm::createNewTargetCFGExtractor(NewTargetMachine &tm) {
    return new CFGExtractor(tm);
}

ModulePass *llvm::createProfileBBOrderExtractor() {
    return new ProfileBBOrderExtractor();
}

