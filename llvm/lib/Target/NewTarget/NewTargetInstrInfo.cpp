/*
 * NewTargetInstrInfo.cpp
 *
 *  Created on: Mar 8, 2013
 *      Author: andreu
 */

#include "NewTargetInstrInfo.h"
#include "NewTarget.h"
#include "NewTargetMachine.h"
#include "NewTargetScoreboardHazardRecognizer.h"
#include "NewTargetAnalyzeImmediate.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/CommandLine.h"
#include <iostream>

#define GET_INSTRINFO_CTOR
#include "NewTargetGenInstrInfo.inc"
#include "NewTargetGenDFAPacketizer.inc"

using namespace llvm;

static cl::
opt<bool> EnableStaticBranchPredicion("enable-newtarget-staticbp",
        cl::Hidden, cl::ZeroOrMore, cl::init(false),
        cl::desc("Enable New Target static branch prediction"));

struct BooleanAlternator NewTargetInstrInfo::MarRegAlternator;

NewTargetInstrInfo::NewTargetInstrInfo(NewTargetMachine &tm)
: NewTargetGenInstrInfo(NewTarget::ADJCALLSTACKDOWN, NewTarget::ADJCALLSTACKUP), RI(tm, *this) {
    //MarRegAlternator.val = false;
}

const NewTargetInstrInfo *NewTargetInstrInfo::create(NewTargetMachine &TM) {

    return new NewTargetInstrInfo(TM);
}

/// CreateTargetHazardRecognizer - Return the hazard recognizer to use for
/// this target when scheduling the DAG.

ScheduleHazardRecognizer *NewTargetInstrInfo::CreateTargetHazardRecognizer(
        const TargetMachine *TM,
        const ScheduleDAG *DAG) const {

    return TargetInstrInfo::CreateTargetHazardRecognizer(TM, DAG);
    // const InstrItineraryData *II = TM->getInstrItineraryData();
    //return new NewTargetScoreboardHazardRecognizer(II, DAG);
}

/// CreateTargetPostRAHazardRecognizer - Return the postRA hazard recognizer
/// to use for this target when scheduling the DAG.

ScheduleHazardRecognizer *NewTargetInstrInfo::CreateTargetPostRAHazardRecognizer(
        const InstrItineraryData *II,
        const ScheduleDAG *DAG) const {

    std::cout << "NewTargetInstrInfo::CreateTargetPostRAHazardRecognizer\n";

    //return TargetInstrInfo::CreateTargetPostRAHazardRecognizer(II, DAG);
    return new NewTargetScoreboardHazardRecognizer(II, DAG);
}

bool NewTargetInstrInfo::expandPostRAPseudo(MachineBasicBlock::iterator MI) const {
    MachineBasicBlock &MBB = *MI->getParent();

    //std::cout << "ewTargetInstrInfo::expandPostRAPseudo partially implemented\n";
    switch (MI->getDesc().getOpcode()) {
        case NewTarget::RetRA:
            ExpandRet(MBB, MI, NewTarget::GOTOLr);
            break;
        case NewTarget::BranchBR:
            ExpandBranchBR(MBB, MI, true);
            break;
        case NewTarget::BranchBRF:
            ExpandBranchBR(MBB, MI, false);
            break;
        case NewTarget::NewTargetSelect:
            ExpandSelect(MBB, MI);
            break;
        case NewTarget::ImmediateConstant32:
            ExpandImmediateConstant32(MBB, MI);
            break;
        case NewTarget::NewTargetSUBC:
        case NewTarget::NewTargetSUBE:
        case NewTarget::NewTargetADDC:
        case NewTarget::NewTargetADDE:
            //llvm_unreachable("instruções com carry");
            ExpandArithCarryInst(MBB, MI);
            break;
            // case NewTarget::NewTargetSelectV2:
            //     llvm_unreachable("NewTargetSelectV2");
            //  break;      
        default:
            return false;
    }

    MBB.erase(MI);
    return true;
}

void NewTargetInstrInfo::ExpandRet(MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I,
        unsigned Opc) const {
    //std::cout << "NNewTargetEInstrInfo::ExpandRetRA done =)\n";
    BuildMI(MBB, I, I->getDebugLoc(), get(Opc)).addReg(NewTarget::LR);
}

bool NewTargetInstrInfo::isCmpReg(MachineBasicBlock::iterator I, unsigned reg) const {

    unsigned opcode = I->getOpcode();

    switch (opcode) {
            // reg
        case NewTarget::CMPEQREG:
        case NewTarget::CMPGEREG:
        case NewTarget::CMPGEuREG:
        case NewTarget::CMPGTREG:
        case NewTarget::CMPGTuREG:
        case NewTarget::CMPLEREG:
        case NewTarget::CMPLEuREG:
        case NewTarget::CMPLTREG:
        case NewTarget::CMPLTuREG:
        case NewTarget::CMPNEREG:
            // imm
        case NewTarget::CMPEQiREG:
        case NewTarget::CMPGEiREG:
        case NewTarget::CMPGEiuREG:
        case NewTarget::CMPGTiREG:
        case NewTarget::CMPGTiuREG:
        case NewTarget::CMPLEiREG:
        case NewTarget::CMPLEiuREG:
        case NewTarget::CMPLTiREG:
        case NewTarget::CMPLTiuREG:
        case NewTarget::CMPNEiREG:
            if (I->getOperand(0).getReg() == reg) {
                return true;
            }
            break;
    }
    return false;
}

unsigned NewTargetInstrInfo::cmpRegToFlag(MachineBasicBlock::iterator I) const {

    unsigned opcode = I->getOpcode();

    switch (opcode) {
            // reg
        case NewTarget::CMPEQREG:
            return NewTarget::CMPEQBR;
            break;

        case NewTarget::CMPGEREG:
            return NewTarget::CMPGEBR;
            break;

        case NewTarget::CMPGEuREG:
            return NewTarget::CMPGEuBR;
            break;

        case NewTarget::CMPGTREG:
            return NewTarget::CMPGTBR;
            break;

        case NewTarget::CMPGTuREG:
            return NewTarget::CMPGTuBR;
            break;

        case NewTarget::CMPLEREG:
            return NewTarget::CMPLEBR;
            break;

        case NewTarget::CMPLEuREG:
            return NewTarget::CMPLEuBR;
            break;

        case NewTarget::CMPLTREG:
            return NewTarget::CMPLTBR;
            break;

        case NewTarget::CMPLTuREG:
            return NewTarget::CMPLTuBR;
            break;

        case NewTarget::CMPNEREG:
            return NewTarget::CMPNEBR;
            break;
            // imm
        case NewTarget::CMPEQiREG:
            return NewTarget::CMPEQiBR;
            break;

        case NewTarget::CMPGEiREG:
            return NewTarget::CMPGEiBR;
            break;

        case NewTarget::CMPGEiuREG:
            return NewTarget::CMPGEiuBR;
            break;

        case NewTarget::CMPGTiREG:
            return NewTarget::CMPGTiBR;
            break;

        case NewTarget::CMPGTiuREG:
            return NewTarget::CMPGTiuBR;
            break;

        case NewTarget::CMPLEiREG:
            return NewTarget::CMPLEiBR;
            break;

        case NewTarget::CMPLEiuREG:
            return NewTarget::CMPLEiuBR;
            break;

        case NewTarget::CMPLTiREG:
            return NewTarget::CMPLTiBR;
            break;

        case NewTarget::CMPLTiuREG:
            return NewTarget::CMPLTiuBR;
            break;

        case NewTarget::CMPNEiREG:
            return NewTarget::CMPNEiBR;
            break;
    }

    llvm_unreachable("this cannot happen");

    return 0;
}

