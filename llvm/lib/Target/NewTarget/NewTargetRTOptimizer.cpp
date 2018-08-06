/*
 * NewTargetRTOptimizer.cpp
 *
 *  Created on: Mar 12, 2014
 *      Author: andreu
 */

#include "NewTarget.h"
#include "NewTargetMFSaver.h"
#include "NewTargetWCETEstimator.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include <llvm/CodeGen/MachineFunction.h>
#include <llvm/CodeGen/GCMetadata.h>
#include <llvm/CodeGen/MachineModuleInfo.h>
#include "llvm/CodeGen/MachineInstrBuilder.h"

#include <iostream>

// helper pass, used to map Functions to MachineFunctions

using namespace llvm;

namespace {

    class RTOptimizer : public MachineFunctionPass {
    public:

        RTOptimizer(NewTargetMachine &tm) : MachineFunctionPass(ID), TM(tm) {
        };

        virtual const char *getPassName() const {
            return "NewTarget Real Time Optimizer";
        }

        void getAnalysisUsage(AnalysisUsage &AU) const {
            //AU.setPreservesAll();
            MachineFunctionPass::getAnalysisUsage(AU);
            AU.addRequired<MachineModuleInfo>();
            AU.addRequired<GCModuleInfo>();
            //if (isVerbose())
            //	AU.addRequired<MachineLoopInfo>();
        }

        void applyOptimizations(Module& M);
        void optimizeBranches(Module& M, NewTargetWCETEstimator * Estimator);

        bool doInitialization(Module& M) {

            MachineModuleInfo* MMI = getAnalysisIfAvailable<MachineModuleInfo>();
            GCModuleInfo* MI = getAnalysisIfAvailable<GCModuleInfo>();

            Estimator = new NewTargetWCETEstimator(TM, M, MMI, MI);

            return false;
        }

        bool doFinalization(Module& M) {

            //MachineFunctionSaver* MFSaver = new MachineFunctionSaver(&MF);

            //Estimator->runAnalyzer();

            applyOptimizations(M);

            //MFSaver->rollbackMachineFunction(&MF);

            delete Estimator;

            return false;
        }

        bool runOnMachineFunction(MachineFunction &MF) {


            //std::cout << "------------------antes-------------------" << "\n";

            //MachineFunctionSaver* MFSaver = new MachineFunctionSaver(&MF);

            //Estimator->runAnalyzer();

            //std::cout << "++++++++++++++++++depois++++++++++++++++++" << "\n";
            //MFSaver->rollbackMachineFunction(&MF);
            //MF.dump();

            //delete MFSaver;


            return true;
        }

    private:
        static char ID;
        NewTargetWCETEstimator* Estimator;
        NewTargetMachine &TM;
    };
    char RTOptimizer::ID = 0;
}

class RTOptimizerPass {
public:
    NewTargetWCETEstimator* Estimator;
    const TargetInstrInfo *TII;
    Module &M;

    RTOptimizerPass(NewTargetWCETEstimator* estimator, const TargetInstrInfo *tii, Module &m) :
    Estimator(estimator), TII(tii), M(m) {
    }

    virtual void applyOptimization() {
    }

};

static MachineBasicBlock* getOtherTarget(MachineBasicBlock* MBB, MachineBasicBlock* Target) {

    MachineBasicBlock::succ_iterator IT;
    MachineBasicBlock* OtherTarget = Target;

    for (IT = MBB->succ_begin(); IT != MBB->succ_end(); IT++) {
        MachineBasicBlock* ActualTarget = *IT;
        if (ActualTarget != Target) {
            OtherTarget = ActualTarget;
        }
    }
    return OtherTarget;
}

static bool isNop(MachineInstr *MI) {

    if (MI->getOpcode() == NewTarget::ADDi &&
            MI->getOperand(0).getReg() == NewTarget::ZERO &&
            MI->getOperand(1).getReg() == NewTarget::ZERO &&
            MI->getOperand(2).getImm() == 0) {
        return true;
    }
    return false;
}

