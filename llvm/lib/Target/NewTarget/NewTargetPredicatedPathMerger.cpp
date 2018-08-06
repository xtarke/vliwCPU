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
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/system_error.h"
#include "llvm/MC/MachineLocation.h"

#include <iostream>
#include <list>
#include <algorithm>
#include <sstream>
#include <cstdio>

using namespace llvm;

static bool forceIfConversion = false;
static bool predicatedLoopUnrolling = true;
static bool forceNewBasicBlocks = false; // true is for bsort100

static cl::
opt<bool> EnableIfConv("enable-newtarget-ifconv",
        cl::Hidden, cl::ZeroOrMore, cl::init(false),
        cl::desc("Enable NewTarget If-conv Optimizations"));

static cl::
opt<bool> EnableLU("enable-newtarget-lu",
        cl::Hidden, cl::ZeroOrMore, cl::init(false),
        cl::desc("Enable NewTarget LU Optimizations"));

namespace {

    enum LoopTypes {
        SIMPLE_FIXED = 0,
        SIMPLE,
        SIMPLE_WITH_CALL,
        COMPLEX,
        UNTOCHABLE
    };

    struct LoopStruct {
        int id;
        MachineBasicBlock *Header;
        MachineBasicBlock *Latch;
        unsigned type;
        bool skip;
    };

    class NewTargetPredicatedPathMerger : public MachineFunctionPass {
    public:

        static char ID; // Class identification, replacement for typeinfo
        std::list<LoopStruct> actualLoops;

        explicit NewTargetPredicatedPathMerger(const TargetInstrInfo *tii)
        : MachineFunctionPass(ID), TII(tii) {
            std::string ErrorInfo;
            LoopInfoOut = new raw_fd_ostream("loop-out.txt", ErrorInfo);
            IfInfoOut = new raw_fd_ostream("if-out.txt", ErrorInfo);

            OwningPtr<MemoryBuffer> Filename;
            if (MemoryBuffer::getFile("loop-in.txt", Filename)) {
                //report_fatal_error("Error on opening, source code file not found.");
                std::cout << "not found.....\n";
            } else {

                const char* buffer = Filename.get()->getBufferStart();
                int s = Filename.get()->getBufferSize();

                while (s > 0) {
                    int32_t id, uf;
                    sscanf(buffer, "%d=%d\n", &id, &uf);

                    loopUnrollingFac.insert(std::make_pair(id, uf));

                    do {
                        s--;
                        buffer++;
                        //std::cout << "" << buffer[0];
                    } while (buffer[0] != '\n');
                    s--;
                    buffer++;
                }

            }
            if (MemoryBuffer::getFile("if-in.txt", Filename)) {
                //report_fatal_error("Error on opening, source code file not found.");
                std::cout << "not found ifs info.....\n";
            } else {

                const char* buffer = Filename.get()->getBufferStart();
                int s = Filename.get()->getBufferSize();

                while (s > 0) {

                    int32_t id, flag;
                    sscanf(buffer, "%d=%d\n", &id, &flag);
                    std::cout << "id: " << id << " flag: " << flag << "\n";
                    ifMustBeMerged.insert(std::make_pair(id, (bool)flag));

                    do {
                        s--;
                        buffer++;
                        //std::cout << "" << buffer[0];
                    } while (buffer[0] != '\n');
                    s--;
                    buffer++;
                }

            }
        }

        virtual void getAnalysisUsage(AnalysisUsage &AU) const {
            AU.setPreservesCFG();
            AU.addRequired<MachineDominatorTree>();
            AU.addPreserved<MachineDominatorTree>();
            AU.addRequired<MachineLoopInfo>();
            AU.addPreserved<MachineLoopInfo>();
            MachineFunctionPass::getAnalysisUsage(AU);
        }

        virtual bool runOnMachineFunction(MachineFunction &MF);
        void loopAnalysis(MachineFunction &MF);
        void predicatedUnroll(MachineFunction &MF, LoopStruct* ls);
        void branchUnroll(MachineFunction &MF, LoopStruct* ls);
        void fixedUnroll(MachineFunction &MF, LoopStruct* ls);
        int getUnrollingFactor(int id);
        bool getConversionFlag(int id);
        void unifyDiamond(MachineBasicBlock *MBB, MachineBasicBlock *Exit);
        void unifyTriangular(MachineBasicBlock *MBB, MachineBasicBlock *Exit);
        void tryToUnrollLoops(MachineFunction &MF);
        void tryToUnrollLoopsV2(MachineFunction &MF);
        void tryToUnrollLoopsV3(MachineFunction &MF);
        bool removeBranch(MachineBasicBlock *MBB);

        bool checkDiamondStructure(const MachineBasicBlock &MBB, MachineBasicBlock* &Exit);
        bool checkTriangularStructure(const MachineBasicBlock &MBB, MachineBasicBlock* &Exit);

    private:
        const TargetInstrInfo *TII;
        MachineLoopInfo *MLI;
        raw_fd_ostream *LoopInfoOut;
        raw_fd_ostream *IfInfoOut;
        std::map<int, int> loopUnrollingFac;
        std::map<int, bool> ifMustBeMerged;
    };
    char NewTargetPredicatedPathMerger::ID = 0;

}

static int loopCounter = 0;
static int ifCounter = 0;

int NewTargetPredicatedPathMerger::getUnrollingFactor(int id) {

    std::map<int, int>::iterator IT = loopUnrollingFac.find(id);
    if (IT != loopUnrollingFac.end()) {
        //std::cout << "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n";
        return IT->second;
    }

    //std::cout << "tesdgfsdgdfgsdfgdfgsdfgdfgsdfgs\n";
    return 0;
}

bool NewTargetPredicatedPathMerger::getConversionFlag(int id) {

    std::map<int, bool>::iterator IT = ifMustBeMerged.find(id);
    if (IT != ifMustBeMerged.end()) {
        return IT->second;
    }

    std::cout << "aquiiiiii\n";
    return false;
}

static bool hasCallOrReturn(MachineBasicBlock *MBB) {
    MachineBasicBlock::iterator IT;

    for (IT = MBB->begin(); IT != MBB->end(); IT++) {
        if (IT->isCall() || IT->isReturn()) {
            return true;
        }
    }

    return false;
}

bool NewTargetPredicatedPathMerger::checkDiamondStructure(const MachineBasicBlock &MBB, MachineBasicBlock* &Exit) {


    if (MBB.succ_size() != 2) {
        return false;
    }

    //MachineBasicBlock::succ_iterator IT = MBB->succ_begin();

    MachineBasicBlock *MBBLeft = *(MBB.succ_begin());
    MachineBasicBlock *MBBRight = *(MBB.succ_begin() + 1);

    if (MBBLeft->succ_size() != 1) {
        return false;
    }

    if (MBBRight->succ_size() != 1) {
        return false;
    }


    if (MBBLeft->isSuccessor(&MBB)) {
        return false;
    }

    if (MBBRight->isSuccessor(&MBB)) {
        return false;
    }

    if (*MBBLeft->succ_begin() != *MBBRight->succ_begin()) {
        return false;
    }

    if (!MBBLeft->isLayoutSuccessor(MBBRight) && !MBBRight->isLayoutSuccessor(MBBLeft)) {
        return false;
    }

    MachineBasicBlock* MBBSucc = *MBBRight->succ_begin();

    if (!MBBLeft->isLayoutSuccessor(MBBSucc) && !MBBRight->isLayoutSuccessor(MBBSucc)) {
        //return false;
        Exit = MBBSucc;
        std::cout << "eewrwrtertert\n";
        //MBB.dump();
        //return false;
    }

    if (hasCallOrReturn(MBBLeft) || hasCallOrReturn(MBBRight)) {
        return false;
    }


    std::cout << "MF: " << MBB.getParent()->getName().data() << " BB: " << MBB.getName().data() << "\n";
    std::cout << "isDiamonsStructure: " << MBBLeft->size() << " " << MBBRight->size() << "\n";

    int ifId = ifCounter++;

    *IfInfoOut << "" << ifId << "\n";
    IfInfoOut->flush();


    return true;

}

bool NewTargetPredicatedPathMerger::checkTriangularStructure(const MachineBasicBlock &MBB, MachineBasicBlock* &Exit) {

    if (MBB.succ_size() != 2) {
        return false;
    }

    // get successors
    MachineBasicBlock *MBBLeft = *(MBB.succ_begin());
    MachineBasicBlock *MBBRight = *(MBB.succ_begin() + 1);

    //if ((!MBB.isLayoutSuccessor(MBBLeft) && !MBBLeft->isLayoutSuccessor(MBBRight)) ||
    //        (!MBB.isLayoutSuccessor(MBBRight) && !MBBRight->isLayoutSuccessor(MBBLeft))) {
    //    return false;
    //}
    // if (hasCallOrReturn(MBB)) {
    //    return false;
    // }

    if (MBB.isLayoutSuccessor(MBBLeft)) {

        if (hasCallOrReturn(MBBLeft)) {
            return false;
        }

        if (MBBLeft->succ_size() != 1) {
            return false;
        }
        if (!MBBLeft->isSuccessor(MBBRight)) {
            return false;
        }

        if (!MBBLeft->isLayoutSuccessor(MBBRight)) {
            std::cout << "-----------------\n";
            Exit = MBBRight;
        }
        std::cout << "==============================A\n";
        //MBB.dump();
        //MBBLeft->dump();
        //MBBRight->dump();

    } else if (MBB.isLayoutSuccessor(MBBRight)) {

        if (hasCallOrReturn(MBBRight)) {
            return false;
        }

        if (MBBRight->succ_size() != 1) {
            return false;
        }
        if (!MBBRight->isSuccessor(MBBLeft)) {
            return false;
        }
        if (!MBBRight->isLayoutSuccessor(MBBLeft)) {
            std::cout << "-----------------\n";
            Exit = MBBLeft;
        }

        std::cout << "==============================B\n";
        //MBB.dump();
        //MBBRight->dump();
        //MBBLeft->dump();
    } else {
        return false;
    }

    std::cout << "MF: " << MBB.getParent()->getName().data() << " BB: " << MBB.getName().data() << "\n";
    std::cout << "isTriangularStructure: " << MBBLeft->size() << " " << MBBRight->size() << "\n";
    // MBB.dump();

    int ifId = ifCounter++;

    *IfInfoOut << "" << ifId << "\n";
    IfInfoOut->flush();


    return true;

}