void NewTargetInstrInfo::ExpandSelect(MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I) const {

    unsigned ORL = NewTarget::ORLBR;
    unsigned SELECT = NewTarget::SELECT;

    unsigned BRFlag = NewTarget::BRFLAG1;
    unsigned DstReg = I->getOperand(0).getReg();
    unsigned CondReg = I->getOperand(1).getReg();
    unsigned TrueReg = I->getOperand(2).getReg();
    unsigned FalseReg = I->getOperand(3).getReg();

    //std::cout << "teste!!!!!\n";
    //I->getPrevNode()->dump();
    //std::cout << "teste????\n";

    //std::cout << "A: " << I->getPrevNode()->isBundled() << "\n";
    //std::cout << "B: " << !isCmpReg(I->getPrevNode(), CondReg) << "\n";


    if (!I->getPrevNode()->isBundled() && isCmpReg(I->getPrevNode(), CondReg)) {
        //std::cout << "testeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee\n";

        // optimize the case when the comparation instruction is immediately before de branch instruction.
        // we convert the instruction to generate results direcly on branch flag register br0 
        MachineBasicBlock::iterator IOld = I->getPrevNode();
        MachineOperand M1 = IOld->getOperand(1);
        MachineOperand M2 = IOld->getOperand(2);

        BuildMI(MBB, IOld, IOld->getDebugLoc(), get(cmpRegToFlag(IOld)), BRFlag).addOperand(M1).addOperand(M2);
        MBB.remove(IOld);

    } else {

        BuildMI(MBB, I, I->getDebugLoc(), get(ORL), BRFlag).addReg(CondReg).addReg(NewTarget::ZERO);
    }

    //std::cout << "testaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n";

    BuildMI(MBB, I, I->getDebugLoc(), get(SELECT), DstReg).addReg(BRFlag).addReg(TrueReg).addReg(FalseReg);


    //llvm_unreachable("cannot expand select");

}

void NewTargetInstrInfo::ExpandArithCarryInst(MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I) const {

    DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
    unsigned SELECTF = NewTarget::SELECTFi;
    unsigned ADDCG = NewTarget::ADDCG;
    unsigned SUBCG = NewTarget::SUBCG;
    unsigned ORL = NewTarget::ORLBR;

    unsigned ZeroReg = NewTarget::ZERO;
    unsigned BRFLAGReg = NewTarget::BRFLAG7;

    unsigned PseudoOpcode = I->getOpcode();
    unsigned Opcode;
    bool CarryIn = false;

    unsigned DstReg = I->getOperand(0).getReg();
    unsigned DstRegFlag = I->getOperand(1).getReg();
    unsigned SrcReg1 = I->getOperand(2).getReg();
    unsigned SrcReg2 = I->getOperand(3).getReg();
    unsigned SrcRegFlag;

    switch (PseudoOpcode) {
        case NewTarget::NewTargetADDE:
            CarryIn = true;
            Opcode = NewTarget::ADDCG;
            break;
        case NewTarget::NewTargetADDC:
            Opcode = NewTarget::ADDCG;
            break;
        case NewTarget::NewTargetSUBE:
            CarryIn = true;
            Opcode = NewTarget::SUBCG;
            break;
        case NewTarget::NewTargetSUBC:
            Opcode = NewTarget::SUBCG;
            break;
        default:
            break;
    }



    if (CarryIn) {

        // copy carry from general register to flag register
        SrcRegFlag = I->getOperand(4).getReg();

        if (I->getPrevNode() &&
                I->getPrevNode()->getOpcode() == NewTarget::SELECTFi &&
                I->getPrevNode()->getOperand(0).getReg() == SrcRegFlag) {
            MachineBasicBlock::iterator IOld = I->getPrevNode();
            MBB.erase(IOld);
        } else {
            BuildMI(MBB, I, I->getDebugLoc(), get(ORL), BRFLAGReg).addReg(SrcRegFlag).addReg(NewTarget::ZERO);
        }

    } else {
        BuildMI(MBB, I, I->getDebugLoc(), get(ORL), BRFLAGReg).addReg(ZeroReg).addReg(ZeroReg);
    }

    BuildMI(MBB, I, I->getDebugLoc(), get(Opcode), DstReg)
            .addReg(BRFLAGReg, RegState::Define) // without this, we cannot guarantee a reg dependence
            .addReg(SrcReg1)
            .addReg(SrcReg2)
            .addReg(BRFLAGReg);

    BuildMI(MBB, I, I->getDebugLoc(), get(SELECTF), DstRegFlag)
            .addReg(BRFLAGReg, RegState::Kill)
            .addReg(ZeroReg)
            .addImm(1);

    //llvm_unreachable("okkkkkl");
}

void NewTargetInstrInfo::ExpandImmediateConstant32(MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I) const {

    DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
    unsigned ADDi = NewTarget::ADDi;
    unsigned IMM = NewTarget::IMML;
    unsigned ZeroReg = NewTarget::ZERO;
    unsigned DstReg = I->getOperand(0).getReg();

    if (I->getOperand(1).isImm()) {

        int32_t Amount;
        int32_t Amount9;
        int32_t Amount23;

        Amount = I->getOperand(1).getImm();
        Amount9 = Amount & 0x1FF;
        Amount23 = (Amount >> 9) & 0x7FFFFF;

        BuildMI(MBB, I, DL, get(ADDi), DstReg).addReg(ZeroReg).addImm(Amount9);
        BuildMI(MBB, I, DL, get(IMM)).addImm(Amount23);

    } else if (I->getOperand(1).isGlobal()) {

        //const GlobalValue* gv = I->getOperand(1).getGlobal();

        BuildMI(MBB, I, DL, get(ADDi), DstReg).addReg(ZeroReg).addOperand(I->getOperand(1));
        BuildMI(MBB, I, DL, get(IMM)).addOperand(I->getOperand(1));

    } else if (I->getOperand(1).isJTI()) {

        BuildMI(MBB, I, DL, get(ADDi), DstReg).addReg(ZeroReg).addOperand(I->getOperand(1));
        BuildMI(MBB, I, DL, get(IMM)).addOperand(I->getOperand(1));

        //llvm_unreachable("something wrong happened here");
    } else {
        llvm_unreachable("something wrong happened here");
    }

    MachineInstr* FirstInstr = I->getPrevNode();
    FirstInstr->bundleWithPred();

}