static bool isPreload(MachineInstr *MI) {

    if (MI->getOpcode() == NewTarget::PRELD) {
        return true;
    }
    return false;
}

static bool removePreload(const TargetInstrInfo *TII, MachineBasicBlock *MBB, MachineBasicBlock::iterator &Position, MachineBasicBlock *Target) {

    bool inserted = false;
    if (Position == MBB->end()) {
        return false;
    }

    //MBB->dump();

    if (Position->isBundle()) {
        MachineBasicBlock::instr_iterator MII = Position.getInstrIterator();
        MachineInstr *NOPInst;
        bool found = false;
        ++MII;
        while (MII != MBB->end() && MII->isInsideBundle()) {
            NOPInst = MII;
            if (isPreload(NOPInst)) {
                found = true;
                break;
            }
            ++MII;
        }
        if (found) {
            MachineBasicBlock::iterator Iter = Position;
            MachineInstrBuilder MB;
            //MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::PRELD)).addMBB(Target);
            MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::ADDi), NewTarget::ZERO).addReg(NewTarget::ZERO).addImm(0);
            MIBundleBuilder(Iter).append(MB);
            MII->eraseFromBundle();
            inserted = true;
        }

    } else if (isPreload(Position)) {
        MachineBasicBlock::iterator Iter = Position;
        MachineInstrBuilder MB;
        //MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::PRELD)).addMBB(Target);
        MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::ADDi), NewTarget::ZERO).addReg(NewTarget::ZERO).addImm(0);
        Iter = MBB->erase(Iter);
        MBB->insert(Iter, MB);
        inserted = true;
    } else {
        Position->dump();
        llvm_unreachable("this should not happen");
    }

    return inserted;
}

static bool tryToInsertPreload(const TargetInstrInfo *TII, MachineBasicBlock *MBB, MachineBasicBlock::iterator &Position, MachineBasicBlock *Target) {

    bool inserted = false;
    if (Position == MBB->end()) {
        return false;
    }

    //MBB->dump();

    if (Position->isBundle()) {
        MachineBasicBlock::instr_iterator MII = Position.getInstrIterator();
        MachineInstr *NOPInst;
        bool found = false;
        ++MII;
        while (MII != MBB->end() && MII->isInsideBundle()) {
            NOPInst = MII;
            if (isNop(NOPInst)) {
                found = true;
                break;
            }
            ++MII;
        }
        if (found) {
            MachineBasicBlock::iterator Iter = Position;
            MachineInstrBuilder MB;
            MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::PRELD)).addMBB(Target);
            MIBundleBuilder(Iter).append(MB);
            MII->eraseFromBundle();
            inserted = true;
        }

    } else if (isNop(Position)) {
        MachineBasicBlock::iterator Iter = Position;
        MachineInstrBuilder MB;
        MB = BuildMI(*MBB->getParent(), Iter->getDebugLoc(), TII->get(NewTarget::PRELD)).addMBB(Target);
        Iter = MBB->erase(Iter);
        MBB->insert(Iter, MB);
        inserted = true;
    } else {
        Position->dump();
        llvm_unreachable("this should not happen");
    }

    return inserted;
}

