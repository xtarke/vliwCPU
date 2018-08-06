//===- NewTargetInstrInfo.td - Target Description for Mips Target -*- tablegen -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Mips implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// NewTarget profiles and nodes
//===----------------------------------------------------------------------===//


// Call
def SDT_NewTargetJmpLink      : SDTypeProfile<0, 1, [SDTCisVT<0, iPTR>]>;

def NewTargetJmpLink : SDNode<"NewTargetISD::JmpLink",SDT_NewTargetJmpLink,
                         [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue,
                          SDNPVariadic]>;

def SDT_NewTargetBranchBR      : SDTypeProfile<0, 2, [SDTCisInt<0>, SDTCisVT<1, OtherVT>]>;
def SDT_NewTargetBranchBRF      : SDTypeProfile<0, 2, [SDTCisInt<0>, SDTCisVT<1, OtherVT>]>;

def SDT_NewTargetImmediate32      : SDTypeProfile<1, 1, [SDTCisInt<0>, SDTCisVT<1, i32>]>;

def SDTBinaryArithWithFlags : SDTypeProfile<2, 2,
                                            [SDTCisSameAs<0, 2>,
                                             SDTCisSameAs<0, 3>,
                                             SDTCisInt<0>, 
                                             SDTCisVT<1, i32>]>;

// SDTBinaryArithWithFlagsInOut - RES1, BRFLAG7 = op LHS, RHS, BRFLAG7
def SDTBinaryArithWithFlagsInOut : SDTypeProfile<2, 3,
                                            [SDTCisSameAs<0, 2>,
                                             SDTCisSameAs<0, 3>,
                                             SDTCisInt<0>,
                                             SDTCisVT<1, i32>,
                                             SDTCisVT<4, i32>]>;


def NewTargetaddc          : SDNode<"NewTargetISD::ADDC",  SDTBinaryArithWithFlags,
                              [SDNPCommutative]>;
def NewTargetsubc          : SDNode<"NewTargetISD::SUBC",  SDTBinaryArithWithFlags>;
def NewTargetadde          : SDNode<"NewTargetISD::ADDE",  SDTBinaryArithWithFlagsInOut>;
def NewTargetsube          : SDNode<"NewTargetISD::SUBE",  SDTBinaryArithWithFlagsInOut>;

def NewTargetBranchBR : SDNode<"NewTargetISD::BranchBR", SDT_NewTargetBranchBR,
                     [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def NewTargetBranchBRF : SDNode<"NewTargetISD::BranchBRF", SDT_NewTargetBranchBRF,
                     [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

def NewTargetImmediate32 : SDNode<"NewTargetISD::Immediate32", SDT_NewTargetImmediate32,
                     [SDNPVariadic]>;

// These are target-independent nodes, but have target-specific formats.
def SDT_NewTargetCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>]>;
def SDT_NewTargetCallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i32>, SDTCisVT<1, i32>]>;


