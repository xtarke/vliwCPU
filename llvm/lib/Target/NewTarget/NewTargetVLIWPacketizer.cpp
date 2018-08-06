//===----- NewTargetVLIWPacketizer.cpp - vliw packetizer ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This implements a simple VLIW packetizer using DFA. The packetizer works on
// machine basic blocks. For each instruction I in BB, the packetizer consults
// the DFA to see if machine resources are available to execute I. If so, the
// packetizer checks if I depends on any instruction J in the current packet.
// If no dependency is found, I is added to current packet and machine resource
// is marked as taken. If any dependency is found, a target API call is made to
// prune the dependence.
//
//===----------------------------------------------------------------------===//
#define DEBUG_TYPE "packets"
#include "NewTarget.h"
#include "NewTargetMachineFunction.h"
#include "NewTargetRegisterInfo.h"
#include "NewTargetSubtarget.h"
#include "NewTargetMachine.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/DFAPacketizer.h"
#include "llvm/CodeGen/LatencyPriorityQueue.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionAnalysis.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/CodeGen/ScheduleDAGInstrs.h"
#include "llvm/CodeGen/ScheduleHazardRecognizer.h"
#include "llvm/CodeGen/SchedulerRegistry.h"
#include "llvm/MC/MCInstrItineraries.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include <map>
#include <iostream>

using namespace llvm;

static cl::
opt<bool> DisableDualMem("disable-newtarget-dualmem",
        cl::Hidden, cl::ZeroOrMore, cl::init(false),
        cl::desc("Disable New Target dual memory ops per bundle"));

static bool IsControlFlow(MachineInstr* MI) {
    return (MI->getDesc().isTerminator() || MI->getDesc().isCall());
}

static bool IsRegDependence(const SDep::Kind DepType) {
    return (DepType == SDep::Data || DepType == SDep::Anti ||
            DepType == SDep::Output);
}

static bool IsIndirectCall(MachineInstr* MI) {
    return ((MI->getOpcode() == NewTarget::GOTOR));
}

static bool DefinesUnsavableReg(const NewTargetRegisterInfo* QRI, MachineInstr *J) {

    //return false;

    const uint16_t* saved = QRI->getCalleeSavedRegs(NULL);
    bool definesUnsavable = true;

    for (int i = 0; i < saved[i] != 0; i++) {
        MCPhysReg reg = saved[i];

        if (J->definesRegister(reg, QRI)) {
            definesUnsavable = false;
            break;
        }
    }

    return definesUnsavable;
}

namespace {

    class NewTargetPacketizer : public MachineFunctionPass {
    public:
        static char ID;

        NewTargetPacketizer() : MachineFunctionPass(ID) {
        }

        void getAnalysisUsage(AnalysisUsage &AU) const {
            AU.setPreservesCFG();
            AU.addRequired<MachineDominatorTree>();
            AU.addPreserved<MachineDominatorTree>();
            AU.addRequired<MachineLoopInfo>();
            AU.addPreserved<MachineLoopInfo>();
            MachineFunctionPass::getAnalysisUsage(AU);
        }

        const char *getPassName() const {
            return "NewTarget Packetizer";
        }

        bool runOnMachineFunction(MachineFunction &Fn);
    };
    char NewTargetPacketizer::ID = 0;

    class NewTargetPacketizerList : public VLIWPacketizerList {
    private:

        // Check if there is a dependence between some instruction already in this
        // packet and this instruction.
        bool Dependence;
        // Only check for dependence if there are resources available to
        // schedule this instruction.
        bool FoundSequentialDependence;

        SDep::Kind DependencyType;
    public:
        // Ctor.
        NewTargetPacketizerList(MachineFunction &MF, MachineLoopInfo &MLI,
                MachineDominatorTree &MDT);

        // initPacketizerState - initialize some internal flags.

        void initPacketizerState();

        // ignorePseudoInstruction - Ignore bundling of pseudo instructions.
        bool ignorePseudoInstruction(MachineInstr *MI, MachineBasicBlock *MBB);

        MachineBasicBlock::iterator addToPacket(MachineInstr *MI);

        // isSoloInstruction - return true if instruction MI can not be packetized
        // with any other instruction, which means that MI itself is a packet.
        bool isSoloInstruction(MachineInstr *MI);


