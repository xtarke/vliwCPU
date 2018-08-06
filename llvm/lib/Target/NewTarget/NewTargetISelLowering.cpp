/*
 * NewTargetSelLowering.cpp
 *
 *  Created on: Mar 12, 2013
 *      Author: andreu
 */

//
#include <set>
#include <deque>
#include "InstPrinter/NewTargetInstPrinter.h"
#include "MCTargetDesc/NewTargetBaseInfo.h"
#include "NewTargetMachineFunction.h"
#include "NewTargetSubtarget.h"
#include "NewTargetMachine.h"
#include "NewTargetTargetObjectFile.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "NewTargetISelLowering.h"
#include <iostream>


using namespace llvm;

//===----------------------------------------------------------------------===//
//  Lower helper functions
//===----------------------------------------------------------------------===//

static SDValue LowerADDC_ADDE_SUBC_SUBE(SDValue Op, SelectionDAG &DAG) {
    EVT VT = Op.getNode()->getValueType(0);
    SDVTList VTs = DAG.getVTList(VT, MVT::i32);

    unsigned Opc;
    bool ExtraOp = false;
    switch (Op.getOpcode()) {
        default: llvm_unreachable("Invalid code");
        case ISD::ADDC: Opc = NewTargetISD::ADDC;
            break;
        case ISD::ADDE: Opc = NewTargetISD::ADDE;
            ExtraOp = true;
            break;
        case ISD::SUBC: Opc = NewTargetISD::SUBC;
            break;
        case ISD::SUBE: Opc = NewTargetISD::SUBE;
            ExtraOp = true;
            break;
    }

    //std::cout << "aquiiiiiiiiiiiiiiiiii---\n";

    //Op.dumpr();

    if (!ExtraOp)
        return DAG.getNode(Opc, Op->getDebugLoc(), VTs, Op.getOperand(0),
            Op.getOperand(1));
    return DAG.getNode(Opc, Op->getDebugLoc(), VTs, Op.getOperand(0),
            Op.getOperand(1), Op.getOperand(2));
}

static SDValue GetGlobalReg(SelectionDAG &DAG, EVT Ty) {
    NewTargetFunctionInfo *FI = DAG.getMachineFunction().getInfo<NewTargetFunctionInfo>();
    return DAG.getRegister(FI->getGlobalBaseReg(), Ty);
}

static SDValue getTargetNode(SDValue Op, SelectionDAG &DAG, unsigned Flag) {
    EVT Ty = Op.getValueType();

    if (GlobalAddressSDNode * N = dyn_cast<GlobalAddressSDNode>(Op))
        return DAG.getTargetGlobalAddress(N->getGlobal(), Op.getDebugLoc(), Ty, 0,
            Flag);
    if (ExternalSymbolSDNode * N = dyn_cast<ExternalSymbolSDNode>(Op))
        return DAG.getTargetExternalSymbol(N->getSymbol(), Ty, Flag);
    if (BlockAddressSDNode * N = dyn_cast<BlockAddressSDNode>(Op))
        return DAG.getTargetBlockAddress(N->getBlockAddress(), Ty, 0, Flag);
    if (JumpTableSDNode * N = dyn_cast<JumpTableSDNode>(Op))  
        return DAG.getTargetJumpTable(N->getIndex(), Ty, Flag);  
    if (ConstantPoolSDNode * N = dyn_cast<ConstantPoolSDNode>(Op))
        return DAG.getTargetConstantPool(N->getConstVal(), Ty, N->getAlignment(),
            N->getOffset(), Flag);

    llvm_unreachable("Unexpected node type.");
    return SDValue();
}

static SDValue getAddrNonPIC(SDValue Op, SelectionDAG &DAG) {

    DebugLoc DL = Op.getDebugLoc();
    EVT Ty = Op.getValueType();
    //SDValue Hi = getTargetNode(Op, DAG, NewTargetII::MO_ABS_HI);
    //SDValue Lo = getTargetNode(Op, DAG, NewTargetII::MO_ABS_LO);

    //SDValue node = DAG.getNode(ISD::ADD, DL, Ty,
    //                   DAG.getNode(NewTargetISD::Hi, DL, Ty, Hi),
    //                   DAG.getNode(NewTargetISD::Lo, DL, Ty, Lo))

    SDValue AbsAddr = getTargetNode(Op, DAG, NewTargetII::MO_ABS);
    SDValue node = DAG.getNode(NewTargetISD::Abs, DL, Ty, AbsAddr);

    return node;
}

static SDValue getAddrLocal(SDValue Op, SelectionDAG &DAG) {
    DebugLoc DL = Op.getDebugLoc();
    EVT Ty = Op.getValueType();
    unsigned GOTFlag = NewTargetII::MO_GOT;
    SDValue GOT = DAG.getNode(NewTargetISD::Wrapper, DL, Ty, GetGlobalReg(DAG, Ty),
            getTargetNode(Op, DAG, GOTFlag));
    SDValue Load = DAG.getLoad(Ty, DL, DAG.getEntryNode(), GOT,
            MachinePointerInfo::getGOT(), false, false, false,
            0);
    unsigned LoFlag = NewTargetII::MO_ABS_LO;
    SDValue Lo = DAG.getNode(NewTargetISD::Lo, DL, Ty, getTargetNode(Op, DAG, LoFlag));
    return DAG.getNode(ISD::ADD, DL, Ty, Load, Lo);
}

// AddLiveIn - This helper function adds the specified physical register to the
// MachineFunction as a live in value.  It also creates a corresponding
// virtual register for it.

static unsigned
AddLiveIn(MachineFunction &MF, unsigned PReg, const TargetRegisterClass *RC) {
    unsigned VReg = MF.getRegInfo().createVirtualRegister(RC);
    MF.getRegInfo().addLiveIn(PReg, VReg);
    return VReg;
}

static const uint16_t IntRegs[8] = {
    NewTarget::R16, NewTarget::R17, NewTarget::R18, NewTarget::R19,
    NewTarget::R20, NewTarget::R21, NewTarget::R22, NewTarget::R23
};

static const unsigned IntRegsSize = 8;

NewTargetTargetLowering::NewTargetTargetLowering(NewTargetMachine &tm) :
TargetLowering(tm, new NewTargetTargetObjectFile()),
Subtarget(*tm.getSubtargetImpl()) {

    TD = getDataLayout();

    setSchedulingPreference(Sched::VLIW);

    //std::cout << "NewTargetTargetLowering::NewTargetTargetLowering (ctor) partially implemented\n";

    // Set up the register classes
    addRegisterClass(MVT::i32, &NewTarget::CPURegsRegClass);
    //addRegisterClass(MVT::i1, &NewTarget::CPUPredRegsRegClass);

    setBooleanContents(ZeroOrOneBooleanContent);
    setBooleanVectorContents(ZeroOrOneBooleanContent); // FIXME: Is this correct?

    //AddPromotedToType(ISD::SETCC, MVT::i1, MVT::i32);

    // Load extented operations for i1 types must be promoted
    setLoadExtAction(ISD::EXTLOAD, MVT::i1, Promote);
    setLoadExtAction(ISD::ZEXTLOAD, MVT::i1, Promote);
    setLoadExtAction(ISD::SEXTLOAD, MVT::i1, Promote);

    // MIPS doesn't have extending float->double load/store
    setLoadExtAction(ISD::EXTLOAD, MVT::f32, Expand);
    setTruncStoreAction(MVT::f64, MVT::f32, Expand);

    // Used by legalize types to correctly generate the setcc result.
    // Without this, every float setcc comes with a AND/OR with the result,
    // we don't want this, since the fpcmp result goes to a flag register,
    // which is used implicitly by brcond and select operations.
    AddPromotedToType(ISD::SETCC, MVT::i1, MVT::i32);
    AddPromotedToType(ISD::SELECT, MVT::i1, MVT::i32);
    AddPromotedToType(ISD::SELECT_CC, MVT::i1, MVT::i32);
    AddPromotedToType(ISD::BRCOND, MVT::i1, MVT::i32);
    //setOperationAction(ISD::SELECT,               MVT::i1,   Custom);

    setOperationAction(ISD::TRUNCATE, MVT::i1, Expand);

    //setOperationAction(ISD::SELECT_CC, MVT::i32,   Custom);
    setOperationAction(ISD::SELECT_CC, MVT::i1, Promote);
    setOperationAction(ISD::SELECT, MVT::i32, Custom);
    setOperationAction(ISD::SELECT, MVT::i1, Promote);

    setOperationAction(ISD::SETCC, MVT::i32, Custom);
    setOperationAction(ISD::SETCC, MVT::i1, Promote);

    setOperationAction(ISD::GlobalAddress, MVT::i32, Custom);
    setOperationAction(ISD::BlockAddress, MVT::i32, Custom);
    //setOperationAction(ISD::BRCOND,             MVT::i1, Expand);
    setOperationAction(ISD::JumpTable, MVT::i32, Custom);


    setOperationAction(ISD::EH_RETURN, MVT::Other, Custom);
    setOperationAction(ISD::LOAD, MVT::i32, Custom);
    setOperationAction(ISD::STORE, MVT::i32, Custom);
    setOperationAction(ISD::ADD, MVT::i32, Custom);

    // Operations not directly supported by NewTarget.
    setOperationAction(ISD::BR_JT, MVT::Other, Expand);
    setOperationAction(ISD::BR_CC, MVT::Other, Expand);
    setOperationAction(ISD::SELECT_CC, MVT::Other, Expand);
    setOperationAction(ISD::CTPOP,             MVT::i32,   Expand);
    setOperationAction(ISD::CTPOP,             MVT::i64,   Expand);
    setOperationAction(ISD::CTLZ, MVT::i32, Expand);
    setOperationAction(ISD::CTLZ, MVT::i64, Expand);
    setOperationAction(ISD::CTTZ,              MVT::i32,   Expand);
    setOperationAction(ISD::CTTZ,              MVT::i64,   Expand);
    setOperationAction(ISD::CTTZ_ZERO_UNDEF,   MVT::i32,   Expand);
    setOperationAction(ISD::CTTZ_ZERO_UNDEF,   MVT::i64,   Expand);
    setOperationAction(ISD::CTLZ_ZERO_UNDEF,   MVT::i32,   Expand);
    setOperationAction(ISD::CTLZ_ZERO_UNDEF,   MVT::i64,   Expand);

    //AddPromotedToType(ISD::SETCC, MVT::i32, MVT::i1);

    //setOperationAction(ISD::UREM, MVT::i32, Expand);

    // setOperationAction(ISD::XOR, MVT::i1, Expand);

    //setTargetDAGCombine(ISD::ADDE);
    setOperationAction(ISD::ADDC, MVT::i32, Custom);
    setOperationAction(ISD::ADDE, MVT::i32, Custom);
    setOperationAction(ISD::SUBC, MVT::i32, Custom);
    setOperationAction(ISD::SUBE, MVT::i32, Custom);

    //-------------

    //setTargetDAGCombine(ISD::UDIVREM);
    //setTargetDAGCombine(ISD::SDIVREM);
    
    setOperationAction(ISD::UDIVREM, MVT::i32, Expand);
    setOperationAction(ISD::SDIVREM, MVT::i32, Expand);
    
    //setOperationAction(ISD::UREM, MVT::i32, Legal);
    //setOperationAction(ISD::SREM, MVT::i32, Custom);
    //setOperationAction(ISD::SDIV, MVT::i32, Custom);
    //setOperationAction(ISD::UDIV, MVT::i32, Custom);
    
    //------------------
    
    setTargetDAGCombine(ISD::ADD);

    setOperationAction(ISD::SHL_PARTS, MVT::i32, Custom);

    setOperationAction(ISD::ROTL, MVT::i32, Expand);
    setOperationAction(ISD::ROTR, MVT::i32, Expand);
    setOperationAction(ISD::ROTL, MVT::i64, Expand);
    setOperationAction(ISD::ROTR, MVT::i64, Expand);

    //setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i8,  Expand);
    setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i8, Expand);
    setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i16, Expand);

    setOperationAction(ISD::SRA_PARTS, MVT::i32, Custom);

    //setOperationAction(ISD::GlobalTLSAddress,   MVT::i32,   Custom);

    //setOperationAction(ISD::SDIV, MVT::i32, Expand);
    //setOperationAction(ISD::SREM, MVT::i32, Expand);
    //setOperationAction(ISD::UDIV, MVT::i32, Expand);
    //setOperationAction(ISD::UREM, MVT::i32, Expand);
    setOperationAction(ISD::SDIV, MVT::i64, Expand);
    setOperationAction(ISD::SREM, MVT::i64, Expand);
    setOperationAction(ISD::UDIV, MVT::i64, Expand);
    setOperationAction(ISD::UREM, MVT::i64, Expand);

    computeRegisterProperties();

}