bool NewTargetPredicatedPathMerger::removeBranch(MachineBasicBlock *MBB) {
    MachineBasicBlock::iterator IT;
    MachineInstr* Instr = NULL;
    MachineInstr* FlagInstr = NULL;

    for (IT = MBB->begin(); IT != MBB->end(); IT++) {
        if (IT->getOpcode() != NewTarget::BR && IT->getOpcode() != NewTarget::BRF) {
            if (IT->getNumOperands() > 0) {
                if (IT->getOperand(0).isReg()) {
                    if (IT->getOperand(0).getReg() == NewTarget::BRFLAG0);
                    FlagInstr = IT;
                    continue;
                }
            }
        }
        if (IT->getOpcode() == NewTarget::BR || IT->getOpcode() == NewTarget::BRF) {
            Instr = IT;
            break;
        }
    }
    // build paron instruction
    BuildMI(*MBB, IT, DebugLoc(), TII->get(NewTarget::PARON));
    ;

    FlagInstr->getOperand(0).setReg(NewTarget::BRFLAG4);
    MBB->remove(Instr); //delete? 
    //MBB->erase(Instr);

    if (Instr->getOpcode() == NewTarget::BR) {
        return true;
    }

    return false;
}

static void removeUncondBranches(MachineBasicBlock *MBB) {
    MachineBasicBlock::iterator IT;
    MachineInstr* Instr = NULL;

    for (IT = MBB->begin(); IT != MBB->end(); IT++) {
        if (IT->getOpcode() == NewTarget::GOTO) {
            Instr = IT;
            break;
        }
    }
    if (Instr) {
        MBB->remove(Instr);
    }

    //MBB->erase(Instr);
}

void NewTargetPredicatedPathMerger::unifyDiamond(MachineBasicBlock *MBB, MachineBasicBlock *Exit) {

    MachineBasicBlock *MBBFalse, *MBBTrue;
    MachineBasicBlock::succ_iterator IT = MBB->succ_begin();
    const NewTargetInstrInfo* tii = (const NewTargetInstrInfo*) TII;
    bool MustConvert;

    MustConvert = getConversionFlag(ifCounter - 1) | forceIfConversion;
    std::cout << "Loop id: " << ifCounter - 1 << " val " << getConversionFlag(ifCounter - 1) << "\n";

    if (!MustConvert) {
        return;
    }

    MBBFalse = *IT++;
    MBBTrue = *IT;

    bool cond = removeBranch(MBB);

    // verify order
    if (cond) {
        MachineBasicBlock *tmp = MBBFalse;
        MBBFalse = MBBTrue;
        MBBTrue = tmp;
    }

    // remove branches
    removeUncondBranches(MBBFalse);
    removeUncondBranches(MBBTrue);

    MachineBasicBlock::instr_iterator ITLeft, ITRight;

    ITRight = MBBTrue->instr_begin();

    // merge if and else into a unique basic block
    for (ITLeft = MBBFalse->instr_begin(); ITLeft != MBBFalse->instr_end(); ITLeft++) {

        if (!ITLeft->isBundledWithPred()) {
            if (ITRight != MBBTrue->instr_end()) {
                ITRight++;

                if (ITRight->isBundledWithPred()) {
                    ITRight++;
                }
            }
        }
        tii->buildPredicatedInstrCopy(ITLeft, MBBTrue, ITRight);

        if (ITLeft->isBundledWithPred() && !ITRight->getPrevNode()->isBundledWithPred()) {
            ITRight->getPrevNode()->bundleWithPred();
        }
    }

    //bool bundled = false;

    /*
    // copy instructions to MBB
    while (!MBBTrue->empty()) {
        bool prevBundled = bundled;
        MachineInstr* Instr = MBBTrue->instr_begin();

        if (Instr->isBundledWithSucc()) {
            bundled = true;
        } else {
            bundled = false;
        }

        MBBTrue->remove_instr(Instr);

        MBB->insert(MBB->instr_end(), Instr);

        if (prevBundled) {
            Instr->bundleWithPred();
        }
    }
     */
    MBBFalse->clear();
    //MBBTrue->clear();

    //remove MBBFalse and MBBTrue
    MBB->removeSuccessor(MBBFalse);
    //MBB->removeSuccessor(MBBTrue);
    MBBFalse->removeSuccessor(*MBBFalse->succ_begin());
    //MBBTrue->removeSuccessor(*MBBTrue->succ_begin());
    //delete them
    MBBFalse->eraseFromParent();
    //MBBTrue->eraseFromParent();

    BuildMI(MBBTrue, DebugLoc(), TII->get(NewTarget::PAROFF));

    if (Exit) {
        //std::cout << "aqui: " << Exit->succ_size() << "\n";
        BuildMI(MBBTrue, DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(Exit);
    }
}

void NewTargetPredicatedPathMerger::unifyTriangular(MachineBasicBlock *MBB, MachineBasicBlock *Exit) {

    MachineBasicBlock *MBBTrue, *MBBExit;
    MachineBasicBlock::succ_iterator IT = MBB->succ_begin();
    const NewTargetInstrInfo* tii = (const NewTargetInstrInfo*) TII;
    bool MustConvert;

    MustConvert = getConversionFlag(ifCounter - 1) | forceIfConversion;

    if (!MustConvert) {
        return;
    }

    MBBTrue = *IT++;
    MBBExit = *IT;
    //MBB->dump();
    if (!MBB->isLayoutSuccessor(MBBTrue)) {
        MachineBasicBlock *Temp;
        Temp = MBBTrue;
        MBBTrue = MBBExit;
        MBBExit = Temp;
    }


    bool cond = removeBranch(MBB);

    // remove branches
    removeUncondBranches(MBBTrue);

    if (!cond) {
        llvm_unreachable("we must finish this code");
        MachineBasicBlock::instr_iterator ITTrue;
        ITTrue = MBBTrue->instr_begin();

        // merge if and else into a unique basic block
        for (unsigned n = 0; n < MBBTrue->size(); n++) {

            MachineBasicBlock::instr_iterator Pos = MBBTrue->instr_end();

            tii->buildPredicatedInstrCopy(ITTrue, MBBTrue, Pos);

            //if (ITLeft->isBundledWithPred()) {
            //    ITRight->getPrevNode()->bundleWithPred();
            //}

            ITTrue++;
        }
    }

    MBB->removeSuccessor(MBBExit);

    BuildMI(MBBTrue, DebugLoc(), TII->get(NewTarget::PAROFF));

    if (Exit) {
        BuildMI(MBBTrue, DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(Exit);
    }

    //MBB->dump();
    //MBBTrue->dump();
    //MBBExit->dump();
}

// original loog unrolling used in the paper.

void NewTargetPredicatedPathMerger::tryToUnrollLoops(MachineFunction &MF) {
    MLI = &getAnalysis<MachineLoopInfo>();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;
    // get the register information
    std::list<MachineLoop*> loopList;

    for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
            I != E; ++I) {
        MachineLoop *L = *I;
        loopList.push_back(L);
    }

    bool changed = true;

    while (changed) {
        changed = false;

        std::list<MachineLoop*>::iterator IT1;
        MachineLoop *LI = NULL;
        for (IT1 = loopList.begin(); IT1 != loopList.end(); IT1++) {
            MachineLoop *L1 = *IT1;
            if (L1->getSubLoops().size() > 0) {
                LI = L1;
                break;
            }
        }
        if (LI) {
            changed = true;
            loopList.remove(LI);
            std::vector<MachineLoop*> subloops = LI->getSubLoops();
            for (int i = 0; i < subloops.size(); i++) {
                loopList.push_back(subloops[i]);
            }
        }
    }
    //std::cout << "Internal loops: " << loopList.size() << "\n";

    for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
            I != E; ++I) {
        MachineLoop *L = *I;

        // for (std::list<MachineLoop*>::iterator I = loopList.begin();
        //         I != loopList.end(); ++I) {
        //     MachineLoop *L = *I;

        int loopId = loopCounter++;

        int uf = getUnrollingFactor(loopId);

        //std::cout << "loop id: " << loopId << "\n";
        *LoopInfoOut << "" << loopId << " " << (uint64_t) L->getHeader() << "\n";
        LoopInfoOut->flush();

        //uf=2;
        if (uf == 0) {
            continue;
        }


        //L->dump();
        //L->getHeader()->dump();

        std::cout << "##analisando loop: " << L->getSubLoops().size() << "\n";

        // verify if we must skip this loop
        if (/*!L->getParentLoop() &&*/ (L->getLoopLatch() != NULL) && (L->getNumBlocks() == 2)) {
            MachineBasicBlock* LoopHeader = L->getHeader();
            MachineBasicBlock* LoopLatch = L->getLoopLatch();
            bool shouldAbord = false;
            MachineBasicBlock::instr_iterator ITLatch, ITHeader;

            for (ITLatch = LoopLatch->instr_begin(); ITLatch != LoopLatch->instr_end(); ITLatch++) {
                if (ITLatch->isCall()) {
                    shouldAbord = true;
                }
            }

            for (ITHeader = LoopHeader->instr_begin(); ITHeader != LoopHeader->instr_end(); ITHeader++) {
                if (ITHeader->isCall()) {
                    shouldAbord = true;
                }
            }

            if (shouldAbord) {
                continue;
            }

            MachineBasicBlock::instr_iterator ITc;

            std::list<MachineInstr*> compareInstrs;

            for (ITc = LoopHeader->instr_begin();
                    ITc != LoopHeader->instr_end(); ITc++) {
                if (!ITc->isCompare()) {
                    continue;
                }
                switch (ITc->getOpcode()) {
                    case NewTarget::CMPGTBR:
                        break;
                    case NewTarget::CMPGTiBR:
                        break;
                    case NewTarget::CMPLTBR:
                        break;
                    case NewTarget::CMPLTiBR:
                        break;
                    case NewTarget::CMPLTiuBR:
                        break;
                    case NewTarget::CMPGEBR:
                        break;
                    case NewTarget::CMPGEiBR:
                        break;
                    case NewTarget::CMPGEiuBR:
                        break;
                    case NewTarget::CMPGEuBR:
                        break;
                    case NewTarget::CMPLEBR:
                        break;
                    case NewTarget::CMPLEiBR:
                        break;
                    default:
                        compareInstrs.push_back(&(*ITc));
                        //ITc->dump();
                        shouldAbord = true;
                }
            }

            if (shouldAbord) {
                //std::cout << "abortando........: " << compareInstrs.size() << "\n";
                //ITc->dump();
                //LoopHeader->dump();
                continue;
            }
            //LoopHeader->dump();
            std::map<const BasicBlock*, bool>::iterator IsExact;
            std::map<const BasicBlock*, int>::iterator TripCount;


            IsExact = llvm::IsLoopBoundExact.find(LoopHeader->getBasicBlock());
            TripCount = llvm::LoopBounds.find(LoopHeader->getBasicBlock());

            if (IsExact != IsLoopBoundExact.end()) {
                if (IsExact->second) {
                    //std::cout << "Este loop é exato: " << TripCount->second << "\n";
                } else {
                    //std::cout << "Este loop NÃO é exato: " << TripCount->second << "\n";
                }
            }

            if (TripCount->second == 0xCACACACA) {
                continue;
            }

            if (TripCount->second < 10) {
                continue;
            }

            if (LoopLatch->isLayoutSuccessor(LoopHeader)) {
                LoopHeader->moveBefore(LoopLatch);
                MachineBasicBlock *MBBPrev = LoopHeader->getPrevNode();

                MachineBasicBlock::instr_iterator ITgoto;
                for (ITgoto = MBBPrev->instr_begin();
                        ITgoto != MBBPrev->instr_end(); ITgoto++) {
                    if (ITgoto->isUnconditionalBranch() && ITgoto->getOperand(0).getMBB() == LoopHeader) {
                        break;
                    }
                }


                if (ITgoto != MBBPrev->instr_end()) {
                    MBBPrev->remove_instr(ITgoto);
                }


                // change branch that enters the loop body to the exit
                MachineBasicBlock::instr_iterator ITbranch, ITcmp, ITgoto1;
                bool changeCompare = true;

                for (ITbranch = LoopHeader->instr_begin();
                        ITbranch != LoopHeader->instr_end(); ITbranch++) {
                    if (ITbranch->isConditionalBranch()) {
                        ITbranch->getOperand(0).setReg(NewTarget::BRFLAG4);

                        if (ITbranch->getOperand(1).getMBB() == LoopLatch) {
                            ITbranch->getOperand(1).setMBB(LoopLatch->getNextNode());
                        } else {
                            changeCompare = false;
                        }

                    } else if (ITbranch->isCompare()) {
                        ITcmp = ITbranch;
                    } else if (ITbranch->isUnconditionalBranch()) {
                        ITgoto1 = ITbranch;
                    }
                }

                if (changeCompare) {
                    MachineInstr *MICMP = ITcmp;
                    unsigned opcode = 0;
                    switch (ITcmp->getOpcode()) {
                        case NewTarget::CMPGTBR:
                            opcode = NewTarget::CMPLEBR;
                            break;
                        case NewTarget::CMPGTiBR:
                            opcode = NewTarget::CMPLEiBR;
                            break;
                        case NewTarget::CMPLTBR:
                            opcode = NewTarget::CMPGEBR;
                            break;
                        case NewTarget::CMPLTiBR:
                            opcode = NewTarget::CMPGEiBR;
                            break;
                        case NewTarget::CMPLTiuBR:
                            opcode = NewTarget::CMPGEiuBR;
                            break;
                        case NewTarget::CMPGEBR:
                            opcode = NewTarget::CMPLTBR;
                            break;
                        case NewTarget::CMPGEiBR:
                            opcode = NewTarget::CMPLTiBR;
                            break;
                        case NewTarget::CMPGEiuBR:
                            opcode = NewTarget::CMPLTiuBR;
                            break;
                        case NewTarget::CMPGEuBR:
                            opcode = NewTarget::CMPLTuBR;
                            break;
                        case NewTarget::CMPLEBR:
                            opcode = NewTarget::CMPGTBR;
                            break;
                        case NewTarget::CMPLEiBR:
                            opcode = NewTarget::CMPGTiBR;
                            break;
                        default:
                            llvm_unreachable("");
                    }

                    MachineOperand M1 = ITcmp->getOperand(1);
                    MachineOperand M2 = ITcmp->getOperand(2);


                    BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), NewTarget::BRFLAG4).addOperand(M1).addOperand(M2);
                    LoopHeader->remove_instr(MICMP);

                } else {
                    LoopHeader->remove_instr(ITgoto1);
                    ITcmp->getOperand(0).setReg(NewTarget::BRFLAG4);
                }

                //LoopHeader->dump();


                MachineFunction* MF = LoopHeader->getParent();
                MachineBasicBlock* Position = LoopLatch;

                MachineBasicBlock * MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());

                MF->insert(MF->end(), MBB);
                MBB->moveAfter(Position);

                MachineBasicBlock::instr_iterator IT;
                for (int i = 0; i < uf; i++) {
                    //std::cout << "iteração: " << i << "\n";
                    MachineBasicBlock::instr_iterator IT;
                    // copy loop's body
                    for (IT = LoopLatch->instr_begin(); IT != LoopLatch->instr_end(); IT++) {
                        MachineInstr& Instr = *IT;
                        if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                        MachineBasicBlock::instr_iterator ITEnd = MBB->instr_end();
                        NTII->buildPredicatedInstrCopy(IT, MBB, ITEnd);
                    }

                    Position = MBB;
                    // new
                    if (i != 1) {
                        for (IT = LoopHeader->instr_begin(); IT != LoopHeader->instr_end(); IT++) {
                            MachineInstr& Instr = *IT;
                            if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                            else {
                                MBB->insert(MBB->instr_end(), MF->CloneMachineInstr(&Instr));
                                if (IT->isBundledWithPred()) {
                                    MBB->back().bundleWithPred();
                                }
                            }
                        }

                        // this is a synchronizatio step necessary to ensure that a predicate write preceedes a
                        // predicated instruction in at last 2 clock cycles.
                        BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::ADDi)).addReg(NewTarget::ZERO).
                                addReg(NewTarget::ZERO).addImm(5);
                    }
                }

                //TripCount->second = 2;
                int newCount = TripCount->second - 1;

                while ((newCount % uf) != 0) {
                    newCount++;
                }

                TripCount->second = (newCount / uf) + 1;


                LoopHeader->replaceSuccessor(LoopLatch, MBB);
                LoopLatch->removeFromParent();
                MF->DeleteMachineBasicBlock(LoopLatch);

                MBB->addSuccessor(LoopHeader);
                BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
                //MF->viewCFG();
            } else {
            }
        } else {
            //std::cout << "seria este o caso2?\n";
            // L->dump();
            //L->getHeader()->dump();
        }
    }
}