static bool IsLiveInSucessors(MachineBasicBlock &MBB, unsigned reg){
    
    MachineBasicBlock::succ_iterator IT;
    
    for(IT = MBB.succ_begin(); IT != MBB.succ_end(); IT++){
        MachineBasicBlock *MBBSucc = *IT;
        
        if(MBBSucc->isLiveIn(reg)){
            return true;
        }
    }
    
    return false;
}

void NewTargetInstrInfo::ExpandBranchBR(MachineBasicBlock &MBB, MachineBasicBlock::iterator I, bool br) const {

    unsigned ORL = NewTarget::ORLBR;
    MachineBasicBlock* MBBTarget = I->getOperand(1).getMBB();
    unsigned BR;

    if (br) {

        // static branch prediction approach
        if (EnableStaticBranchPredicion && (MBB.getNumber() > MBBTarget->getNumber())) {
            // polarized as taken
            BR = NewTarget::BR;
        } else {
            // polarized as not taken
            BR = NewTarget::BR;
        }

    } else {

        // static branch prediction approach
        if (EnableStaticBranchPredicion && (MBB.getNumber() > MBBTarget->getNumber())) {
            // polarized as taken
            BR = NewTarget::BRF;
        } else {
            // polarized as not taken
            BR = NewTarget::BRF;
        }

    }

    unsigned BRFlag = NewTarget::BRFLAG0;
    unsigned CondReg = I->getOperand(0).getReg();


    //std::cout << "Reg: " << CondReg << "\n";
    // std::cout << "BB Target: " << MBBTarget->getNumber() << "\n";
    //std::cout << "liveIn: " << IsLiveInSucessors(MBB, CondReg) << "\n";
    
    if (!isCmpReg(I->getPrevNode(), CondReg) || IsLiveInSucessors(MBB, CondReg)) {
        //std::cout << "Este caso-------------------\n";
        //I->dump();
        BuildMI(MBB, I, I->getDebugLoc(), get(ORL), BRFlag).addReg(CondReg).addReg(NewTarget::ZERO);
        
        //I->dump();

    } else {
        //std::cout << "++++++++++outro caso\n";
        // optimize the case when the comparation instruction is immediately before de branch instruction.
        // we convert the instruction to generate results direcly on branch flag register br0 
        MachineBasicBlock::iterator IOld = I->getPrevNode();
        MachineOperand M1 = IOld->getOperand(1);
        MachineOperand M2 = IOld->getOperand(2);

        BuildMI(MBB, IOld, IOld->getDebugLoc(), get(cmpRegToFlag(IOld)), BRFlag).addOperand(M1).addOperand(M2);
        MBB.remove(IOld);
    }
    BuildMI(MBB, I, I->getDebugLoc(), get(BR)).addReg(BRFlag).addMBB(MBBTarget);

    //assert(false && "iniciando...."); 
}

/// Adjust SP by Amount bytes.

void NewTargetInstrInfo::adjustStackPtr(unsigned SP, int64_t Amount,
        MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I) const {

    DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
    //unsigned ADD = NewTarget::ADD;
    unsigned ADDi = NewTarget::ADDi;
    unsigned IMM = NewTarget::IMML;

    if (isInt<9>(Amount))// addi sp, sp, amount
        //BuildMI(MBB, I, DL, get(ADDi), SP).addReg(SP).addImm(Amount);
        BuildMI(MBB, I, DL, get(ADDi), SP).addReg(SP).addImm(Amount);

    else { // Expand immediate
        int32_t Amount9;
        int32_t Amount23;

        Amount9 = Amount & 0x1FF;
        Amount23 = (Amount >> 9) & 0x7FFFFF;

        BuildMI(MBB, I, DL, get(ADDi), SP).addReg(SP).addImm(Amount9);

        BuildMI(MBB, I, DL, get(IMM)).addImm(Amount23);

        MachineInstr* FirstInstr = I->getPrevNode();
        FirstInstr->bundleWithPred();

        //BuildMI(MBB, I, DL, get(IMM), SP).addImm(Amount23);

        //unsigned Reg = loadImmediate(Amount, MBB, I, DL, 0);
        //BuildMI(MBB, I, DL, get(ADD), SP).addReg(SP).addReg(Reg, RegState::Kill);
    }
}

void NewTargetInstrInfo::
storeRegToStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
        unsigned SrcReg, bool isKill, int FI,
        const TargetRegisterClass *RC,
        const TargetRegisterInfo *TRI) const {

    DebugLoc DL;
    if (I != MBB.end()) DL = I->getDebugLoc();
    MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOStore);


    if (!true) {
        unsigned Reg = GetMarReg();
        BuildMI(MBB, I, DL, get(NewTarget::ADDi), Reg).addReg(NewTarget::SP).addImm(FI * 4 + 4);

        BuildMI(MBB, I, DL, get(NewTarget::SW)).addReg(SrcReg, getKillRegState(isKill))
                .addReg(Reg, RegState::Kill).addImm(0).addMemOperand(MMO);
    } else {

        BuildMI(MBB, I, DL, get(NewTarget::SW)).addReg(SrcReg, getKillRegState(isKill))
                .addFrameIndex(FI).addImm(0).addMemOperand(MMO);

    }

}

void NewTargetInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
        unsigned DestReg, int FI,
        const TargetRegisterClass *RC,
        const TargetRegisterInfo *TRI) const {
    DebugLoc DL;
    if (I != MBB.end()) DL = I->getDebugLoc();
    MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOLoad);

    //MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();

    //getReg(DestReg).
    //MBB->get

    if (!true) {
        unsigned Reg = GetMarReg();
        //unsigned Reg = DestReg;
        BuildMI(MBB, I, DL, get(NewTarget::ADDi), Reg).addReg(NewTarget::SP).addImm(FI * 4 + 4);

        BuildMI(MBB, I, DL, get(NewTarget::LW), DestReg).addReg(Reg).addImm(0).addMemOperand(MMO);
    } else {

        BuildMI(MBB, I, DL, get(NewTarget::LW), DestReg).addFrameIndex(FI).addImm(0)
                .addMemOperand(MMO);

        //BuildMI(MBB, I, DL, get(IMM)).addOperand(I->getOperand(1));
        //    MachineInstr* FirstInstr = I->getPrevNode();
        // FirstInstr->bundleWithPred();

    }



}