// SelectMadd -
// Transforms a subgraph in CurDAG if the following pattern is found:
//  (addc multLo, Lo0), (adde multHi, Hi0),
// where,
//  multHi/Lo: product of multiplication
//  Lo0: initial value of Lo register
//  Hi0: initial value of Hi register
// Return true if pattern matching was successful.

static bool SelectMadd(SDNode *ADDENode, SelectionDAG *CurDAG) {

    llvm_unreachable("SelectMadd not implemented");
    // ADDENode's second operand must be a flag output of an ADDC node in order
    // for the matching to be successful.
    SDNode *ADDCNode = ADDENode->getOperand(2).getNode();

    if (ADDCNode->getOpcode() != ISD::ADDC)
        return false;

    SDValue MultHi = ADDENode->getOperand(0);
    SDValue MultLo = ADDCNode->getOperand(0);
    SDNode *MultNode = MultHi.getNode();
    unsigned MultOpc = MultHi.getOpcode();

    // MultHi and MultLo must be generated by the same node,
    if (MultLo.getNode() != MultNode)
        return false;

    // and it must be a multiplication.
    if (MultOpc != ISD::SMUL_LOHI && MultOpc != ISD::UMUL_LOHI)
        return false;

    // MultLo amd MultHi must be the first and second output of MultNode
    // respectively.
    if (MultHi.getResNo() != 1 || MultLo.getResNo() != 0)
        return false;

    // Transform this to a MADD only if ADDENode and ADDCNode are the only users
    // of the values of MultNode, in which case MultNode will be removed in later
    // phases.
    // If there exist users other than ADDENode or ADDCNode, this function returns
    // here, which will result in MultNode being mapped to a single MULT
    // instruction node rather than a pair of MULT and MADD instructions being
    // produced.
    if (!MultHi.hasOneUse() || !MultLo.hasOneUse())
        return false;

    SDValue Chain = CurDAG->getEntryNode();
    DebugLoc dl = ADDENode->getDebugLoc();

    // create MipsMAdd(u) node
    MultOpc = MultOpc == ISD::UMUL_LOHI ? NewTargetISD::MAddu : NewTargetISD::MAdd;

    SDValue MAdd = CurDAG->getNode(MultOpc, dl, MVT::Glue,
            MultNode->getOperand(0), // Factor 0
            MultNode->getOperand(1), // Factor 1
            ADDCNode->getOperand(1), // Lo0
            ADDENode->getOperand(1)); // Hi0

    // create CopyFromReg nodes
    SDValue CopyFromLo = CurDAG->getCopyFromReg(Chain, dl, NewTarget::LO, MVT::i32,
            MAdd);
    SDValue CopyFromHi = CurDAG->getCopyFromReg(CopyFromLo.getValue(1), dl,
            NewTarget::HI, MVT::i32,
            CopyFromLo.getValue(2));

    // replace uses of adde and addc here
    if (!SDValue(ADDCNode, 0).use_empty())
        CurDAG->ReplaceAllUsesOfValueWith(SDValue(ADDCNode, 0), CopyFromLo);

    if (!SDValue(ADDENode, 0).use_empty())
        CurDAG->ReplaceAllUsesOfValueWith(SDValue(ADDENode, 0), CopyFromHi);

    return true;
}

const char *NewTargetTargetLowering::getTargetNodeName(unsigned Opcode) const {
    switch (Opcode) {
        case NewTargetISD::JmpLink: return "NewTargetISD::JmpLink";
        case NewTargetISD::Ret: return "NewTargetISD::Ret";
        case NewTargetISD::MULT: return "NewTargetISD::MULT";
        case NewTargetISD::ADDC: return "NewTargetISD::ADDC";
        case NewTargetISD::ADDE: return "NewTargetISD::ADDE";
        case NewTargetISD::SUBC: return "NewTargetISD::SUBC";
        case NewTargetISD::SUBE: return "NewTargetISD::SUBE";
        default: return NULL;
    }
}

void
NewTargetTargetLowering::LowerOperationWrapper(SDNode *N,
        SmallVectorImpl<SDValue> &Results,
        SelectionDAG &DAG) const {

    //std::cout << "NewTargetTargetLowering::LowerOperationWrapper implemented :-)\n";

    SDValue Res = LowerOperation(SDValue(N, 0), DAG);

    for (unsigned I = 0, E = Res->getNumValues(); I != E; ++I)
        Results.push_back(Res.getValue(I));
}

void
NewTargetTargetLowering::ReplaceNodeResults(SDNode *N,
        SmallVectorImpl<SDValue> &Results,
        SelectionDAG &DAG) const {

    //std::cout << "NewTargetTargetLowering::ReplaceNodeResults implemented :-)\n";
    SDValue Res = LowerOperation(SDValue(N, 0), DAG);

    for (unsigned I = 0, E = Res->getNumValues(); I != E; ++I)
        Results.push_back(Res.getValue(I));
}

SDValue NewTargetTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const {
    //std::cout << "#################NewTargetTargetLowering::LowerOperation partially implemented\n";
    switch (Op.getOpcode()) {
        case ISD::BRCOND: return LowerBRCOND(Op, DAG);
            //case ISD::ConstantPool:       return LowerConstantPool(Op, DAG);
        case ISD::GlobalAddress: return LowerGlobalAddress(Op, DAG);
            //case ISD::BlockAddress:       return LowerBlockAddress(Op, DAG);
            //case ISD::GlobalTLSAddress:   return LowerGlobalTLSAddress(Op, DAG);
        case ISD::JumpTable: return LowerJumpTable(Op, DAG);
        case ISD::SELECT: return LowerSELECT(Op, DAG);
        case ISD::SELECT_CC: return LowerSELECT_CC(Op, DAG);
        case ISD::SETCC: return LowerSETCC(Op, DAG);
            //case ISD::VASTART:            return LowerVASTART(Op, DAG);
            //case ISD::FCOPYSIGN:          return LowerFCOPYSIGN(Op, DAG);
            //case ISD::FABS:               return LowerFABS(Op, DAG);
        case ISD::FRAMEADDR: return LowerFRAMEADDR(Op, DAG);
        case ISD::RETURNADDR: return LowerRETURNADDR(Op, DAG);
        case ISD::EH_RETURN: return LowerEH_RETURN(Op, DAG);
            //case ISD::MEMBARRIER:         return LowerMEMBARRIER(Op, DAG);
            //case ISD::ATOMIC_FENCE:       return LowerATOMIC_FENCE(Op, DAG);
        case ISD::SHL_PARTS: return LowerShiftLeftParts(Op, DAG);
        case ISD::SRA_PARTS: return LowerShiftRightParts(Op, DAG, true);
        case ISD::SRL_PARTS: return LowerShiftRightParts(Op, DAG, false);
        case ISD::LOAD: return LowerLOAD(Op, DAG);
        case ISD::STORE: return LowerSTORE(Op, DAG);
            // case ISD::INTRINSIC_WO_CHAIN: return LowerINTRINSIC_WO_CHAIN(Op, DAG);
            // case ISD::INTRINSIC_W_CHAIN:  return LowerINTRINSIC_W_CHAIN(Op, DAG);
        case ISD::ADD: return LowerADD(Op, DAG);
        case ISD::ADDC:
        case ISD::ADDE:
        case ISD::SUBC:
        case ISD::SUBE: return LowerADDC_ADDE_SUBC_SUBE(Op, DAG);
        default:
            Op.getNode()->dump();
            llvm_unreachable("cannot lower");
    }
    return SDValue();
}

SDValue NewTargetTargetLowering::LowerSETCC(SDValue Op, SelectionDAG &DAG) const {

    //std::cout << "SETCC\n"; 

    SDValue LHS = Op.getOperand(0);
    SDValue RHS = Op.getOperand(1);
    SDValue CC = Op.getOperand(2);
    DebugLoc dl = Op.getDebugLoc();

    SDValue Cond = DAG.getNode(ISD::SETCC, dl, MVT::i32, LHS, RHS, CC);

    //Cond.dump();

    return Cond;
}

SDValue NewTargetTargetLowering::
LowerSELECT(SDValue Op, SelectionDAG &DAG) const {

    //SDValue Cond = Op.getOperand(0);
    return Op;
}

SDValue
NewTargetTargetLowering::LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const {

    std::cout << "SELECT_CC\n";

    SDValue LHS = Op.getOperand(0);
    SDValue RHS = Op.getOperand(1);
    SDValue CC = Op.getOperand(4);
    SDValue TrueVal = Op.getOperand(2);
    SDValue FalseVal = Op.getOperand(3);
    DebugLoc dl = Op.getDebugLoc();
    SDNode* OpNode = Op.getNode();
    EVT SVT = OpNode->getValueType(0);

    SDValue Cond = DAG.getNode(ISD::SETCC, dl, MVT::i32, LHS, RHS, CC);
    return DAG.getNode(ISD::SELECT, dl, SVT, Cond, TrueVal, FalseVal);
}