void NewTargetPredicatedPathMerger::loopAnalysis(MachineFunction &MF) {
    MLI = &getAnalysis<MachineLoopInfo>();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;
    // get the register information
    std::list<MachineLoop*> loopList;

    for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
            I != E; ++I) {
        MachineLoop *L = *I;
        loopList.push_back(L);
    }

    bool changed = true;

    while (changed) {
        changed = false;

        std::list<MachineLoop*>::iterator IT1;
        MachineLoop *LI = NULL;
        for (IT1 = loopList.begin(); IT1 != loopList.end(); IT1++) {
            MachineLoop *L1 = *IT1;
            if (L1->getSubLoops().size() > 0) {
                LI = L1;
                break;
            }
        }
        if (LI) {
            changed = true;
            loopList.remove(LI);
            std::vector<MachineLoop*> subloops = LI->getSubLoops();
            for (int i = 0; i < subloops.size(); i++) {
                loopList.push_back(subloops[i]);
            }
        }
    }

    for (std::list<MachineLoop*>::iterator I = loopList.begin();
            I != loopList.end(); ++I) {
        MachineLoop *L = *I;
        //for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
        //      I != E; ++I) {
        //MachineLoop *L = *I;

        int loopId = loopCounter++;

        int uf = getUnrollingFactor(loopId);

        //std::cout << "loop id: " << loopId << "\n";
        *LoopInfoOut << "" << loopId << " " << (uint64_t) L->getHeader() << " ";


        // verify if we must skip this loop
        if (/*!L->getParentLoop() &&*/ (L->getLoopLatch() != NULL) && (L->getNumBlocks() == 2)) {
            MachineBasicBlock* LoopHeader = L->getHeader();
            MachineBasicBlock* LoopLatch = L->getLoopLatch();
            bool hasCall = false;
            MachineBasicBlock::instr_iterator ITLatch, ITHeader;

            for (ITLatch = LoopLatch->instr_begin(); ITLatch != LoopLatch->instr_end(); ITLatch++) {
                if (ITLatch->isCall()) {
                    hasCall = true;
                }
            }

            for (ITHeader = LoopHeader->instr_begin(); ITHeader != LoopHeader->instr_end(); ITHeader++) {
                if (ITHeader->isCall()) {
                    hasCall = true;
                }
            }

            MachineBasicBlock::instr_iterator ITc;

            std::list<MachineInstr*> compareInstrs;

            for (ITc = LoopHeader->instr_begin();
                    ITc != LoopHeader->instr_end(); ITc++) {
                if (!ITc->isCompare()) {
                    continue;
                }
                switch (ITc->getOpcode()) {
                    case NewTarget::CMPGTBR:
                        break;
                    case NewTarget::CMPGTiBR:
                        break;
                    case NewTarget::CMPLTBR:
                        break;
                    case NewTarget::CMPLTiBR:
                        break;
                    case NewTarget::CMPLTiuBR:
                        break;
                    case NewTarget::CMPGEBR:
                        break;
                    case NewTarget::CMPGEiBR:
                        break;
                    case NewTarget::CMPGEiuBR:
                        break;
                    case NewTarget::CMPGEuBR:
                        break;
                    case NewTarget::CMPLEBR:
                        break;
                    case NewTarget::CMPLEiBR:
                        break;
                    default:
                        compareInstrs.push_back(&(*ITc));
                        //ITc->dump();
                        //hasCall = true;
                }
            }

            //LoopHeader->dump();
            std::map<const BasicBlock*, bool>::iterator IsExact;
            std::map<const BasicBlock*, int>::iterator TripCount;

            IsExact = llvm::IsLoopBoundExact.find(LoopHeader->getBasicBlock());
            TripCount = llvm::LoopBounds.find(LoopHeader->getBasicBlock());

            struct LoopStruct thisLoop;

            thisLoop.Header = LoopHeader;
            thisLoop.Latch = LoopLatch;
            thisLoop.id = loopId;

            if (uf == 0) {
                thisLoop.skip = true;
            } else {
                thisLoop.skip = false;
            }

            if (TripCount->second == 0xCACACACA) {
                thisLoop.type = UNTOCHABLE;
            } else if (IsExact->second && !hasCall) {
                thisLoop.type = SIMPLE_FIXED;
            } else if (hasCall) {
                thisLoop.type = SIMPLE_WITH_CALL;
            } else {
                thisLoop.type = SIMPLE;
            }
            *LoopInfoOut << "" << thisLoop.type << " " << TripCount->second - 1 << "\n";
            //std::cout << "" << thisLoop.type << " " << TripCount->second << "\n";
            actualLoops.push_back(thisLoop);
        } else {
            *LoopInfoOut << "" << UNTOCHABLE << " " << 0 << "\n";
        }
        LoopInfoOut->flush();
    }
}