MachineMemOperand *NewTargetInstrInfo::GetMemOperand(MachineBasicBlock &MBB, int FI,
        unsigned Flag) const {
    MachineFunction &MF = *MBB.getParent();
    MachineFrameInfo &MFI = *MF.getFrameInfo();
    unsigned Align = MFI.getObjectAlignment(FI);

    return MF.getMachineMemOperand(MachinePointerInfo::getFixedStack(FI), Flag,
            MFI.getObjectSize(FI), Align);
}

/// This function generates the sequence of instructions needed to get the
/// result of adding register REG and immediate IMM.

unsigned
NewTargetInstrInfo::loadImmediate(int64_t Imm, MachineBasicBlock &MBB,
        MachineBasicBlock::iterator II, DebugLoc DL,
        unsigned *NewImm) const {
    //std::cout << "========================\n";


    MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();
    unsigned Size = 32;

    const TargetRegisterClass *RC = &NewTarget::CPURegsRegClass;

    //std::cout << "Valor do imediato: " << Imm << "\n";

    unsigned Reg = RegInfo.createVirtualRegister(RC);


    /*
    if (Inst->Opc == LUi)
        BuildMI(MBB, II, DL, get(LUi), Reg).addImm(SignExtend64<16>(Inst->ImmOpnd));
    else
        BuildMI(MBB, II, DL, get(Inst->Opc), Reg).addReg(ZEROReg)
        .addImm(SignExtend64<16>(Inst->ImmOpnd));

    // Build the remaining instructions in Seq.
    for (++Inst; Inst != Seq.end() - LastInstrIsADDiu; ++Inst)
        BuildMI(MBB, II, DL, get(Inst->Opc), Reg).addReg(Reg, RegState::Kill)
        .addImm(SignExtend64<16>(Inst->ImmOpnd));

    if (LastInstrIsADDiu)
     *NewImm = Inst->ImmOpnd;

     */
    int32_t Amount;
    int32_t Amount9;
    int32_t Amount23;

    Amount = Imm;
    Amount9 = Amount & 0x1FF;
    Amount23 = (Amount >> 9) & 0x7FFFFF;

    BuildMI(MBB, II, DL, get(NewTarget::ADDi), Reg).addReg(NewTarget::ZERO).addImm(Amount9);
    BuildMI(MBB, II, DL, get(NewTarget::IMML)).addImm(Amount23);

    MachineInstr* FirstInstr = II->getPrevNode();
    FirstInstr->bundleWithPred();

    *NewImm = 0;

    return Reg;
}

void NewTargetInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I, DebugLoc DL,
        unsigned DestReg, unsigned SrcReg,
        bool KillSrc) const {
    unsigned Opc = 0, ZeroReg = 0;

    if (NewTarget::CPURegsRegClass.contains(DestReg)) { // Copy to CPU Reg.
        if (NewTarget::CPURegsRegClass.contains(SrcReg))
            Opc = NewTarget::OR, ZeroReg = NewTarget::ZERO;
    } else if (NewTarget::CPUPredRegsRegClass.contains(DestReg)) {
        /*very ugly, we need an instruction do copy predicates*/
        //MachineInstrBuilder MIB = BuildMI(MBB, I, DL, get(NewTarget::CMPNEBR));
        //MIB.addReg(DestReg, RegState::Define);
        //MIB.addReg(NewTarget::ZERO, getKillRegState(KillSrc));
        //MIB.addReg(NewTarget::ZERO);

        //MachineInstrBuilder MIB2 = BuildMI(MBB, I, DL, get(NewTarget::ORL));
        //MIB2.addReg(DestReg, RegState::Define);
        //MIB2.addReg(SrcReg, getKillRegState(KillSrc));
        //MIB2.addReg(DestReg);
        //llvm_unreachable("cannot copy branch registers!");

        return;
    }

    assert(Opc && "Cannot copy registers");

    MachineInstrBuilder MIB = BuildMI(MBB, I, DL, get(Opc));

    if (DestReg)
        MIB.addReg(DestReg, RegState::Define);

    if (SrcReg)
        MIB.addReg(SrcReg, getKillRegState(KillSrc));

    if (ZeroReg)
        MIB.addReg(ZeroReg);
}


/// ReverseBranchCondition - Return the inverse opcode of the
/// specified Branch instruction.

bool NewTargetInstrInfo::
ReverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const {

    unsigned opcode = 0;

    if (Cond[0].getImm() == NewTarget::BR) {
        opcode = NewTarget::BRF;
    } else if (Cond[0].getImm() == NewTarget::BRF) {
        opcode = NewTarget::BR;
    } else if (Cond[0].getImm() == NewTarget::BranchBR) {
        opcode = NewTarget::BranchBRF;
    } else if (Cond[0].getImm() == NewTarget::BranchBRF) {
        opcode = NewTarget::BranchBR;
    }


    //std::cout << "Opcode: " << opcode << "\n";

    assert((Cond.size() && Cond.size() <= 3) &&
            "Invalid Mips branch condition!");
    Cond[0].setImm(opcode);
    return false;
}

unsigned NewTargetInstrInfo::GetAnalyzableBrOpc(unsigned Opc) const {

    //return 0;

    //if(Opc == NewTarget::BranchBR){
    //    return NewTarget::BR;
    //}

    return (Opc == NewTarget::BRF || Opc == NewTarget::BR || Opc == NewTarget::GOTO
            || Opc == NewTarget::BranchBR || Opc == NewTarget::BranchBRF) ?
            Opc : 0;
}

void NewTargetInstrInfo::BuildCondBr(MachineBasicBlock &MBB,
        MachineBasicBlock *TBB, DebugLoc DL,
        const SmallVectorImpl<MachineOperand>& Cond)
const {
    unsigned Opc = Cond[0].getImm();
    const MCInstrDesc &MCID = get(Opc);
    MachineInstrBuilder MIB = BuildMI(&MBB, DL, MCID);

    for (unsigned i = 1; i < Cond.size(); ++i) {
        if (Cond[i].isReg())
            MIB.addReg(Cond[i].getReg());
        else if (Cond[i].isImm())
            MIB.addImm(Cond[i].getImm());
        else
            assert(true && "Cannot copy operand");
    }
    MIB.addMBB(TBB);
}