SDValue NewTargetTargetLowering::
LowerBRCOND(SDValue Op, SelectionDAG &DAG) const {
    //std::cout << "NewTargetTargetLowering::LowerBRCOND under implementation\n";
    // The first operand is the chain, the second is the condition, the third is
    // the block to branch to if the condition is true.
    //SDValue Chain = Op.getOperand(0);
    //SDValue Dest = Op.getOperand(2);
    //DebugLoc dl = Op.getDebugLoc();

    std::cout << "NewTargetTargetLowering::LowerBRCOND under implementation\n";


    return Op;

    //return DAG.getNode(ISD::BRCOND, dl)
}

SDValue NewTargetTargetLowering::LowerADD(SDValue Op, SelectionDAG &DAG) const {
    if (Op->getOperand(0).getOpcode() != ISD::FRAMEADDR
            || cast<ConstantSDNode>
            (Op->getOperand(0).getOperand(0))->getZExtValue() != 0
            || Op->getOperand(1).getOpcode() != ISD::FRAME_TO_ARGS_OFFSET)
        return SDValue();

    // The pattern
    //   (add (frameaddr 0), (frame_to_args_offset))
    // results from lowering llvm.eh.dwarf.cfa intrinsic. Transform it to
    //   (add FrameObject, 0)
    // where FrameObject is a fixed StackObject with offset 0 which points to
    // the old stack pointer.
    MachineFrameInfo *MFI = DAG.getMachineFunction().getFrameInfo();
    EVT ValTy = Op->getValueType(0);
    int FI = MFI->CreateFixedObject(Op.getValueSizeInBits() / 8, 0, false);
    SDValue InArgsAddr = DAG.getFrameIndex(FI, ValTy);
    return DAG.getNode(ISD::ADD, Op->getDebugLoc(), ValTy, InArgsAddr,
            DAG.getConstant(0, ValTy));
}

//static SDValue CreateLoadLR(unsigned Opc, SelectionDAG &DAG, LoadSDNode *LD,
//        SDValue Chain, SDValue Src, unsigned Offset) {
//    SDValue Ptr = LD->getBasePtr();
//    EVT VT = LD->getValueType(0), MemVT = LD->getMemoryVT();
//    EVT BasePtrVT = Ptr.getValueType();
//    DebugLoc DL = LD->getDebugLoc();
//    SDVTList VTList = DAG.getVTList(VT, MVT::Other);
//
//    if (Offset)
//        Ptr = DAG.getNode(ISD::ADD, DL, BasePtrVT, Ptr,
//            DAG.getConstant(Offset, BasePtrVT));
//
//    SDValue Ops[] = {Chain, Ptr, Src};
//    return DAG.getMemIntrinsicNode(Opc, DL, VTList, Ops, 3, MemVT,
//            LD->getMemOperand());
//}

// Expand an unaligned 32 or 64-bit integer load node.

SDValue NewTargetTargetLowering::LowerLOAD(SDValue Op, SelectionDAG &DAG) const {
    LoadSDNode *LD = cast<LoadSDNode>(Op);
    EVT MemVT = LD->getMemoryVT();

    // Return if load is aligned or if MemVT is neither i32 nor i64.
    if ((LD->getAlignment() >= MemVT.getSizeInBits() / 8) ||
            ((MemVT != MVT::i32) && (MemVT != MVT::i64)))
        return SDValue();

    llvm_unreachable("cannot generate code for this");

    return SDValue();
}

//static SDValue CreateStoreLR(unsigned Opc, SelectionDAG &DAG, StoreSDNode *SD,
//        SDValue Chain, unsigned Offset) {
//    SDValue Ptr = SD->getBasePtr(), Value = SD->getValue();
//    EVT MemVT = SD->getMemoryVT(), BasePtrVT = Ptr.getValueType();
//    DebugLoc DL = SD->getDebugLoc();
//    SDVTList VTList = DAG.getVTList(MVT::Other);

//    if (Offset)
//        Ptr = DAG.getNode(ISD::ADD, DL, BasePtrVT, Ptr,
//            DAG.getConstant(Offset, BasePtrVT));

//    SDValue Ops[] = {Chain, Value, Ptr};
//    return DAG.getMemIntrinsicNode(Opc, DL, VTList, Ops, 3, MemVT,
//            SD->getMemOperand());
//}

// Expand an unaligned 32 or 64-bit integer store node.

SDValue NewTargetTargetLowering::LowerSTORE(SDValue Op, SelectionDAG &DAG) const {
    StoreSDNode *SD = cast<StoreSDNode>(Op);
    EVT MemVT = SD->getMemoryVT();

    // Return if store is aligned or if MemVT is neither i32 nor i64.
    if ((SD->getAlignment() >= MemVT.getSizeInBits() / 8) ||
            ((MemVT != MVT::i32) && (MemVT != MVT::i64)))
        return SDValue();

    SDValue Value = SD->getValue();
    EVT VT = Value.getValueType();

    if ((VT == MVT::i32) || SD->isTruncatingStore()) {
        llvm_unreachable("Truncating store not supported");
    }

    if (VT == MVT::i64) {
        llvm_unreachable("Store of MVT::i64 not supported");
    }

    return SDValue();
}

unsigned NewTargetTargetLowering::getJumpTableEncoding() const {
    //std::cout << "NewTargetTargetLowering::getJumpTableEncoding\n";  

    return TargetLowering::getJumpTableEncoding();
}

//===----------------------------------------------------------------------===//
//                      Calling Convention Implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// TODO: Implement a generic logic using tblgen that can support this.
// Mips O32 ABI rules:
// ---
// i32 - Passed in A0, A1, A2, A3 and stack
// f32 - Only passed in f32 registers if no int reg has been used yet to hold
//       an argument. Otherwise, passed in A1, A2, A3 and stack.
// f64 - Only passed in two aliased f32 registers if no int reg has been used
//       yet to hold an argument. Otherwise, use A2, A3 and stack. If A1 is
//       not used, it must be shadowed. If only A3 is avaiable, shadow it and
//       go to stack.
//
//  For vararg functions, all arguments are passed in A0, A1, A2, A3 and stack.
//===----------------------------------------------------------------------===//

static bool CC_NewTargetCC(unsigned ValNo, MVT ValVT,
        MVT LocVT, CCValAssign::LocInfo LocInfo,
        ISD::ArgFlagsTy ArgFlags, CCState &State) {

    //static const unsigned IntRegsSize=4, FloatRegsSize=2;

    static const uint16_t IntRegs[] = {
        NewTarget::R16, NewTarget::R17, NewTarget::R18, NewTarget::R19,
        NewTarget::R20, NewTarget::R21, NewTarget::R22, NewTarget::R23
    };

    // Do not process byval args here.
    if (ArgFlags.isByVal())
        return true;

    // Promote i8 and i16
    if (LocVT == MVT::i8 || LocVT == MVT::i16) {
        LocVT = MVT::i32;
        if (ArgFlags.isSExt())
            LocInfo = CCValAssign::SExt;
        else if (ArgFlags.isZExt())
            LocInfo = CCValAssign::ZExt;
        else
            LocInfo = CCValAssign::AExt;
    }

    unsigned Reg = 0;

    unsigned OrigAlign = ArgFlags.getOrigAlign();

    if (ValVT == MVT::i32) {
        Reg = State.AllocateReg(IntRegs, IntRegsSize);
        LocVT = MVT::i32;
    }

    if (!Reg) {
        unsigned Offset = State.AllocateStack(ValVT.getSizeInBits() >> 3,
                OrigAlign);
        State.addLoc(CCValAssign::getMem(ValNo, ValVT, Offset, LocVT, LocInfo));
    } else
        State.addLoc(CCValAssign::getReg(ValNo, ValVT, Reg, LocVT, LocInfo));

    return false;
}

#include "NewTargetGenCallingConv.inc"

//===----------------------------------------------------------------------===//
//                  Call Calling Convention Implementation
//===----------------------------------------------------------------------===//

SDValue
NewTargetTargetLowering::passArgOnStack(SDValue StackPtr, unsigned Offset,
        SDValue Chain, SDValue Arg, DebugLoc DL,
        bool IsTailCall, SelectionDAG &DAG) const {
    if (!IsTailCall) {
        SDValue PtrOff = DAG.getNode(ISD::ADD, DL, getPointerTy(), StackPtr,
                DAG.getIntPtrConstant(Offset));
        return DAG.getStore(Chain, DL, Arg, PtrOff, MachinePointerInfo(), false,
                false, 0);
    }

    MachineFrameInfo *MFI = DAG.getMachineFunction().getFrameInfo();
    int FI = MFI->CreateFixedObject(Arg.getValueSizeInBits() / 8, Offset, false);
    SDValue FIN = DAG.getFrameIndex(FI, getPointerTy());
    return DAG.getStore(Chain, DL, Arg, FIN, MachinePointerInfo(),
            /*isVolatile=*/ true, false, 0);
}

NewTargetTargetLowering::NewTargetCC::NewTargetCC(CallingConv::ID CC,
        CCState &Info)
: CCInfo(Info), CallConv(CC) {
    // Pre-allocate reserved argument area.
    CCInfo.AllocateStack(reservedArgArea(), 1);
}

void NewTargetTargetLowering::NewTargetCC::
analyzeCallOperands(const SmallVectorImpl<ISD::OutputArg> &Args,
        bool IsVarArg) {
    assert((CallConv != CallingConv::Fast || !IsVarArg) &&
            "CallingConv::Fast shouldn't be used for vararg functions.");

    unsigned NumOpnds = Args.size();
    llvm::CCAssignFn *FixedFn = fixedArgFn(), *VarFn = varArgFn();

    for (unsigned I = 0; I != NumOpnds; ++I) {
        MVT ArgVT = Args[I].VT;
        ISD::ArgFlagsTy ArgFlags = Args[I].Flags;
        bool R;

        if (ArgFlags.isByVal()) {
            handleByValArg(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags);
            continue;
        }

        if (IsVarArg && !Args[I].IsFixed)
            R = VarFn(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags, CCInfo);
        else
            R = FixedFn(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags, CCInfo);

        if (R) {
#ifndef NDEBUG
            dbgs() << "Call operand #" << I << " has unhandled type "
                    << EVT(ArgVT).getEVTString();
#endif
            llvm_unreachable(0);
        }
    }
}

void NewTargetTargetLowering::NewTargetCC::
analyzeFormalArguments(const SmallVectorImpl<ISD::InputArg> &Args) {
    unsigned NumArgs = Args.size();
    llvm::CCAssignFn *FixedFn = fixedArgFn();

    for (unsigned I = 0; I != NumArgs; ++I) {
        MVT ArgVT = Args[I].VT;
        ISD::ArgFlagsTy ArgFlags = Args[I].Flags;

        if (ArgFlags.isByVal()) {
            handleByValArg(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags);
            continue;
        }

        if (!FixedFn(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags, CCInfo))
            continue;

#ifndef NDEBUG
        dbgs() << "Formal Arg #" << I << " has unhandled type "
                << EVT(ArgVT).getEVTString();
#endif
        llvm_unreachable(0);
    }
}