        // isLegalToPacketizeTogether - Is it legal to packetize SUI and SUJ
        // together.
        bool isLegalToPacketizeTogether(SUnit *SUI, SUnit *SUJ);

        // isLegalToPruneDependencies - Is it legal to prune dependece between SUI
        // and SUJ.
        bool isLegalToPruneDependencies(SUnit *SUI, SUnit *SUJ);

    private:
        bool IsCallDependent(MachineInstr* MI, SDep::Kind DepType, unsigned DepReg);
        bool tryAllocateResourcesForExt(MachineInstr* MI);
        void reserveResourcesForExt(MachineInstr* MI);
    };
}


// NewTargetPacketizerList Ctor.

NewTargetPacketizerList::NewTargetPacketizerList(
        MachineFunction &MF, MachineLoopInfo &MLI, MachineDominatorTree &MDT)
: VLIWPacketizerList(MF, MLI, MDT, true) {
}

bool NewTargetPacketizer::runOnMachineFunction(MachineFunction &Fn) {
    const TargetInstrInfo *TII = Fn.getTarget().getInstrInfo();
    MachineLoopInfo &MLI = getAnalysis<MachineLoopInfo>();
    MachineDominatorTree &MDT = getAnalysis<MachineDominatorTree>();

    // Instantiate the packetizer.
    NewTargetPacketizerList Packetizer(Fn, MLI, MDT);

    // DFA state table should not be empty.
    assert(Packetizer.getResourceTracker() && "Empty DFA table!");


    //std::cout << "NewTargetPacketizer::runOnMachineFunction\n";
    //
    // Loop over all basic blocks and remove KILL pseudo-instructions
    // These instructions confuse the dependence analysis. Consider:
    // D0 = ...   (Insn 0)
    // R0 = KILL R0, D0 (Insn 1)
    // R0 = ... (Insn 2)
    // Here, Insn 1 will result in the dependence graph not emitting an output
    // dependence between Insn 0 and Insn 2. This can lead to incorrect
    // packetization
    //
    for (MachineFunction::iterator MBB = Fn.begin(), MBBe = Fn.end();
            MBB != MBBe; ++MBB) {
        MachineBasicBlock::iterator End = MBB->end();
        MachineBasicBlock::iterator MI = MBB->begin();
        /*
        while (MI != End) {
            MI->dump();
            //std::cout << "::" << MI->getNumOperands() << "\n";
            if (MI->isKill()) {
                MachineBasicBlock::iterator DeleteMI = MI;
                ++MI;
                MBB->erase(DeleteMI);
                End = MBB->end();
                continue;
            }
            ++MI;
        }*/
    }

    // Loop over all of the basic blocks.
    for (MachineFunction::iterator MBB = Fn.begin(), MBBe = Fn.end();
            MBB != MBBe; ++MBB) {
        // Find scheduling regions and schedule / packetize each region.
        unsigned RemainingCount = MBB->size();
        for (MachineBasicBlock::iterator RegionEnd = MBB->end();
                RegionEnd != MBB->begin();) {
            // The next region starts above the previous region. Look backward in the
            // instruction stream until we find the nearest boundary.
            MachineBasicBlock::iterator I = RegionEnd;
            for (; I != MBB->begin(); --I, --RemainingCount) {
                if (TII->isSchedulingBoundary(llvm::prior(I), MBB, Fn))
                    break;
            }
            I = MBB->begin();

            // Skip empty scheduling regions.
            if (I == RegionEnd) {
                RegionEnd = llvm::prior(RegionEnd);
                --RemainingCount;
                continue;
            }
            // Skip regions with one instruction.
            if (I == llvm::prior(RegionEnd)) {
                RegionEnd = llvm::prior(RegionEnd);
                continue;
            }
            //std::cout << "Packetizer.PacketizeMIs(MBB, I, RegionEnd)\n";
            Packetizer.PacketizeMIs(MBB, I, RegionEnd);
            RegionEnd = I;
        }
    }
    return true;
}



// initPacketizerState - Initialize packetizer flags

void NewTargetPacketizerList::initPacketizerState() {

    //std::cout << "initPacketizerState\n";
    Dependence = false;
    FoundSequentialDependence = false;
    DependencyType = SDep::Order;
    return;
}

// ignorePseudoInstruction - Ignore bundling of pseudo instructions.