static MachineBasicBlock* getBranchTarget(MachineBasicBlock* MBB,
        MachineBasicBlock::iterator &PrevMI, MachineBasicBlock::iterator &PrevPrevMI,
        bool &preloaded) {
    MachineBasicBlock* MBBTarget = NULL;


    for (MachineBasicBlock::iterator MI = MBB->begin(), ME = MBB->end();
            MI != ME; ++MI) {

        if (MI->isBundle()) {
            MachineBasicBlock::instr_iterator MII = MI.getInstrIterator();
            const MachineInstr *MInst;
            ++MII;
            while (MII != MBB->end() && MII->isInsideBundle()) {
                MInst = MII;
                if (MInst->isConditionalBranch()) {
                    // get address
                    MBBTarget = MInst->getOperand(1).getMBB();
                    break;
                } else if (MInst->getOpcode() == NewTarget::PRELD) {
                    //std::cout << "PRELOAD\n";
                    preloaded = true;
                }
                ++MII;
            }
        } else {

            if (MI->isConditionalBranch()) {
                // get address
                //MI->dump();
                MBBTarget = MI->getOperand(1).getMBB();
                break;
            } else if (MI->getOpcode() == NewTarget::PRELD) {
                //std::cout << "PRELOAD\n";
                preloaded = true;
            }
        }

        if (MBBTarget) {
            break;
        }

        PrevPrevMI = PrevMI;
        PrevMI = MI;
    }




    return MBBTarget;
}

void RTOptimizer::optimizeBranches(Module& M, NewTargetWCETEstimator * Estimator) {

}

class RTBranchOptimizator : public RTOptimizerPass {
public:

    RTBranchOptimizator(NewTargetWCETEstimator* estimator, const TargetInstrInfo *tii, Module &m) :
    RTOptimizerPass(estimator, tii, m) {
    }

    void applyOptimization() {
        Module::iterator FT;
        // generate output code for each function
        for (FT = M.begin(); FT != M.end(); FT++) {
            Function* F = &(*FT);
            MachineFunction* MF = F->getMachineFunction();

            if (!MF) {
                continue;
            }

            Estimator->runAnalyzer();
            //MachineFunctionSaver* MFSaver = new MachineFunctionSaver(MF);

            BasicBlockListType::iterator IT;

            for (IT = MF->begin(); IT != MF->end(); IT++) {
                MachineBasicBlock* MBB = &(*IT);

                MachineBasicBlock::iterator PrevMI = MBB->end();
                MachineBasicBlock::iterator PrevPrevMI = MBB->end();
                MachineBasicBlock* MBBTarget = NULL;
                bool preloaded = false;

                MBBTarget = getBranchTarget(MBB, PrevMI, PrevPrevMI, preloaded);

                if (!preloaded && MBBTarget) {

                    if (Estimator->isInWCEP(MBB) && Estimator->isInWCEP(MBBTarget)) {
                        std::cout << "==========caso de interesse========\n";
                        MachineBasicBlock* MBBOtherTarget = getOtherTarget(MBB, MBBTarget);
                        uint32_t TargetCount = Estimator->getMBBWCC(MBBTarget);
                        uint32_t OtherTargetCount = Estimator->getMBBWCC(MBBOtherTarget);
                        std::cout << "Target: " << TargetCount << "\n";
                        std::cout << "OtherTarget: " << OtherTargetCount << "\n";

                        std::cout << "Target bundles: " << MBBTarget->size() << "\n";
                        std::cout << "OtherTarget bundles: " << MBBOtherTarget->size() << "\n";
                        if (TargetCount > OtherTargetCount && (TargetCount - OtherTargetCount) > 2) {
                            std::cout << "\t\t->ok\n";
                            //PrevPrevMI->dump();
                            tryToInsertPreload(TII, MBB, PrevPrevMI, MBBTarget);
                        }
                    }
                }

            }

            //MFSaver->rollbackMachineFunction(MF);

            //MFSaver->commitMachineFunction(MF);
        }
    }

};

static unsigned getNumberOfBundles(MachineBasicBlock *MBB) {
    unsigned count = 0;

    for (MachineBasicBlock::iterator MI = MBB->begin(), ME = MBB->end();
            MI != ME; ++MI) {

        if (MI->isBundle()) {
            count++;
        } else {

            if (!MI->isDebugValue()) {
                count++;
            }
        }
    }

    return count;
}

// their optimizator (literature))
class RTBranchOptimizatorV2 : public RTOptimizerPass {
public:

