// Format specifies the encoding used by the instruction.  This is part of the
// ad-hoc solution used to emit machine instruction encodings by our machine
// code emitter.
class Format<bits<4> val> {
  bits<4> Value = val;
}

def Pseudo    : Format<0>;
def FrmR      : Format<1>;
def FrmI      : Format<2>;
def FrmJ      : Format<3>;
def FrmFR     : Format<4>;
def FrmFI     : Format<5>;
def FrmOther  : Format<6>; // Instruction w/ a custom format

// Generic Format
class NewTargetInst<dag outs, dag ins, string asmstr, list<dag> pattern,
               InstrItinClass itin, Format f>: Instruction
{
  field bits<32> Inst;
  Format Form = f;

  let Namespace = "NewTarget";

  let Size = 4;

  bits<6> Opcode = 0;

  // Top 6 bits are the 'opcode' field
  let Inst{31-26} = Opcode;

  let OutOperandList = outs;
  let InOperandList  = ins;

  let AsmString   = asmstr;
  let Pattern     = pattern;
  let Itinerary   = itin;

  //
  // Attributes specific to Mips instructions...
  //
  bits<4> FormBits = Form.Value;

  // TSFlags layout should be kept in sync with MipsInstrInfo.h.
  let TSFlags{3-0}   = FormBits;

  let DecoderNamespace = "NewTarget";
  let PostEncoderMethod = "StopBitEncoder";

  field bits<32> SoftFail = 0;
}
// Instruction Format
class InstSE<dag outs, dag ins, string asmstr, list<dag> pattern,
             InstrItinClass itin, Format f>:
  NewTargetInst<outs, ins, asmstr, pattern, itin, f> {
  //let Predicates = [HasStdEnc];
}

// Pseudo Instructions Format
class NewTargetPseudo<dag outs, dag ins, list<dag> pattern,
                 InstrItinClass itin = IIPseudo> :
  NewTargetInst<outs, ins, "", pattern, itin, Pseudo> {
  let isCodeGenOnly = 1;
  let isPseudo = 1;
}

// Pseudo Instruction Format
class PseudoSE<dag outs, dag ins, list<dag> pattern,
               InstrItinClass itin = IIPseudo>:
  NewTargetPseudo<outs, ins, pattern, itin> {
  //let Predicates = [HasStdEnc];
}

// Pseudo-instructions for alternate assembly syntax (never used by codegen).
// These are aliases that require C++ handling to convert to the target
// instruction, while InstAliases can be handled directly by tblgen.
class NewTargetAsmPseudoInst<dag outs, dag ins, string asmstr>:
  NewTargetInst<outs, ins, asmstr, [], IIPseudo, Pseudo> {
  let isPseudo = 1;
  let Pattern = [];
}

//===----------------------------------------------------------------------===//
// Instructions for VLIW
//===----------------------------------------------------------------------===//


class Int3Ri<bits<5> op, bit pred> {

    bits<1> stopbit = 1;
    bits<6> dest;
    bits<6> src2;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x0;
    let Inst{25-21} = op;
    let Inst{17-12} = dest;
    let Inst{11-6} = src2;
    let Inst{5-0} = src1;
}

class Int3R<bits<5> op> {

    bits<1> stopbit = 1;
    bits<6> dest;
    bits<6> src2;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x0;
    let Inst{25-21} = op;
    let Inst{17-12} = dest;
    let Inst{11-6} = src2;
    let Inst{5-0} = src1;
}

class Int3I<bits<5> op, bit pred> {

    bits<1> stopbit = 1;
    bits<9> isrc2;
    bits<6> idest;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x2;
    let Inst{25-21} = op;
    let Inst{20-12} = isrc2;
    let Inst{11-6} = idest;
    let Inst{5-0} = src1;
}

class SZExt<bits<5> op, bits<2> type> {

    bits<1> stopbit = 1;
    bits<6> idest;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x2;
    let Inst{25-21} = op;
    let Inst{20-14} = 0;
    let Inst{13-12} = type;
    let Inst{11-6} = idest;
    let Inst{5-0} = src1;
}

// a format with mem operand
class Int3I_MEM<bits<5> op, bit pred> {
// isto tem que ser arrumado
    bits<1> stopbit = 1;
    bits<15> addr;
    bits<6> idest;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x2;
    let Inst{25-21} = op;
    let Inst{20-12} = addr{14-6};
    let Inst{11-6} = idest;
    let Inst{5-0} = addr{5-0};
}

class Monadic<bits<9> op> {

    bits<1> stopbit = 1;
    bits<6> idest;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x2;
    let Inst{25-21} = 0xE;
    let Inst{20-12} = op;
    let Inst{11-6} = idest;
    let Inst{5-0} = src1;
}

class Cmp3R_Reg<bits<4> op, bit pred> {

    bits<1> stopbit = 1;
    bits<6> dest;
    bits<6> src2;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-25} = 0x2;
    let Inst{24-21} = op;
    let Inst{17-12} = dest;
    let Inst{11-6} = src2;
    let Inst{5-0} = src1;
}

class Cmp3R_Br<bits<4> op, bit pred> {

    bits<1> stopbit = 1;
    bits<3> bdest;
    bits<6> src2;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-25} = 0x3;
    let Inst{24-21} = op;
    let Inst{20-18} = bdest;
    let Inst{11-6} = src2;
    let Inst{5-0} = src1;
}

class Cmp3I_Reg<bits<4> op, bit pred> {

    bits<1> stopbit = 1;
    bits<9> isrc2;
    bits<6> idest;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-25} = 0x6;
    let Inst{24-21} = op;
    let Inst{20-12} = isrc2;
    let Inst{11-6} = idest;
    let Inst{5-0} = src1;
}