bool NewTargetPacketizerList::ignorePseudoInstruction(MachineInstr *MI,
        MachineBasicBlock *MBB) {
    if (MI->isDebugValue()) {
        return true;
    }

    // We must print out inline assembly
    if (MI->isInlineAsm())
        return false;

    if (MI->isLabel()) {
        return true;
    }

    // We check if MI has any functional units mapped to it.
    // If it doesn't, we ignore the instruction.
    const MCInstrDesc& TID = MI->getDesc();
    unsigned SchedClass = TID.getSchedClass();
    const InstrStage* IS =
            ResourceTracker->getInstrItins()->beginStage(SchedClass);
    unsigned FuncUnits = IS->getUnits();
    return !FuncUnits;
}

MachineBasicBlock::iterator
NewTargetPacketizerList::addToPacket(MachineInstr *MI) {


    MachineBasicBlock::iterator MII = MI;
    MachineBasicBlock *MBB = MI->getParent();

    const NewTargetInstrInfo *QII = (const NewTargetInstrInfo *) TII;

    assert(ResourceTracker->canReserveResources(MI));
    ResourceTracker->reserveResources(MI);


    if (QII->isExtended(MI)) {
        MachineInstr *MIImm = MI->getNextNode();
        if (!tryAllocateResourcesForExt(MIImm)) {
            endPacket(MBB, MI);
            //reserve resources twice
            ResourceTracker->reserveResources(MI);
            reserveResourcesForExt(MI);

        }
        CurrentPacketMIs.push_back(MI);
    } else {
        CurrentPacketMIs.push_back(MI);
    }

    return MII;
}


// isSoloInstruction: - Returns true for instructions that must be
// scheduled in their own packet.

bool NewTargetPacketizerList::isSoloInstruction(MachineInstr *MI) {

    //std::cout << "solo\n";  

    if (MI->isInlineAsm())
        return true;

    if (MI->isEHLabel())
        return true;

    if (MI->isPrologLabel()) {
        return true;
    }

    if (MI->getOpcode() == NewTarget::ADDi &&
            MI->getOperand(0).getReg() == NewTarget::ZERO &&
            MI->getOperand(1).getReg() == NewTarget::ZERO &&
            MI->getOperand(2).getImm() == 5) {
        MI->getOperand(2).ChangeToImmediate(0);
        return true;
    }

    if (MI->isCompare() && (MI->getOperand(0).getReg() == NewTarget::BRFLAG4)) {
        return true;
    }

    return false;
}

bool NewTargetPacketizerList::IsCallDependent(MachineInstr* MI,
        SDep::Kind DepType,
        unsigned DepReg) {

    //const NewTargetInstrInfo *QII = (const NewTargetInstrInfo *) TII;
    const NewTargetRegisterInfo* QRI =
            (const NewTargetRegisterInfo *) TM.getRegisterInfo();

    // Check for lr dependence
    if (DepReg == QRI->getRARegister()) {
        return true;
    }

    // if (QII->isDeallocRet(MI)) {
    //   if (DepReg == QRI->getFrameRegister() ||
    //       DepReg == QRI->getStackRegister())
    //     return true;
    // }

    // Check if this is a predicate dependence
    // const TargetRegisterClass* RC = QRI->getMinimalPhysRegClass(DepReg);
    // if (RC == &Hexagon::PredRegsRegClass) {
    //   return true;
    // }

    //
    // Lastly check for an operand used in an indirect call
    // If we had an attribute for checking if an instruction is an indirect call,
    // then we could have avoided this relatively brittle implementation of
    // IsIndirectCall()
    //
    // Assumes that the first operand of the CALLr is the function address
    //
    if (IsIndirectCall(MI) && (DepType == SDep::Data)) {
        MachineOperand MO = MI->getOperand(0);
        if (MO.isReg() && MO.isUse() && (MO.getReg() == DepReg)) {
            return true;
        }
    }

    return false;
}


// isLegalToPacketizeTogether:
// SUI is the current instruction that is out side of the current packet.
// SUJ is the current instruction inside the current packet against which that
// SUI will be packetized.