void NewTargetPredicatedPathMerger::fixedUnroll(MachineFunction &MF, LoopStruct* ls) {
    MLI = &getAnalysis<MachineLoopInfo>();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;



    MachineBasicBlock* LoopHeader = ls->Header;
    MachineBasicBlock* LoopLatch = ls->Latch;

    std::map<const BasicBlock*, bool>::iterator IsExact;
    std::map<const BasicBlock*, int>::iterator TripCount;

    IsExact = llvm::IsLoopBoundExact.find(LoopHeader->getBasicBlock());
    TripCount = llvm::LoopBounds.find(LoopHeader->getBasicBlock());

    int uf = getUnrollingFactor(ls->id);

    if (LoopLatch->isLayoutSuccessor(LoopHeader)) {
        LoopHeader->moveBefore(LoopLatch);
        MachineBasicBlock *MBBPrev = LoopHeader->getPrevNode();

        MachineBasicBlock::instr_iterator ITgoto;
        for (ITgoto = MBBPrev->instr_begin();
                ITgoto != MBBPrev->instr_end(); ITgoto++) {
            if (ITgoto->isUnconditionalBranch() && ITgoto->getOperand(0).getMBB() == LoopHeader) {
                break;
            }
        }

        if (ITgoto != MBBPrev->instr_end()) {
            MBBPrev->remove_instr(ITgoto);
        }

        // change branch that enters the loop body to the exit
        MachineBasicBlock::instr_iterator ITHeader, ITcmp, ITgoto1, ITBranch;
        ITgoto1 = LoopHeader->instr_end();
        bool changeCompare = true;
        bool changeBranch = false;

        for (ITHeader = LoopHeader->instr_begin();
                ITHeader != LoopHeader->instr_end(); ITHeader++) {
            if (ITHeader->isConditionalBranch()) {
                ITHeader->getOperand(0).setReg(NewTarget::BRFLAG4);

                if (ITHeader->getOperand(1).getMBB() == LoopLatch) {
                    ITHeader->getOperand(1).setMBB(LoopLatch->getNextNode());
                } else {
                    ///std::cout << "changeCompare = false;\n";
                    //LoopLatch->dump();
                    //LoopHeader->dump();
                    //changeCompare = false;
                    ITBranch = ITHeader;
                    changeBranch = true;
                }

            } else if (ITHeader->isCompare()) {
                ITcmp = ITHeader;
            } else if (ITHeader->isUnconditionalBranch()) {
                ITgoto1 = ITHeader;
            }
        }

        if (changeCompare) {
            //std::cout << "if (changeCompare) \n";
            bool isSelect = false;
            MachineInstr *MICMP = ITcmp;
            unsigned opcode = 0;
            switch (ITcmp->getOpcode()) {
                case NewTarget::CMPGTBR:
                    opcode = NewTarget::CMPLEBR;
                    break;
                case NewTarget::CMPGTiBR:
                    opcode = NewTarget::CMPLEiBR;
                    break;
                    // under test
                case NewTarget::CMPGTiREG:
                    opcode = NewTarget::CMPLEiREG;
                    break;
                case NewTarget::CMPLTBR:
                    opcode = NewTarget::CMPGEBR;
                    break;
                case NewTarget::CMPLTiBR:
                    opcode = NewTarget::CMPGEiBR;
                    break;
                case NewTarget::CMPLTiuBR:
                    opcode = NewTarget::CMPGEiuBR;
                    break;
                case NewTarget::CMPGEBR:
                    opcode = NewTarget::CMPLTBR;
                    break;
                case NewTarget::CMPGEiBR:
                    opcode = NewTarget::CMPLTiBR;
                    break;
                case NewTarget::CMPGEiuBR:
                    opcode = NewTarget::CMPLTiuBR;
                    break;
                case NewTarget::CMPGEuBR:
                    opcode = NewTarget::CMPLTuBR;
                    break;
                case NewTarget::CMPLEBR:
                    opcode = NewTarget::CMPGTBR;
                    break;
                case NewTarget::CMPLEiBR:
                    opcode = NewTarget::CMPGTiBR;
                    break;
                case NewTarget::SELECT:
                    opcode = NewTarget::SELECTF;
                    isSelect = true;
                    break;
                case NewTarget::SELECTF:
                    opcode = NewTarget::SELECT;
                    isSelect = true;
                    break;
                default:
                    ITcmp->dump();
                    llvm_unreachable("");
            }

            if (isSelect) {
                MachineOperand M0 = ITcmp->getOperand(0);
                MachineOperand M1 = ITcmp->getOperand(1);
                MachineOperand M2 = ITcmp->getOperand(2);
                MachineOperand M3 = ITcmp->getOperand(3);

                BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), M0.getReg()).addOperand(M1).addOperand(M2).addOperand(M3);
                LoopHeader->remove_instr(MICMP);
            } else {
                MachineOperand M0 = ITcmp->getOperand(0);
                MachineOperand M1 = ITcmp->getOperand(1);
                MachineOperand M2 = ITcmp->getOperand(2);

                BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), M0.getReg()).addOperand(M1).addOperand(M2);
                LoopHeader->remove_instr(MICMP);
            }

            if (changeBranch) {
                MachineOperand M3 = ITBranch->getOperand(0);
                MachineOperand M4 = ITBranch->getOperand(1);
                unsigned opcodeBranch = ITBranch->getOpcode();
                opcodeBranch = (opcodeBranch == NewTarget::BR) ? NewTarget::BRF : NewTarget::BR;

                BuildMI(*LoopHeader, ITBranch, DebugLoc(), TII->get(opcodeBranch)).addOperand(M3).addOperand(M4);
                LoopHeader->remove_instr(ITBranch);

                LoopHeader->remove_instr(ITgoto1);
                ITcmp->getOperand(0).setReg(NewTarget::BRFLAG0);
            }


        } else {
            LoopHeader->remove_instr(ITgoto1);
            ITcmp->getOperand(0).setReg(NewTarget::BRFLAG0);
        }

        MachineFunction* MF = LoopHeader->getParent();
        MachineBasicBlock* Position = LoopLatch;

        MachineBasicBlock * MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());

        MF->insert(MF->end(), MBB);
        MBB->moveAfter(Position);
        MachineBasicBlock* FirstMBB = NULL;

        MachineBasicBlock::instr_iterator IT;
        for (int i = 0; i < uf; i++) {

            if (forceNewBasicBlocks) {
                MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());
                MF->insert(MF->end(), MBB);
                MBB->moveAfter(Position);


                if (FirstMBB == NULL) {
                    FirstMBB = MBB;
                }

                Position->addSuccessor(MBB);

                Position = MBB;
            }

            MachineBasicBlock::instr_iterator IT;
            // copy loop's body
            for (IT = LoopLatch->instr_begin(); IT != LoopLatch->instr_end(); IT++) {
                MachineInstr& Instr = *IT;
                if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                MachineBasicBlock::instr_iterator ITEnd = MBB->instr_end();
                NTII->buildInstrCopy(IT, MBB, ITEnd);
            }

            Position = MBB;
        }

        //TripCount->second = 2;
        int newCount = TripCount->second - 1;

        while ((newCount % uf) != 0) {
            newCount++;
        }

        TripCount->second = (newCount / uf) + 1;

        if (LoopLatch->isSuccessor(LoopHeader)) {
            LoopLatch->removeSuccessor(LoopHeader);
        }

        if (forceNewBasicBlocks) {
            LoopHeader->replaceSuccessor(LoopLatch, FirstMBB);
            LoopLatch->removeFromParent();
            MF->DeleteMachineBasicBlock(LoopLatch);

            MBB->addSuccessor(LoopHeader);
            BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
        } else {
            LoopHeader->replaceSuccessor(LoopLatch, MBB);
            LoopLatch->removeFromParent();
            MF->DeleteMachineBasicBlock(LoopLatch);

            MBB->addSuccessor(LoopHeader);

            BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
        }

    }
}