class Cmp3I_Br<bits<4> op, bit pred> {

    bits<1> stopbit = 1;
    bits<9> isrc2;
    bits<3> ibdest;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-25} = 0x7;
    let Inst{24-21} = op;
    let Inst{20-12} = isrc2;
    let Inst{8-6} = ibdest;
    let Inst{5-0} = src1;
}

class Imm<bits<5> op> {

    bits<1> stopbit = 1;
    bits<23> imm;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x1;
    let Inst{27-23} = op;
    let Inst{22-0} = imm;
}

class Par<bits<4> op> {

    bits<1> stopbit = 1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x1;
    let Inst{27-24} = op;
}

class SelectR<bits<3> op, bit pred> {

    bits<1> stopbit = 1;
    bits<3> scond;
    bits<6> dest;
    bits<6> src2;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x1;
    let Inst{27} = 0x0;
    let Inst{26-24} = op;
    let Inst{23-21} = scond;
    let Inst{17-12} = dest;
    let Inst{11-6} = src2;
    let Inst{5-0} = src1;
}

class SelectI<bits<3> op, bit pred> {

    bits<1> stopbit = 1;
    bits<3> scond;
    bits<9> isrc2;
    bits<6> idest;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x1;
    let Inst{27} = 0x1;
    let Inst{26-24} = op;
    let Inst{23-21} = scond;
    let Inst{20-12} = isrc2;
    let Inst{11-6} = idest;
    let Inst{5-0} = src1;
}

class cgen<bits<4> op, bit pred> {
    
    bits<1> stopbit = 1;
    bits<3> scond;
    bits<3> bdest;
    bits<6> dest;
    bits<6> src2;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x1;
    let Inst{27-24} = op;
    let Inst{23-21} = scond;
    let Inst{20-18} = bdest;
    let Inst{17-12} = dest;
    let Inst{11-6} = src2;
    let Inst{5-0} = src1;
}

class SysOp<bits<7> op> {

    bits<1> stopbit =1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x1;
    let Inst{27-21} = op;
}

class SBreak<bits<7> op> {

    bits<1> stopbit = 1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x1;
    let Inst{27-21} = op;
}

class LoadV2<bits<4> op, bits<1> d, bit pred> {

    bits<1> stopbit = 1;
    //bits<1> d;
    //bits<9> isrc2;
    bits<6> idest;
    //bits<6> src1;
    bits<21> addr;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x2;
    let Inst{27-24} = op;
    let Inst{23} = d;
    let Inst{20-12} = addr{20-12};
    let Inst{11-6} = idest;
    let Inst{5-0} = addr{5-0};
}


class StoreV2<bits<5> op, bit pred> {

    bits<1> stopbit = 1;
    //bits<9> isrc2;
    bits<6> src2;
    //bits<6> src1;
    bits<21> addr;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x2;
    let Inst{27-23} = op;
    let Inst{20-12} = addr{20-12};
    let Inst{11-6} = src2;
    let Inst{5-0} = addr{5-0};
}

class Call<bits<3> op, bits<1> lnk> {

    bits<1> stopbit = 1;
    bits<23> target; // btarg
    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x3;
    let Inst{27} = 0x0;
    let Inst{26-24} = op;
    let Inst{23} = lnk;
    let Inst{22-0} = target;
}

class Goto_reg {

    //bits<1> stopbit = 1;
    bits<32> Inst;

    let Inst{31} = 0;
    let Inst{29-28} = 0x3;
    let Inst{27} = 0x0;
    let Inst{26-24} = 0x1;
    let Inst{23} = 0x1;
    let Inst{22-0} = 0x0;
}


class Branch<bits<1> op> {

    bits<1> stopbit = 1;
    //bits<3> bcond;
    bits<23> btarg;
    bits<3> bcond;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x3;
    let Inst{27} = 0x1;
    let Inst{26} = op;
    let Inst{25-23} = bcond;
    let Inst{22-0} = btarg;
}

class Mul64R<bits<5> op, bit pred> {

    bits<1> stopbit = 1;
    bits<6> dest;
    bits<6> src2;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{30} = pred;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x1;
    let Inst{25-21} = op;
    let Inst{17-12} = dest;
    let Inst{11-6} = src2;
    let Inst{5-0} = src1;
}

class Mul64I<bits<5> op> {

    bits<1> stopbit = 1;
    bits<9> isrc2;
    bits<6> idest;
    bits<6> src1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x0;
    let Inst{27-26} = 0x3;
    let Inst{25-21} = op;
    let Inst{20-12} = isrc2;
    let Inst{11-6} = idest;
    let Inst{5-0} = src1;
}

class Asm<bits<5> op> {

    bits<1> stopbit = 1;

    bits<32> Inst;

    let Inst{31} = stopbit;
    let Inst{29-28} = 0x2;
    let Inst{27-26} = 0x3;
    let Inst{25-21} = op;

}

/*
class Int3IIMM<bits<5> op,  dag outs, dag ins, string asmstr,
         list<dag> pattern, InstrItinClass itin>:
  InstSE64<outs, ins, asmstr, pattern, itin, FrmR> {

    bits<1> stopbit = 1;
    bits<9> isrc2;
    bits<6> idest;
    bits<6> src1;
    bits<32> imm;

    bits<64> Inst;

    let Inst{63} = 0;
    let Inst{61-60} = 0x0;
    let Inst{59-58} = 0x2;
    let Inst{57-53} = op;
    let Inst{52-44} = imm{8-0};
    let Inst{43-38} = idest;
    let Inst{37-32} = src1;
    let Inst{31} = stopbit;
    let Inst{29-28} = 0x1;
    let Inst{27-23} = op;
    let Inst{22-0} = imm{31-9};
}
*/