bool NewTargetPacketizerList::isLegalToPacketizeTogether(SUnit *SUI, SUnit *SUJ) {
    MachineInstr *I = SUI->getInstr();
    MachineInstr *J = SUJ->getInstr();
    NewTargetInstrInfo* NTII = (NewTargetInstrInfo*) TII;

    //std::cout << "========\n";

    assert(I && J && "Unable to packetize null instruction!");

    const MCInstrDesc &MCIDI = I->getDesc();
    const MCInstrDesc &MCIDJ = J->getDesc();

    //if(I->getOpcode() == NewTarget::LW && J->getOpcode() == NewTarget::LW){
    //    std::cout << "========\n";
    //    I->dump();
    //    J->dump();
    //}

    //MachineBasicBlock::iterator II = I;

    if (I->getOpcode() == TargetOpcode::INLINEASM) {
        return false;
    }

    if (J->getOpcode() == TargetOpcode::INLINEASM) {
        return false;
    }

    const NewTargetRegisterInfo* QRI =
            (const NewTargetRegisterInfo *) TM.getRegisterInfo();
    //const NewTargetInstrInfo *QII = (const NewTargetInstrInfo *) TII;

    // Two control flow instructions cannot go in the same packet.
    if (IsControlFlow(I) && IsControlFlow(J)) {
        Dependence = true;
        return false;
    }
    if (IsControlFlow(J)) {

        if (DefinesUnsavableReg(QRI, I)) {
            //std::cout << "ponto 0\n";
            Dependence = true;
            return false;
        }
    }

    // disable dual memory operatins issue if requested by command line
    if (DisableDualMem) {
        //std::cout << "ponto 1\n";
        /*
        // two stores are illegal
        if (MCIDI.mayStore() && MCIDJ.mayStore()) {
            Dependence = true;
            return false;
        }

        // two loads are illegal
        if (MCIDI.mayLoad() && MCIDJ.mayLoad()) {
            Dependence = true;
            //std::cout << "C\n";
            return false;
        }

        // load and store are illegal
        if (MCIDI.mayLoad() && MCIDJ.mayStore()) {
            Dependence = true;
            return false;
        }

        // store and load are illegal
        if (MCIDI.mayStore() && MCIDJ.mayLoad()) {
            Dependence = true;
            return false;
        }
         */
        if (NTII->isMemoryInstr(I) && NTII->isMemoryInstr(J)) {
            Dependence = true;
            return false;
        }
    }

    //std::cout << "ponto 2\n";


    if (SUJ->isSucc(SUI)) {
        //std::cout << "ponto 3\n";
        for (unsigned i = 0; (i < SUJ->Succs.size()) && !FoundSequentialDependence; ++i) {

            if (SUJ->Succs[i].getSUnit() != SUI) {
                continue;
            }

            SDep::Kind DepType = SUJ->Succs[i].getKind();

            unsigned DepReg = 0;
            const TargetRegisterClass* RC = NULL;
            if (DepType == SDep::Data) {
                DepReg = SUJ->Succs[i].getReg();
                RC = QRI->getMinimalPhysRegClass(DepReg);
            }
            // call and ret instructions have data dependency,
            // but we can ignore them

            if ((MCIDI.isCall() || MCIDI.isReturn()) &&
                    (!IsRegDependence(DepType) ||
                    !IsCallDependent(I, DepType, SUJ->Succs[i].getReg()))) {
                /* do nothing */
            } else if (MCIDI.isUnconditionalBranch()) {
                /* do nothing */
            } else if (DepType == SDep::Output) {
                // DepReg is the register that's responsible for the dependence.
                DependencyType = SDep::Output;
                unsigned DepReg = SUJ->Succs[i].getReg();

                // Check if I and J really defines DepReg.
                if (I->definesRegister(DepReg) ||
                        J->definesRegister(DepReg)) {
                    FoundSequentialDependence = true;
                    //std::cout << "---------output--------\n";
                    break;

                }
            } else if (DepType == SDep::Data) {
                //std::cout << "DepType == SDep::Data\n";

                // DepReg is the register that's responsible for the dependence.
                DependencyType = SDep::Data;
                unsigned DepReg = SUJ->Succs[i].getReg();
                if (I->readsRegister(DepReg) &&
                        J->definesRegister(DepReg)) {
                    FoundSequentialDependence = true;
                    //std::cout << "---------data--------\n";
                    break;
                }
            } else if (DepType == SDep::Order) {
                //std::cout << "---------order--------\n";

                //SUI->

                DependencyType = SDep::Order;
                FoundSequentialDependence = true;
                break;
            } else if (DepType == SDep::Anti) {
                unsigned DepReg = SUJ->Succs[i].getReg();
                if (I->definesRegister(DepReg) && J->readsRegister(DepReg)) {
                    DependencyType = SDep::Anti;
                    FoundSequentialDependence = true;
                    break;
                }
            }
        }

        if (FoundSequentialDependence) {
            Dependence = true;
            return false;
        }

    }
    return true;
}