void NewTargetPredicatedPathMerger::predicatedUnroll(MachineFunction &MF, LoopStruct* ls) {
    MLI = &getAnalysis<MachineLoopInfo>();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;



    MachineBasicBlock* LoopHeader = ls->Header;
    MachineBasicBlock* LoopLatch = ls->Latch;

    std::map<const BasicBlock*, bool>::iterator IsExact;
    std::map<const BasicBlock*, int>::iterator TripCount;

    IsExact = llvm::IsLoopBoundExact.find(LoopHeader->getBasicBlock());
    TripCount = llvm::LoopBounds.find(LoopHeader->getBasicBlock());

    int uf = getUnrollingFactor(ls->id);

    if (LoopLatch->isLayoutSuccessor(LoopHeader)) {
        LoopHeader->moveBefore(LoopLatch);
        MachineBasicBlock *MBBPrev = LoopHeader->getPrevNode();

        MachineBasicBlock::instr_iterator ITgoto;
        for (ITgoto = MBBPrev->instr_begin();
                ITgoto != MBBPrev->instr_end(); ITgoto++) {
            if (ITgoto->isUnconditionalBranch() && ITgoto->getOperand(0).getMBB() == LoopHeader) {
                break;
            }
        }

        if (ITgoto != MBBPrev->instr_end()) {
            MBBPrev->remove_instr(ITgoto);
        }

        // change branch that enters the loop body to the exit
        MachineBasicBlock::instr_iterator ITHeader, ITcmp, ITgoto1, ITBranch;
        ITgoto1 = LoopHeader->instr_end();
        bool changeCompare = true;
        bool changeBranch = false;

        for (ITHeader = LoopHeader->instr_begin();
                ITHeader != LoopHeader->instr_end(); ITHeader++) {
            if (ITHeader->isConditionalBranch()) {
                ITHeader->getOperand(0).setReg(NewTarget::BRFLAG4);

                if (ITHeader->getOperand(1).getMBB() == LoopLatch) {
                    ITHeader->getOperand(1).setMBB(LoopLatch->getNextNode());
                } else {
                    ///std::cout << "changeCompare = false;\n";
                    //LoopLatch->dump();
                    //LoopHeader->dump();
                    //changeCompare = false;
                    ITBranch = ITHeader;
                    changeBranch = true;
                }

            } else if (ITHeader->isCompare()) {
                ITcmp = ITHeader;
            } else if (ITHeader->isUnconditionalBranch()) {
                ITgoto1 = ITHeader;
            }
        }

        if (changeCompare) {
            bool isSelect = false;
            MachineInstr *MICMP = ITcmp;
            unsigned opcode = 0;
            switch (ITcmp->getOpcode()) {
                case NewTarget::CMPGTBR:
                    opcode = NewTarget::CMPLEBR;
                    break;
                case NewTarget::CMPGTiBR:
                    opcode = NewTarget::CMPLEiBR;
                    break;
                case NewTarget::CMPLTBR:
                    opcode = NewTarget::CMPGEBR;
                    break;
                case NewTarget::CMPLTiBR:
                    opcode = NewTarget::CMPGEiBR;
                    break;
                case NewTarget::CMPLTiuBR:
                    opcode = NewTarget::CMPGEiuBR;
                    break;
                case NewTarget::CMPGEBR:
                    opcode = NewTarget::CMPLTBR;
                    break;
                case NewTarget::CMPGEiBR:
                    opcode = NewTarget::CMPLTiBR;
                    break;
                case NewTarget::CMPGEiuBR:
                    opcode = NewTarget::CMPLTiuBR;
                    break;
                case NewTarget::CMPGEuBR:
                    opcode = NewTarget::CMPLTuBR;
                    break;
                case NewTarget::CMPLEBR:
                    opcode = NewTarget::CMPGTBR;
                    break;
                case NewTarget::CMPLEiBR:
                    opcode = NewTarget::CMPGTiBR;
                    break;
                case NewTarget::SELECT:
                    opcode = NewTarget::SELECTF;
                    isSelect = true;
                    break;
                case NewTarget::SELECTF:
                    opcode = NewTarget::SELECT;
                    isSelect = true;
                    break;
                default:
                    ITcmp->dump();
                    llvm_unreachable("");
            }

            if (isSelect) {
                MachineOperand M0 = ITcmp->getOperand(0);
                MachineOperand M1 = ITcmp->getOperand(1);
                MachineOperand M2 = ITcmp->getOperand(2);
                MachineOperand M3 = ITcmp->getOperand(3);

                BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), M0.getReg()).addOperand(M1).addOperand(M2).addOperand(M3);
                LoopHeader->remove_instr(MICMP);

                MachineBasicBlock::instr_iterator ITTemp = LoopHeader->instr_begin();

                while (ITTemp != LoopHeader->instr_end()) {
                    //ITTemp->dump();

                    if (ITTemp->getOperand(0).isReg() && ITTemp->getOperand(0).getReg() == NewTarget::BRFLAG0) {
                        ITTemp->getOperand(0).setReg(NewTarget::BRFLAG4);
                        break;
                    }
                    ITTemp++;
                }

            } else {
                MachineOperand M1 = ITcmp->getOperand(1);
                MachineOperand M2 = ITcmp->getOperand(2);

                BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), NewTarget::BRFLAG4).addOperand(M1).addOperand(M2);
                LoopHeader->remove_instr(MICMP);
            }


            if (changeBranch) {
                MachineOperand M3 = ITBranch->getOperand(0);
                MachineOperand M4 = ITBranch->getOperand(1);
                unsigned opcodeBranch = ITBranch->getOpcode();
                opcodeBranch = (opcodeBranch == NewTarget::BR) ? NewTarget::BRF : NewTarget::BR;

                BuildMI(*LoopHeader, ITBranch, DebugLoc(), TII->get(opcodeBranch)).addOperand(M3).addOperand(M4);
                LoopHeader->remove_instr(ITBranch);

                LoopHeader->remove_instr(ITgoto1);
                ITcmp->getOperand(0).setReg(NewTarget::BRFLAG4);
            }


        } else {
            LoopHeader->remove_instr(ITgoto1);
            ITcmp->getOperand(0).setReg(NewTarget::BRFLAG4);
        }

        MachineFunction* MF = LoopHeader->getParent();
        MachineBasicBlock* Position = LoopLatch;

        MachineBasicBlock * MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());

        MF->insert(MF->end(), MBB);
        MBB->moveAfter(Position);
        MachineBasicBlock* FirstMBB = NULL;

        MachineBasicBlock::instr_iterator IT;
        for (int i = 0; i < uf; i++) {

            if (forceNewBasicBlocks) {
                MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());
                MF->insert(MF->end(), MBB);
                MBB->moveAfter(Position);


                if (FirstMBB == NULL) {
                    FirstMBB = MBB;
                }

                Position->addSuccessor(MBB);

                Position = MBB;
            }

            MachineBasicBlock::instr_iterator IT;
            // copy loop's body
            for (IT = LoopLatch->instr_begin(); IT != LoopLatch->instr_end(); IT++) {
                MachineInstr& Instr = *IT;
                if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                MachineBasicBlock::instr_iterator ITEnd = MBB->instr_end();
                NTII->buildPredicatedInstrCopy(IT, MBB, ITEnd);
            }

            Position = MBB;
            // new
            if (i != 1) {
                for (IT = LoopHeader->instr_begin(); IT != LoopHeader->instr_end(); IT++) {
                    MachineInstr& Instr = *IT;
                    if (Instr.isConditionalBranch() || Instr.isUnconditionalBranch() || Instr.isDebugValue()) continue;
                    else {
                        MBB->insert(MBB->instr_end(), MF->CloneMachineInstr(&Instr));
                        if (IT->isBundledWithPred()) {
                            MBB->back().bundleWithPred();
                        }
                    }
                }

                // this is a synchronizatio step necessary to ensure that a predicate write preceedes a
                // predicated instruction in at last 2 clock cycles.
                BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::ADDi)).addReg(NewTarget::ZERO).
                        addReg(NewTarget::ZERO).addImm(5);
            }
        }

        //TripCount->second = 2;
        int newCount = TripCount->second - 1;

        while ((newCount % uf) != 0) {
            newCount++;
        }

        TripCount->second = (newCount / uf) + 1;

        if (LoopLatch->isSuccessor(LoopHeader)) {
            LoopLatch->removeSuccessor(LoopHeader);
        }

        if (forceNewBasicBlocks) {
            LoopHeader->replaceSuccessor(LoopLatch, FirstMBB);
            LoopLatch->removeFromParent();
            MF->DeleteMachineBasicBlock(LoopLatch);

            MBB->addSuccessor(LoopHeader);
            BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
        } else {
            LoopHeader->replaceSuccessor(LoopLatch, MBB);
            LoopLatch->removeFromParent();
            MF->DeleteMachineBasicBlock(LoopLatch);

            MBB->addSuccessor(LoopHeader);

            BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
        }

    }
}