unsigned NewTargetInstrInfo::
InsertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
        MachineBasicBlock *FBB,
        const SmallVectorImpl<MachineOperand> &Cond,
        DebugLoc DL) const {

    //MBB.dump();

    unsigned int UncondBrOpc = NewTarget::GOTO;
    // Shouldn't be a fall through.
    assert(TBB && "InsertBranch must not be told to insert a fallthrough");

    // # of condition operands:
    //  Unconditional branches: 0
    //  Floating point branches: 1 (opc)
    //  Int BranchZero: 2 (opc, reg)
    //  Int Branch: 3 (opc, reg0, reg1)
    assert((Cond.size() <= 3) &&
            "# of Mips branch conditions must be <= 3!");

    // Two-way Conditional branch.
    if (FBB) {
        BuildCondBr(MBB, TBB, DL, Cond);
        BuildMI(&MBB, DL, get(UncondBrOpc)).addMBB(FBB);
        return 2;
    }

    // One way branch.
    // Unconditional branch.
    if (Cond.empty())
        BuildMI(&MBB, DL, get(UncondBrOpc)).addMBB(TBB);
    else // Conditional branch.
        BuildCondBr(MBB, TBB, DL, Cond);
    return 1;
}

unsigned NewTargetInstrInfo::
RemoveBranch(MachineBasicBlock &MBB) const {
    MachineBasicBlock::reverse_iterator I = MBB.rbegin(), REnd = MBB.rend();
    MachineBasicBlock::reverse_iterator FirstBr;
    unsigned removed;

    // Skip all the debug instructions.
    while (I != REnd && I->isDebugValue())
        ++I;

    FirstBr = I;

    // Up to 2 branches are removed.
    // Note that indirect branches are not removed.
    for (removed = 0; I != REnd && removed < 2; ++I, ++removed)
        if (!GetAnalyzableBrOpc(I->getOpcode()))
            break;

    MBB.erase(I.base(), FirstBr.base());

    return removed;
}

bool NewTargetInstrInfo::AnalyzeBranch(MachineBasicBlock &MBB,
        MachineBasicBlock *&TBB,
        MachineBasicBlock *&FBB,
        SmallVectorImpl<MachineOperand> &Cond,
        bool AllowModify) const {
    SmallVector<MachineInstr*, 2> BranchInstrs;

    BranchType BT = AnalyzeBranch(MBB, TBB, FBB, Cond, AllowModify, BranchInstrs);

    return (BT == BT_None) || (BT == BT_Indirect);
}

NewTargetInstrInfo::BranchType NewTargetInstrInfo::
AnalyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
        MachineBasicBlock *&FBB, SmallVectorImpl<MachineOperand> &Cond,
        bool AllowModify,
        SmallVectorImpl<MachineInstr*> &BranchInstrs) const {

    MachineBasicBlock::reverse_iterator I = MBB.rbegin(), REnd = MBB.rend();
    unsigned int UncondBrOpc = NewTarget::GOTO;

    //llvm_unreachable("....................");
    // Skip all the debug instructions.
    while (I != REnd && I->isDebugValue())
        ++I;

    /// 1. If this block ends with no branches (it just falls through to its succ)
    ///    just return false, leaving TBB/FBB null.
    if (I == REnd || !isUnpredicatedTerminator(&*I)) {
        // This block ends with no branches (it just falls through to its succ).
        // Leave TBB/FBB null.
        TBB = FBB = NULL;
        return BT_NoBranch;
    }

    MachineInstr *LastInst = &*I;
    unsigned LastOpc = LastInst->getOpcode();
    BranchInstrs.push_back(LastInst);

    // Not an analyzable branch (e.g., indirect jump).
    if (!GetAnalyzableBrOpc(LastOpc)) {
        // LastInst->dump();
        // std::cout << "----2----\n";
        return LastInst->isIndirectBranch() ? BT_Indirect : BT_None;
    }

    // Get the second to last instruction in the block.
    unsigned SecondLastOpc = 0;
    MachineInstr *SecondLastInst = NULL;

    if (++I != REnd) {
        SecondLastInst = &*I;
        SecondLastOpc = GetAnalyzableBrOpc(SecondLastInst->getOpcode());

        // Not an analyzable branch (must be an indirect jump).
        //SecondLastInst->dump();
        if (isUnpredicatedTerminator(SecondLastInst) && !SecondLastOpc) {
            //std::cout << "----3----\n";
            return BT_None;
        }
    }

    // If there is only one terminator instruction, process it.
    if (!SecondLastOpc) {
        // Unconditional branch
        if (LastOpc == UncondBrOpc) {
            TBB = LastInst->getOperand(0).getMBB();
            // std::cout << "----BT_Uncond----\n";
            return BT_Uncond;
        }

        // Conditional branch
        AnalyzeCondBr(LastInst, LastOpc, TBB, Cond);
        return BT_Cond;
    }

    // If we reached here, there are two branches.
    // If there are three terminators, we don't know what sort of block this is.
    if (++I != REnd && isUnpredicatedTerminator(&*I)) {
        //std::cout << "----6----\n";
        return BT_None;
    }

    BranchInstrs.insert(BranchInstrs.begin(), SecondLastInst);

    // If second to last instruction is an unconditional branch,
    // analyze it and remove the last instruction.
    if (SecondLastOpc == UncondBrOpc) {
        // Return if the last instruction cannot be removed.
        if (!AllowModify) {
            return BT_None;
        }

        TBB = SecondLastInst->getOperand(0).getMBB();
        LastInst->eraseFromParent();
        BranchInstrs.pop_back();
        //std::cout << "----8----\n";
        return BT_Uncond;
    }

    // Conditional branch followed by an unconditional branch.
    // The last one must be unconditional.
    if (LastOpc != UncondBrOpc) {
        // std::cout << "----9----\n";
        return BT_None;
    }

    AnalyzeCondBr(SecondLastInst, SecondLastOpc, TBB, Cond);
    FBB = LastInst->getOperand(0).getMBB();

    return BT_CondUncond;
}

void NewTargetInstrInfo::AnalyzeCondBr(const MachineInstr *Inst, unsigned Opc,
        MachineBasicBlock *&BB,
        SmallVectorImpl<MachineOperand> &Cond) const {
    assert(GetAnalyzableBrOpc(Opc) && "Not an analyzable branch");
    int NumOp = Inst->getNumExplicitOperands();

    // for both int and fp branches, the last explicit operand is the
    // MBB.
    BB = Inst->getOperand(NumOp - 1).getMBB();
    Cond.push_back(MachineOperand::CreateImm(Opc));

    for (int i = 0; i < NumOp - 1; i++) {
        Cond.push_back(Inst->getOperand(i));
        //std::cout << "t operandos: " << Inst->getOperand(i).isReg() << "\n";
    }
}