void
NewTargetTargetLowering::NewTargetCC::handleByValArg(unsigned ValNo, MVT ValVT,
        MVT LocVT,
        CCValAssign::LocInfo LocInfo,
        ISD::ArgFlagsTy ArgFlags) {
    assert(ArgFlags.getByValSize() && "Byval argument's size shouldn't be 0.");

    struct ByValArgInfo ByVal;
    unsigned RegSize = regSize();
    unsigned ByValSize = RoundUpToAlignment(ArgFlags.getByValSize(), RegSize);
    unsigned Align = std::min(std::max(ArgFlags.getByValAlign(), RegSize),
            RegSize * 2);

    if (useRegsForByval())
        allocateRegs(ByVal, ByValSize, Align);

    // Allocate space on caller's stack.
    ByVal.Address = CCInfo.AllocateStack(ByValSize - RegSize * ByVal.NumRegs,
            Align);
    CCInfo.addLoc(CCValAssign::getMem(ValNo, ValVT, ByVal.Address, LocVT,
            LocInfo));
    ByValArgs.push_back(ByVal);
}

unsigned NewTargetTargetLowering::NewTargetCC::numIntArgRegs() const {
    return array_lengthof(IntRegs);
}

unsigned NewTargetTargetLowering::NewTargetCC::reservedArgArea() const {
    return (CallConv != CallingConv::Fast) ? 16 : 0;
}

const uint16_t *NewTargetTargetLowering::NewTargetCC::intArgRegs() const {
    return IntRegs;
}

llvm::CCAssignFn *NewTargetTargetLowering::NewTargetCC::fixedArgFn() const {
    // if (CallConv == CallingConv::Fast)
    //   return CC_Mips_FastCC;

    return CC_NewTargetCC;
}

llvm::CCAssignFn *NewTargetTargetLowering::NewTargetCC::varArgFn() const {
    return CC_NewTargetCC;
}

const uint16_t *NewTargetTargetLowering::NewTargetCC::shadowRegs() const {
    return IntRegs;
}

void NewTargetTargetLowering::NewTargetCC::allocateRegs(ByValArgInfo &ByVal,
        unsigned ByValSize,
        unsigned Align) {
    unsigned RegSize = regSize(), NumIntArgRegs = numIntArgRegs();
    const uint16_t *IntArgRegs = intArgRegs(), *ShadowRegs = shadowRegs();
    assert(!(ByValSize % RegSize) && !(Align % RegSize) &&
            "Byval argument's size and alignment should be a multiple of"
            "RegSize.");

    ByVal.FirstIdx = CCInfo.getFirstUnallocated(IntArgRegs, NumIntArgRegs);

    // If Align > RegSize, the first arg register must be even.
    if ((Align > RegSize) && (ByVal.FirstIdx % 2)) {
        CCInfo.AllocateReg(IntArgRegs[ByVal.FirstIdx], ShadowRegs[ByVal.FirstIdx]);
        ++ByVal.FirstIdx;
    }

    // Mark the registers allocated.
    for (unsigned I = ByVal.FirstIdx; ByValSize && (I < NumIntArgRegs);
            ByValSize -= RegSize, ++I, ++ByVal.NumRegs)
        CCInfo.AllocateReg(IntArgRegs[I], ShadowRegs[I]);
}

void NewTargetTargetLowering::
copyByValRegs(SDValue Chain, DebugLoc DL, std::vector<SDValue> &OutChains,
        SelectionDAG &DAG, const ISD::ArgFlagsTy &Flags,
        SmallVectorImpl<SDValue> &InVals, const Argument *FuncArg,
        const NewTargetCC &CC, const ByValArgInfo &ByVal) const {

    //std::cout << "NewTargetTargetLowering::copyByValRegs ??\n";

    MachineFunction &MF = DAG.getMachineFunction();
    MachineFrameInfo *MFI = MF.getFrameInfo();
    unsigned RegAreaSize = ByVal.NumRegs * CC.regSize();
    unsigned FrameObjSize = std::max(Flags.getByValSize(), RegAreaSize);
    int FrameObjOffset;

    if (RegAreaSize)
        FrameObjOffset = (int) CC.reservedArgArea() -
        (int) ((CC.numIntArgRegs() - ByVal.FirstIdx) * CC.regSize());
    else
        FrameObjOffset = ByVal.Address;

    // Create frame object.
    EVT PtrTy = getPointerTy();
    int FI = MFI->CreateFixedObject(FrameObjSize, FrameObjOffset, true);
    SDValue FIN = DAG.getFrameIndex(FI, PtrTy);
    InVals.push_back(FIN);

    if (!ByVal.NumRegs)
        return;

    // Copy arg registers.
    MVT RegTy = MVT::getIntegerVT(CC.regSize() * 8);
    const TargetRegisterClass *RC = getRegClassFor(RegTy);

    for (unsigned I = 0; I < ByVal.NumRegs; ++I) {
        unsigned ArgReg = CC.intArgRegs()[ByVal.FirstIdx + I];
        unsigned VReg = AddLiveIn(MF, ArgReg, RC);
        unsigned Offset = I * CC.regSize();
        SDValue StorePtr = DAG.getNode(ISD::ADD, DL, PtrTy, FIN,
                DAG.getConstant(Offset, PtrTy));
        SDValue Store = DAG.getStore(Chain, DL, DAG.getRegister(VReg, RegTy),
                StorePtr, MachinePointerInfo(FuncArg, Offset),
                false, false, 0);
        OutChains.push_back(Store);
    }
}

// Copy byVal arg to registers and stack.

void NewTargetTargetLowering::
passByValArg(SDValue Chain, DebugLoc DL,
        std::deque< std::pair<unsigned, SDValue> > &RegsToPass,
        SmallVector<SDValue, 8> &MemOpChains, SDValue StackPtr,
        MachineFrameInfo *MFI, SelectionDAG &DAG, SDValue Arg,
        const NewTargetCC &CC, const ByValArgInfo &ByVal,
        const ISD::ArgFlagsTy &Flags, bool isLittle) const {
    unsigned ByValSize = Flags.getByValSize();
    unsigned Offset = 0; // Offset in # of bytes from the beginning of struct.
    unsigned RegSize = CC.regSize();
    unsigned Alignment = std::min(Flags.getByValAlign(), RegSize);
    EVT PtrTy = getPointerTy(), RegTy = MVT::getIntegerVT(RegSize * 8);

    //Arg.dumpr();
    //llvm_unreachable("");
    if (ByVal.NumRegs) {
        const uint16_t *ArgRegs = CC.intArgRegs();
        bool LeftoverBytes = (ByVal.NumRegs * RegSize > ByValSize);
        unsigned I = 0;

        // Copy words to registers.
        for (; I < ByVal.NumRegs - LeftoverBytes; ++I, Offset += RegSize) {
            SDValue LoadPtr = DAG.getNode(ISD::ADD, DL, PtrTy, Arg,
                    DAG.getConstant(Offset, PtrTy));
            SDValue LoadVal = DAG.getLoad(RegTy, DL, Chain, LoadPtr,
                    MachinePointerInfo(), false, false, false,
                    Alignment);
            MemOpChains.push_back(LoadVal.getValue(1));
            unsigned ArgReg = ArgRegs[ByVal.FirstIdx + I];
            RegsToPass.push_back(std::make_pair(ArgReg, LoadVal));
        }

        // Return if the struct has been fully copied.
        if (ByValSize == Offset)
            return;

        // Copy the remainder of the byval argument with sub-word loads and shifts.
        if (LeftoverBytes) {
            assert((ByValSize > Offset) && (ByValSize < Offset + RegSize) &&
                    "Size of the remainder should be smaller than RegSize.");
            SDValue Val;

            for (unsigned LoadSize = RegSize / 2, TotalSizeLoaded = 0;
                    Offset < ByValSize; LoadSize /= 2) {
                unsigned RemSize = ByValSize - Offset;

                if (RemSize < LoadSize)
                    continue;

                // Load subword.
                SDValue LoadPtr = DAG.getNode(ISD::ADD, DL, PtrTy, Arg,
                        DAG.getConstant(Offset, PtrTy));
                SDValue LoadVal =
                        DAG.getExtLoad(ISD::ZEXTLOAD, DL, RegTy, Chain, LoadPtr,
                        MachinePointerInfo(), MVT::getIntegerVT(LoadSize * 8),
                        false, false, Alignment);
                MemOpChains.push_back(LoadVal.getValue(1));

                // Shift the loaded value.
                unsigned Shamt;

                if (isLittle)
                    Shamt = TotalSizeLoaded;
                else
                    Shamt = (RegSize - (TotalSizeLoaded + LoadSize)) * 8;

                SDValue Shift = DAG.getNode(ISD::SHL, DL, RegTy, LoadVal,
                        DAG.getConstant(Shamt, MVT::i32));

                if (Val.getNode())
                    Val = DAG.getNode(ISD::OR, DL, RegTy, Val, Shift);
                else
                    Val = Shift;

                Offset += LoadSize;
                TotalSizeLoaded += LoadSize;
                Alignment = std::min(Alignment, LoadSize);
            }

            unsigned ArgReg = ArgRegs[ByVal.FirstIdx + I];
            RegsToPass.push_back(std::make_pair(ArgReg, Val));
            return;
        }
    }
    // Copy remainder of byval arg to it with memcpy.
    unsigned MemCpySize = ByValSize - Offset;
    SDValue Src = DAG.getNode(ISD::ADD, DL, PtrTy, Arg,
            DAG.getConstant(Offset, PtrTy));
    SDValue Dst = DAG.getNode(ISD::ADD, DL, PtrTy, StackPtr,
            DAG.getIntPtrConstant(ByVal.Address));
    Chain = DAG.getMemcpy(Chain, DL, Dst, Src,
            DAG.getConstant(MemCpySize, PtrTy), Alignment,
            /*isVolatile=*/false, /*AlwaysInline=*/false,
            MachinePointerInfo(0), MachinePointerInfo(0));
    MemOpChains.push_back(Chain);
}