def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_NewTargetCallSeqStart,
                           [SDNPHasChain, SDNPSideEffect, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_NewTargetCallSeqEnd,
                           [SDNPHasChain, SDNPSideEffect,
                            SDNPOptInGlue, SDNPOutGlue]>;
// Return
def NewTargetRet : SDNode<"NewTargetISD::Ret", SDTNone,
                     [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

// Abs node is used to handle global addresses. Used on
// MipsISelLowering to lower stuff like GlobalAddress, ExternalSymbol
// static model.
def NewTargetAbs    : SDNode<"NewTargetISD::Abs", SDTIntUnaryOp>;


                     
//===----------------------------------------------------------------------===//
// Mips Instruction Predicate Definitions.
//===----------------------------------------------------------------------===//

def RelocStatic :     Predicate<"TM.getRelocationModel() == Reloc::Static">;

def RelocPIC    :     Predicate<"TM.getRelocationModel() == Reloc::PIC_">;
                     

class NewTargetPat<dag pattern, dag result> : Pat<pattern, result> {
  //let Predicates = [HasStdEnc];
}
   
class IsBranch {
  bit isBranch = 1;
}   

class IsAsCheapAsAMove {
  bit isAsCheapAsAMove = 1;
} 


//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//
                        

include "NewTargetInstrFormats.td"

//===----------------------------------------------------------------------===//
// NewTarget Operand, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//

// Instruction operand types
def jmptarget   : Operand<OtherVT> {
  let EncoderMethod = "getJumpTargetOpValue";
}
def brtarget    : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetOpValue";
  let OperandType = "OPERAND_PCREL";
  let DecoderMethod = "DecodeBranchTarget";
}
def calltarget  : Operand<iPTR> {
  let EncoderMethod = "getJumpTargetOpValue";
}   

def simm16      : Operand<i32> {
  let DecoderMethod= "DecodeSimm16";
}

def imm32      : Operand<i32> {
  let DecoderMethod= "Decodeimm32";
}

def shamt       : Operand<i32>;

// Unsigned Operand
def uimm16      : Operand<i32> {
  let PrintMethod = "printUnsignedImm";
}

def NewTargetMemAsmOperand : AsmOperandClass {
  let Name = "Mem";
  let ParserMethod = "parseMemOperand";
}

// Transformation Function - get the lower 16 bits.
def LO16 : SDNodeXForm<imm, [{
  return getImm(N, N->getZExtValue() & 0xFFFF);
}]>;

// Transformation Function - get the higher 16 bits.
def HI16 : SDNodeXForm<imm, [{
  return getImm(N, (N->getZExtValue() >> 16) & 0xFFFF);
}]>;

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt8  : PatLeaf<(imm), [{ return isInt<8>(N->getSExtValue()); }]>;

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt16  : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

def immSExt9  : PatLeaf<(imm), [{ return isInt<8>(N->getSExtValue()); }]>;

def immSExt32  : PatLeaf<(imm), [{ return isInt<8>(N->getSExtValue()); }]>;

// Node immediate fits as 15-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt15  : PatLeaf<(imm), [{ return isInt<15>(N->getSExtValue()); }]>;

// Node immediate fits as 16-bit zero extended on target immediate.
// The LO16 param means that only the lower 16 bits of the node
// immediate are caught.
// e.g. addiu, sltiu
def immZExt16  : PatLeaf<(imm), [{
  if (N->getValueType(0) == MVT::i32)
    return (uint32_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
  else
    return (uint64_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
}], LO16>;

// Immediate can be loaded with LUi (32-bit int with lower 16-bit cleared).
def immLow16Zero : PatLeaf<(imm), [{
  int64_t Val = N->getSExtValue();
  return isInt<32>(Val) && !(Val & 0xffff);
}]>;

// shamt field must fit in 9 bits.
def immZExt9 : ImmLeaf<i32, [{return Imm == (Imm & 0xff);}]>;

// shamt field must fit in 5 bits.

def immZExt23 : ImmLeaf<i32, [{return Imm == (Imm & 0x7fffff);}]>;


// Mips Address Mode! SDNode frameindex could possibily be a match
// since load and store instructions from stack used it.

def addrRegImm :
  ComplexPattern<iPTR, 2, "selectAddrRegImm", [frameindex]>;

def addrDefault :
  ComplexPattern<iPTR, 2, "selectAddrDefault", [frameindex]>;

def addr :
  ComplexPattern<iPTR, 2, "selectIntAddr", [frameindex]>;

def simm32      : Operand<i32> {
  let DecoderMethod= "DecodeSimm32";
}

// Unsigned Operand
def uimm9      : Operand<i32> {
  let PrintMethod = "printUnsignedImm";
}

def simm9      : Operand<i32> {
  let DecoderMethod= "DecodeSimm9";
}

def uimm23      : Operand<i32> {
  let DecoderMethod= "DecodeUimm23";
}

// Address operand
def mem : Operand<i32> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops CPURegs, simm9);
  let EncoderMethod = "getMemEncoding";
  let ParserMatchClass = NewTargetMemAsmOperand;
}

def mem_ea : Operand<i32> {
  let PrintMethod = "printMemOperandEA";
  let MIOperandInfo = (ops CPURegs, simm9);
  let EncoderMethod = "getMemEncodingEA";
}

class BinOpWithFlagFrag<dag res> :
      PatFrag<(ops node:$LHS, node:$RHS, node:$FLAG), res>;
class BinOpFrag<dag res> : PatFrag<(ops node:$LHS, node:$RHS), res>;

//===----------------------------------------------------------------------===//
// Instructions specific format
//===----------------------------------------------------------------------===//

// Signal/Zero extension instructions.
class SignalZeroExtension<string opstr, RegisterOperand RO,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag>:
  InstSE<(outs RO:$idest), (ins RO:$src1),
         !strconcat(opstr, "\t$idest = $src1"),
         [(set RO:$idest, (OpNode RO:$src1))], Itin, FrmR> {
  let isReMaterializable = 1;
  string BaseOpcode;
  string Arch;
}

// Interger division.
class IntegerDivision<string opstr, RegisterOperand RO, bit isComm = 0,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag>:
  InstSE<(outs RO:$dest), (ins RO:$src1, RO:$src2),
         !strconcat(opstr, "\t$dest = $src1, $src2"),
         [(set RO:$dest, (OpNode RO:$src1, RO:$src2))], Itin, FrmR> {
  let isCommutable = isComm;
  let isReMaterializable = 1;
  string BaseOpcode;
  string Arch;
}

multiclass MultIntegerDivision<int opcode, string opstr, RegisterOperand RO, bit isComm = 0,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag> {
        def NAME : IntegerDivision<opstr, RO, isComm, Itin, OpNode>, Int3Ri<opcode, 0>;
        def NAME#_p : IntegerDivision<"(p)"#opstr, RO, isComm, Itin, null_frag>, Int3Ri<opcode, 1>;
}

// Arithmetic and logical instructions with 3 register operands.
class ArithLogicRtest<string opstr, RegisterOperand RO, bit isComm = 0, bit pred = 0,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag>:
  InstSE<(outs RO:$dest), (ins RO:$src2, RO:$src1),
         !strconcat(opstr, "\t$dest = $src1, $src2"),
         [(set RO:$dest, (OpNode RO:$src2, RO:$src1))], Itin, FrmR> {
  let isCommutable = isComm;
  let isReMaterializable = 1;
  string BaseOpcode;
  string Arch;
}

multiclass MultArithLogicRtest<int opcode, string opstr, RegisterOperand RO, bit isComm = 0,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag> {

      def NAME : ArithLogicRtest<opstr, RO, 1, 0, Itin, OpNode>, Int3Ri<opcode, 0>;

      def NAME#_p : ArithLogicRtest<"(p)"#opstr, RO, 1, 1, Itin, null_frag>, Int3Ri<opcode, 1>;

}

multiclass MultArithLogicRtestV2<int opcode, string opstr, RegisterOperand RO, bit isComm = 0,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag> {

      def NAME : ArithLogicRtest<opstr, RO, 1, 0, Itin, OpNode>, Mul64R<opcode, 0>;

      def NAME#_p : ArithLogicRtest<"(p)"#opstr, RO, 1, 1, Itin, null_frag>, Mul64R<opcode, 1>;

}

// Arithmetic and logical instructions with 3 register operands.
class ArithCarryInOut<string opstr, RegisterClass RO, RegisterClass R1,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag>:
  InstSE<(outs RO:$dest, R1:$bdest), (ins RO:$src2, RO:$src1, R1:$scond),
         !strconcat(opstr, "\t$dest, $bdest = $src1, $src2, $scond"),
         [], Itin, FrmR> {
  let isReMaterializable = 1;
  string BaseOpcode;
  string Arch;
}


multiclass MultArithCarryInOut<int opcode, string opstr, RegisterClass RO, RegisterClass R1,
                  InstrItinClass Itin = IIAlu,
                  SDPatternOperator OpNode = null_frag>{

        def NAME : ArithCarryInOut<opstr, RO, R1, Itin>, cgen<opcode, 0>;
        def NAME#_p : ArithCarryInOut<"(p)"#opstr, RO, R1, Itin>, cgen<opcode, 1>;
}


// Arithmetic and logical instructions with 2 register operands.
class ArithLogicItest<string opstr, Operand Od, RegisterOperand RO,
                  SDPatternOperator imm_type = null_frag,
                  SDPatternOperator OpNode = null_frag> :
  InstSE<(outs RO:$idest), (ins RO:$src1, Od:$isrc2),
         !strconcat(opstr, "\t$idest = $src1, $isrc2"),
         [(set RO:$idest, (OpNode RO:$src1, imm_type:$isrc2))], IIAlu, FrmI> {
  let isReMaterializable = 1;
}

multiclass MultArithLogicItest<int opcode, string opstr, Operand Od, RegisterOperand RO,
                  SDPatternOperator imm_type = null_frag,
                  SDPatternOperator OpNode = null_frag> {

        def NAME : ArithLogicItest<opstr, Od, RO, imm_type, OpNode>, Int3I<opcode, 0>;
        def NAME#_p : ArithLogicItest<"(p)"#opstr, Od, RO, imm_type, null_frag>, Int3I<opcode, 1>;
}

class EffectiveAddress<string opstr, RegisterClass RC, Operand Mem> :
  InstSE<(outs RC:$idest), (ins Mem:$addr), !strconcat(opstr, "\t$idest = $addr"),
         [(set RC:$idest, addr:$addr)], IIAlu, FrmI> {
  let isCodeGenOnly = 1;
  let DecoderMethod = "DecodeMem";
}

multiclass MultEffectiveAddress<int opcode, string opstr, RegisterClass RC, Operand Mem>{

    def NAME : EffectiveAddress<opstr, RC, Mem>, Int3I_MEM<opcode, 0>;
    def NAME#_p : EffectiveAddress<"(p)"#opstr, RC, Mem>, Int3I_MEM<opcode, 1>;
}

// Memory Load/Store
class Loadtest<string opstr, SDPatternOperator OpNode, RegisterClass RC,
           Operand MemOpnd> :
  InstSE<(outs RC:$idest), (ins MemOpnd:$addr), !strconcat(opstr, "\t$idest = $addr"),
         [(set RC:$idest, (OpNode addr:$addr))], IILoad, FrmI> {
  let DecoderMethod = "DecodeMem";
  let canFoldAsLoad = 1;
}

class Storetest<string opstr, SDPatternOperator OpNode, RegisterClass RC,
            Operand MemOpnd> :
  InstSE<(outs), (ins RC:$idest, MemOpnd:$addr), !strconcat(opstr, "\t$addr = $idest"),
         [(OpNode RC:$idest, addr:$addr)], IIStore, FrmI> {
  let DecoderMethod = "DecodeMem";
}


multiclass LoadMtest<int opcode, string opstr, RegisterClass RC,
                 SDPatternOperator OpNode = null_frag> {
    def NAME : Loadtest<opstr, OpNode, RC, mem>, LoadV2<opcode, 0x0, 0>;
    def NAME#_p : Loadtest<"(p)"#opstr, null_frag, RC, mem>, LoadV2<opcode, 0x0, 1>;
}

multiclass StoreMtest<int opcode, string opstr, RegisterClass RC,
                  SDPatternOperator OpNode = null_frag> {
    def NAME : Storetest<opstr, OpNode, RC, mem>, StoreV2<opcode, 0>;
    def NAME#_p : Storetest<"(p)"#opstr, null_frag, RC, mem>, StoreV2<opcode, 1>;
}

// Jump and Link (Call)
let isCall=1, Defs = [LR] in {
  class CallInst<string opstr> :
    InstSE<(outs), (ins calltarget:$target), !strconcat(opstr, "\t$target"),
           [(NewTargetJmpLink imm:$target)], IIBranch, FrmJ> {
    let DecoderMethod = "DecodeJumpTarget";
    // let isBarrier=1;
    // let isTerminator=1;
  }

}


// Base class for indirect branch and return instruction classes.
let isTerminator=1, isBarrier=1 in
class JumpFRtest<RegisterClass RC, SDPatternOperator operator = null_frag>:
  InstSE<(outs), (ins RC:$target), "goto \t$target", [(operator RC:$target)], IIBranch, FrmR>;

// Indirect branch
class IndirectBranchtest<RegisterClass RC>: JumpFRtest<RC, brind> {
  let isBranch = 1;
  let isIndirectBranch = 1;
}

// Return instruction
class RetBasetest<RegisterClass RC>: JumpFRtest<RC> {
  let isReturn = 1;
  let isCodeGenOnly = 1;
  let hasCtrlDep = 1;
  let hasExtraSrcRegAllocReq = 1;
}


class GotoDirect<DAGOperand opnd, string opstr, SDPatternOperator operator,
             SDPatternOperator targetoperator> :
  InstSE<(outs), (ins opnd:$target), !strconcat(opstr, "\t$target"),
         [(operator targetoperator:$target)], IIBranch, FrmJ> {
  let isTerminator=1;
  let isBarrier=1;
  let hasDelaySlot = 1;
  let DecoderMethod = "DecodeJumpTarget";
  //let Defs = [AT];
}

// Conditional Branch
class CBranch<string opstr, RegisterClass RC> :
  InstSE<(outs), (ins RC:$bcond, brtarget:$btarg),
         !strconcat(opstr, "\t$bcond, $btarg"),
         [],
         IIBranch,
         FrmI> {
  let isBranch = 1;
  let isTerminator = 1;
  let hasDelaySlot = 1;
  //let Defs = [AT];
}

// target preload
class PreloadInst<string opstr> :
    InstSE<(outs), (ins brtarget:$btarg), !strconcat(opstr, "\t$btarg"),
           [], IIBranch, FrmJ> {
}

class shift_rotate_imm_test<string opstr, Operand ImmOpnd,
                       RegisterOperand RC, SDPatternOperator OpNode = null_frag,
                       SDPatternOperator PF = null_frag> :
  InstSE<(outs RC:$idest), (ins RC:$src1, ImmOpnd:$isrc2),
         !strconcat(opstr, "\t$idest, $src1, $isrc2"),
         [(set RC:$idest, (OpNode RC:$src1, PF:$isrc2))], IIAlu, FrmR>;

multiclass Multshift_rotate_imm_test<int opcode, string opstr, Operand ImmOpnd,
                       RegisterOperand RC, SDPatternOperator OpNode = null_frag,
                       SDPatternOperator PF = null_frag>{

        def NAME : shift_rotate_imm_test<opstr, ImmOpnd, RC, OpNode, PF>, Int3I<opcode, 0>;
        def NAME#_p : shift_rotate_imm_test<"(p)"#opstr, ImmOpnd, RC, null_frag, PF>, Int3I<opcode, 1>;
}

class shift_rotate_reg_test<string opstr, RegisterOperand RC,
                       SDPatternOperator OpNode = null_frag>:
  InstSE<(outs RC:$dest), (ins CPURegsOpnd:$src2, RC:$src1),
         !strconcat(opstr, "\t$dest, $src1, $src2"),
         [(set RC:$dest, (OpNode RC:$src1, CPURegsOpnd:$src2))], IIAlu, FrmR>;

multiclass Multshift_rotate_reg_test<int opcode, string opstr, RegisterOperand RC,
                       SDPatternOperator OpNode = null_frag>{

        def NAME : shift_rotate_reg_test<opstr, RC, OpNode>, Int3Ri<opcode, 0>;
        def NAME#_p : shift_rotate_reg_test<"(p)"#opstr, RC, null_frag>, Int3Ri<opcode, 1>;
}

/// SetCC classes

let isCompare=1 in
class SetCC_RR<string opstr, PatFrag cond_op, RegisterClass RC> :
  InstSE<(outs CPURegsOpnd:$dest), (ins RC:$src1, RC:$src2),
         !strconcat(opstr, "\t$dest, $src1, $src2"),
         [(set CPURegsOpnd:$dest, (cond_op RC:$src1, RC:$src2))], IIAlu, FrmR>;

multiclass MultSetCC_RR<int opcode, string opstr, PatFrag cond_op, RegisterClass RC>{

    def NAME : SetCC_RR<opstr, cond_op, RC>, Cmp3R_Reg<opcode, 0>;
    def NAME#_p : SetCC_RR<"(p)"#opstr, cond_op, RC>, Cmp3R_Reg<opcode, 1>;
}
       
let isCompare=1 in  
class SetCC_IR<string opstr, PatFrag cond_op, Operand Od, PatLeaf imm_type,
              RegisterClass RC>:
  InstSE<(outs CPURegsOpnd:$idest), (ins RC:$src1, Od:$isrc2),
         !strconcat(opstr, "\t$idest, $src1, $isrc2"),
         [(set CPURegsOpnd:$idest, (cond_op RC:$src1, imm_type:$isrc2))],
         IIAlu, FrmI>;

multiclass MultSetCC_IR<int opcode, string opstr, PatFrag cond_op, Operand Od, PatLeaf imm_type,
              RegisterClass RC>{

    def NAME : SetCC_IR<opstr, cond_op, Od, imm_type,RC>, Cmp3I_Reg<opcode, 0>;
    def NAME#_p : SetCC_IR<"(p)"#opstr, cond_op, Od, imm_type, RC>, Cmp3I_Reg<opcode, 1>;
}

let isCompare=1 in
class SetCC_RB<string opstr, PatFrag cond_op, RegisterClass RC1, RegisterClass RC2> :
  InstSE<(outs RC1:$bdest), (ins RC2:$src1, RC2:$src2),
         !strconcat(opstr, "\t$bdest, $src1, $src2"),
         [(set RC1:$bdest, (cond_op RC2:$src1, RC2:$src2))], IIAluWriteFlag, FrmR>;

multiclass MultSetCC_RB<int opcode, string opstr, PatFrag cond_op, RegisterClass RC1, RegisterClass RC2>{

    def NAME : SetCC_RB<opstr, cond_op, RC1, RC2>, Cmp3R_Br<opcode, 0>;
    def NAME#_p : SetCC_RB<"(p)"#opstr, cond_op, RC1, RC2>, Cmp3R_Br<opcode, 1>;
}

class SetCC_RB_NC<string opstr, RegisterClass RC1, RegisterClass RC2> :
  InstSE<(outs RC1:$bdest), (ins RC2:$src1, RC2:$src2),
         !strconcat(opstr, "\t$bdest, $src1, $src2"),
         [], IIAluWriteFlag, FrmR>;


multiclass MultiSetCC_RB_NC<int opcode, string opstr, RegisterClass RC1, RegisterClass RC2>{

    def NAME : SetCC_RB_NC<opstr, RC1, RC2>, Cmp3R_Br<0xC, 0>;
    def NAME#_p : SetCC_RB_NC<"(p)"#opstr, RC1, RC2>, Cmp3R_Br<0xC, 1>;
}

let isCompare=1 in
class SetCC_IB<string opstr, PatFrag cond_op, Operand Od, PatLeaf imm_type,
              RegisterClass RC1, RegisterClass RC2>:
  InstSE<(outs RC1:$bdest), (ins RC2:$src1, Od:$isrc2),
         !strconcat(opstr, "\t$bdest, $src1, $isrc2"),
         [(set RC1:$bdest, (cond_op RC2:$src1, imm_type:$isrc2))],
         IIAlu, FrmI>;

 multiclass MultSetCC_IB<int opcode, string opstr, PatFrag cond_op, Operand Od, PatLeaf imm_type,
              RegisterClass RC1, RegisterClass RC2> {
    def NAME : SetCC_IB<opstr, cond_op, Od, imm_type, RC1, RC2>, Cmp3I_Br<opcode, 0>;
    def NAME#_p : SetCC_IB<"(p)"#opstr,cond_op, Od, imm_type,  RC1, RC2>, Cmp3I_Br<opcode, 1>;
}
         
let isCompare=1 in
class SelR<string opstr, RegisterClass RC1, RegisterClass RC2> :
  InstSE<(outs RC2:$dest), (ins RC1:$scond, RC2:$src1, RC2:$src2),
         !strconcat(opstr, "\t$dest = $scond, $src1, $src2"),
         [(set RC2:$dest, (select RC1:$scond, RC2:$src1, RC2:$src2))], IIAlu, FrmR>;

multiclass MultSelR<int opcode, string opstr, RegisterClass RC1, RegisterClass RC2> {

    def NAME : SelR<opstr, RC1, RC2>, SelectR<opcode, 0>;
    def NAME#_p : SelR<"(p)"#opstr, RC1, RC2>, SelectR<opcode, 1>;
}

class SelI<string opstr, Operand Od, PatLeaf imm_type, RegisterClass RC1, RegisterClass RC2> :
  InstSE<(outs RC2:$dest), (ins RC1:$scond, RC2:$src1, Od:$isrc2),
         !strconcat(opstr, "\t$dest = $scond, $src1, $isrc2"),
         [(set RC2:$dest, (select RC1:$scond, RC2:$src1, imm_type:$isrc2))], IIAlu, FrmR>;


multiclass MultSelI<int opcode, string opstr, Operand Od, PatLeaf imm_type, RegisterClass RC1, RegisterClass RC2> {

    def NAME : SelI<opstr, Od, imm_type, RC1, RC2>, SelectI<opcode, 0>;
    def NAME#_p : SelI<"(p)"#opstr, Od, imm_type, RC1, RC2>, SelectI<opcode, 1>;
}

class Immediate<string opstr, Operand Od, SDPatternOperator imm_type> : 
  InstSE<(outs), (ins Od:$imm),
         !strconcat(opstr, "\t$imm"),
         [], IIAlu, FrmR>; 

class ParInstr<string opstr> : 
  InstSE<(outs), (ins),
         opstr,
         [], IIAlu, FrmR>; 

//===----------------------------------------------------------------------===//
// Instruction definition
//===----------------------------------------------------------------------===//


/// Extension Instructions

def SXTB :  SignalZeroExtension<"sxtb", CPURegsOpnd, IIAlu>, SZExt<0xE, 0x0>;
def SXTH :  SignalZeroExtension<"sxtb", CPURegsOpnd, IIAlu>, SZExt<0xE, 0x1>;
def ZXTH :  SignalZeroExtension<"sxtb", CPURegsOpnd, IIAlu>, SZExt<0xE, 0x3>;

/// Arithmetic Instructions (3 register operands)

defm ADD  : MultArithLogicRtest<0x0, "add", CPURegsOpnd, 1, IIAlu, add>;
defm SUB  : MultArithLogicRtest<0x1, "sub", CPURegsOpnd, 0, IIAlu, sub>;
defm AND  : MultArithLogicRtest<0x9, "and", CPURegsOpnd, 1, IIAlu, and>;
defm OR   : MultArithLogicRtest<0xB, "or", CPURegsOpnd, 1, IIAlu, or>;
defm XOR  : MultArithLogicRtest<0xD, "xor", CPURegsOpnd, 1, IIAlu, xor>;

/// with flags

defm ADDCG  : MultArithCarryInOut<0x2, "addcg", CPURegs, BRFLAG, IIAlu>;
defm SUBCG  : MultArithCarryInOut<0x3, "subcg", CPURegs, BRFLAG, IIAlu>;

defm MUL32  : MultArithLogicRtest<0x15, "mull", CPURegsOpnd, 1, IIImul, mul>;

defm MUL64h  : MultArithLogicRtestV2<0xF, "mul64h", CPURegsOpnd, 1, IIImul>;
defm MUL64hu  : MultArithLogicRtestV2<0x1E, "mul64hu", CPURegsOpnd, 1, IIImul>;

defm DIV_R  : MultIntegerDivision<0x1E, "sdivr", CPURegsOpnd, 1, IIImul, srem>;
defm DIV_Q  : MultIntegerDivision<0x1F, "sdivq", CPURegsOpnd, 1, IIImul, sdiv>;

defm DIV_RU  : MultIntegerDivision<0x1C, "udivr", CPURegsOpnd, 1, IIImul, urem>;
defm DIV_QU  : MultIntegerDivision<0x1D, "udivq", CPURegsOpnd, 1, IIImul, udiv>;


/// Arithmetic Instructions (2 register operands and an immediate)

defm ADDi : MultArithLogicItest<0x0, "add", simm9, CPURegsOpnd, immSExt9, add>,
            IsAsCheapAsAMove; 
defm ANDi  : MultArithLogicItest<0x9, "and", uimm9, CPURegsOpnd, immSExt9, and>;              
defm ORi   : MultArithLogicItest<0xB, "or", uimm9, CPURegsOpnd, immSExt9, or>;              
defm XORi  : MultArithLogicItest<0xD, "xor", uimm9, CPURegsOpnd, immSExt9, xor>;

//def MUL32i  : ArithLogicItest<"mull", simm9, CPURegsOpnd, immSExt9>,
//            Int3I<0xE>; 

defm MUL64hi  : MultArithLogicItest<0xF, "mul64h", simm9, CPURegsOpnd, immSExt9>; 
defm MUL64hui  : MultArithLogicItest<0x1E, "mul64hu", simm9, CPURegsOpnd, immSExt9>; 

/// Carry instructions 

//let Uses = [BRFLAG7] in
//def ADCG1 : ArithCarryInOut<"addcg", CPURegsOpnd, 1, IIAlu, NewTargetadde>, Int3R<0x6>;

//def ADCG2 : ArithCarryOut<"addcg", CPURegsOpnd, 1, IIAlu, NewTargetaddc>, Int3R<0x7>;


//(outs CPURegs:$reg), (ins imm32:$im), [(set CPURegs:$reg, (NewTargetImmediate32 imm:$im))]>;

//def ADDCG_P : PseudoSE<(outs CPURegs:$dest, BRFLAG:$flag1), (ins CPURegs:$src2, CPURegs:$src1, BRFLAG:$flag2), 
//        [(NewTargetadde CPURegs:$dest, BRFLAG:$flag2, CPURegs:$src1, CPURegs:$src2, BRFLAG:$flag1)]>;

/// Load and Store Instructions

defm LB  : LoadMtest<0x3,"ldb", CPURegs, sextloadi8>;
defm LBu : LoadMtest<0x4, "ldbu", CPURegs, zextloadi8>;
defm LH  : LoadMtest<0x1, "ldh", CPURegs, sextloadi16>;
defm LHu : LoadMtest<0x2, "ldhu", CPURegs, zextloadi16>;
defm LW  : LoadMtest<0x0, "ldw", CPURegs, load>;
defm SB  : StoreMtest<0xC, "stb", CPURegs, truncstorei8>;
defm SH  : StoreMtest<0xB, "sth", CPURegs, truncstorei16>;
defm SW  : StoreMtest<0xA, "stw", CPURegs, store>;

/// Call and return

def CALL : CallInst<"call">, Call<0x0, 0x0>;
def PRELD : PreloadInst<"preld">, Call<0x7, 0x0>;

def GOTOLr : RetBasetest<CPURegs>, Call<0x1, 0x1>;

/// Direct jump

def GOTO : GotoDirect<brtarget, "goto", br, bb>, Call<0x1, 0x0>,
              Requires<[RelocStatic]>, IsBranch;

/// Indirect jump

def GOTOR : IndirectBranchtest<CPURegs>, Call<0x1, 0x1>;


/// Branch instructions

def BR		: CBranch<"br", CPUPredRegs>,Branch<0x0>;
def BRF		: CBranch<"brf", CPUPredRegs>, Branch<0x1>;

/// shift instructions implementation


defm SHLi  : Multshift_rotate_imm_test<0x2, "shl", shamt, CPURegsOpnd, shl, immZExt9>;
defm SHRi  : Multshift_rotate_imm_test<0x3, "shr", shamt, CPURegsOpnd, sra, immZExt9>;
defm SHRUi  : Multshift_rotate_imm_test<0x4, "shru", shamt, CPURegsOpnd, srl, immZExt9>;

defm SHLr : Multshift_rotate_reg_test<0x2, "shl", CPURegsOpnd, shl>;
defm SHRr : Multshift_rotate_reg_test<0x3, "shr", CPURegsOpnd, srl>;
defm SHRUr : Multshift_rotate_reg_test<0x4, "shru", CPURegsOpnd, sra>;


/// Comparison instructions with 2 registers operands, which save results in general registers.

defm CMPEQREG  : MultSetCC_RR<0x0, "cmpeq", seteq, CPURegs>;
defm CMPGEREG  : MultSetCC_RR<0x2, "cmpge", setge, CPURegs>; 
defm CMPGEuREG  : MultSetCC_RR<0x3, "cmpgeu", setuge, CPURegs>;
defm CMPGTREG  : MultSetCC_RR<0x4, "cmpgt", setgt, CPURegs>;
defm CMPGTuREG  : MultSetCC_RR<0x5, "cmpgtu", setugt, CPURegs>;
defm CMPLEREG  : MultSetCC_RR<0x6, "cmple", setle, CPURegs>;
defm CMPLEuREG  : MultSetCC_RR<0x7, "cmpleu", setule, CPURegs>;
defm CMPLTREG  : MultSetCC_RR<0x8, "cmplt", setlt, CPURegs>;
defm CMPLTuREG  : MultSetCC_RR<0x9, "cmpltu", setult, CPURegs>;
defm CMPNEREG  : MultSetCC_RR<0x1, "cmpne", setne, CPURegs>; 


/// Comparison instructions with an immediate and a register operands, which save results in general registers.

defm CMPEQiREG  : MultSetCC_IR<0x0, "cmpeq", seteq, simm9, immSExt9, CPURegs>;
defm CMPGEiREG  : MultSetCC_IR<0x2, "cmpge", setge, simm9, immSExt9, CPURegs>; 
defm CMPGEiuREG  : MultSetCC_IR<0x3, "cmpgeu", setuge, simm9, immSExt9, CPURegs>;
defm CMPGTiREG  : MultSetCC_IR<0x4, "cmpgt", setgt, simm9, immSExt9, CPURegs>;
defm CMPGTiuREG  : MultSetCC_IR<0x5, "cmpgtu", setugt, simm9, immSExt9, CPURegs>;
defm CMPLEiREG  : MultSetCC_IR<0x6, "cmple", setle, simm9, immSExt9, CPURegs>;
defm CMPLEiuREG  : MultSetCC_IR<0x7, "cmpleu", setule, simm9, immSExt9, CPURegs>;
defm CMPLTiREG  : MultSetCC_IR<0x8, "cmplt", setlt, simm9, immSExt9, CPURegs>;
defm CMPLTiuREG  : MultSetCC_IR<0x9, "cmpltu", setult, simm9, immSExt9, CPURegs>;
defm CMPNEiREG  : MultSetCC_IR<0x1, "cmpne", setne, simm9, immSExt9, CPURegs>; 


/// Comparison instructions with 2 registers operands, which save results in branch registers.

defm CMPEQBR  : MultSetCC_RB<0x0, "cmpeq", seteq, BRFLAG, CPURegs>;
defm CMPGEBR  : MultSetCC_RB<0x2, "cmpge", setge, BRFLAG, CPURegs>;
defm CMPGEuBR  : MultSetCC_RB<0x3, "cmpgeu", setuge, BRFLAG, CPURegs>;
defm CMPGTBR  : MultSetCC_RB<0x4, "cmpgt", setgt, BRFLAG, CPURegs>;
defm CMPGTuBR  : MultSetCC_RB<0x5, "cmpgtu", setugt, BRFLAG, CPURegs>;
defm CMPLEBR  : MultSetCC_RB<0x6, "cmple", setle, BRFLAG, CPURegs>;
defm CMPLEuBR  : MultSetCC_RB<0x7, "cmple", setule, BRFLAG, CPURegs>;
defm CMPLTBR  : MultSetCC_RB<0x8, "cmplt", setlt, BRFLAG, CPURegs>;
defm CMPLTuBR  : MultSetCC_RB<0x9, "cmpltu", setult, BRFLAG, CPURegs>;
defm CMPNEBR  : MultSetCC_RB<0x1, "cmpne", setne, BRFLAG, CPURegs>;

defm ORLBR : MultiSetCC_RB_NC<0xC, "orl", BRFLAG, CPURegs>;

/// Comparison instructions with an immediate and a register operands, which save results in branch registers.

defm CMPEQiBR  : MultSetCC_IB<0x0, "cmpeq", seteq, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPGEiBR  : MultSetCC_IB<0x2, "cmpge", setge, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPGEiuBR  : MultSetCC_IB<0x3, "cmpgeu", setuge, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPGTiBR  : MultSetCC_IB<0x4, "cmpgt", setgt, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPGTiuBR  : MultSetCC_IB<0x5, "cmpgtu", setugt, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPLEiBR  : MultSetCC_IB<0x6, "cmple", setle, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPLEiuBR  : MultSetCC_IB<0x7, "cmpleu", setule, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPLTiBR  : MultSetCC_IB<0x8, "cmplt", setlt, simm9, immSExt9, BRFLAG, CPURegs>;
defm CMPLTiuBR  : MultSetCC_IB<0x9, "cmpltu", setult, simm9, immSExt9, BRFLAG, CPURegs>; 
defm CMPNEiBR  : MultSetCC_IB<0x1, "cmpne", setne, simm9, immSExt9, BRFLAG, CPURegs>; 



/// Select

defm SELECT : MultSelR<0x0, "slct", BRFLAG, CPURegs>;
defm SELECTi : MultSelI<0x0, "slct", simm9, immSExt9, BRFLAG, CPURegs>;

defm SELECTF : MultSelR<0x1, "slctf", BRFLAG, CPURegs>;
defm SELECTFi : MultSelI<0x1, "slctf", simm9, immSExt9, BRFLAG, CPURegs>;

// Extended immediate instruction

def IMML : Immediate<"imml", uimm23, immZExt23>, Imm<0xA>;

// Par on/off instructions

let Defs = [BRFLAG4] in {

def PARON : ParInstr<"paron">, Par<0x6>;

}
def PAROFF : ParInstr<"paroff">, Par<0x7>;

//===----------------------------------------------------------------------===//
// Pseudo instructions
//===----------------------------------------------------------------------===//

let isTerminator=1, hasDelaySlot=1, isBranch=1, hasCtrlDep=1 in
def BranchBR : PseudoSE<(outs), (ins CPURegs:$reg, brtarget:$btarg), [(NewTargetBranchBR CPURegs:$reg, bb:$btarg)]>;
let isTerminator=1, hasDelaySlot=1, isBranch=1, hasCtrlDep=1 in
def BranchBRF : PseudoSE<(outs), (ins CPURegs:$reg, brtarget:$btarg), [(NewTargetBranchBR CPURegs:$reg, bb:$btarg)]>;


def NewTargetADDC : PseudoSE<(outs CPURegs:$res, CPURegs:$flag), 
                (ins CPURegs:$rega, CPURegs:$regb), 
                []>;

def NewTargetSUBC : PseudoSE<(outs CPURegs:$res, CPURegs:$flag), 
                (ins CPURegs:$rega, CPURegs:$regb), 
                []>;

def NewTargetADDE : PseudoSE<(outs CPURegs:$res, CPURegs:$flag2), 
                (ins CPURegs:$rega, CPURegs:$regb, CPURegs:$flag1), 
                []>;

def NewTargetSUBE : PseudoSE<(outs CPURegs:$res, CPURegs:$flag2), 
                (ins CPURegs:$rega, CPURegs:$regb, CPURegs:$flag1), 
                []>;

def ImmediateConstant32 : PseudoSE<(outs CPURegs:$reg), (ins imm32:$im), [(set CPURegs:$reg, (NewTargetImmediate32 imm:$im))]>;


// Return RA.
let isReturn=1, isTerminator=1, hasDelaySlot=1, isBarrier=1, hasCtrlDep=1 in
def RetRA : PseudoSE<(outs), (ins), [(NewTargetRet)]>;

def NewTargetSelect : PseudoSE<(outs CPURegs:$cond), 
                                (ins CPURegs:$pred,
                                     CPURegs:$tval,
                                     CPURegs:$fval),
                                     []>;

let Defs = [SP], Uses = [SP], hasSideEffects = 1 in {
def ADJCALLSTACKDOWN : NewTargetPseudo<(outs), (ins i32imm:$amt),
                                  [(callseq_start timm:$amt)]>;
def ADJCALLSTACKUP   : NewTargetPseudo<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                                  [(callseq_end timm:$amt1, timm:$amt2)]>;

}

//===----------------------------------------------------------------------===//
// Assembler Pseudo Instructions
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
//  Arbitrary patterns that map to one or more instructions
//===----------------------------------------------------------------------===//

/// Extension patterns
//def : NewTargetPat<(i32 (sext  addr:$src)

/// Conditional branch pattern
//def : NewTargetPat<(brcond CPUPredRegs:$cond, bb:$dst),
//              (BR CPUPredRegs:$cond, bb:$dst)>;	

/// Conditional branch pattern
def : NewTargetPat<(brcond CPURegs:$cond, bb:$dst),
              (BranchBR CPURegs:$cond, bb:$dst)>;		                     

def : NewTargetPat<(i32 imm:$imm),
          (ImmediateConstant32 imm:$imm)>;

// Call
def : NewTargetPat<(NewTargetJmpLink (i32 tglobaladdr:$dst)),
              (CALL tglobaladdr:$dst)>;
def : NewTargetPat<(NewTargetJmpLink (i32 texternalsym:$dst)),
              (CALL texternalsym:$dst)>;
//def : NewTargetPat<(NewTargetJmpLink CPURegs:$dst),
//              (JALR CPURegs:$dst)>;

/// load patterns

def : NewTargetPat<(i32 (extloadi1  addr:$src)), (LBu addr:$src)>;
def : NewTargetPat<(i32 (extloadi8  addr:$src)), (LBu addr:$src)>;
def : NewTargetPat<(i32 (extloadi16 addr:$src)), (LHu addr:$src)>;


def : NewTargetPat<(NewTargetAbs tglobaladdr:$in), (ImmediateConstant32 tglobaladdr:$in)>;
def : NewTargetPat<(NewTargetAbs tblockaddress:$in), (ImmediateConstant32 tblockaddress:$in)>;
def : NewTargetPat<(NewTargetAbs tjumptable:$in), (ImmediateConstant32 tjumptable:$in)>;
def : NewTargetPat<(NewTargetAbs tconstpool:$in), (ImmediateConstant32 tconstpool:$in)>;
def : NewTargetPat<(NewTargetAbs tglobaltlsaddr:$in), (ImmediateConstant32 tglobaltlsaddr:$in)>;
def : NewTargetPat<(NewTargetAbs texternalsym:$in), (ImmediateConstant32 texternalsym:$in)>;

// Small immediates
def : NewTargetPat<(i32 immSExt9:$in),
              (ADDi ZERO, imm:$in)>;

def NOP : PseudoSE<(outs), (ins), []>, PseudoInstExpansion<(ADDi ZERO, ZERO, 0)>;

// FrameIndexes are legalized when they are operands from load/store
// instructions. The same not happens for stack address copies, so an
// add op with mem ComplexPattern is used and the stack address copy
// can be matched. It's similar to Sparc LEA_ADDRi

defm LEA_ADDiu : MultEffectiveAddress<0x0, "add", CPURegs, mem_ea>;

//===----------------------------------------------------------------------===//
// Instruction aliases/macros
//===----------------------------------------------------------------------===//

def : InstAlias<"nop", (ADDi ZERO, ZERO, 0), 1>;
def : InstAlias<"mov $dest = $src1", (ADD CPURegsOpnd:$dest, CPURegsOpnd:$src1, ZERO), 1>;
def : InstAlias<"mov $dest = $imm", (ADDi CPURegsOpnd:$dest, ZERO, Operand<i32>:$imm), 1>;
//def : InstAlias<"mtp $dest = $src2", (ORLBR BRFLAG:$dest, ZERO, CPURegsOpnd:$src2), 1>;

//===----------------------------------------------------------------------===//
// Peephole optimizations
//===----------------------------------------------------------------------===//

def : NewTargetPat<(store (i32 0), addr:$dst), (SW ZERO, addr:$dst)>;  