MachineInstr*
NewTargetInstrInfo::emitFrameIndexDebugValue(MachineFunction &MF, int FrameIx,
        uint64_t Offset, const MDNode *MDPtr,
        DebugLoc DL) const {
    MachineInstrBuilder MIB = BuildMI(MF, DL, get(NewTarget::DBG_VALUE))
            .addFrameIndex(FrameIx).addImm(0).addImm(Offset).addMetadata(MDPtr);
    return &*MIB;
}

bool NewTargetInstrInfo::isExtended(const MachineInstr *Inst) const {

    const MachineInstr *InstNext = Inst->getNextNode();

    //if(Inst->isBundledWithSucc()){
    //    return true;
    // }

    if (InstNext && InstNext->getOpcode() == NewTarget::IMML) {
        return true;
    }

    return false;
}

bool NewTargetInstrInfo::isPredicatedOpcode(MachineInstr *Inst) const {
    switch (Inst->getOpcode()) {
        case NewTarget::ADD_p:
            return true;
        case NewTarget::ADDCG_p:
            return true;
        case NewTarget::SUBCG_p:
            return true;    
        case NewTarget::ADDi_p:
            return true;
        case NewTarget::AND_p:
            return true;
        case NewTarget::ANDi_p:
            return true;
        case NewTarget::DIV_Q_p:
            return true;
        case NewTarget::DIV_QU_p:
            return true;
        case NewTarget::DIV_R_p:
            return true;
        case NewTarget::DIV_RU_p:
            return true;
        case NewTarget::LB_p:
            return true;
        case NewTarget::LBu_p:
            return true;
        case NewTarget::LEA_ADDiu_p:
            return true;
        case NewTarget::LH_p:
            return true;
        case NewTarget::LHu_p:
            return true;
        case NewTarget::LW_p:
            return true;
        case NewTarget::MUL32_p:
            return true;
        case NewTarget::MUL64h_p:
            return true;
        case NewTarget::MUL64hi_p:
            return true;
        case NewTarget::MUL64hu_p:
            return true;
        case NewTarget::MUL64hui_p:
            return true;
        case NewTarget::OR_p:
            return true;
        case NewTarget::ORi_p:
            return true;
        case NewTarget::ORLBR_p:
            return true;
        case NewTarget::SB_p:
            return true;
        case NewTarget::SH_p:
            return true;
        case NewTarget::SW_p:
            return true;
        case NewTarget::SHLi_p:
            return true;
        case NewTarget::SHLr_p:
            return true;
        case NewTarget::SHRUi_p:
            return true;
        case NewTarget::SHRUr_p:
            return true;
        case NewTarget::SHRi_p:
            return true;
        case NewTarget::SHRr_p:
            return true;
        case NewTarget::SUB_p:
            return true;
        case NewTarget::XOR_p:
            return true;
        case NewTarget::XORi_p:
            return true;
        case NewTarget::SELECT_p:
            return true;
        case NewTarget::SELECTF_p:
            return true;
        case NewTarget::SELECTi_p:
            return true;
        case NewTarget::SELECTFi_p:
            return true;

        case NewTarget::CMPEQREG_p:
            return true;
        case NewTarget::CMPGEREG_p:
            return true;
        case NewTarget::CMPGEuREG_p:
            return true;
        case NewTarget::CMPGTREG_p:
            return true;
        case NewTarget::CMPGTuREG_p:
            return true;
        case NewTarget::CMPLEREG_p:
            return true;
        case NewTarget::CMPLEuREG_p:
            return true;
        case NewTarget::CMPLTREG_p:
            return true;
        case NewTarget::CMPNEREG_p:
            return true;
        case NewTarget::CMPEQiREG_p:
            return true;
        case NewTarget::CMPGEiREG_p:
            return true;
        case NewTarget::CMPGEiuREG_p:
            return true;
        case NewTarget::CMPGTiREG_p:
            return true;
        case NewTarget::CMPGTiuREG_p:
            return true;
        case NewTarget::CMPLEiREG_p:
            return true;
        case NewTarget::CMPLEiuREG_p:
            return true;
        case NewTarget::CMPLTiREG_p:
            return true;
        case NewTarget::CMPLTiuREG_p:
            return true;
        case NewTarget::CMPNEiREG_p:
            return true;
        case NewTarget::CMPEQBR_p:
            return true;
        case NewTarget::CMPGEBR_p:
            return true;
        case NewTarget::CMPGEuBR_p:
            return true;
        case NewTarget::CMPGTBR_p:
            return true;
        case NewTarget::CMPGTuBR_p:
            return true;
        case NewTarget::CMPLEBR_p:
            return true;
        case NewTarget::CMPLEuBR_p:
            return true;
        case NewTarget::CMPLTBR_p:
            return true;
        case NewTarget::CMPLTuBR_p:
            return true;
        case NewTarget::CMPNEBR_p:
            return true;
        case NewTarget::CMPEQiBR_p:
            return true;
        case NewTarget::CMPGEiBR_p:
            return true;
        case NewTarget::CMPGEiuBR_p:
            return true;
        case NewTarget::CMPGTiBR_p:
            return true;
        case NewTarget::CMPGTiuBR_p:
            return true;
        case NewTarget::CMPLEiBR_p:
            return true;
        case NewTarget::CMPLEiuBR_p:
            return true;
        case NewTarget::CMPLTiBR_p:
            return true;
        case NewTarget::CMPLTiuBR_p:
            return true;
        case NewTarget::CMPNEiBR_p:
            return true;
    }

    return false;
}

bool NewTargetInstrInfo::isMemoryInstr(MachineInstr *Inst) const {

    if (Inst->mayLoad() || Inst->mayStore()) {
        return true;
    }

    if ((Inst->getOpcode() == NewTarget::LB_p) ||
            (Inst->getOpcode() == NewTarget::LBu_p) ||
            (Inst->getOpcode() == NewTarget::LH_p) ||
            (Inst->getOpcode() == NewTarget::LHu_p) ||
            (Inst->getOpcode() == NewTarget::LW_p) ||
            (Inst->getOpcode() == NewTarget::SB_p) ||
            (Inst->getOpcode() == NewTarget::SH_p) ||
            (Inst->getOpcode() == NewTarget::SW_p)) {
        return true;
    }

    return false;
}