void
NewTargetTargetLowering::writeVarArgRegs(std::vector<SDValue> &OutChains,
        const NewTargetCC &CC, SDValue Chain,
        DebugLoc DL, SelectionDAG &DAG) const {
    unsigned NumRegs = CC.numIntArgRegs();
    const uint16_t *ArgRegs = CC.intArgRegs();
    const CCState &CCInfo = CC.getCCInfo();
    unsigned Idx = CCInfo.getFirstUnallocated(ArgRegs, NumRegs);
    unsigned RegSize = CC.regSize();
    MVT RegTy = MVT::getIntegerVT(RegSize * 8);
    const TargetRegisterClass *RC = getRegClassFor(RegTy);
    MachineFunction &MF = DAG.getMachineFunction();
    MachineFrameInfo *MFI = MF.getFrameInfo();
    NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();

    // Offset of the first variable argument from stack pointer.
    int VaArgOffset;

    if (NumRegs == Idx)
        VaArgOffset = RoundUpToAlignment(CCInfo.getNextStackOffset(), RegSize);
    else
        VaArgOffset =
            (int) CC.reservedArgArea() - (int) (RegSize * (NumRegs - Idx));

    // Record the frame index of the first variable argument
    // which is a value necessary to VASTART.
    int FI = MFI->CreateFixedObject(RegSize, VaArgOffset, true);
    NewTargetFI->setVarArgsFrameIndex(FI);

    // Copy the integer registers that have not been used for argument passing
    // to the argument register save area. For O32, the save area is allocated
    // in the caller's stack frame, while for N32/64, it is allocated in the
    // callee's stack frame.
    for (unsigned I = Idx; I < NumRegs; ++I, VaArgOffset += RegSize) {
        unsigned Reg = AddLiveIn(MF, ArgRegs[I], RC);
        SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, Reg, RegTy);
        FI = MFI->CreateFixedObject(RegSize, VaArgOffset, true);
        SDValue PtrOff = DAG.getFrameIndex(FI, getPointerTy());
        SDValue Store = DAG.getStore(Chain, DL, ArgValue, PtrOff,
                MachinePointerInfo(), false, false, 0);
        cast<StoreSDNode>(Store.getNode())->getMemOperand()->setValue(0);
        OutChains.push_back(Store);
    }
}

SDValue
NewTargetTargetLowering::LowerFormalArguments(SDValue Chain,
        CallingConv::ID CallConv,
        bool isVarArg,
        const SmallVectorImpl<ISD::InputArg> &Ins,
        DebugLoc dl, SelectionDAG &DAG,
        SmallVectorImpl<SDValue> &InVals)
const {
    //std::cout << "NewTargetTargetLowering::LowerFormalArguments not implemented\n";

    MachineFunction &MF = DAG.getMachineFunction();
    MachineFrameInfo *MFI = MF.getFrameInfo();
    NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();

    NewTargetFI->setVarArgsFrameIndex(0);

    // Used with vargs to acumulate store chains.
    std::vector<SDValue> OutChains;

    // Assign locations to all of the incoming arguments.
    SmallVector<CCValAssign, 16> ArgLocs;
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
            getTargetMachine(), ArgLocs, *DAG.getContext());
    NewTargetCC NewTargetCCInfo(CallConv, CCInfo);

    NewTargetCCInfo.analyzeFormalArguments(Ins);
    NewTargetFI->setFormalArgInfo(CCInfo.getNextStackOffset(),
            NewTargetCCInfo.hasByValArg());

    Function::const_arg_iterator FuncArg =
            DAG.getMachineFunction().getFunction()->arg_begin();
    unsigned CurArgIdx = 0;
    NewTargetCC::byval_iterator ByValArg = NewTargetCCInfo.byval_begin();

    for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
        CCValAssign &VA = ArgLocs[i];
        std::advance(FuncArg, Ins[i].OrigArgIndex - CurArgIdx);
        CurArgIdx = Ins[i].OrigArgIndex;
        EVT ValVT = VA.getValVT();
        ISD::ArgFlagsTy Flags = Ins[i].Flags;
        bool IsRegLoc = VA.isRegLoc();

        if (Flags.isByVal()) {
            assert(Flags.getByValSize() &&
                    "ByVal args of size 0 should have been ignored by front-end.");
            assert(ByValArg != NewTargetCCInfo.byval_end());
            copyByValRegs(Chain, dl, OutChains, DAG, Flags, InVals, &*FuncArg,
                    NewTargetCCInfo, *ByValArg);
            ++ByValArg;
            continue;
        }

        // Arguments stored on registers
        if (IsRegLoc) {
            EVT RegVT = VA.getLocVT();
            unsigned ArgReg = VA.getLocReg();
            const TargetRegisterClass *RC;

            if (RegVT == MVT::i32)
                RC = &NewTarget::CPURegsRegClass;
            else
                llvm_unreachable("RegVT not supported by FormalArguments Lowering");

            // Transform the arguments stored on
            // physical registers into virtual ones
            unsigned Reg = AddLiveIn(DAG.getMachineFunction(), ArgReg, RC);
            SDValue ArgValue = DAG.getCopyFromReg(Chain, dl, Reg, RegVT);

            // If this is an 8 or 16-bit value, it has been passed promoted
            // to 32 bits.  Insert an assert[sz]ext to capture this, then
            // truncate to the right size.
            if (VA.getLocInfo() != CCValAssign::Full) {
                unsigned Opcode = 0;
                if (VA.getLocInfo() == CCValAssign::SExt)
                    Opcode = ISD::AssertSext;
                else if (VA.getLocInfo() == CCValAssign::ZExt)
                    Opcode = ISD::AssertZext;
                if (Opcode)
                    ArgValue = DAG.getNode(Opcode, dl, RegVT, ArgValue,
                        DAG.getValueType(ValVT));
                ArgValue = DAG.getNode(ISD::TRUNCATE, dl, ValVT, ArgValue);
            }

            InVals.push_back(ArgValue);
        } else { // VA.isRegLoc()

            // sanity check
            assert(VA.isMemLoc());

            // The stack pointer offset is relative to the caller stack frame.
            int FI = MFI->CreateFixedObject(ValVT.getSizeInBits() / 8,
                    VA.getLocMemOffset(), true);

            // Create load nodes to retrieve arguments from the stack
            SDValue FIN = DAG.getFrameIndex(FI, getPointerTy());
            InVals.push_back(DAG.getLoad(ValVT, dl, Chain, FIN,
                    MachinePointerInfo::getFixedStack(FI),
                    false, false, false, 0));
        }
    }

    // The mips ABIs for returning structs by value requires that we copy
    // the sret argument into $v0 for the return. Save the argument into
    // a virtual register so that we can access it from the return points.
    if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
        unsigned Reg = NewTargetFI->getSRetReturnReg();
        if (!Reg) {
            Reg = MF.getRegInfo().
                    createVirtualRegister(getRegClassFor(MVT::i32));
            NewTargetFI->setSRetReturnReg(Reg);
        }
        SDValue Copy = DAG.getCopyToReg(DAG.getEntryNode(), dl, Reg, InVals[0]);
        Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, Copy, Chain);
    }

    if (isVarArg)
        writeVarArgRegs(OutChains, NewTargetCCInfo, Chain, dl, DAG);

    // All stores are grouped in one node to allow the matching between
    // the size of Ins and InVals. This only happens when on varg functions
    if (!OutChains.empty()) {
        OutChains.push_back(Chain);
        Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other,
                &OutChains[0], OutChains.size());
    }

    return Chain;
}

/// LowerCall - functions arguments are copied from virtual regs to
/// (physical regs)/(stack frame), CALLSEQ_START and CALLSEQ_END are emitted.