    RTBranchOptimizatorV2(NewTargetWCETEstimator* estimator, const TargetInstrInfo *tii, Module &m) :
    RTOptimizerPass(estimator, tii, m) {
    }

    void applyOptimization() {
        Module::iterator FT;
        for (FT = M.begin(); FT != M.end(); FT++) {
            Function* F = &(*FT);
            MachineFunction* MF = F->getMachineFunction();

            if (!MF) {
                continue;
            }

            BasicBlockListType::iterator IT;

            for (IT = MF->begin(); IT != MF->end(); IT++) {
                MachineBasicBlock* MBB = &(*IT);
                llvm::NotPredictedMBBs.insert(MBB);
            }
        }

        bool converged = false;

        Estimator->runAnalyzer();

        MBBSet* mbbset = Estimator->getMWorstCaseMBBSet();

        while (!converged) {

            MBBSet::iterator IT;
            //std::cout << "=============== step ===============\n";
            for (IT = mbbset->begin(); IT != mbbset->end(); IT++) {
                MachineBasicBlock* MBB = *IT;

                MachineBasicBlock::iterator PrevMI = MBB->end();
                MachineBasicBlock::iterator PrevPrevMI = MBB->end();
                MachineBasicBlock* MBBTarget = NULL;
                bool preloaded = false;

                if (isPredicted(MBB)) {
                    continue;
                }
                llvm::NotPredictedMBBs.erase(MBB);
                markAsPredicted(MBB);

                MBBTarget = getBranchTarget(MBB, PrevMI, PrevPrevMI, preloaded);

                if (!preloaded && MBBTarget) {

                    if (Estimator->isInWCEP(MBB) && Estimator->isInWCEP(MBBTarget)) {
                        //std::cout << "==========caso de interesse========\n";
                        MachineBasicBlock* MBBOtherTarget = getOtherTarget(MBB, MBBTarget);
                        uint32_t TargetCount = Estimator->getMBBWCC(MBBTarget);
                        uint32_t OtherTargetCount = Estimator->getMBBWCC(MBBOtherTarget);
                        //std::cout << "Target: " << TargetCount << "\n";
                        //std::cout << "OtherTarget: " << OtherTargetCount << "\n";

                        uint32_t TargetMinCycles = getNumberOfBundles(MBBTarget);
                        uint32_t OtherTargetMinCycles = getNumberOfBundles(MBBOtherTarget);

                        //std::cout << "Target bundles: " << TargetMinCycles << "\n";
                        //std::cout << "OtherTarget bundles: " << OtherTargetMinCycles << "\n";

                        if (TargetCount > OtherTargetCount) {
                        //std::cout << "Target: " << TargetCount << "\n";
                        //std::cout << "OtherTarget: " << OtherTargetCount << "\n";
                            tryToInsertPreload(TII, MBB, PrevPrevMI, MBBTarget);
                        }

                    }
                }
            }
            delete mbbset;
            Estimator->runAnalyzer();
            mbbset = Estimator->getMWorstCaseMBBSet();
            if (isAllPredicted(mbbset)) {
                converged = true;
            }
        }
    }
private:
    std::set<MachineBasicBlock*> predicted;

    void markAsPredicted(MachineBasicBlock* MBB) {
        predicted.insert(MBB);
    }

    bool isPredicted(MachineBasicBlock* MBB) {

        std::set<MachineBasicBlock*>::iterator IT;

        IT = predicted.find(MBB);

        if (IT != predicted.end()) {
            return true;
        }

        return false;
    }

    bool isAllPredicted(MBBSet* mbbset) {
        MBBSet::iterator IT;

        for (IT = mbbset->begin(); IT != mbbset->end(); IT++) {
            MachineBasicBlock* MBB = *IT;

            if (!isPredicted(MBB)) {
                return false;
            }
        }
        return true;
    }
};