unsigned NewTargetInstrInfo::getPredicatedOpcode(unsigned opcode) const {

    switch (opcode) {
        case NewTarget::ADD:
            return NewTarget::ADD_p;
        case NewTarget::ADDCG:
            return NewTarget::ADDCG_p;
        case NewTarget::SUBCG:
            return NewTarget::SUBCG_p;            
        case NewTarget::ADDi:
            return NewTarget::ADDi_p;
        case NewTarget::AND:
            return NewTarget::AND_p;
        case NewTarget::ANDi:
            return NewTarget::ANDi_p;
        case NewTarget::DIV_Q:
            return NewTarget::DIV_Q_p;
        case NewTarget::DIV_QU:
            return NewTarget::DIV_QU_p;
        case NewTarget::DIV_R:
            return NewTarget::DIV_R_p;
        case NewTarget::DIV_RU:
            return NewTarget::DIV_RU_p;
        case NewTarget::LB:
            return NewTarget::LB_p;
        case NewTarget::LBu:
            return NewTarget::LBu_p;
        case NewTarget::LEA_ADDiu:
            return NewTarget::LEA_ADDiu_p;
        case NewTarget::LH:
            return NewTarget::LH_p;
        case NewTarget::LHu:
            return NewTarget::LHu_p;
        case NewTarget::LW:
            return NewTarget::LW_p;
        case NewTarget::MUL32:
            return NewTarget::MUL32_p;
        case NewTarget::MUL64h:
            return NewTarget::MUL64h_p;
        case NewTarget::MUL64hi:
            return NewTarget::MUL64hi_p;
        case NewTarget::MUL64hu:
            return NewTarget::MUL64hu_p;
        case NewTarget::MUL64hui:
            return NewTarget::MUL64hui_p;
        case NewTarget::OR:
            return NewTarget::OR_p;
        case NewTarget::ORi:
            return NewTarget::ORi_p;
        case NewTarget::ORLBR:
            return NewTarget::ORLBR_p;
        case NewTarget::SB:
            return NewTarget::SB_p;
        case NewTarget::SH:
            return NewTarget::SH_p;
        case NewTarget::SW:
            return NewTarget::SW_p;
        case NewTarget::SHLi:
            return NewTarget::SHLi_p;
        case NewTarget::SHLr:
            return NewTarget::SHLr_p;
        case NewTarget::SHRUi:
            return NewTarget::SHRUi_p;
        case NewTarget::SHRUr:
            return NewTarget::SHRUr_p;
        case NewTarget::SHRi:
            return NewTarget::SHRi_p;
        case NewTarget::SHRr:
            return NewTarget::SHRr_p;
        case NewTarget::SUB:
            return NewTarget::SUB_p;
        case NewTarget::XOR:
            return NewTarget::XOR_p;
        case NewTarget::XORi:
            return NewTarget::XORi_p;
        case NewTarget::IMML:
            return NewTarget::IMML;
        case NewTarget::SELECT:
            return NewTarget::SELECT_p;
        case NewTarget::SELECTF:
            return NewTarget::SELECTF_p;
        case NewTarget::SELECTi:
            return NewTarget::SELECTi_p;
        case NewTarget::SELECTFi:
            return NewTarget::SELECTFi_p;
        case NewTarget::CMPEQREG:
            return NewTarget::CMPEQREG_p;
        case NewTarget::CMPGEREG:
            return NewTarget::CMPGEREG_p;
        case NewTarget::CMPGEuREG:
            return NewTarget::CMPGEuREG_p;
        case NewTarget::CMPGTREG:
            return NewTarget::CMPGTREG_p;
        case NewTarget::CMPGTuREG:
            return NewTarget::CMPGTuREG_p;
        case NewTarget::CMPLEREG:
            return NewTarget::CMPLEREG_p;
        case NewTarget::CMPLEuREG:
            return NewTarget::CMPLEuREG_p;
        case NewTarget::CMPLTREG:
            return NewTarget::CMPLTREG_p;
        case NewTarget::CMPNEREG:
            return NewTarget::CMPNEREG_p;
        case NewTarget::CMPEQiREG:
            return NewTarget::CMPEQiREG;
        case NewTarget::CMPGEiREG:
            return NewTarget::CMPGEiREG_p;
        case NewTarget::CMPGEiuREG:
            return NewTarget::CMPGEiuREG_p;
        case NewTarget::CMPGTiREG:
            return NewTarget::CMPGTiREG_p;
        case NewTarget::CMPGTiuREG:
            return NewTarget::CMPGTiuREG_p;
        case NewTarget::CMPLEiREG:
            return NewTarget::CMPLEiREG_p;
        case NewTarget::CMPLEiuREG:
            return NewTarget::CMPLEiuREG_p;
        case NewTarget::CMPLTiREG:
            return NewTarget::CMPLTiREG_p;
        case NewTarget::CMPLTiuREG:
            return NewTarget::CMPLTiuREG_p;
        case NewTarget::CMPNEiREG:
            return NewTarget::CMPNEiREG_p;
        case NewTarget::CMPEQBR:
            return NewTarget::CMPEQBR_p;
        case NewTarget::CMPGEBR:
            return NewTarget::CMPGEBR_p;
        case NewTarget::CMPGEuBR:
            return NewTarget::CMPGEuBR_p;
        case NewTarget::CMPGTBR:
            return NewTarget::CMPGTBR_p;
        case NewTarget::CMPGTuBR:
            return NewTarget::CMPGTuBR_p;
        case NewTarget::CMPLEBR:
            return NewTarget::CMPLEBR_p;
        case NewTarget::CMPLEuBR:
            return NewTarget::CMPLEuBR_p;
        case NewTarget::CMPLTBR:
            return NewTarget::CMPLTBR_p;
        case NewTarget::CMPLTuBR:
            return NewTarget::CMPLTuBR_p;
        case NewTarget::CMPNEBR:
            return NewTarget::CMPNEBR_p;
        case NewTarget::CMPEQiBR:
            return NewTarget::CMPEQiBR_p;
        case NewTarget::CMPGEiBR:
            return NewTarget::CMPGEiBR_p;
        case NewTarget::CMPGEiuBR:
            return NewTarget::CMPGEiuBR_p;
        case NewTarget::CMPGTiBR:
            return NewTarget::CMPGTiBR_p;
        case NewTarget::CMPGTiuBR:
            return NewTarget::CMPGTiuBR_p;
        case NewTarget::CMPLEiBR:
            return NewTarget::CMPLEiBR_p;
        case NewTarget::CMPLEiuBR:
            return NewTarget::CMPLEiuBR_p;
        case NewTarget::CMPLTiBR:
            return NewTarget::CMPLTiBR_p;
        case NewTarget::CMPLTiuBR:
            return NewTarget::CMPLTiuBR_p;
        case NewTarget::CMPNEiBR:
            return NewTarget::CMPNEiBR_p;
        default:
            llvm_unreachable("unable to find predicated opcode");
    }

    return 0;
}