void NewTargetPredicatedPathMerger::branchUnroll(MachineFunction &MF, LoopStruct* ls) {
    MLI = &getAnalysis<MachineLoopInfo>();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;



    MachineBasicBlock* LoopHeader = ls->Header;
    MachineBasicBlock* LoopLatch = ls->Latch;

    std::map<const BasicBlock*, bool>::iterator IsExact;
    std::map<const BasicBlock*, int>::iterator TripCount;

    IsExact = llvm::IsLoopBoundExact.find(LoopHeader->getBasicBlock());
    TripCount = llvm::LoopBounds.find(LoopHeader->getBasicBlock());

    int uf = getUnrollingFactor(ls->id);

    if (LoopLatch->isLayoutSuccessor(LoopHeader)) {

        LoopHeader->moveBefore(LoopLatch);
        MachineBasicBlock *MBBPrev = LoopHeader->getPrevNode();

        MachineBasicBlock::instr_iterator ITgoto;
        for (ITgoto = MBBPrev->instr_begin();
                ITgoto != MBBPrev->instr_end(); ITgoto++) {
            if (ITgoto->isUnconditionalBranch() && ITgoto->getOperand(0).getMBB() == LoopHeader) {
                break;
            }
        }


        if (ITgoto != MBBPrev->instr_end()) {
            MBBPrev->remove_instr(ITgoto);
        }


        // change branch that enters the loop body to the exit
        MachineBasicBlock::instr_iterator ITbranch, ITcmp, ITgoto1;
        bool changeCompare = true;
        MachineBasicBlock * LoopExit = NULL;

        for (ITbranch = LoopHeader->instr_begin();
                ITbranch != LoopHeader->instr_end(); ITbranch++) {
            if (ITbranch->isConditionalBranch()) {
                ITbranch->getOperand(0).setReg(NewTarget::BRFLAG0);
                LoopExit = ITbranch->getOperand(1).getMBB();
                if (ITbranch->getOperand(1).getMBB() == LoopLatch) {
                    ITbranch->getOperand(1).setMBB(LoopLatch->getNextNode());
                } else {
                    changeCompare = false;
                }

            } else if (ITbranch->isCompare()) {
                ITcmp = ITbranch;
            } else if (ITbranch->isUnconditionalBranch()) {
                ITgoto1 = ITbranch;
            }
        }

        if (changeCompare) {
            bool isSelect = false;
            MachineInstr *MICMP = ITcmp;
            unsigned opcode = 0;
            switch (ITcmp->getOpcode()) {
                case NewTarget::CMPGTBR:
                    opcode = NewTarget::CMPLEBR;
                    break;
                case NewTarget::CMPGTiBR:
                    opcode = NewTarget::CMPLEiBR;
                    break;
                case NewTarget::CMPGTiREG:
                    opcode = NewTarget::CMPLEiREG;
                    break;
                case NewTarget::CMPLTBR:
                    opcode = NewTarget::CMPGEBR;
                    break;
                case NewTarget::CMPLTiBR:
                    opcode = NewTarget::CMPGEiBR;
                    break;
                case NewTarget::CMPLTiREG:
                    opcode = NewTarget::CMPGEiREG;
                    break;
                case NewTarget::CMPLTiuBR:
                    opcode = NewTarget::CMPGEiuBR;
                    break;
                case NewTarget::CMPGEBR:
                    opcode = NewTarget::CMPLTBR;
                    break;
                case NewTarget::CMPGEiBR:
                    opcode = NewTarget::CMPLTiBR;
                    break;
                case NewTarget::CMPGEiuBR:
                    opcode = NewTarget::CMPLTiuBR;
                    break;
                case NewTarget::CMPGEuBR:
                    opcode = NewTarget::CMPLTuBR;
                    break;
                case NewTarget::CMPLEBR:
                    opcode = NewTarget::CMPGTBR;
                    break;
                case NewTarget::CMPLEiBR:
                    opcode = NewTarget::CMPGTiBR;
                    break;
                case NewTarget::SELECT:
                    opcode = NewTarget::SELECTF;
                    isSelect = true;
                    break;
                case NewTarget::SELECTF:
                    opcode = NewTarget::SELECT;
                    break;
                case NewTarget::CMPNEiREG:
                    opcode = NewTarget::CMPEQiREG;
                    break;
                default:
                    ITcmp->dump();
                    llvm_unreachable("");
            }


            if (isSelect) {
                MachineOperand M0 = ITcmp->getOperand(0);
                MachineOperand M1 = ITcmp->getOperand(1);
                MachineOperand M2 = ITcmp->getOperand(2);
                MachineOperand M3 = ITcmp->getOperand(3);

                BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), M0.getReg()).addOperand(M1).addOperand(M2).addOperand(M3);
                LoopHeader->remove_instr(MICMP);
            } else {
                MachineOperand M0 = ITcmp->getOperand(0);
                MachineOperand M1 = ITcmp->getOperand(1);
                MachineOperand M2 = ITcmp->getOperand(2);

                BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), M0.getReg()).addOperand(M1).addOperand(M2);
                LoopHeader->remove_instr(MICMP);
            }

        } else {
            LoopHeader->remove_instr(ITgoto1);
            ITcmp->getOperand(0).setReg(NewTarget::BRFLAG0);
        }

        //LoopHeader->dump();


        MachineFunction* MF = LoopHeader->getParent();
        MachineBasicBlock* Position = LoopLatch;
        MachineBasicBlock* FirstMBB = NULL;

        MachineBasicBlock * MBB;

        MachineBasicBlock::instr_iterator IT;

        bool firstCopy = true;

        for (int i = 0; i < uf; i++) {
            //std::cout << "iteração: " << i << "\n";
            MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());
            MF->insert(MF->end(), MBB);
            MBB->moveAfter(Position);


            if (FirstMBB == NULL) {
                FirstMBB = MBB;
                Position = MBB;
            } else {
                Position->addSuccessor(MBB);

                Position = MBB;
            }


            MachineBasicBlock::instr_iterator IT;
            // copy loop's body
            for (IT = LoopLatch->instr_begin(); IT != LoopLatch->instr_end(); IT++) {
                MachineInstr& Instr = *IT;
                if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                MachineBasicBlock::instr_iterator ITEnd = MBB->instr_end();

                //if(!(!firstCopy && IT->getOpcode() == NewTarget::MUL32)){
                NTII->buildInstrCopy(IT, MBB, ITEnd);
                //}
            }

            // new
            if (i != 1) {
                for (IT = LoopHeader->instr_begin(); IT != LoopHeader->instr_end(); IT++) {
                    MachineInstr& Instr = *IT;
                    if (Instr.isDebugValue()) continue;
                    else {
                        MBB->insert(MBB->instr_end(), MF->CloneMachineInstr(&Instr));
                        if (IT->isBundledWithPred()) {
                            MBB->back().bundleWithPred();
                        }
                        if (IT->isConditionalBranch()) {
                            MBB->addSuccessor(IT->getOperand(1).getMBB());
                        }
                    }
                }

                //BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::ADDi)).addReg(NewTarget::ZERO).
                //        addReg(NewTarget::ZERO).addImm(5);

            }
            firstCopy = false;
        }

        //TripCount->second = 2;
        int newCount = TripCount->second - 1;

        while ((newCount % uf) != 0) {
            newCount++;
        }

        TripCount->second = (newCount / uf) + 1;

        LoopHeader->replaceSuccessor(LoopLatch, FirstMBB);
        //FirstMBB->removeSuccessor(LoopLatch);

        LoopLatch->removeSuccessor(LoopHeader);

        LoopLatch->removeFromParent();

        MF->DeleteMachineBasicBlock(LoopLatch);

        MBB->addSuccessor(LoopHeader);

        if (!LoopHeader->isLayoutSuccessor(MBB)) {
            BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
        }

        //BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
        //MF->viewCFG();
    }
}

bool NewTargetPredicatedPathMerger::runOnMachineFunction(MachineFunction & MF) {


    if (EnableIfConv) {
        for (MachineFunction::iterator FI = MF.begin(), FE = MF.end();
                FI != FE; ++FI) {
            const MachineBasicBlock &MBB = *FI;
            MachineBasicBlock * Exit = NULL;

            if (checkDiamondStructure(MBB, Exit)) {
                unifyDiamond((MachineBasicBlock *) & MBB, Exit);
            } else if (checkTriangularStructure(MBB, Exit)) {
                unifyTriangular((MachineBasicBlock *) & MBB, Exit);
            }
            //ckeckNaturalLoop(MBB);
        }
    }

    if (EnableLU) {
        /*
        if (predicatedLoopUnrolling) {
            //tryToUnrollLoopsV3 only for bsorst100
            tryToUnrollLoopsV2(MF); 
           
        } else {
            //tryToUnrollLoopsV2(MF);
        }
         */


        loopAnalysis(MF);
        std::list<LoopStruct>::iterator IT;
        //MF.viewCFG();
        //std::cout << "Function " << MF.getName().data() << "\n";

        for (IT = actualLoops.begin(); IT != actualLoops.end(); IT++) {
            LoopStruct* loop = &(*IT);

            if (loop->skip) {
                continue;
            }

            switch (loop->type) {
                case SIMPLE_FIXED:
                    //std::cout << "****************\n";
                    fixedUnroll(MF, loop);
                    break;
                case SIMPLE:
                    //std::cout << "++++++++++++++++\n";
                    //branchUnroll(MF, loop);
                    predicatedUnroll(MF, loop);
                    break;
                case SIMPLE_WITH_CALL:
                    //std::cout << "================\n";
                    //MF.viewCFG();
                    branchUnroll(MF, loop);
                    break;
                case UNTOCHABLE:
                default:
                    break;
            }
        }
    }
    actualLoops.clear();
    return false;
}

FunctionPass * llvm::createNewTargetPredicatedPathMerger(const TargetInstrInfo * TII) {
    return new NewTargetPredicatedPathMerger(TII);

}

// traditional loop unrolling