// our optimizator
class RTBranchOptimizatorV3 : public RTOptimizerPass {
public:

    RTBranchOptimizatorV3(NewTargetWCETEstimator* estimator, const TargetInstrInfo *tii, Module &m) :
    RTOptimizerPass(estimator, tii, m) {
    }

    void applyOptimization() {

        bool converged = false;
        uint32_t oldWcet;

        Estimator->runAnalyzer();
        oldWcet = Estimator->getWCET();

        MBBSet* mbbset = Estimator->getMWorstCaseMBBSet();

        while (!converged) {
            //std::cout << "==================================\n";
            MBBSet::iterator IT;

            for (IT = mbbset->begin(); IT != mbbset->end(); IT++) {
                MachineBasicBlock* MBB = *IT;

                MachineBasicBlock::iterator PrevMI = MBB->end();
                MachineBasicBlock::iterator PrevPrevMI = MBB->end();
                MachineBasicBlock* MBBTarget = NULL;
                bool preloaded = false;

                if (isPredicted(MBB)) {
                    continue;
                }
                markAsPredicted(MBB);

                MBBTarget = getBranchTarget(MBB, PrevMI, PrevPrevMI, preloaded);

                if (!preloaded && MBBTarget) {

                    MachineBasicBlock *MBBOtherTarget = getOtherTarget(MBB, MBBTarget);

                    if (Estimator->getMBBWCC(MBBTarget) > Estimator->getMBBWCC(MBBOtherTarget)) {
                        bool inserted = tryToInsertPreload(TII, MBB, PrevPrevMI, MBBTarget);
                        if (inserted) {
                            Estimator->runAnalyzer();
                            uint32_t newWcet = Estimator->getWCET();
                            //std::cout << "Old Wcet: " << oldWcet << "\n";
                            //std::cout << "New Wcet: " << newWcet << "\n";
                            if (newWcet > oldWcet) {
                                PrevMI = MBB->end();
                                PrevPrevMI = MBB->end();
                                getBranchTarget(MBB, PrevMI, PrevPrevMI, preloaded);
                                //std::cout << "Ops, this shound not happen.\n";
                                removePreload(TII, MBB, PrevPrevMI, MBBTarget);
                                Estimator->runAnalyzer();

                            } else {
                                //std::cout << "Yes, this shound happen.\n.";
                                oldWcet = newWcet;
                                break;
                            }
                        }
                    }


                }
            }
            delete mbbset;
            //Estimator->runAnalyzer();
            mbbset = Estimator->getMWorstCaseMBBSet();
            if (isAllPredicted(mbbset)) {
                converged = true;
            }
        }
    }
private:
    std::set<MachineBasicBlock*> predicted;

    void markAsPredicted(MachineBasicBlock* MBB) {
        predicted.insert(MBB);
    }

    bool isPredicted(MachineBasicBlock* MBB) {

        std::set<MachineBasicBlock*>::iterator IT;

        IT = predicted.find(MBB);

        if (IT != predicted.end()) {
            return true;
        }

        return false;
    }

    bool isAllPredicted(MBBSet* mbbset) {
        MBBSet::iterator IT;

        for (IT = mbbset->begin(); IT != mbbset->end(); IT++) {
            MachineBasicBlock* MBB = *IT;

            if (!isPredicted(MBB)) {
                return false;
            }
        }
        return true;
    }
};

void RTOptimizer::applyOptimizations(Module & M) {


    //RTOptimizerPass* bp = new RTBranchOptimizator(Estimator, TM.getInstrInfo(), M);
    //bp->applyOprimization();

    RTOptimizerPass* bp = new RTBranchOptimizatorV2(Estimator, TM.getInstrInfo(), M);
    bp->applyOptimization();

    //optimizeBranches(M, Estimator);

}

FunctionPass * llvm::createRTOptimizer(NewTargetMachine & TM) {
    return new RTOptimizer(TM);
}