SDValue
NewTargetTargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
        SmallVectorImpl<SDValue> &InVals) const {

    //std::cout << "NewTargetTargetLowering::LowerCall partially implemented\n";

    SelectionDAG &DAG = CLI.DAG;
    DebugLoc &dl = CLI.DL;
    SmallVector<ISD::OutputArg, 32> &Outs = CLI.Outs;
    SmallVector<SDValue, 32> &OutVals = CLI.OutVals;
    SmallVector<ISD::InputArg, 32> &Ins = CLI.Ins;
    SDValue Chain = CLI.Chain;
    SDValue Callee = CLI.Callee;
    bool &isTailCall = CLI.IsTailCall;
    CallingConv::ID CallConv = CLI.CallConv;
    bool isVarArg = CLI.IsVarArg;

    MachineFunction &MF = DAG.getMachineFunction();
    MachineFrameInfo *MFI = MF.getFrameInfo();
    const TargetFrameLowering *TFL = MF.getTarget().getFrameLowering();
    bool IsPIC = getTargetMachine().getRelocationModel() == Reloc::PIC_;


    if (isTailCall) {
        std::cout << "NewTargetTargetLowering::LowerCall-> tail call not supported\n";
        isTailCall = false;
    }

    // Analyze operands of the call, assigning locations to each operand.
    SmallVector<CCValAssign, 16> ArgLocs;

    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
            getTargetMachine(), ArgLocs, *DAG.getContext());

    NewTargetCC NewTargetCCInfo(CallConv, CCInfo);

    NewTargetCCInfo.analyzeCallOperands(Outs, isVarArg);

    // Get a count of how many bytes are to be pushed on the stack.
    unsigned NextStackOffset = CCInfo.getNextStackOffset();

    // Chain is the output chain of the last Load/Store or CopyToReg node.
    // ByValChain is the output chain of the last Memcpy node created for copying
    // byval arguments to the stack.
    unsigned StackAlignment = TFL->getStackAlignment();
    NextStackOffset = RoundUpToAlignment(NextStackOffset, StackAlignment);
    SDValue NextStackOffsetVal = DAG.getIntPtrConstant(NextStackOffset, true);

    if (!isTailCall)
        Chain = DAG.getCALLSEQ_START(Chain, NextStackOffsetVal);

    SDValue StackPtr = DAG.getCopyFromReg(Chain, dl,
            NewTarget::SP,
            getPointerTy());

    // With EABI is it possible to have 16 args on registers.
    std::deque< std::pair<unsigned, SDValue> > RegsToPass;
    SmallVector<SDValue, 8> MemOpChains;
    NewTargetCC::byval_iterator ByValArg = NewTargetCCInfo.byval_begin();


    // Walk the register/memloc assignments, inserting copies/loads.
    for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
        SDValue Arg = OutVals[i];
        CCValAssign &VA = ArgLocs[i];
        MVT LocVT = VA.getLocVT();
        ISD::ArgFlagsTy Flags = Outs[i].Flags;

        // ByVal Arg.
        if (Flags.isByVal()) {
            assert(Flags.getByValSize() &&
                    "ByVal args of size 0 should have been ignored by front-end.");
            assert(ByValArg != NewTargetCCInfo.byval_end());
            assert(!isTailCall &&
                    "Do not tail-call optimize if there is a byval argument.");
            passByValArg(Chain, dl, RegsToPass, MemOpChains, StackPtr, MFI, DAG, Arg,
                    NewTargetCCInfo, *ByValArg, Flags, false);
            ++ByValArg;
            continue;
        }
        // Promote the value if needed.
        switch (VA.getLocInfo()) {
            default: llvm_unreachable("Unknown loc info!");
            case CCValAssign::Full:
                if (VA.isRegLoc()) {

                }
                break;
            case CCValAssign::SExt:
                Arg = DAG.getNode(ISD::SIGN_EXTEND, dl, LocVT, Arg);
                break;
            case CCValAssign::ZExt:
                Arg = DAG.getNode(ISD::ZERO_EXTEND, dl, LocVT, Arg);
                break;
            case CCValAssign::AExt:
                Arg = DAG.getNode(ISD::ANY_EXTEND, dl, LocVT, Arg);
                break;
        }
        // Arguments that can be passed on register must be kept at
        // RegsToPass vector
        if (VA.isRegLoc()) {
            RegsToPass.push_back(std::make_pair(VA.getLocReg(), Arg));
            continue;
        }

        // Register can't get to this point...
        assert(VA.isMemLoc());

        // emit ISD::STORE whichs stores the
        // parameter value to a stack Location
        MemOpChains.push_back(passArgOnStack(StackPtr, VA.getLocMemOffset(),
                Chain, Arg, dl, isTailCall, DAG));
    }

    // Transform all store nodes into one single node because all store
    // nodes are independent of each other.
    if (!MemOpChains.empty())
        Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other,
            &MemOpChains[0], MemOpChains.size());

    // If the callee is a GlobalAddress/ExternalSymbol node (quite common, every
    // direct call is) turn it into a TargetGlobalAddress/TargetExternalSymbol
    // node so that legalize doesn't hack it.
    bool IsPICCall = (IsPIC); // true if calls are translated to jalr $25
    bool GlobalOrExternal = false, InternalLinkage = false;
    SDValue CalleeLo;

    if (GlobalAddressSDNode * G = dyn_cast<GlobalAddressSDNode>(Callee)) {
        if (IsPICCall) {
            InternalLinkage = G->getGlobal()->hasInternalLinkage();
            //std::cout << "NewTargetTargetLowering::LowerCall-> IsPICCall\n";
            //if (InternalLinkage)
            //Callee = getAddrLocal(Callee, DAG, HasMips64);
            //else if (LargeGOT)
            //Callee = getAddrGlobalLargeGOT(Callee, DAG, MipsII::MO_CALL_HI16,
            //                              MipsII::MO_CALL_LO16);
            //else
            //Callee = getAddrGlobal(Callee, DAG, MipsII::MO_GOT_CALL);
        } else {
            //std::cout << "NewTargetTargetLowering::LowerCall-> !IsPICCall\n";
            Callee = DAG.getTargetGlobalAddress(G->getGlobal(), dl, getPointerTy(), 0,
                    NewTargetII::MO_NO_FLAG);
        }
        GlobalOrExternal = true;
    } else if (ExternalSymbolSDNode * S = dyn_cast<ExternalSymbolSDNode>(Callee)) {
        if (!IsPIC)
        //    std::cout << "-----Isto é um external symbol-----\n";
        //std::cout << "Nome: " << S->getSymbol() << "\n";
        // !N64 && static
        Callee = DAG.getTargetExternalSymbol(S->getSymbol(), getPointerTy(),
                NewTargetII::MO_NO_FLAG);
        //else if (LargeGOT)
        //Callee = getAddrGlobalLargeGOT(Callee, DAG, MipsII::MO_CALL_HI16,
        //                               MipsII::MO_CALL_LO16);
        //else // N64 || PIC
        //Callee = getAddrGlobal(Callee, DAG, MipsII::MO_GOT_CALL);

        GlobalOrExternal = true;
    }

    SDValue JumpTarget = Callee;

    // T9 should contain the address of the callee function if
    // -reloction-model=pic or it is an indirect call.
    if (IsPIC) {
        std::cout << "NewTargetTargetLowering::LowerCall-> IsPIC\n";
    }

    // Build a sequence of copy-to-reg nodes chained together with token
    // chain and flag operands which copy the outgoing args into registers.
    // The InFlag in necessary since all emitted instructions must be
    // stuck together.
    SDValue InFlag;

    for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i) {
        Chain = DAG.getCopyToReg(Chain, dl, RegsToPass[i].first,
                RegsToPass[i].second, InFlag);
        InFlag = Chain.getValue(1);
    }

    // MipsJmpLink = #chain, #target_address, #opt_in_flags...
    //             = Chain, Callee, Reg#1, Reg#2, ...
    //
    // Returns a chain & a flag for retval copy to use.
    SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);
    SmallVector<SDValue, 8> Ops(1, Chain);

    if (JumpTarget.getNode())
        Ops.push_back(JumpTarget);

    // Add argument registers to the end of the list so that they are
    // known live into the call.
    for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i)
        Ops.push_back(DAG.getRegister(RegsToPass[i].first,
            RegsToPass[i].second.getValueType()));

    // Add a register mask operand representing the call-preserved registers.
    const TargetRegisterInfo *TRI = getTargetMachine().getRegisterInfo();
    const uint32_t *Mask = TRI->getCallPreservedMask(CallConv);
    assert(Mask && "Missing call preserved mask for calling convention");
    Ops.push_back(DAG.getRegisterMask(Mask));

    if (InFlag.getNode())
        Ops.push_back(InFlag);

    if (isTailCall)
      return DAG.getNode(NewTargetISD::TailCall, dl, MVT::Other, &Ops[0], Ops.size());

    Chain = DAG.getNode(NewTargetISD::JmpLink, dl, NodeTys, &Ops[0], Ops.size());
    InFlag = Chain.getValue(1);

    // Create the CALLSEQ_END node.
    Chain = DAG.getCALLSEQ_END(Chain, NextStackOffsetVal,
            DAG.getIntPtrConstant(0, true), InFlag);
    InFlag = Chain.getValue(1);

    //Chain.getNode()->dumpr();

    // Handle result values, copying them out of physregs into vregs that we
    // return.
    return LowerCallResult(Chain, InFlag, CallConv, isVarArg,
            Ins, dl, DAG, InVals);
    return Chain;
}

/// LowerCallResult - Lower the result values of a call into the
/// appropriate copies out of appropriate physical registers.

SDValue
NewTargetTargetLowering::LowerCallResult(SDValue Chain, SDValue InFlag,
        CallingConv::ID CallConv, bool isVarArg,
        const SmallVectorImpl<ISD::InputArg> &Ins,
        DebugLoc dl, SelectionDAG &DAG,
        SmallVectorImpl<SDValue> &InVals) const {
    //std::cout << "NewTargetTargetLowering::LowerCallResult ??\n";
    // Assign locations to each value returned by this call.
    SmallVector<CCValAssign, 16> RVLocs;
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
            getTargetMachine(), RVLocs, *DAG.getContext());

    CCInfo.AnalyzeCallResult(Ins, RetCC_NewTarget);

    // Copy all of the result registers out of their specified physreg.
    for (unsigned i = 0; i != RVLocs.size(); ++i) {
        Chain = DAG.getCopyFromReg(Chain, dl, RVLocs[i].getLocReg(),
                RVLocs[i].getValVT(), InFlag).getValue(1);
        InFlag = Chain.getValue(2);
        InVals.push_back(Chain.getValue(0));
    }

    return Chain;
}



//===----------------------------------------------------------------------===//
//               Return Value Calling Convention Implementation
//===----------------------------------------------------------------------===//

bool
NewTargetTargetLowering::CanLowerReturn(CallingConv::ID CallConv,
        MachineFunction &MF, bool isVarArg,
        const SmallVectorImpl<ISD::OutputArg> &Outs,
        LLVMContext &Context) const {
    //std::cout << "NewTargetTargetLowering::CanLowerReturn ??\n";
    SmallVector<CCValAssign, 16> RVLocs;
    CCState CCInfo(CallConv, isVarArg, MF, getTargetMachine(),
            RVLocs, Context);
    return CCInfo.CheckReturn(Outs, RetCC_NewTarget);
}

SDValue
NewTargetTargetLowering::LowerReturn(SDValue Chain,
        CallingConv::ID CallConv, bool isVarArg,
        const SmallVectorImpl<ISD::OutputArg> &Outs,
        const SmallVectorImpl<SDValue> &OutVals,
        DebugLoc dl, SelectionDAG &DAG) const {

    //std::cout << "NewTargetTargetLowering::LowerReturn ??\n";
    // CCValAssign - represent the assignment of
    // the return value to a location
    SmallVector<CCValAssign, 16> RVLocs;

    // CCState - Info about the registers and stack slot.
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
            getTargetMachine(), RVLocs, *DAG.getContext());

    // Analize return values.
    CCInfo.AnalyzeReturn(Outs, RetCC_NewTarget);

    SDValue Flag;
    SmallVector<SDValue, 4> RetOps(1, Chain);

    // Copy the result values into the output registers.
    for (unsigned i = 0; i != RVLocs.size(); ++i) {
        CCValAssign &VA = RVLocs[i];
        assert(VA.isRegLoc() && "Can only return in registers!");

        Chain = DAG.getCopyToReg(Chain, dl, VA.getLocReg(), OutVals[i], Flag);

        // Guarantee that all emitted copies are stuck together with flags.
        Flag = Chain.getValue(1);
        RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
    }

    // The mips ABIs for returning structs by value requires that we copy
    // the sret argument into $v0 for the return. We saved the argument into
    // a virtual register in the entry block, so now we copy the value out
    // and into $v0.
    if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
        MachineFunction &MF = DAG.getMachineFunction();
        NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();
        unsigned Reg = NewTargetFI->getSRetReturnReg();

        if (!Reg)
            llvm_unreachable("sret virtual register not created in the entry block");
        SDValue Val = DAG.getCopyFromReg(Chain, dl, Reg, getPointerTy());
        unsigned R16 = NewTarget::R16;

        Chain = DAG.getCopyToReg(Chain, dl, R16, Val, Flag);
        Flag = Chain.getValue(1);
        RetOps.push_back(DAG.getRegister(R16, getPointerTy()));
    }

    RetOps[0] = Chain; // Update chain.

    // Add the flag if we have it.
    if (Flag.getNode())
        RetOps.push_back(Flag);

    // Return on Mips is always a "jr $ra"
    return DAG.getNode(NewTargetISD::Ret, dl, MVT::Other, &RetOps[0], RetOps.size());
}

//===----------------------------------------------------------------------===//
//  Misc Lower Operation implementation
//===----------------------------------------------------------------------===//

SDValue NewTargetTargetLowering::
LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const {
    // check the depth
    assert((cast<ConstantSDNode>(Op.getOperand(0))->getZExtValue() == 0) &&
            "Frame address can only be determined for current frame.");

    MachineFrameInfo *MFI = DAG.getMachineFunction().getFrameInfo();
    MFI->setFrameAddressIsTaken(true);
    EVT VT = Op.getValueType();
    DebugLoc dl = Op.getDebugLoc();
    // R15 is provisory
    SDValue FrameAddr = DAG.getCopyFromReg(DAG.getEntryNode(), dl, NewTarget::R15, VT);
    return FrameAddr;
}