void NewTargetPredicatedPathMerger::tryToUnrollLoopsV2(MachineFunction & MF) {
    MLI = &getAnalysis<MachineLoopInfo>();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;
    // get the register information

    std::list<MachineLoop*> loopList;

    for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
            I != E; ++I) {
        MachineLoop *L = *I;
        loopList.push_back(L);
    }

    bool changed = true;

    while (changed) {
        changed = false;

        std::list<MachineLoop*>::iterator IT1;
        MachineLoop *LI = NULL;
        for (IT1 = loopList.begin(); IT1 != loopList.end(); IT1++) {
            MachineLoop *L1 = *IT1;
            if (L1->getSubLoops().size() > 0) {
                LI = L1;
                break;
            }
        }
        if (LI) {
            changed = true;
            loopList.remove(LI);
            std::vector<MachineLoop*> subloops = LI->getSubLoops();
            for (int i = 0; i < subloops.size(); i++) {
                loopList.push_back(subloops[i]);
            }
        }
    }
    //std::cout << "Internal loops: " << loopList.size() << "\n";

    for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
            I != E; ++I) {
        MachineLoop *L = *I;

        // for (std::list<MachineLoop*>::iterator I = loopList.begin();
        //         I != loopList.end(); ++I) {
        //     MachineLoop *L = *I;

        int loopId = loopCounter++;

        int uf = getUnrollingFactor(loopId);

        //std::cout << "loop id: " << loopId << "\n";
        *LoopInfoOut << "" << loopId << " " << (uint64_t) L->getHeader() << "\n";
        LoopInfoOut->flush();

        //uf=2;
        if (uf == 0) {
            continue;
        }

        //L->dump();
        //L->getHeader()->dump();

        std::cout << "##analisando loop: " << L->getSubLoops().size() << "\n";

        // verify if we must skip this loop
        if (/*!L->getParentLoop() &&*/ (L->getLoopLatch() != NULL) && (L->getNumBlocks() == 2)) {
            MachineBasicBlock* LoopHeader = L->getHeader();
            MachineBasicBlock* LoopLatch = L->getLoopLatch();
            bool shouldAbord = false;
            MachineBasicBlock::instr_iterator ITLatch, ITHeader;

            for (ITLatch = LoopLatch->instr_begin(); ITLatch != LoopLatch->instr_end(); ITLatch++) {
                if (ITLatch->isCall()) {
                    shouldAbord = true;
                }
            }

            for (ITHeader = LoopHeader->instr_begin(); ITHeader != LoopHeader->instr_end(); ITHeader++) {
                if (ITHeader->isCall()) {
                    shouldAbord = true;
                }
            }

            if (shouldAbord) {
                continue;
            }


            MachineBasicBlock::instr_iterator ITc;

            std::list<MachineInstr*> compareInstrs;

            for (ITc = LoopHeader->instr_begin();
                    ITc != LoopHeader->instr_end(); ITc++) {
                if (!ITc->isCompare()) {
                    continue;
                }
                switch (ITc->getOpcode()) {
                    case NewTarget::CMPGTBR:
                        break;
                    case NewTarget::CMPGTiBR:
                        break;
                    case NewTarget::CMPLTBR:
                        break;
                    case NewTarget::CMPLTiBR:
                        break;
                    case NewTarget::CMPLTiuBR:
                        break;
                    case NewTarget::CMPGEBR:
                        break;
                    case NewTarget::CMPGEiBR:
                        break;
                    case NewTarget::CMPGEiuBR:
                        break;
                    case NewTarget::CMPGEuBR:
                        break;
                    case NewTarget::CMPLEBR:
                        break;
                    case NewTarget::CMPLEiBR:
                        break;
                    default:
                        compareInstrs.push_back(&(*ITc));
                        //ITc->dump();
                        shouldAbord = true;
                }
            }

            if (shouldAbord) {
                //std::cout << "abortando........: " << compareInstrs.size() << "\n";
                //ITc->dump();
                //LoopHeader->dump();
                continue;
            }
            //LoopHeader->dump();
            std::map<const BasicBlock*, bool>::iterator IsExact;
            std::map<const BasicBlock*, int>::iterator TripCount;


            IsExact = llvm::IsLoopBoundExact.find(LoopHeader->getBasicBlock());
            TripCount = llvm::LoopBounds.find(LoopHeader->getBasicBlock());

            if (IsExact != IsLoopBoundExact.end()) {
                if (IsExact->second) {
                    //std::cout << "Este loop é exato: " << TripCount->second << "\n";
                } else {
                    //std::cout << "Este loop NÃO é exato: " << TripCount->second << "\n";
                }
            }

            if (TripCount->second == 0xCACACACA) {
                continue;
            }

            if (TripCount->second < 10) {
                continue;
            }

            if (LoopLatch->isLayoutSuccessor(LoopHeader)) {
                LoopHeader->moveBefore(LoopLatch);
                MachineBasicBlock *MBBPrev = LoopHeader->getPrevNode();

                MachineBasicBlock::instr_iterator ITgoto;
                for (ITgoto = MBBPrev->instr_begin();
                        ITgoto != MBBPrev->instr_end(); ITgoto++) {
                    if (ITgoto->isUnconditionalBranch() && ITgoto->getOperand(0).getMBB() == LoopHeader) {
                        break;
                    }
                }


                if (ITgoto != MBBPrev->instr_end()) {
                    MBBPrev->remove_instr(ITgoto);
                }


                // change branch that enters the loop body to the exit
                MachineBasicBlock::instr_iterator ITbranch, ITcmp, ITgoto1;
                bool changeCompare = true;
                MachineBasicBlock * LoopExit = NULL;

                for (ITbranch = LoopHeader->instr_begin();
                        ITbranch != LoopHeader->instr_end(); ITbranch++) {
                    if (ITbranch->isConditionalBranch()) {
                        ITbranch->getOperand(0).setReg(NewTarget::BRFLAG4);
                        LoopExit = ITbranch->getOperand(1).getMBB();
                        if (ITbranch->getOperand(1).getMBB() == LoopLatch) {
                            ITbranch->getOperand(1).setMBB(LoopLatch->getNextNode());
                        } else {
                            changeCompare = false;
                        }

                    } else if (ITbranch->isCompare()) {
                        ITcmp = ITbranch;
                    } else if (ITbranch->isUnconditionalBranch()) {
                        ITgoto1 = ITbranch;
                    }
                }

                if (changeCompare) {
                    MachineInstr *MICMP = ITcmp;
                    unsigned opcode = 0;
                    switch (ITcmp->getOpcode()) {
                        case NewTarget::CMPGTBR:
                            opcode = NewTarget::CMPLEBR;
                            break;
                        case NewTarget::CMPGTiBR:
                            opcode = NewTarget::CMPLEiBR;
                            break;
                        case NewTarget::CMPLTBR:
                            opcode = NewTarget::CMPGEBR;
                            break;
                        case NewTarget::CMPLTiBR:
                            opcode = NewTarget::CMPGEiBR;
                            break;
                        case NewTarget::CMPLTiuBR:
                            opcode = NewTarget::CMPGEiuBR;
                            break;
                        case NewTarget::CMPGEBR:
                            opcode = NewTarget::CMPLTBR;
                            break;
                        case NewTarget::CMPGEiBR:
                            opcode = NewTarget::CMPLTiBR;
                            break;
                        case NewTarget::CMPGEiuBR:
                            opcode = NewTarget::CMPLTiuBR;
                            break;
                        case NewTarget::CMPGEuBR:
                            opcode = NewTarget::CMPLTuBR;
                            break;
                        case NewTarget::CMPLEBR:
                            opcode = NewTarget::CMPGTBR;
                            break;
                        case NewTarget::CMPLEiBR:
                            opcode = NewTarget::CMPGTiBR;
                            break;
                        default:
                            llvm_unreachable("");
                    }

                    MachineOperand M1 = ITcmp->getOperand(1);
                    MachineOperand M2 = ITcmp->getOperand(2);

                    BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), NewTarget::BRFLAG4).addOperand(M1).addOperand(M2);
                    LoopHeader->remove_instr(MICMP);

                } else {
                    LoopHeader->remove_instr(ITgoto1);
                    ITcmp->getOperand(0).setReg(NewTarget::BRFLAG4);
                }

                //LoopHeader->dump();


                MachineFunction* MF = LoopHeader->getParent();
                MachineBasicBlock* Position = LoopLatch;
                MachineBasicBlock* FirstMBB = NULL;
                ;

                MachineBasicBlock * MBB;

                MachineBasicBlock::instr_iterator IT;

                for (int i = 0; i < uf; i++) {
                    //std::cout << "iteração: " << i << "\n";
                    MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());
                    MF->insert(MF->end(), MBB);
                    MBB->moveAfter(Position);


                    if (FirstMBB == NULL) {
                        FirstMBB = MBB;
                    }

                    Position->addSuccessor(MBB);

                    Position = MBB;

                    MachineBasicBlock::instr_iterator IT;
                    // copy loop's body
                    for (IT = LoopLatch->instr_begin(); IT != LoopLatch->instr_end(); IT++) {
                        MachineInstr& Instr = *IT;
                        if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                        MachineBasicBlock::instr_iterator ITEnd = MBB->instr_end();
                        NTII->buildPredicatedInstrCopy(IT, MBB, ITEnd);
                    }

                    // new
                    if (i != 1) {
                        for (IT = LoopHeader->instr_begin(); IT != LoopHeader->instr_end(); IT++) {
                            MachineInstr& Instr = *IT;
                            if (Instr.isDebugValue()) continue;
                            else {
                                MBB->insert(MBB->instr_end(), MF->CloneMachineInstr(&Instr));
                                if (IT->isBundledWithPred()) {
                                    MBB->back().bundleWithPred();
                                }
                                if (IT->isConditionalBranch()) {
                                    MBB->addSuccessor(IT->getOperand(1).getMBB());
                                }
                            }
                        }

                        //BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::ADDi)).addReg(NewTarget::ZERO).
                        //        addReg(NewTarget::ZERO).addImm(5);

                    }
                }

                //TripCount->second = 2;
                int newCount = TripCount->second - 1;

                while ((newCount % uf) != 0) {
                    newCount++;
                }

                TripCount->second = (newCount / uf) + 1;

                LoopHeader->replaceSuccessor(LoopLatch, FirstMBB);
                LoopLatch->removeFromParent();
                MF->DeleteMachineBasicBlock(LoopLatch);

                MBB->addSuccessor(LoopHeader);
                BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
                //MF->viewCFG();
            } else {
            }
        } else {
            //std::cout << "seria este o caso2?\n";
            // L->dump();
            //L->getHeader()->dump();
        }
    }
}

// predicated loop unrolling that puts each body copy into a separated basic block
//(actually should not be used)