void NewTargetInstrInfo::buildPredicatedInstrCopy(MachineBasicBlock::instr_iterator &MI,
        MachineBasicBlock *MBB, MachineBasicBlock::instr_iterator &Iter) const {

    if (MI->isDebugValue()) return;
    if (MI->isLabel()) return;
    if (MI->isInlineAsm()) llvm_unreachable("cannot create a predicated copy of inline code");

    //MI->dump();
    unsigned predOpcode = getPredicatedOpcode(MI->getOpcode());
    

    MachineInstrBuilder MB;

    MB = BuildMI(*MBB->getParent(), MI->getDebugLoc(), get(predOpcode));

    MB->setFlags(MI->getFlags());
    // copy operands
    for (unsigned op = 0; op < MI->getNumOperands(); op++) {
        MB.addOperand(MI->getOperand(op));
    }


    MBB->insert(Iter, MB);

    if (MI->isBundledWithPred()) {
        MB->bundleWithPred();
    }

    //MB->dump();
}

void NewTargetInstrInfo::buildInstrCopy(MachineBasicBlock::instr_iterator &MI,
        MachineBasicBlock *MBB, MachineBasicBlock::instr_iterator &Iter) const {

    if (MI->isDebugValue()) return;
    if (MI->isLabel()) return;
    if (MI->isInlineAsm()) llvm_unreachable("cannot create a predicated copy of inline code");

    unsigned Opcode = MI->getOpcode();


    MachineInstrBuilder MB;

    MB = BuildMI(*MBB->getParent(), MI->getDebugLoc(), get(Opcode));

    MB->setFlags(MI->getFlags());
    // copy operands
    for (unsigned op = 0; op < MI->getNumOperands(); op++) {
        MB.addOperand(MI->getOperand(op));
    }


    MBB->insert(Iter, MB);

    if (MI->isBundledWithPred()) {
        MB->bundleWithPred();
    }

    //MB->dump();
}

unsigned NewTargetInstrInfo::GetInstSizeInBytes(const MachineInstr *MI) const {
    switch (MI->getOpcode()) {
        default:
            return MI->getDesc().getSize();
        case TargetOpcode::INLINEASM:
        { // Inline Asm: Variable size.
            const MachineFunction *MF = MI->getParent()->getParent();
            const char *AsmStr = MI->getOperand(0).getSymbolName();
            return getInlineAsmLength(AsmStr, *MF->getTarget().getMCAsmInfo());
        }
    }
}

DFAPacketizer *NewTargetInstrInfo::
CreateTargetScheduleState(const TargetMachine *TM,
        const ScheduleDAG *DAG) const {
    const InstrItineraryData *II = TM->getInstrItineraryData();
    return TM->getSubtarget<NewTargetGenSubtargetInfo>().createDFAPacketizer(II);
}

bool NewTargetInstrInfo::isSchedulingBoundary(const MachineInstr *MI,
        const MachineBasicBlock *MBB,
        const MachineFunction &MF) const {
    // Debug info is never a scheduling boundary. It's necessary to be explicit
    // due to the special treatment of IT instructions below, otherwise a
    // dbg_value followed by an IT will result in the IT instruction being
    // considered a scheduling hazard, which is wrong. It should be the actual
    // instruction preceding the dbg_value instruction(s), just like it is
    // when debug info is not present.
    if (MI->isDebugValue())
        return false;

    // Terminators and labels can't be scheduled around.
    if (MI->getDesc().isTerminator() || MI->isLabel() || MI->isInlineAsm())
        return true;

    return false;
}

unsigned NewTargetInstrInfo::GetMarReg() const {

    unsigned Reg;

    if (MarRegAlternator.val == false) {
        Reg = NewTarget::MAR1;
        MarRegAlternator.setTrue();
    } else {
        Reg = NewTarget::MAR2;
        MarRegAlternator.setFalse();
    }

    return Reg;
}

bool NewTargetInstrInfo::canInsertSelect(const MachineBasicBlock &MBB,
        const SmallVectorImpl<MachineOperand> &Cond,
        unsigned TrueReg, unsigned FalseReg,
        int &CondCycles,
        int &TrueCycles, int &FalseCycles) const {

    return false;
    // Check register classes.
    const MachineRegisterInfo &MRI = MBB.getParent()->getRegInfo();
    const TargetRegisterClass *RC =
            RI.getCommonSubClass(MRI.getRegClass(TrueReg), MRI.getRegClass(FalseReg));


    if (NewTarget::CPURegsRegClass.hasSubClassEq(RC)) {
        std::cout << "--canInsertSelect--\n";
        CondCycles = 2;
        TrueCycles = 2;
        FalseCycles = 2;
        return true;
    }


    return false;
}

void NewTargetInstrInfo::insertSelect(MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I, DebugLoc DL,
        unsigned DstReg,
        const SmallVectorImpl<MachineOperand> &Cond,
        unsigned TrueReg, unsigned FalseReg) const {

    std::cout << "++InsertSelect++\n";

    //MachineRegisterInfo &MRI = MBB.getParent()->getRegInfo();

    //std::cout << "size " << Cond.size() << "\n";

    assert(Cond.size() == 2 && "Invalid Cond array");
    // unsigned Opc = getCMovFromCond((X86::CondCode)Cond[0].getImm(),
    //                                MRI.getRegClass(DstReg)->getSize(),
    //                                false/*HasMemoryOperand*/);

    //unsigned Opc = NewTarget::SELECT;

    //BuildMI(MBB, I, DL, get(Opc), DstReg).addReg(FalseReg).addReg(TrueReg);


    unsigned ORL = NewTarget::ORLBR;
    unsigned SELECT = NewTarget::SELECT;

    unsigned BRFlag = NewTarget::BRFLAG1;
    //unsigned CondReg = I->getOperand(1).getReg();
    unsigned CondReg = Cond[1].getReg();

    if (!isCmpReg(I->getPrevNode(), CondReg)) {
        BuildMI(MBB, I, I->getDebugLoc(), get(ORL), BRFlag).addReg(CondReg).addReg(NewTarget::ZERO);
    } else {
        // optimize the case when the comparation instruction is immediately before de branch instruction.
        // we convert the instruction to generate results direcly on branch flag register br0 
        MachineBasicBlock::iterator IOld = I->getPrevNode();
        MachineOperand M1 = IOld->getOperand(1);
        MachineOperand M2 = IOld->getOperand(2);

        BuildMI(MBB, IOld, IOld->getDebugLoc(), get(cmpRegToFlag(IOld)), BRFlag).addOperand(M1).addOperand(M2);
        MBB.remove(IOld);
    }
    BuildMI(MBB, I, I->getDebugLoc(), get(SELECT), DstReg).addReg(BRFlag).addReg(TrueReg).addReg(FalseReg);

}