SDValue NewTargetTargetLowering::LowerRETURNADDR(SDValue Op,
        SelectionDAG &DAG) const {

    //std::cout << "###########################NewTargetTargetLowering::LowerRETURNADDR\n";
    // check the depth
    assert((cast<ConstantSDNode>(Op.getOperand(0))->getZExtValue() == 0) &&
            "Return address can be determined only for current frame.");

    MachineFunction &MF = DAG.getMachineFunction();
    MachineFrameInfo *MFI = MF.getFrameInfo();
    MVT VT = Op.getSimpleValueType();
    unsigned LR = NewTarget::LR;
    MFI->setReturnAddressIsTaken(true);

    // Return RA, which contains the return address. Mark it an implicit live-in.
    unsigned Reg = MF.addLiveIn(LR, getRegClassFor(VT));
    return DAG.getCopyFromReg(DAG.getEntryNode(), Op.getDebugLoc(), Reg, VT);
}

// An EH_RETURN is the result of lowering llvm.eh.return which in turn is
// generated from __builtin_eh_return (offset, handler)
// The effect of this is to adjust the stack pointer by "offset"
// and then branch to "handler".

SDValue NewTargetTargetLowering::LowerEH_RETURN(SDValue Op, SelectionDAG &DAG)
const {
    MachineFunction &MF = DAG.getMachineFunction();
    NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();

    NewTargetFI->setCallsEhReturn();
    SDValue Chain = Op.getOperand(0);
    SDValue Offset = Op.getOperand(1);
    SDValue Handler = Op.getOperand(2);
    DebugLoc DL = Op.getDebugLoc();
    EVT Ty = MVT::i32;

    // Store stack offset in V1, store jump target in V0. Glue CopyToReg and
    // EH_RETURN nodes, so that instructions are emitted back-to-back.
    unsigned OffsetReg = NewTarget::R17;
    unsigned AddrReg = NewTarget::R16;
    Chain = DAG.getCopyToReg(Chain, DL, OffsetReg, Offset, SDValue());
    Chain = DAG.getCopyToReg(Chain, DL, AddrReg, Handler, Chain.getValue(1));
    return DAG.getNode(NewTargetISD::EH_RETURN, DL, MVT::Other, Chain,
            DAG.getRegister(OffsetReg, Ty),
            DAG.getRegister(AddrReg, getPointerTy()),
            Chain.getValue(1));
}

SDValue NewTargetTargetLowering::
LowerJumpTable(SDValue Op, SelectionDAG &DAG) const {
    if (getTargetMachine().getRelocationModel() != Reloc::PIC_)
        return getAddrNonPIC(Op, DAG);

    return getAddrLocal(Op, DAG);
}

SDValue NewTargetTargetLowering::LowerShiftLeftParts(SDValue Op,
        SelectionDAG &DAG) const {
    DebugLoc DL = Op.getDebugLoc();
    SDValue Lo = Op.getOperand(0), Hi = Op.getOperand(1);
    SDValue Shamt = Op.getOperand(2);

    // if shamt < 32:
    //  lo = (shl lo, shamt)
    //  hi = (or (shl hi, shamt) (srl (srl lo, 1), ~shamt))
    // else:
    //  lo = 0
    //  hi = (shl lo, shamt[4:0])
    SDValue Not = DAG.getNode(ISD::XOR, DL, MVT::i32, Shamt,
            DAG.getConstant(-1, MVT::i32));
    SDValue ShiftRight1Lo = DAG.getNode(ISD::SRL, DL, MVT::i32, Lo,
            DAG.getConstant(1, MVT::i32));
    SDValue ShiftRightLo = DAG.getNode(ISD::SRL, DL, MVT::i32, ShiftRight1Lo,
            Not);
    SDValue ShiftLeftHi = DAG.getNode(ISD::SHL, DL, MVT::i32, Hi, Shamt);
    SDValue Or = DAG.getNode(ISD::OR, DL, MVT::i32, ShiftLeftHi, ShiftRightLo);
    SDValue ShiftLeftLo = DAG.getNode(ISD::SHL, DL, MVT::i32, Lo, Shamt);
    SDValue Cond = DAG.getNode(ISD::AND, DL, MVT::i32, Shamt,
            DAG.getConstant(0x20, MVT::i32));
    Lo = DAG.getNode(ISD::SELECT, DL, MVT::i32, Cond,
            DAG.getConstant(0, MVT::i32), ShiftLeftLo);
    Hi = DAG.getNode(ISD::SELECT, DL, MVT::i32, Cond, ShiftLeftLo, Or);

    SDValue Ops[2] = {Lo, Hi};
    return DAG.getMergeValues(Ops, 2, DL);
}

SDValue NewTargetTargetLowering::LowerShiftRightParts(SDValue Op, SelectionDAG &DAG,
        bool IsSRA) const {
    DebugLoc DL = Op.getDebugLoc();
    SDValue Lo = Op.getOperand(0), Hi = Op.getOperand(1);
    SDValue Shamt = Op.getOperand(2);

    // if shamt < 32:
    //  lo = (or (shl (shl hi, 1), ~shamt) (srl lo, shamt))
    //  if isSRA:
    //    hi = (sra hi, shamt)
    //  else:
    //    hi = (srl hi, shamt)
    // else:
    //  if isSRA:
    //   lo = (sra hi, shamt[4:0])
    //   hi = (sra hi, 31)
    //  else:
    //   lo = (srl hi, shamt[4:0])
    //   hi = 0
    SDValue Not = DAG.getNode(ISD::XOR, DL, MVT::i32, Shamt,
            DAG.getConstant(-1, MVT::i32));
    SDValue ShiftLeft1Hi = DAG.getNode(ISD::SHL, DL, MVT::i32, Hi,
            DAG.getConstant(1, MVT::i32));
    SDValue ShiftLeftHi = DAG.getNode(ISD::SHL, DL, MVT::i32, ShiftLeft1Hi, Not);
    SDValue ShiftRightLo = DAG.getNode(ISD::SRL, DL, MVT::i32, Lo, Shamt);
    SDValue Or = DAG.getNode(ISD::OR, DL, MVT::i32, ShiftLeftHi, ShiftRightLo);
    SDValue ShiftRightHi = DAG.getNode(IsSRA ? ISD::SRA : ISD::SRL, DL, MVT::i32,
            Hi, Shamt);
    SDValue Cond = DAG.getNode(ISD::AND, DL, MVT::i32, Shamt,
            DAG.getConstant(0x20, MVT::i32));
    SDValue Shift31 = DAG.getNode(ISD::SRA, DL, MVT::i32, Hi,
            DAG.getConstant(31, MVT::i32));
    Lo = DAG.getNode(ISD::SELECT, DL, MVT::i32, Cond, ShiftRightHi, Or);
    Hi = DAG.getNode(ISD::SELECT, DL, MVT::i32, Cond,
            IsSRA ? Shift31 : DAG.getConstant(0, MVT::i32),
            ShiftRightHi);

    SDValue Ops[2] = {Lo, Hi};
    return DAG.getMergeValues(Ops, 2, DL);
}

SDValue NewTargetTargetLowering::LowerGlobalAddress(SDValue Op,
        SelectionDAG &DAG) const {

    /*
      // FIXME there isn't actually debug info here
      DebugLoc dl = Op.getDebugLoc();
      const GlobalValue *GV = cast<GlobalAddressSDNode>(Op)->getGlobal();

      if (getTargetMachine().getRelocationModel() != Reloc::PIC_ && !IsN64) {
        const MipsTargetObjectFile &TLOF =
          (const MipsTargetObjectFile&)getObjFileLowering();

        // %gp_rel relocation
        if (TLOF.IsGlobalInSmallSection(GV, getTargetMachine())) {
          SDValue GA = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                  MipsII::MO_GPREL);
          SDValue GPRelNode = DAG.getNode(MipsISD::GPRel, dl,
                                          DAG.getVTList(MVT::i32), &GA, 1);
          SDValue GPReg = DAG.getRegister(Mips::GP, MVT::i32);
          return DAG.getNode(ISD::ADD, dl, MVT::i32, GPReg, GPRelNode);
        }

        // %hi/%lo relocation
        return getAddrNonPIC(Op, DAG);
      }

      if (GV->hasInternalLinkage() || (GV->hasLocalLinkage() && !isa<Function>(GV)))
        return getAddrLocal(Op, DAG, HasMips64);

      if (LargeGOT)
        return getAddrGlobalLargeGOT(Op, DAG, MipsII::MO_GOT_HI16,
                                     MipsII::MO_GOT_LO16);

      return getAddrGlobal(Op, DAG,
                           HasMips64 ? MipsII::MO_GOT_DISP : MipsII::MO_GOT16);
     */

    //DebugLoc dl = Op.getDebugLoc();
    const GlobalValue *GV = cast<GlobalAddressSDNode>(Op)->getGlobal();

    if (getTargetMachine().getRelocationModel() != Reloc::PIC_) {
        //std::cout << "Nao eh pic\n";

        const NewTargetTargetObjectFile &TLOF =
                (const NewTargetTargetObjectFile&) getObjFileLowering();

        if (TLOF.IsGlobalInSmallSection(GV, getTargetMachine())) {
            //std::cout << "teste\n";
        }

        //llvm_unreachable_internal("implementando agora....");

        return getAddrNonPIC(Op, DAG);
    }

    llvm_unreachable_internal("PIC address not implemented!");

}

EVT NewTargetTargetLowering::getSetCCResultType(EVT VT) const {
    // altered vliw
    return MVT::i32;
}

static SDValue PerformDivRemCombine(SDNode *N, SelectionDAG &DAG,
        TargetLowering::DAGCombinerInfo &DCI) {
    if (DCI.isBeforeLegalizeOps())
        return SDValue();
    
    llvm_unreachable("division not implemented");
/*
    EVT Ty = N->getValueType(0);
    unsigned LO = NewTarget::LO;
    unsigned HI = NewTarget::HI;
    unsigned opc = N->getOpcode() == ISD::SDIVREM ? NewTargetISD::DivRem :
            NewTargetISD::DivRemU;
    DebugLoc dl = N->getDebugLoc();

    SDValue DivRem = DAG.getNode(opc, dl, MVT::Glue,
            N->getOperand(0), N->getOperand(1));
    SDValue InChain = DAG.getEntryNode();
    SDValue InGlue = DivRem;

    // insert MFLO
    if (N->hasAnyUseOfValue(0)) {
        SDValue CopyFromLo = DAG.getCopyFromReg(InChain, dl, LO, Ty,
                InGlue);
        DAG.ReplaceAllUsesOfValueWith(SDValue(N, 0), CopyFromLo);
        InChain = CopyFromLo.getValue(1);
        InGlue = CopyFromLo.getValue(2);
    }

    // insert MFHI
    if (N->hasAnyUseOfValue(1)) {
        SDValue CopyFromHi = DAG.getCopyFromReg(InChain, dl,
                HI, Ty, InGlue);
        DAG.ReplaceAllUsesOfValueWith(SDValue(N, 1), CopyFromHi);
    }
*/
    return SDValue();
}