void NewTargetPredicatedPathMerger::tryToUnrollLoopsV3(MachineFunction & MF) {
    MLI = &getAnalysis<MachineLoopInfo>();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;
    // get the register information
    std::list<MachineLoop*> loopList;

    for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
            I != E; ++I) {
        MachineLoop *L = *I;
        loopList.push_back(L);
    }

    bool changed = true;

    while (changed) {
        changed = false;

        std::list<MachineLoop*>::iterator IT1;
        MachineLoop *LI = NULL;
        for (IT1 = loopList.begin(); IT1 != loopList.end(); IT1++) {
            MachineLoop *L1 = *IT1;
            if (L1->getSubLoops().size() > 0) {
                LI = L1;
                break;
            }
        }
        if (LI) {
            changed = true;
            loopList.remove(LI);
            std::vector<MachineLoop*> subloops = LI->getSubLoops();
            for (int i = 0; i < subloops.size(); i++) {
                loopList.push_back(subloops[i]);
            }
        }
    }
    //std::cout << "Internal loops: " << loopList.size() << "\n";

    for (MachineLoopInfo::iterator I = MLI->begin(), E = MLI->end();
            I != E; ++I) {
        MachineLoop *L = *I;

        // for (std::list<MachineLoop*>::iterator I = loopList.begin();
        //         I != loopList.end(); ++I) {
        //     MachineLoop *L = *I;

        int loopId = loopCounter++;

        int uf = getUnrollingFactor(loopId);

        //std::cout << "loop id: " << loopId << "\n";
        *LoopInfoOut << "" << loopId << " " << (uint64_t) L->getHeader() << "\n";
        LoopInfoOut->flush();

        //uf=2;
        if (uf == 0) {
            continue;
        }

        //L->dump();
        //L->getHeader()->dump();

        std::cout << "##analisando loop: " << L->getSubLoops().size() << "\n";

        // verify if we must skip this loop
        if (/*!L->getParentLoop() &&*/ (L->getLoopLatch() != NULL) && (L->getNumBlocks() == 2)) {
            MachineBasicBlock* LoopHeader = L->getHeader();
            MachineBasicBlock* LoopLatch = L->getLoopLatch();
            bool shouldAbord = false;
            MachineBasicBlock::instr_iterator ITLatch, ITHeader;

            for (ITLatch = LoopLatch->instr_begin(); ITLatch != LoopLatch->instr_end(); ITLatch++) {
                if (ITLatch->isCall()) {
                    shouldAbord = true;
                }
            }

            for (ITHeader = LoopHeader->instr_begin(); ITHeader != LoopHeader->instr_end(); ITHeader++) {
                if (ITHeader->isCall()) {
                    shouldAbord = true;
                }
            }

            if (shouldAbord) {
                continue;
            }


            MachineBasicBlock::instr_iterator ITc;

            std::list<MachineInstr*> compareInstrs;

            for (ITc = LoopHeader->instr_begin();
                    ITc != LoopHeader->instr_end(); ITc++) {
                if (!ITc->isCompare()) {
                    continue;
                }
                switch (ITc->getOpcode()) {
                    case NewTarget::CMPGTBR:
                        break;
                    case NewTarget::CMPGTiBR:
                        break;
                    case NewTarget::CMPLTBR:
                        break;
                    case NewTarget::CMPLTiBR:
                        break;
                    case NewTarget::CMPLTiuBR:
                        break;
                    case NewTarget::CMPGEBR:
                        break;
                    case NewTarget::CMPGEiBR:
                        break;
                    case NewTarget::CMPGEiuBR:
                        break;
                    case NewTarget::CMPGEuBR:
                        break;
                    case NewTarget::CMPLEBR:
                        break;
                    case NewTarget::CMPLEiBR:
                        break;
                    default:
                        compareInstrs.push_back(&(*ITc));
                        //ITc->dump();
                        shouldAbord = true;
                }
            }

            if (shouldAbord) {
                //std::cout << "abortando........: " << compareInstrs.size() << "\n";
                //ITc->dump();
                //LoopHeader->dump();
                continue;
            }
            //LoopHeader->dump();
            std::map<const BasicBlock*, bool>::iterator IsExact;
            std::map<const BasicBlock*, int>::iterator TripCount;


            IsExact = llvm::IsLoopBoundExact.find(LoopHeader->getBasicBlock());
            TripCount = llvm::LoopBounds.find(LoopHeader->getBasicBlock());

            if (IsExact != IsLoopBoundExact.end()) {
                if (IsExact->second) {
                    //std::cout << "Este loop é exato: " << TripCount->second << "\n";
                } else {
                    //std::cout << "Este loop NÃO é exato: " << TripCount->second << "\n";
                }
            }

            if (TripCount->second == 0xCACACACA) {
                continue;
            }

            if (TripCount->second < 10) {
                continue;
            }

            if (LoopLatch->isLayoutSuccessor(LoopHeader)) {
                LoopHeader->moveBefore(LoopLatch);
                MachineBasicBlock *MBBPrev = LoopHeader->getPrevNode();

                MachineBasicBlock::instr_iterator ITgoto;
                for (ITgoto = MBBPrev->instr_begin();
                        ITgoto != MBBPrev->instr_end(); ITgoto++) {
                    if (ITgoto->isUnconditionalBranch() && ITgoto->getOperand(0).getMBB() == LoopHeader) {
                        break;
                    }
                }


                if (ITgoto != MBBPrev->instr_end()) {
                    MBBPrev->remove_instr(ITgoto);
                }


                // change branch that enters the loop body to the exit
                MachineBasicBlock::instr_iterator ITbranch, ITcmp, ITgoto1;
                bool changeCompare = true;

                for (ITbranch = LoopHeader->instr_begin();
                        ITbranch != LoopHeader->instr_end(); ITbranch++) {
                    if (ITbranch->isConditionalBranch()) {
                        ITbranch->getOperand(0).setReg(NewTarget::BRFLAG4);

                        if (ITbranch->getOperand(1).getMBB() == LoopLatch) {
                            ITbranch->getOperand(1).setMBB(LoopLatch->getNextNode());
                        } else {
                            changeCompare = false;
                        }

                    } else if (ITbranch->isCompare()) {
                        ITcmp = ITbranch;
                    } else if (ITbranch->isUnconditionalBranch()) {
                        ITgoto1 = ITbranch;
                    }
                }

                if (changeCompare) {
                    MachineInstr *MICMP = ITcmp;
                    unsigned opcode = 0;
                    switch (ITcmp->getOpcode()) {
                        case NewTarget::CMPGTBR:
                            opcode = NewTarget::CMPLEBR;
                            break;
                        case NewTarget::CMPGTiBR:
                            opcode = NewTarget::CMPLEiBR;
                            break;
                        case NewTarget::CMPLTBR:
                            opcode = NewTarget::CMPGEBR;
                            break;
                        case NewTarget::CMPLTiBR:
                            opcode = NewTarget::CMPGEiBR;
                            break;
                        case NewTarget::CMPLTiuBR:
                            opcode = NewTarget::CMPGEiuBR;
                            break;
                        case NewTarget::CMPGEBR:
                            opcode = NewTarget::CMPLTBR;
                            break;
                        case NewTarget::CMPGEiBR:
                            opcode = NewTarget::CMPLTiBR;
                            break;
                        case NewTarget::CMPGEiuBR:
                            opcode = NewTarget::CMPLTiuBR;
                            break;
                        case NewTarget::CMPGEuBR:
                            opcode = NewTarget::CMPLTuBR;
                            break;
                        case NewTarget::CMPLEBR:
                            opcode = NewTarget::CMPGTBR;
                            break;
                        case NewTarget::CMPLEiBR:
                            opcode = NewTarget::CMPGTiBR;
                            break;
                        default:
                            llvm_unreachable("");
                    }

                    MachineOperand M1 = ITcmp->getOperand(1);
                    MachineOperand M2 = ITcmp->getOperand(2);


                    BuildMI(*LoopHeader, ITcmp, DebugLoc(), TII->get(opcode), NewTarget::BRFLAG4).addOperand(M1).addOperand(M2);
                    LoopHeader->remove_instr(MICMP);

                } else {
                    LoopHeader->remove_instr(ITgoto1);
                    ITcmp->getOperand(0).setReg(NewTarget::BRFLAG4);
                }

                //LoopHeader->dump();


                MachineFunction* MF = LoopHeader->getParent();
                MachineBasicBlock* Position = LoopLatch;
                MachineBasicBlock* FirstMBB = NULL;

                MachineBasicBlock * MBB;

                MachineBasicBlock::instr_iterator IT;

                for (int i = 0; i < uf; i++) {
                    MBB = MF->CreateMachineBasicBlock(LoopLatch->getBasicBlock());
                    MF->insert(MF->end(), MBB);
                    MBB->moveAfter(Position);


                    if (FirstMBB == NULL) {
                        FirstMBB = MBB;
                    }

                    Position->addSuccessor(MBB);

                    Position = MBB;
                    MachineBasicBlock::instr_iterator IT;
                    // copy loop's body
                    for (IT = LoopLatch->instr_begin(); IT != LoopLatch->instr_end(); IT++) {
                        MachineInstr& Instr = *IT;
                        if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                        MachineBasicBlock::instr_iterator ITEnd = MBB->instr_end();
                        NTII->buildPredicatedInstrCopy(IT, MBB, ITEnd);
                    }

                    Position = MBB;
                    // new
                    if (i != 1) {
                        for (IT = LoopHeader->instr_begin(); IT != LoopHeader->instr_end(); IT++) {
                            MachineInstr& Instr = *IT;
                            if (Instr.isConditionalBranch() || Instr.isDebugValue()) continue;
                            else {
                                MBB->insert(MBB->instr_end(), MF->CloneMachineInstr(&Instr));
                                if (IT->isBundledWithPred()) {
                                    MBB->back().bundleWithPred();
                                }
                            }
                        }

                        BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::ADDi)).addReg(NewTarget::ZERO).
                                addReg(NewTarget::ZERO).addImm(5);
                    }
                }

                //TripCount->second = 2;
                int newCount = TripCount->second - 1;

                while ((newCount % uf) != 0) {
                    newCount++;
                }

                TripCount->second = (newCount / uf) + 1;


                LoopHeader->replaceSuccessor(LoopLatch, FirstMBB);
                LoopLatch->removeFromParent();
                MF->DeleteMachineBasicBlock(LoopLatch);

                MBB->addSuccessor(LoopHeader);
                BuildMI(*MBB, MBB->instr_end(), DebugLoc(), TII->get(NewTarget::GOTO)).addMBB(LoopHeader);
                //MF->viewCFG();
            } else {
            }
        } else {
            //std::cout << "seria este o caso2?\n";
            // L->dump();
            //L->getHeader()->dump();
        }
    }
}