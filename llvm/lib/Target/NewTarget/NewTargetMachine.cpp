/*
 * NewTargetMachine.cpp
 *
 *  Created on: Mar 5, 2013
 *      Author: andreu
 */

#include "NewTarget.h"
#include "NewTargetMachine.h"
#include "NewTargetAsmPrinter.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/PassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Analysis/Passes.h"
#include <iostream>

using namespace llvm;


static cl::
opt<bool> EnableRTOptimizations("enable-newtarget-rtopt",
        cl::Hidden, cl::ZeroOrMore, cl::init(false),
        cl::desc("Enable WCET Optimizations"));



extern Target llvm::TheNewTarget;
std::map<const BasicBlock*, bool> llvm::IsLoopBoundExact;
std::map<const BasicBlock*, int> llvm::LoopBounds;
std::map<const Function*, int> llvm::RecursionDepths;
std::set<MachineBasicBlock*> llvm::NotPredictedMBBs;
std::set<BasicBlock*> llvm::AllowedToUseProfileInfo;

extern "C" void LLVMInitializeNewTargetTarget() {
    // Register the target.
    RegisterTargetMachine<NewTargetMachine> X(TheNewTarget);
}

NewTargetMachine::NewTargetMachine(const Target &T, StringRef TT,
        StringRef CPU, StringRef FS,
        const TargetOptions &Options,
        Reloc::Model RM, CodeModel::Model CM,
        CodeGenOpt::Level OL)
: LLVMTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL),
Subtarget(TT, CPU, FS),
//DL("e-p:32:32-f128:128:128"),
DL("e-p:32:32:32-i8:8:32-i16:16:32"),
InstrInfo(*this),
//FrameLowering(Subtarget),
FrameLowering(*this),
TLInfo(*this),
TSInfo(*this),
InstrItins(&Subtarget.getInstrItineraryData()) {
    //std::cout << "CPU: " << CPU.data() << "\n";
}

// addPassesForOptimizations - Allow the backend (target) to add Target
// Independent Optimization passes to the Pass Manager.

bool NewTargetMachine::addPassesForOptimizations(PassManagerBase &PM) {

    //PM.add(createConstantPropagationPass());
    //PM.add(createDeadCodeEliminationPass());
    //PM.add(createDeadStoreEliminationPass());
    //PM.add(createPromoteMemoryToRegisterPass());
    //PM.add(createLoopUnrollPass());
    return true;
}



namespace {
    /// MBlaze Code Generator Pass Configuration Options.

    class NewTargetPassConfig : public TargetPassConfig {
    public:

        NewTargetPassConfig(NewTargetMachine *TM, PassManagerBase &PM)
        : TargetPassConfig(TM, PM) {
        }

        NewTargetMachine &getNewTargetTargetMachine() const {
            return getTM<NewTargetMachine>();
        }

        virtual bool addInstSelector();
        virtual bool addPreEmitPass();
        virtual void addIRPasses();
        virtual bool addPreRegAlloc();
        virtual bool addPreSched2();
        virtual bool addILPOpts();
    };
} // namespace

TargetPassConfig *NewTargetMachine::createPassConfig(PassManagerBase &PM) {

    return new NewTargetPassConfig(this, PM);
}

// Install an instruction selector pass using
// the ISelDag to gen Mips code.

bool NewTargetPassConfig::addInstSelector() {
    //addPass(createLoopBoundExtractor());
    addPass(createNewTargetISelDag(getNewTargetTargetMachine()));
    return false;
}

// Implemented by targets that want to run passes immediately before
// machine code is emitted. return true if -print-machineinstrs should
// print out the code after the passes.

bool NewTargetPassConfig::addPreEmitPass() {

    NewTargetMachine &TM = getNewTargetTargetMachine();
    //addPass(createNewTargetDelaySlotFillerPass(TM));
    if (EnableRTOptimizations) {
        addPass(createRTOptimizer(TM));
    }

    //if (!DisablePredication) {
    addPass(createNewTargetPredicatedPathMerger(TM.getInstrInfo()));
    //}


    // Create Packets.
    addPass(createNewTargetPacketizer());

    //if(EnableBranchPreload){
    addPass(createNewTargetBranchPreloader(TM.getInstrInfo()));
    //}

    addPass(createNewTargetBundleAligner(TM, TM.getInstrInfo()));
    addPass(createNewTargetCFGExtractor(TM));
    return true;
}

void NewTargetPassConfig::addIRPasses() {
    //addPass(createLCSSAPass());
    //addPass(createScalarEvolutionAliasAnalysisPass());
    //addPass(createLoopSimplifyPass());
    //addPass(createLoopRotatePass());
    //addPass(createLoopUnrollPass(UINT_MAX, 2, 2));

    /*
    addPass(createLoopSimplifyPass());

    addPass(createPromoteMemoryToRegisterPass());
    //addPass(createCFGSimplificationPass());
     */
    //addPass(createProfileBBOrderExtractor());
    // -O2 Level:


    //addPass(createScalarReplAggregatesPass());
    //addPass(createEarlyCSEPass());
    //addPass(createLowerExpectIntrinsicPass());



    addPass(createPromoteMemoryToRegisterPass());
    addPass(createLoopBoundExtractor());
    addPass(createRecursionDepthExtractor());
    addPass(createProfileAuthorizationExtractor());
}

bool NewTargetPassConfig::addPreRegAlloc() {
    //NewTargetMachine &TM = getNewTargetTargetMachine();
    //addPass(createNewTargetLoadStoreOffsetExpander(TM));

    return false;
}

bool NewTargetPassConfig::addPreSched2() {
    //NewTargetMachine &TM = getNewTargetTargetMachine();
    //addPass(createNewTargetLoadStoreOffsetExpander(TM));
    // std::cout << "NewTargetPassConfig::addPreSched2\n";
    //  addPass(&IfConverterID);

    return false;
}

bool NewTargetPassConfig::addILPOpts() {

    //std::cout << "NewTargetPassConfig::addILPOpts\n";
    // addPass(&EarlyIfConverterID);
    return false;
}