// isLegalToPruneDependencies

bool NewTargetPacketizerList::isLegalToPruneDependencies(SUnit *SUI, SUnit *SUJ) {

    MachineInstr *I = SUI->getInstr();
    MachineInstr *J = SUJ->getInstr();

    const NewTargetInstrInfo *QII = (const NewTargetInstrInfo *) TII;

    assert(I && SUJ->getInstr() && "Unable to packetize null instruction!");

    //std::cout << "==========================\n";
    //I->dump();
    //J->dump();

    if (Dependence) {

        //if()
        //if (QII->isMemoryInstr(I) && QII->isMemoryInstr(J)) {
        //    return false;
        //}

        if (QII->isPredicatedOpcode(I) && !QII->isPredicatedOpcode(J)) {
            return true;
        }
        if (QII->isPredicatedOpcode(J) && !QII->isPredicatedOpcode(I)) {
            return true;
        }

        // sometimes a orl followed by a adcg appear as an antidependence
        // however we cannot packetize both toghether
        if (DependencyType == SDep::Anti && !J->isCall()) {
            if (I->getOpcode() == NewTarget::ADDCG) {
                if (J->getOpcode() == NewTarget::ORLBR) {
                    return false;
                }
            }
        }

        // extended instructions are used do load 32 bit constants to registers.
        // sometimes, the scheduler insistes that exists Order dependencies between
        // them.
        if (DependencyType == SDep::Anti && !J->isCall()) {
            // if we do not reset this variable, all next sequential dependences will
            // be considered anti dependences.
            FoundSequentialDependence = false;
            return true;
            //return false;
        }


        if (DependencyType == SDep::Order && J->isCall()) {
            return false;
        }

        if ((DependencyType == SDep::Order) && (QII->isExtended(I) || QII->isExtended(J))) {
            return true;
        }

        // em teste
        if (DependencyType == SDep::Order && QII->isPredicatedOpcode(I) && QII->isPredicatedOpcode(J)) {
            return true;
        }

        return false;
    }
    return true;
}

// Allocate resources (i.e. 4 bytes) for constant extender. If succeed, return
// true, otherwise, return false.

bool NewTargetPacketizerList::tryAllocateResourcesForExt(MachineInstr* MI) {
    const NewTargetInstrInfo *QII = (const NewTargetInstrInfo *) TII;
    MachineFunction *MF = MI->getParent()->getParent();
    MachineInstr *PseudoMI = MF->CreateMachineInstr(QII->get(NewTarget::IMML),
            MI->getDebugLoc());

    if (ResourceTracker->canReserveResources(PseudoMI)) {
        ResourceTracker->reserveResources(PseudoMI);
        MI->getParent()->getParent()->DeleteMachineInstr(PseudoMI);
        return true;
    } else {
        MI->getParent()->getParent()->DeleteMachineInstr(PseudoMI);
        return false;
    }
}

// Reserve resources for constant extender. Trigure an assertion if
// reservation fail.

void NewTargetPacketizerList::reserveResourcesForExt(MachineInstr* MI) {
    const NewTargetInstrInfo *QII = (const NewTargetInstrInfo *) TII;
    MachineFunction *MF = MI->getParent()->getParent();
    MachineInstr *PseudoMI = MF->CreateMachineInstr(QII->get(NewTarget::IMML),
            MI->getDebugLoc());

    if (ResourceTracker->canReserveResources(PseudoMI)) {
        ResourceTracker->reserveResources(PseudoMI);
        MI->getParent()->getParent()->DeleteMachineInstr(PseudoMI);
    } else {
        MI->getParent()->getParent()->DeleteMachineInstr(PseudoMI);
        llvm_unreachable("can not reserve resources for constant extender.");
    }
    return;
}

//===----------------------------------------------------------------------===//
//                         Public Constructor Functions
//===----------------------------------------------------------------------===//

FunctionPass *llvm::createNewTargetPacketizer() {
    return new NewTargetPacketizer();
}