static SDValue PerformADDECombine(SDNode *N, SelectionDAG &DAG,
        TargetLowering::DAGCombinerInfo &DCI) {
    if (DCI.isBeforeLegalize())
        return SDValue();

    if (N->getValueType(0) == MVT::i32 && SelectMadd(N, &DAG))
        return SDValue(N, 0);

    return SDValue();
}

static SDValue PerformADDCombine(SDNode *N, SelectionDAG &DAG,
        TargetLowering::DAGCombinerInfo &DCI) {
    // (add v0, (add v1, abs_lo(tjt))) => (add (add v0, v1), abs_lo(tjt))

    if (DCI.isBeforeLegalizeOps())
        return SDValue();

    SDValue Add = N->getOperand(1);

    if (Add.getOpcode() != ISD::ADD)
        return SDValue();

    SDValue Lo = Add.getOperand(1);

    if ((Lo.getOpcode() != NewTargetISD::Lo) ||
            (Lo.getOperand(0).getOpcode() != ISD::TargetJumpTable))
        return SDValue();

    EVT ValTy = N->getValueType(0);
    DebugLoc DL = N->getDebugLoc();

    SDValue Add1 = DAG.getNode(ISD::ADD, DL, ValTy, N->getOperand(0),
            Add.getOperand(0));
    return DAG.getNode(ISD::ADD, DL, ValTy, Add1, Lo);
}

SDValue NewTargetTargetLowering::PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI)
const {
    SelectionDAG &DAG = DCI.DAG;
    unsigned opc = N->getOpcode();

    switch (opc) {
        default: break;
        case ISD::ADDE:
            return PerformADDECombine(N, DAG, DCI);
        case ISD::SUBE:
            // return PerformSUBECombine(N, DAG, DCI, Subtarget);
            llvm_unreachable("ADE");
        //case ISD::SDIVREM:
        //case ISD::UDIVREM:
        //    return PerformDivRemCombine(N, DAG, DCI);
        case ISD::SELECT:
            //return PerformSELECTCombine(N, DAG, DCI, Subtarget);
            llvm_unreachable("ADE");
        case ISD::AND:
            //return PerformANDCombine(N, DAG, DCI, Subtarget);
            llvm_unreachable("ADE");
        case ISD::OR:
            //return PerformORCombine(N, DAG, DCI, Subtarget);
            llvm_unreachable("ADE");
        case ISD::ADD:
            return PerformADDCombine(N, DAG, DCI);
            //llvm_unreachable("ADE");  
    }

    return SDValue();
}

bool
NewTargetTargetLowering::isLegalAddressingMode(const AddrMode &AM, Type *Ty) const {
    // No global is ever allowed as a base.
    if (AM.BaseGV)
        return false;

    switch (AM.Scale) {
        case 0: // "r+i" or just "i", depending on HasBaseReg.
            break;
        case 1:
            if (!AM.HasBaseReg) // allow "r+i".
                break;
            return false; // disallow "r+r" or "r+r+i".
        default:
            return false;
    }

    return true;
}

bool
NewTargetTargetLowering::isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const {
    // The Mips target isn't yet aware of offsets.
    return false;
}

//===----------------------------------------------------------------------===//
//                           NewTarget Inline Assembly Support
//===----------------------------------------------------------------------===//

/// getConstraintType - Given a constraint letter, return the type of
/// constraint it is for this target.

NewTargetTargetLowering::ConstraintType NewTargetTargetLowering::
getConstraintType(const std::string &Constraint) const {
    // Mips specific constrainy
    // GCC config/mips/constraints.md
    //
    // 'd' : An address register. Equivalent to r
    //       unless generating MIPS16 code.
    // 'y' : Equivalent to r; retained for
    //       backwards compatibility.
    // 'c' : A register suitable for use in an indirect
    //       jump. This will always be $25 for -mabicalls.
    // 'l' : The lo register. 1 word storage.
    // 'x' : The hilo register pair. Double word storage.
    if (Constraint.size() == 1) {
        switch (Constraint[0]) {
            default: break;
            case 'd':
            case 'y':
            case 'f':
            case 'c':
            case 'l':
            case 'x':
                return C_RegisterClass;
        }
    }
    return TargetLowering::getConstraintType(Constraint);
}

/// Examine constraint type and operand type and determine a weight value.
/// This object must already have been set up with the operand type
/// and the current alternative constraint selected.

TargetLowering::ConstraintWeight
NewTargetTargetLowering::getSingleConstraintMatchWeight(
        AsmOperandInfo &info, const char *constraint) const {
    ConstraintWeight weight = CW_Invalid;
    Value *CallOperandVal = info.CallOperandVal;
    // If we don't have a value, we can't do a match,
    // but allow it at the lowest weight.
    if (CallOperandVal == NULL)
        return CW_Default;
    Type *type = CallOperandVal->getType();
    // Look at the constraint type.
    switch (*constraint) {
        default:
            weight = TargetLowering::getSingleConstraintMatchWeight(info, constraint);
            break;
        case 'd':
        case 'y':
            if (type->isIntegerTy())
                weight = CW_Register;
            break;
        case 'f':
            if (type->isFloatTy())
                weight = CW_Register;
            break;
        case 'c': // $25 for indirect jumps
        case 'l': // lo register
        case 'x': // hilo register pair
            if (type->isIntegerTy())
                weight = CW_SpecificReg;
            break;
        case 'I': // signed 16 bit immediate
        case 'J': // integer zero
        case 'K': // unsigned 16 bit immediate
        case 'L': // signed 32 bit immediate where lower 16 bits are 0
        case 'N': // immediate in the range of -65535 to -1 (inclusive)
        case 'O': // signed 15 bit immediate (+- 16383)
        case 'P': // immediate in the range of 65535 to 1 (inclusive)
            if (isa<ConstantInt>(CallOperandVal))
                weight = CW_Constant;
            break;
    }
    return weight;
}

/// Given a register class constraint, like 'r', if this corresponds directly
/// to an LLVM register class, return a register of 0 and the register class
/// pointer.

std::pair<unsigned, const TargetRegisterClass*> NewTargetTargetLowering::
getRegForInlineAsmConstraint(const std::string &Constraint, EVT VT) const {
    if (Constraint.size() == 1) {
        switch (Constraint[0]) {
            case 'd': // Address register. Same as 'r' unless generating MIPS16 code.
            case 'y': // Same as 'r'. Exists for compatibility.
            case 'r':
                if (VT == MVT::i32 || VT == MVT::i16 || VT == MVT::i8) {
                    return std::make_pair(0U, &NewTarget::CPURegsRegClass);
                }
                llvm_unreachable("error");
                break;
            case 'c': // register suitable for indirect jump
                //if (VT == MVT::i32)
                //  return std::make_pair((unsigned)Mips::T9, &Mips::CPURegsRegClass);
                llvm_unreachable("error");
            case 'l': // register suitable for indirect jump
                //if (VT == MVT::i32)
                //  return std::make_pair((unsigned)Mips::LO, &Mips::HILORegClass);
                //return std::make_pair((unsigned)Mips::LO64, &Mips::HILO64RegClass);
                llvm_unreachable("error");

            case 'x': // register suitable for indirect jump
                // Fixme: Not triggering the use of both hi and low
                // This will generate an error message
                return std::make_pair(0u, static_cast<const TargetRegisterClass*> (0));
        }
    }
    return TargetLowering::getRegForInlineAsmConstraint(Constraint, VT);
}

/// LowerAsmOperandForConstraint - Lower the specified operand into the Ops
/// vector.  If it is invalid, don't add anything to Ops.

void NewTargetTargetLowering::LowerAsmOperandForConstraint(SDValue Op,
        std::string &Constraint,
        std::vector<SDValue>&Ops,
        SelectionDAG &DAG) const {
    SDValue Result(0, 0);

    // Only support length 1 constraints for now.
    if (Constraint.length() > 1) return;

    char ConstraintLetter = Constraint[0];
    switch (ConstraintLetter) {
        default: break; // This will fall through to the generic implementation
        case 'I': // Signed 16 bit constant
            // If this fails, the parent routine will give an error
            if (ConstantSDNode * C = dyn_cast<ConstantSDNode>(Op)) {
                EVT Type = Op.getValueType();
                int64_t Val = C->getSExtValue();
                if (isInt<16>(Val)) {
                    Result = DAG.getTargetConstant(Val, Type);
                    break;
                }
            }
            return;
        case 'J': // integer zero
            if (ConstantSDNode * C = dyn_cast<ConstantSDNode>(Op)) {
                EVT Type = Op.getValueType();
                int64_t Val = C->getZExtValue();
                if (Val == 0) {
                    Result = DAG.getTargetConstant(0, Type);
                    break;
                }
            }
            return;
        case 'K': // unsigned 16 bit immediate
            if (ConstantSDNode * C = dyn_cast<ConstantSDNode>(Op)) {
                EVT Type = Op.getValueType();
                uint64_t Val = (uint64_t) C->getZExtValue();
                if (isUInt<16>(Val)) {
                    Result = DAG.getTargetConstant(Val, Type);
                    break;
                }
            }
            return;
        case 'L': // signed 32 bit immediate where lower 16 bits are 0
            if (ConstantSDNode * C = dyn_cast<ConstantSDNode>(Op)) {
                EVT Type = Op.getValueType();
                int64_t Val = C->getSExtValue();
                if ((isInt<32>(Val)) && ((Val & 0xffff) == 0)) {
                    Result = DAG.getTargetConstant(Val, Type);
                    break;
                }
            }
            return;
        case 'N': // immediate in the range of -65535 to -1 (inclusive)
            if (ConstantSDNode * C = dyn_cast<ConstantSDNode>(Op)) {
                EVT Type = Op.getValueType();
                int64_t Val = C->getSExtValue();
                if ((Val >= -65535) && (Val <= -1)) {
                    Result = DAG.getTargetConstant(Val, Type);
                    break;
                }
            }
            return;
        case 'O': // signed 15 bit immediate
            if (ConstantSDNode * C = dyn_cast<ConstantSDNode>(Op)) {
                EVT Type = Op.getValueType();
                int64_t Val = C->getSExtValue();
                if ((isInt<15>(Val))) {
                    Result = DAG.getTargetConstant(Val, Type);
                    break;
                }
            }
            return;
        case 'P': // immediate in the range of 1 to 65535 (inclusive)
            if (ConstantSDNode * C = dyn_cast<ConstantSDNode>(Op)) {
                EVT Type = Op.getValueType();
                int64_t Val = C->getSExtValue();
                if ((Val <= 65535) && (Val >= 1)) {
                    Result = DAG.getTargetConstant(Val, Type);
                    break;
                }
            }
            return;
    }

    if (Result.getNode()) {
        Ops.push_back(Result);
        return;
    }

    TargetLowering::LowerAsmOperandForConstraint(Op, Constraint, Ops, DAG);
}
