//===-- NewTargetAsmParser.cpp - Parse NewTarget assembly to MCInst instructions ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/NewTargetMCTargetDesc.h"
#include "NewTargetRegisterInfo.h"
#include "NewTargetMCInst.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCParser/MCAsmLexer.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCTargetAsmParser.h"
#include "llvm/Support/TargetRegistry.h"
#include <iostream>

using namespace llvm;

namespace {

    class NewTargetAssemblerOptions {
    public:

        NewTargetAssemblerOptions() :
        aTReg(1), reorder(true), macro(true) {
        }

        unsigned getATRegNum() {
            return aTReg;
        }
        bool setATReg(unsigned Reg);

        bool isReorder() {
            return reorder;
        }

        void setReorder() {
            reorder = true;
        }

        void setNoreorder() {
            reorder = false;
        }

        bool isMacro() {
            return macro;
        }

        void setMacro() {
            macro = true;
        }

        void setNomacro() {
            macro = false;
        }

    private:
        unsigned aTReg;
        bool reorder;
        bool macro;
    };
}

namespace {

    class NewTargetAsmParser : public MCTargetAsmParser {

        enum FpFormatTy {
            FP_FORMAT_NONE = -1,
            FP_FORMAT_S,
            FP_FORMAT_D,
            FP_FORMAT_L,
            FP_FORMAT_W
        } FpFormat;

        MCSubtargetInfo &STI;
        MCAsmParser &Parser;
        NewTargetAssemblerOptions Options;


#define GET_ASSEMBLER_HEADER
#include "NewTargetGenAsmMatcher.inc"

        bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                SmallVectorImpl<MCParsedAsmOperand*> &Operands,
                MCStreamer &Out, unsigned &ErrorInfo,
                bool MatchingInlineAsm);

        bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, SMLoc &EndLoc);

        bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                SMLoc NameLoc,
                SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        bool parseMathOperation(StringRef Name, SMLoc NameLoc,
                SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        bool ParseDirective(AsmToken DirectiveID);

        NewTargetAsmParser::OperandMatchResultTy
        parseMemOperand(SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        NewTargetAsmParser::OperandMatchResultTy
        parseCPURegs(SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        NewTargetAsmParser::OperandMatchResultTy
        parseCPU64Regs(SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        NewTargetAsmParser::OperandMatchResultTy
        parseHWRegs(SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        NewTargetAsmParser::OperandMatchResultTy
        parseHW64Regs(SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        NewTargetAsmParser::OperandMatchResultTy
        parseCCRRegs(SmallVectorImpl<MCParsedAsmOperand*> &Operands);

        bool ParseOperand(SmallVectorImpl<MCParsedAsmOperand*> &,
                StringRef Mnemonic);

        int tryParseRegister(bool is64BitReg);

        bool tryParseRegisterOperand(SmallVectorImpl<MCParsedAsmOperand*> &Operands,
                bool is64BitReg);

        bool needsExpansion(MCInst &Inst);

        void expandInstruction(MCInst &Inst, SMLoc IDLoc,
                SmallVectorImpl<MCInst> &Instructions);
        void expandLoadImm(MCInst &Inst, SMLoc IDLoc,
                SmallVectorImpl<MCInst> &Instructions);
        void expandLoadAddressImm(MCInst &Inst, SMLoc IDLoc,
                SmallVectorImpl<MCInst> &Instructions);
        void expandLoadAddressReg(MCInst &Inst, SMLoc IDLoc,
                SmallVectorImpl<MCInst> &Instructions);
        bool reportParseError(StringRef ErrorMsg);

        bool parseMemOffset(const MCExpr *&Res);
        bool parseRelocOperand(const MCExpr *&Res);

        bool parseDirectiveSet();

        bool parseSetAtDirective();
        bool parseSetNoAtDirective();
        bool parseSetMacroDirective();
        bool parseSetNoMacroDirective();
        bool parseSetReorderDirective();
        bool parseSetNoReorderDirective();

        bool parseDirectiveWord(unsigned Size, SMLoc L);

        MCSymbolRefExpr::VariantKind getVariantKind(StringRef Symbol);

        bool isNewTarget64() const {
            return /*(STI.getFeatureBits() & NewTarget::FeatureNewTarget64) != 0*/ false;
        }

        bool isFP64() const {
            return /*(STI.getFeatureBits() & NewTarget::FeatureFP64Bit) != 0*/ false;
        }

        int matchRegisterName(StringRef Symbol, bool is64BitReg);

        int matchCPURegisterName(StringRef Symbol);

        int matchRegisterByNumber(unsigned RegNum, unsigned RegClass);

        void setFpFormat(FpFormatTy Format) {
            FpFormat = Format;
        }

        void setDefaultFpFormat();

        void setFpFormat(StringRef Format);

        FpFormatTy getFpFormat() {
            return FpFormat;
        }

        bool requestsDoubleOperand(StringRef Mnemonic);

        unsigned getReg(int RC, int RegNo);

        int getATReg();
    public:

        NewTargetAsmParser(MCSubtargetInfo &sti, MCAsmParser &parser)
        : MCTargetAsmParser(), STI(sti), Parser(parser) {
            // Initialize the set of available features.
            setAvailableFeatures(ComputeAvailableFeatures(STI.getFeatureBits()));
        }

        MCAsmParser &getParser() const {
            return Parser;
        }

        MCAsmLexer &getLexer() const {
            return Parser.getLexer();
        }

    };
}

namespace {

    /// NewTargetOperand - Instances of this class represent a parsed NewTarget machine
    /// instruction.

    class NewTargetOperand : public MCParsedAsmOperand {
    public:

        enum RegisterKind {
            Kind_None,
            Kind_CPURegs,
            Kind_CPU64Regs,
            Kind_HWRegs,
            Kind_HW64Regs,
            Kind_FGR32Regs,
            Kind_FGR64Regs,
            Kind_AFGR64Regs,
            Kind_CCRRegs
        };

    private:

        enum KindTy {
            k_CondCode,
            k_CoprocNum,
            k_Immediate,
            k_Memory,
            k_PostIndexRegister,
            k_Register,
            k_Token
        } Kind;

        NewTargetOperand(KindTy K) : MCParsedAsmOperand(), Kind(K) {
        }

        union {

            struct {
                const char *Data;
                unsigned Length;
            } Tok;

            struct {
                unsigned RegNum;
                RegisterKind Kind;
            } Reg;

            struct {
                const MCExpr *Val;
            } Imm;

            struct {
                unsigned Base;
                const MCExpr *Off;
            } Mem;
        };

        SMLoc StartLoc, EndLoc;

    public:

        void addRegOperands(MCInst &Inst, unsigned N) const {
            assert(N == 1 && "Invalid number of operands!");
            Inst.addOperand(MCOperand::CreateReg(getReg()));
        }

        void addExpr(MCInst &Inst, const MCExpr *Expr) const {
            // Add as immediate when possible.  Null MCExpr = 0.
            if (Expr == 0)
                Inst.addOperand(MCOperand::CreateImm(0));
            else if (const MCConstantExpr * CE = dyn_cast<MCConstantExpr>(Expr))
                Inst.addOperand(MCOperand::CreateImm(CE->getValue()));
            else
                Inst.addOperand(MCOperand::CreateExpr(Expr));
        }

        void addImmOperands(MCInst &Inst, unsigned N) const {
            assert(N == 1 && "Invalid number of operands!");
            const MCExpr *Expr = getImm();
            addExpr(Inst, Expr);
        }

        void addMemOperands(MCInst &Inst, unsigned N) const {
            assert(N == 2 && "Invalid number of operands!");

            Inst.addOperand(MCOperand::CreateReg(getMemBase()));

            const MCExpr *Expr = getMemOff();
            addExpr(Inst, Expr);
        }

        bool isReg() const {
            return Kind == k_Register;
        }

        bool isImm() const {
            return Kind == k_Immediate;
        }

        bool isToken() const {
            return Kind == k_Token;
        }

        bool isMem() const {
            return Kind == k_Memory;
        }

        StringRef getToken() const {
            assert(Kind == k_Token && "Invalid access!");
            return StringRef(Tok.Data, Tok.Length);
        }

        unsigned getReg() const {
            assert((Kind == k_Register) && "Invalid access!");
            return Reg.RegNum;
        }

        void setRegKind(RegisterKind RegKind) {
            assert((Kind == k_Register) && "Invalid access!");
            Reg.Kind = RegKind;
        }

        const MCExpr *getImm() const {
            assert((Kind == k_Immediate) && "Invalid access!");
            return Imm.Val;
        }

        unsigned getMemBase() const {
            assert((Kind == k_Memory) && "Invalid access!");
            return Mem.Base;
        }

        const MCExpr *getMemOff() const {
            assert((Kind == k_Memory) && "Invalid access!");
            return Mem.Off;
        }

        static NewTargetOperand *CreateToken(StringRef Str, SMLoc S) {
            NewTargetOperand *Op = new NewTargetOperand(k_Token);
            Op->Tok.Data = Str.data();
            Op->Tok.Length = Str.size();
            Op->StartLoc = S;
            Op->EndLoc = S;
            return Op;
        }

        static NewTargetOperand *CreateReg(unsigned RegNum, SMLoc S, SMLoc E) {
            NewTargetOperand *Op = new NewTargetOperand(k_Register);
            Op->Reg.RegNum = RegNum;
            Op->StartLoc = S;
            Op->EndLoc = E;
            return Op;
        }

        static NewTargetOperand *CreateImm(const MCExpr *Val, SMLoc S, SMLoc E) {
            NewTargetOperand *Op = new NewTargetOperand(k_Immediate);
            Op->Imm.Val = Val;
            Op->StartLoc = S;
            Op->EndLoc = E;
            return Op;
        }

        static NewTargetOperand *CreateMem(unsigned Base, const MCExpr *Off,
                SMLoc S, SMLoc E) {
            NewTargetOperand *Op = new NewTargetOperand(k_Memory);
            Op->Mem.Base = Base;
            Op->Mem.Off = Off;
            Op->StartLoc = S;
            Op->EndLoc = E;
            return Op;
        }

        bool isCPURegsAsm() const {
            return Kind == k_Register && Reg.Kind == Kind_CPURegs;
        }

        void addCPURegsAsmOperands(MCInst &Inst, unsigned N) const {
            Inst.addOperand(MCOperand::CreateReg(Reg.RegNum));
        }

        bool isCPU64RegsAsm() const {
            return Kind == k_Register && Reg.Kind == Kind_CPU64Regs;
        }

        void addCPU64RegsAsmOperands(MCInst &Inst, unsigned N) const {
            Inst.addOperand(MCOperand::CreateReg(Reg.RegNum));
        }

        bool isHWRegsAsm() const {
            assert((Kind == k_Register) && "Invalid access!");
            return Reg.Kind == Kind_HWRegs;
        }

        void addHWRegsAsmOperands(MCInst &Inst, unsigned N) const {
            Inst.addOperand(MCOperand::CreateReg(Reg.RegNum));
        }

        bool isHW64RegsAsm() const {
            assert((Kind == k_Register) && "Invalid access!");
            return Reg.Kind == Kind_HW64Regs;
        }

        void addHW64RegsAsmOperands(MCInst &Inst, unsigned N) const {
            Inst.addOperand(MCOperand::CreateReg(Reg.RegNum));
        }

        void addCCRAsmOperands(MCInst &Inst, unsigned N) const {
            Inst.addOperand(MCOperand::CreateReg(Reg.RegNum));
        }

        bool isCCRAsm() const {
            assert((Kind == k_Register) && "Invalid access!");
            return Reg.Kind == Kind_CCRRegs;
        }

        /// getStartLoc - Get the location of the first token of this operand.

        SMLoc getStartLoc() const {
            return StartLoc;
        }
        /// getEndLoc - Get the location of the last token of this operand.

        SMLoc getEndLoc() const {
            return EndLoc;
        }

        virtual void print(raw_ostream &OS) const {
            llvm_unreachable("unimplemented!");
        }
    };
}

bool NewTargetAsmParser::needsExpansion(MCInst &Inst) {

    
    // rever....
   // return false;
    
    //switch (Inst.getOpcode()) {
    //    case NewTarget::LoadImm32Reg:
     //   case NewTarget::LoadAddr32Imm:
     //   case NewTarget::LoadAddr32Reg:
     //       return true;
     //   default:
     //       return false;
   // }
    return false;
}

void NewTargetAsmParser::expandInstruction(MCInst &Inst, SMLoc IDLoc,
        SmallVectorImpl<MCInst> &Instructions) {
    //switch (Inst.getOpcode()) {
        //case NewTarget::LoadImm32Reg:
        //    return expandLoadImm(Inst, IDLoc, Instructions);
        //case NewTarget::LoadAddr32Imm:
        //    return expandLoadAddressImm(Inst, IDLoc, Instructions);
        //case NewTarget::LoadAddr32Reg:
        //    return expandLoadAddressReg(Inst, IDLoc, Instructions);
    //}
}

void NewTargetAsmParser::expandLoadImm(MCInst &Inst, SMLoc IDLoc,
        SmallVectorImpl<MCInst> &Instructions) {
    /*
    MCInst tmpInst;
    const MCOperand &ImmOp = Inst.getOperand(1);
    assert(ImmOp.isImm() && "expected immediate operand kind");
    const MCOperand &RegOp = Inst.getOperand(0);
    assert(RegOp.isReg() && "expected register operand kind");

    int ImmValue = ImmOp.getImm();
    tmpInst.setLoc(IDLoc);
    if (0 <= ImmValue && ImmValue <= 65535) {
        // for 0 <= j <= 65535.
        // li d,j => ori d,$zero,j
        tmpInst.setOpcode(NewTarget::ORi);
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(
                MCOperand::CreateReg(NewTarget::ZERO));
        tmpInst.addOperand(MCOperand::CreateImm(ImmValue));
        Instructions.push_back(tmpInst);
    } else if (ImmValue < 0 && ImmValue >= -32768) {
        // for -32768 <= j < 0.
        // li d,j => addiu d,$zero,j
        tmpInst.setOpcode(NewTarget::ADDiu);
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(
                MCOperand::CreateReg(NewTarget::ZERO));
        tmpInst.addOperand(MCOperand::CreateImm(ImmValue));
        Instructions.push_back(tmpInst);
    } else {
        // for any other value of j that is representable as a 32-bit integer.
        // li d,j => lui d,hi16(j)
        //           ori d,d,lo16(j)
        tmpInst.setOpcode(NewTarget::LUi);
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateImm((ImmValue & 0xffff0000) >> 16));
        Instructions.push_back(tmpInst);
        tmpInst.clear();
        tmpInst.setOpcode(NewTarget::ORi);
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateImm(ImmValue & 0xffff));
        tmpInst.setLoc(IDLoc);
        Instructions.push_back(tmpInst);
    }
     */
}

void NewTargetAsmParser::expandLoadAddressReg(MCInst &Inst, SMLoc IDLoc,
        SmallVectorImpl<MCInst> &Instructions) {
    /*
    MCInst tmpInst;
    const MCOperand &ImmOp = Inst.getOperand(2);
    assert(ImmOp.isImm() && "expected immediate operand kind");
    const MCOperand &SrcRegOp = Inst.getOperand(1);
    assert(SrcRegOp.isReg() && "expected register operand kind");
    const MCOperand &DstRegOp = Inst.getOperand(0);
    assert(DstRegOp.isReg() && "expected register operand kind");
    int ImmValue = ImmOp.getImm();
    if (-32768 <= ImmValue && ImmValue <= 65535) {
        //for -32768 <= j <= 65535.
        //la d,j(s) => addiu d,s,j
        tmpInst.setOpcode(NewTarget::ADDiu);
        tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateReg(SrcRegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateImm(ImmValue));
        Instructions.push_back(tmpInst);
    } else {
        //for any other value of j that is representable as a 32-bit integer.
        //la d,j(s) => lui d,hi16(j)
        //             ori d,d,lo16(j)
        //             addu d,d,s
        tmpInst.setOpcode(NewTarget::LUi);
        tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateImm((ImmValue & 0xffff0000) >> 16));
        Instructions.push_back(tmpInst);
        tmpInst.clear();
        tmpInst.setOpcode(NewTarget::ORi);
        tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateImm(ImmValue & 0xffff));
        Instructions.push_back(tmpInst);
        tmpInst.clear();
        tmpInst.setOpcode(NewTarget::ADDu);
        tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateReg(SrcRegOp.getReg()));
        Instructions.push_back(tmpInst);
    }
     */
}

void NewTargetAsmParser::expandLoadAddressImm(MCInst &Inst, SMLoc IDLoc,
        SmallVectorImpl<MCInst> &Instructions) {
    /*
    MCInst tmpInst;
    const MCOperand &ImmOp = Inst.getOperand(1);
    assert(ImmOp.isImm() && "expected immediate operand kind");
    const MCOperand &RegOp = Inst.getOperand(0);
    assert(RegOp.isReg() && "expected register operand kind");
    int ImmValue = ImmOp.getImm();
    if (-32768 <= ImmValue && ImmValue <= 65535) {
        //for -32768 <= j <= 65535.
        //la d,j => addiu d,$zero,j
        tmpInst.setOpcode(NewTarget::ADDiu);
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(
                MCOperand::CreateReg(NewTarget::ZERO));
        tmpInst.addOperand(MCOperand::CreateImm(ImmValue));
        Instructions.push_back(tmpInst);
    } else {
        //for any other value of j that is representable as a 32-bit integer.
        //la d,j => lui d,hi16(j)
        //          ori d,d,lo16(j)
        tmpInst.setOpcode(NewTarget::LUi);
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateImm((ImmValue & 0xffff0000) >> 16));
        Instructions.push_back(tmpInst);
        tmpInst.clear();
        tmpInst.setOpcode(NewTarget::ORi);
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
        tmpInst.addOperand(MCOperand::CreateImm(ImmValue & 0xffff));
        Instructions.push_back(tmpInst);
    }
     */
}

bool NewTargetAsmParser::
MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
        SmallVectorImpl<MCParsedAsmOperand*> &Operands,
        MCStreamer &Out, unsigned &ErrorInfo,
        bool MatchingInlineAsm) {
    NewTargetMCInst Inst;
    Inst.setStartPacket();
    Inst.setEndPacket();

    unsigned MatchResult = MatchInstructionImpl(Operands, Inst, ErrorInfo,
            MatchingInlineAsm);

    //std::cout << "aquiiii\n";
    
    switch (MatchResult) {
        default: break;
        case Match_Success:
        {
            if (needsExpansion(Inst)) {
                SmallVector<MCInst, 4> Instructions;
                expandInstruction(Inst, IDLoc, Instructions);
                for (unsigned i = 0; i < Instructions.size(); i++) {
                    Out.EmitInstruction(Instructions[i]);
                }
            } else {
                Inst.setLoc(IDLoc);
                Out.EmitInstruction(Inst);
            }
            
            return false;
        }
        case Match_MissingFeature:
            Error(IDLoc, "instruction requires a CPU feature not currently enabled");
            return true;
        case Match_InvalidOperand:
        {
            SMLoc ErrorLoc = IDLoc;
            if (ErrorInfo != ~0U) {
                if (ErrorInfo >= Operands.size())
                    return Error(IDLoc, "too few operands for instruction");

                ErrorLoc = ((NewTargetOperand*) Operands[ErrorInfo])->getStartLoc();
                if (ErrorLoc == SMLoc()) ErrorLoc = IDLoc;
            }

            return Error(ErrorLoc, "invalid operand for instruction");
        }
        case Match_MnemonicFail:
            return Error(IDLoc, "invalid instruction");
    }
    return true;
}

int NewTargetAsmParser::matchCPURegisterName(StringRef Name) {
    int CC;

    CC = StringSwitch<unsigned>(Name)
            .Case("zero", 0)
            .Case("r1", 1)
            .Case("r2", 2)
            .Case("r3", 3)
            .Case("r4", 4)
            .Case("r5", 5)
            .Case("r6", 6)
            .Case("r7", 7)
            .Case("r8", 8)
            .Case("r9", 9)
            .Case("r10", 10)
            .Case("r11", 11)

            .Case("sp", 12)
            .Case("tp", 13)
            .Case("gp", 14)
            .Case("r15", 15)

            .Case("r16", 16)
            .Case("r17", 17)
            .Case("r18", 18)
            .Case("r19", 19)
            .Case("r20", 20)
            .Case("r21", 21)
            .Case("r22", 22)
            .Case("r23", 23)
            .Case("r24", 24)
            .Case("r25", 25)
            .Case("r26", 26)
            .Case("r27", 27)
            .Case("r28", 28)
            .Case("r29", 29)
            .Case("r30", 30)
            .Case("r31", 31)
            .Case("r32", 32)
            .Case("r33", 33)
            .Case("r34", 34)
            .Case("r35", 35)
            .Case("r36", 36)
            .Case("r37", 37)
            .Case("r38", 38)
            .Case("r39", 39)
            .Case("r40", 40)
            .Case("r41", 41)
            .Case("r42", 42)
            .Case("r43", 43)
            .Case("r44", 44)
            .Case("r45", 45)
            .Case("r46", 46)
            .Case("r47", 47)
            .Case("r48", 48)
            .Case("r49", 49)
            .Case("r50", 50)
            .Case("r51", 51)
            .Case("r52", 52)
            .Case("r53", 53)
            .Case("r54", 54)
            .Case("r55", 55)
            .Case("r56", 56)
            .Case("r57", 57)
            .Case("r58", 58)
            .Case("r59", 59)
            .Case("r60", 60)

            .Case("mar1", 61)
            .Case("mar2", 62)
            .Case("lr", 63)

            .Default(-1);


    return CC;
}

int NewTargetAsmParser::matchRegisterName(StringRef Name, bool is64BitReg) {

    int CC;
    CC = matchCPURegisterName(Name);
    if (CC != -1)
        return matchRegisterByNumber(CC, NewTarget::CPURegsRegClassID);

    return -1;
}

void NewTargetAsmParser::setDefaultFpFormat() {

    if (isNewTarget64() || isFP64())
        FpFormat = FP_FORMAT_D;
    else
        FpFormat = FP_FORMAT_S;
}

// remover

bool NewTargetAsmParser::requestsDoubleOperand(StringRef Mnemonic) {


    return false;
}

void NewTargetAsmParser::setFpFormat(StringRef Format) {

    FpFormat = StringSwitch<FpFormatTy>(Format.lower())
            .Case(".s", FP_FORMAT_S)
            .Case(".d", FP_FORMAT_D)
            .Case(".l", FP_FORMAT_L)
            .Case(".w", FP_FORMAT_W)
            .Default(FP_FORMAT_NONE);
}

bool NewTargetAssemblerOptions::setATReg(unsigned Reg) {
    if (Reg > 31)
        return false;

    aTReg = Reg;
    return true;
}

int NewTargetAsmParser::getATReg() {
    return Options.getATRegNum();
}

unsigned NewTargetAsmParser::getReg(int RC, int RegNo) {
    return *(getContext().getRegisterInfo().getRegClass(RC).begin() + RegNo);
}

int NewTargetAsmParser::matchRegisterByNumber(unsigned RegNum, unsigned RegClass) {

    if (RegNum > 31)
        return -1;

    return getReg(RegClass, RegNum);
}

int NewTargetAsmParser::tryParseRegister(bool is64BitReg) {
    const AsmToken &Tok = Parser.getTok();
    int RegNum = -1;
    
        if (Tok.is(AsmToken::Identifier)) {
            std::string lowerCase = Tok.getString().lower();
            RegNum = matchRegisterName(lowerCase, is64BitReg);
        } else if (Tok.is(AsmToken::Integer))
            RegNum = matchRegisterByNumber(static_cast<unsigned> (Tok.getIntVal()),
                    NewTarget::CPURegsRegClassID);
   
    return RegNum;
}

bool NewTargetAsmParser::
tryParseRegisterOperand(SmallVectorImpl<MCParsedAsmOperand*> &Operands,
        bool is64BitReg) {

    SMLoc S = Parser.getTok().getLoc();
    int RegNo = -1;

    RegNo = tryParseRegister(is64BitReg);
    if (RegNo == -1)
        return true;

    Operands.push_back(NewTargetOperand::CreateReg(RegNo, S,
            Parser.getTok().getLoc()));
    Parser.Lex(); // Eat register token.
    return false;
}

bool NewTargetAsmParser::ParseOperand(SmallVectorImpl<MCParsedAsmOperand*>&Operands,
        StringRef Mnemonic) {
    
    
    // Check if the current operand has a custom associated parser, if so, try to
    // custom parse the operand, or fallback to the general approach.
    OperandMatchResultTy ResTy = MatchOperandParserImpl(Operands, Mnemonic);
    if (ResTy == MatchOperand_Success){
        //std::cout << "sucesso\n";
        return false;
    }    
    // If there wasn't a custom match, try the generic matcher below. Otherwise,
    // there was a match, but an error occurred, in which case, just return that
    // the operand parsing failed.
    if (ResTy == MatchOperand_ParseFail){
        std::cout << "falha\n";
        return true;
    }    

    
    switch (getLexer().getKind()) {
        default:
            Error(Parser.getTok().getLoc(), "unexpected token in operand");
            return true;
        case AsmToken::Dollar:
        {
            std::cout << "eh dollar\n";
            // parse register
            SMLoc S = Parser.getTok().getLoc();
            Parser.Lex(); // Eat dollar token.
            // parse register operand
            if (!tryParseRegisterOperand(Operands, isNewTarget64())) {
                if (getLexer().is(AsmToken::LBrac)) {
                    // check if it is indexed addressing operand
                    Operands.push_back(NewTargetOperand::CreateToken("[", S));
                    Parser.Lex(); // eat brackets
                    if (getLexer().isNot(AsmToken::Dollar))
                        return true;

                    Parser.Lex(); // eat dollar
                    if (tryParseRegisterOperand(Operands, isNewTarget64()))
                        return true;

                    if (!getLexer().is(AsmToken::RBrac))
                        return true;

                    S = Parser.getTok().getLoc();
                    Operands.push_back(NewTargetOperand::CreateToken("]", S));
                    Parser.Lex();
                }
                return false;
            }
            // maybe it is a symbol reference
            StringRef Identifier;
            if (Parser.parseIdentifier(Identifier))
                return true;

            SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);

            MCSymbol *Sym = getContext().GetOrCreateSymbol("$" + Identifier);

            // Otherwise create a symbol ref.
            const MCExpr *Res = MCSymbolRefExpr::Create(Sym, MCSymbolRefExpr::VK_None,
                    getContext());

            Operands.push_back(NewTargetOperand::CreateImm(Res, S, E));
            return false;
        }
        case AsmToken::Identifier:
        case AsmToken::LParen:
        case AsmToken::Minus:
        case AsmToken::Plus:
        case AsmToken::Integer:
        case AsmToken::String:
        {
            // quoted label names
            const MCExpr *IdVal;
            SMLoc S = Parser.getTok().getLoc();
            if (getParser().parseExpression(IdVal))
                return true;
            SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
            Operands.push_back(NewTargetOperand::CreateImm(IdVal, S, E));
            return false;
        }
        case AsmToken::Percent:
        {
            // it is a symbol reference or constant expression
            const MCExpr *IdVal;
            SMLoc S = Parser.getTok().getLoc(); // start location of the operand
            if (parseRelocOperand(IdVal))
                return true;

            SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);

            Operands.push_back(NewTargetOperand::CreateImm(IdVal, S, E));
            return false;
        } // case AsmToken::Percent
    } // switch(getLexer().getKind())
    return true;
}

bool NewTargetAsmParser::parseRelocOperand(const MCExpr *&Res) {

    Parser.Lex(); // eat % token
    const AsmToken &Tok = Parser.getTok(); // get next token, operation
    if (Tok.isNot(AsmToken::Identifier))
        return true;

    std::string Str = Tok.getIdentifier().str();

    Parser.Lex(); // eat identifier
    // now make expression from the rest of the operand
    const MCExpr *IdVal;
    SMLoc EndLoc;

    if (getLexer().getKind() == AsmToken::LParen) {
        while (1) {
            Parser.Lex(); // eat '(' token
            if (getLexer().getKind() == AsmToken::Percent) {
                Parser.Lex(); // eat % token
                const AsmToken &nextTok = Parser.getTok();
                if (nextTok.isNot(AsmToken::Identifier))
                    return true;
                Str += "(%";
                Str += nextTok.getIdentifier();
                Parser.Lex(); // eat identifier
                if (getLexer().getKind() != AsmToken::LParen)
                    return true;
            } else
                break;
        }
        if (getParser().parseParenExpression(IdVal, EndLoc))
            return true;

        while (getLexer().getKind() == AsmToken::RParen)
            Parser.Lex(); // eat ')' token

    } else
        return true; // parenthesis must follow reloc operand

    // Check the type of the expression
    if (const MCConstantExpr * MCE = dyn_cast<MCConstantExpr>(IdVal)) {
        // it's a constant, evaluate lo or hi value
        int Val = MCE->getValue();
        if (Str == "lo") {
            Val = Val & 0xffff;
        } else if (Str == "hi") {
            int LoSign = Val & 0x8000;
            Val = (Val & 0xffff0000) >> 16;
            //lower part is treated as signed int, so if it is negative
            //we must add 1 to hi part to compensate
            if (LoSign)
                Val++;
        }
        Res = MCConstantExpr::Create(Val, getContext());
        return false;
    }

    if (const MCSymbolRefExpr * MSRE = dyn_cast<MCSymbolRefExpr>(IdVal)) {
        // it's a symbol, create symbolic expression from symbol
        StringRef Symbol = MSRE->getSymbol().getName();
        MCSymbolRefExpr::VariantKind VK = getVariantKind(Str);
        Res = MCSymbolRefExpr::Create(Symbol, VK, getContext());
        return false;
    }
    return true;
}

bool NewTargetAsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
        SMLoc &EndLoc) {

    StartLoc = Parser.getTok().getLoc();
    RegNo = tryParseRegister(isNewTarget64());
    EndLoc = Parser.getTok().getLoc();
    return (RegNo == (unsigned) - 1);
}

bool NewTargetAsmParser::parseMemOffset(const MCExpr *&Res) {

    SMLoc S;

    switch (getLexer().getKind()) {
        default:
            return true;
        case AsmToken::Integer:
        case AsmToken::Minus:
        case AsmToken::Plus:
            return (getParser().parseExpression(Res));
        case AsmToken::Percent:
            return parseRelocOperand(Res);
        case AsmToken::LParen:
            return false; // it's probably assuming 0
    }
    return true;
}

NewTargetAsmParser::OperandMatchResultTy NewTargetAsmParser::parseMemOperand(
        SmallVectorImpl<MCParsedAsmOperand*>&Operands) {

    std::cout << "NewTargetAsmParser::parseMemOperand\n";
    const MCExpr *IdVal = 0;
    SMLoc S;
    // first operand is the offset
    S = Parser.getTok().getLoc();

    if (parseMemOffset(IdVal))
        return MatchOperand_ParseFail;

    const AsmToken &Tok = Parser.getTok(); // get next token
    if (Tok.isNot(AsmToken::LBrac)) {
        Error(Parser.getTok().getLoc(), "'[' expected");
        return MatchOperand_ParseFail;
    }

    Parser.Lex(); // Eat '[' token.

    const AsmToken &Tok1 = Parser.getTok(); // get next token
    if (Tok1.is(AsmToken::Dollar)) {
        std::cout << "registrador\n";
        Parser.Lex(); // Eat '$' token.
        if (tryParseRegisterOperand(Operands, isNewTarget64())) {
            Error(Parser.getTok().getLoc(), "unexpected token in operand");
            return MatchOperand_ParseFail;
        }

    } else {
        Error(Parser.getTok().getLoc(), "unexpected token in operand");
        return MatchOperand_ParseFail;
    }

    const AsmToken &Tok2 = Parser.getTok(); // get next token
    if (Tok2.isNot(AsmToken::RBrac)) {
        Error(Parser.getTok().getLoc(), "']' expected");
        return MatchOperand_ParseFail;
    }

    SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);

    Parser.Lex(); // Eat ']' token.

    if (IdVal == 0)
        IdVal = MCConstantExpr::Create(0, getContext());

    // now replace register operand with the mem operand
    NewTargetOperand* op = static_cast<NewTargetOperand*> (Operands.back());
    int RegNo = op->getReg();
    // remove register from operands
    Operands.pop_back();
    // and add memory operand
    Operands.push_back(NewTargetOperand::CreateMem(RegNo, IdVal, S, E));
    delete op;
    return MatchOperand_Success;
}

NewTargetAsmParser::OperandMatchResultTy
NewTargetAsmParser::parseCPU64Regs(SmallVectorImpl<MCParsedAsmOperand*> &Operands) {

    if (!isNewTarget64())
        return MatchOperand_NoMatch;
    // if the first token is not '$' we have an error
    if (Parser.getTok().isNot(AsmToken::Dollar))
        return MatchOperand_NoMatch;

    Parser.Lex(); // Eat $
    if (!tryParseRegisterOperand(Operands, true)) {
        // set the proper register kind
        NewTargetOperand* op = static_cast<NewTargetOperand*> (Operands.back());
        op->setRegKind(NewTargetOperand::Kind_CPU64Regs);
        return MatchOperand_Success;
    }
    return MatchOperand_NoMatch;
}

NewTargetAsmParser::OperandMatchResultTy
NewTargetAsmParser::parseCPURegs(SmallVectorImpl<MCParsedAsmOperand*> &Operands) {

    // if the first token is not '$' we have an error
    if (Parser.getTok().isNot(AsmToken::Dollar))
        return MatchOperand_NoMatch;

    Parser.Lex(); // Eat $
    if (!tryParseRegisterOperand(Operands, false)) {
        // set the propper register kind
        NewTargetOperand* op = static_cast<NewTargetOperand*> (Operands.back());
        op->setRegKind(NewTargetOperand::Kind_CPURegs);
        return MatchOperand_Success;
    }
    return MatchOperand_NoMatch;
}

NewTargetAsmParser::OperandMatchResultTy
NewTargetAsmParser::parseHWRegs(SmallVectorImpl<MCParsedAsmOperand*> &Operands) {
    /*
        if (isNewTarget64())
            return MatchOperand_NoMatch;

        // if the first token is not '$' we have error
        if (Parser.getTok().isNot(AsmToken::Dollar))
            return MatchOperand_NoMatch;
        SMLoc S = Parser.getTok().getLoc();
        Parser.Lex(); // Eat $

        const AsmToken &Tok = Parser.getTok(); // get next token
        if (Tok.isNot(AsmToken::Integer))
            return MatchOperand_NoMatch;

        unsigned RegNum = Tok.getIntVal();
        // at the moment only hwreg29 is supported
        if (RegNum != 29)
            return MatchOperand_ParseFail;

        NewTargetOperand *op = NewTargetOperand::CreateReg(NewTarget::HWR29, S,
                Parser.getTok().getLoc());
        op->setRegKind(NewTargetOperand::Kind_HWRegs);
        Operands.push_back(op);

        Parser.Lex(); // Eat reg number
     */
    return MatchOperand_Success;
}

NewTargetAsmParser::OperandMatchResultTy
NewTargetAsmParser::parseHW64Regs(SmallVectorImpl<MCParsedAsmOperand*> &Operands) {

    /*
    if (!isNewTarget64())
        return MatchOperand_NoMatch;
    //if the first token is not '$' we have error
    if (Parser.getTok().isNot(AsmToken::Dollar))
        return MatchOperand_NoMatch;
    SMLoc S = Parser.getTok().getLoc();
    Parser.Lex(); // Eat $

    const AsmToken &Tok = Parser.getTok(); // get next token
    if (Tok.isNot(AsmToken::Integer))
        return MatchOperand_NoMatch;

    unsigned RegNum = Tok.getIntVal();
    // at the moment only hwreg29 is supported
    if (RegNum != 29)
        return MatchOperand_ParseFail;

    NewTargetOperand *op = NewTargetOperand::CreateReg(NewTarget::HWR29_64, S,
            Parser.getTok().getLoc());
    op->setRegKind(NewTargetOperand::Kind_HW64Regs);
    Operands.push_back(op);

    Parser.Lex(); // Eat reg number
     */
    return MatchOperand_Success;
}

NewTargetAsmParser::OperandMatchResultTy
NewTargetAsmParser::parseCCRRegs(SmallVectorImpl<MCParsedAsmOperand*> &Operands) {
    /*
    unsigned RegNum;
    //if the first token is not '$' we have error
    if (Parser.getTok().isNot(AsmToken::Dollar))
        return MatchOperand_NoMatch;
    SMLoc S = Parser.getTok().getLoc();
    Parser.Lex(); // Eat $

    const AsmToken &Tok = Parser.getTok(); // get next token
    if (Tok.is(AsmToken::Integer)) {
        RegNum = Tok.getIntVal();
        // at the moment only fcc0 is supported
        if (RegNum != 0)
            return MatchOperand_ParseFail;
    } else if (Tok.is(AsmToken::Identifier)) {
        // at the moment only fcc0 is supported
        if (Tok.getIdentifier() != "fcc0")
            return MatchOperand_ParseFail;
    } else
        return MatchOperand_NoMatch;

    NewTargetOperand *op = NewTargetOperand::CreateReg(NewTarget::FCC0, S,
            Parser.getTok().getLoc());
    op->setRegKind(NewTargetOperand::Kind_CCRRegs);
    Operands.push_back(op);

    Parser.Lex(); // Eat reg number
     */
    return MatchOperand_Success;
}

MCSymbolRefExpr::VariantKind NewTargetAsmParser::getVariantKind(StringRef Symbol) {

    MCSymbolRefExpr::VariantKind VK
            = StringSwitch<MCSymbolRefExpr::VariantKind>(Symbol)
            /*
            .Case("hi", MCSymbolRefExpr::VK_NewTarget_ABS_HI)
            .Case("lo", MCSymbolRefExpr::VK_NewTarget_ABS_LO)
            .Case("gp_rel", MCSymbolRefExpr::VK_NewTarget_GPREL)
            .Case("call16", MCSymbolRefExpr::VK_NewTarget_GOT_CALL)
            .Case("got", MCSymbolRefExpr::VK_NewTarget_GOT)
            .Case("tlsgd", MCSymbolRefExpr::VK_NewTarget_TLSGD)
            .Case("tlsldm", MCSymbolRefExpr::VK_NewTarget_TLSLDM)
            .Case("dtprel_hi", MCSymbolRefExpr::VK_NewTarget_DTPREL_HI)
            .Case("dtprel_lo", MCSymbolRefExpr::VK_NewTarget_DTPREL_LO)
            .Case("gottprel", MCSymbolRefExpr::VK_NewTarget_GOTTPREL)
            .Case("tprel_hi", MCSymbolRefExpr::VK_NewTarget_TPREL_HI)
            .Case("tprel_lo", MCSymbolRefExpr::VK_NewTarget_TPREL_LO)
            .Case("got_disp", MCSymbolRefExpr::VK_NewTarget_GOT_DISP)
            .Case("got_page", MCSymbolRefExpr::VK_NewTarget_GOT_PAGE)
            .Case("got_ofst", MCSymbolRefExpr::VK_NewTarget_GOT_OFST)
            .Case("hi(%neg(%gp_rel", MCSymbolRefExpr::VK_NewTarget_GPOFF_HI)
            .Case("lo(%neg(%gp_rel", MCSymbolRefExpr::VK_NewTarget_GPOFF_LO)
             */
            .Default(MCSymbolRefExpr::VK_None);

    return VK;
}

bool NewTargetAsmParser::
parseMathOperation(StringRef Name, SMLoc NameLoc,
        SmallVectorImpl<MCParsedAsmOperand*> &Operands) {
    // split the format
    size_t Start = Name.find('.'), Next = Name.rfind('.');
    StringRef Format1 = Name.slice(Start, Next);
    // and add the first format to the operands
    Operands.push_back(NewTargetOperand::CreateToken(Format1, NameLoc));
    // now for the second format
    StringRef Format2 = Name.slice(Next, StringRef::npos);
    Operands.push_back(NewTargetOperand::CreateToken(Format2, NameLoc));

    std::cout << "parseMathOperation\n";

    // set the format for the first register
    setFpFormat(Format1);

    // Read the remaining operands.
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        // Read the first operand.
        if (ParseOperand(Operands, Name)) {
            SMLoc Loc = getLexer().getLoc();
            Parser.eatToEndOfStatement();
            return Error(Loc, "unexpected token in argument list");
        }

        if (getLexer().isNot(AsmToken::Comma)) {
            SMLoc Loc = getLexer().getLoc();
            Parser.eatToEndOfStatement();
            return Error(Loc, "unexpected token in argument list");

        }
        Parser.Lex(); // Eat the comma.

        //set the format for the first register
        setFpFormat(Format2);

        // Parse and remember the operand.
        if (ParseOperand(Operands, Name)) {
            SMLoc Loc = getLexer().getLoc();
            Parser.eatToEndOfStatement();
            return Error(Loc, "unexpected token in argument list");
        }
    }

    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        SMLoc Loc = getLexer().getLoc();
        Parser.eatToEndOfStatement();
        return Error(Loc, "unexpected token in argument list");
    }

    Parser.Lex(); // Consume the EndOfStatement
    return false;
}

bool NewTargetAsmParser::
ParseInstruction(ParseInstructionInfo &Info, StringRef Name, SMLoc NameLoc,
        SmallVectorImpl<MCParsedAsmOperand*> &Operands) {
    StringRef Mnemonic;

    //std::cout << "ParseInstruction\n";


    Operands.push_back(NewTargetOperand::CreateToken(Name, NameLoc));
    Mnemonic = Name;

    //std::cout << "Mnemonic: " << Name.data() << "\n";

    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        // Read the first operand.
        if (ParseOperand(Operands, Mnemonic)) {
            SMLoc Loc = getLexer().getLoc();
            Parser.eatToEndOfStatement();
            return Error(Loc, "unexpected token in argument list");
        }

        //std::cout << "-> " << getLexer().getTok().getString().data() << "\n";
        
        while (getLexer().is(AsmToken::Comma) || getLexer().is(AsmToken::Equal)) {
            
            if(getLexer().is(AsmToken::Equal)){
                Operands.push_back(NewTargetOperand::CreateToken("=", getLexer().getLoc()));
            }
            
            Parser.Lex(); // Eat the comma.
            //std::cout << "-> proximo operando\n";
            // Parse and remember the operand.
            if (ParseOperand(Operands, Name)) {
                SMLoc Loc = getLexer().getLoc();
                Parser.eatToEndOfStatement();
                return Error(Loc, "unexpected token in argument list");
            }
        }
    } else {
        //std::cout << "EndOfStatement\n";
    }

    /*
    // floating point instructions: should register be treated as double?
    if (requestsDoubleOperand(Name)) {
        setFpFormat(FP_FORMAT_D);
        Operands.push_back(NewTargetOperand::CreateToken(Name, NameLoc));
        Mnemonic = Name;
    } else {
        setDefaultFpFormat();
        // Create the leading tokens for the mnemonic, split by '.' characters.
        size_t Start = 0, Next = Name.find('.');
        Mnemonic = Name.slice(Start, Next);

        Operands.push_back(NewTargetOperand::CreateToken(Mnemonic, NameLoc));

        if (Next != StringRef::npos) {
            // there is a format token in mnemonic
            // StringRef Rest = Name.slice(Next, StringRef::npos);
            size_t Dot = Name.find('.', Next + 1);
            StringRef Format = Name.slice(Next, Dot);
            if (Dot == StringRef::npos) //only one '.' in a string, it's a format
                Operands.push_back(NewTargetOperand::CreateToken(Format, NameLoc));
            else {
                if (Name.startswith("c.")) {
                    // floating point compare, add '.' and immediate represent for cc
                    Operands.push_back(NewTargetOperand::CreateToken(".", NameLoc));
                    int Cc = ConvertCcString(Format);
                    if (Cc == -1) {
                        return Error(NameLoc, "Invalid conditional code");
                    }
                    SMLoc E = SMLoc::getFromPointer(
                            Parser.getTok().getLoc().getPointer() - 1);
                    Operands.push_back(NewTargetOperand::CreateImm(
                            MCConstantExpr::Create(Cc, getContext()), NameLoc, E));
                } else {
                    // trunc, ceil, floor ...
                    return parseMathOperation(Name, NameLoc, Operands);
                }

                // the rest is a format
                Format = Name.slice(Dot, StringRef::npos);
                Operands.push_back(NewTargetOperand::CreateToken(Format, NameLoc));
            }

            setFpFormat(Format);
        }
    }

    // Read the remaining operands.
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        // Read the first operand.
        if (ParseOperand(Operands, Mnemonic)) {
            SMLoc Loc = getLexer().getLoc();
            Parser.eatToEndOfStatement();
            return Error(Loc, "unexpected token in argument list");
        }

        while (getLexer().is(AsmToken::Comma)) {
            Parser.Lex(); // Eat the comma.

            // Parse and remember the operand.
            if (ParseOperand(Operands, Name)) {
                SMLoc Loc = getLexer().getLoc();
                Parser.eatToEndOfStatement();
                return Error(Loc, "unexpected token in argument list");
            }
        }
    }

    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        SMLoc Loc = getLexer().getLoc();
        Parser.eatToEndOfStatement();
        return Error(Loc, "unexpected token in argument list");
    }

     */
    Parser.Lex(); // Consume the EndOfStatement
    return false;
}

bool NewTargetAsmParser::reportParseError(StringRef ErrorMsg) {
    SMLoc Loc = getLexer().getLoc();
    Parser.eatToEndOfStatement();
    return Error(Loc, ErrorMsg);
}

bool NewTargetAsmParser::parseSetNoAtDirective() {
    // line should look like:
    //  .set noat
    // set at reg to 0
    Options.setATReg(0);
    // eat noat
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        reportParseError("unexpected token in statement");
        return false;
    }
    Parser.Lex(); // Consume the EndOfStatement
    return false;
}

bool NewTargetAsmParser::parseSetAtDirective() {
    // line can be
    //  .set at - defaults to $1
    // or .set at=$reg
    int AtRegNo;
    getParser().Lex();
    if (getLexer().is(AsmToken::EndOfStatement)) {
        Options.setATReg(1);
        Parser.Lex(); // Consume the EndOfStatement
        return false;
    } else if (getLexer().is(AsmToken::Equal)) {
        getParser().Lex(); //eat '='
        if (getLexer().isNot(AsmToken::Dollar)) {
            reportParseError("unexpected token in statement");
            return false;
        }
        Parser.Lex(); // eat '$'
        const AsmToken &Reg = Parser.getTok();
        if (Reg.is(AsmToken::Identifier)) {
            AtRegNo = matchCPURegisterName(Reg.getIdentifier());
        } else if (Reg.is(AsmToken::Integer)) {
            AtRegNo = Reg.getIntVal();
        } else {
            reportParseError("unexpected token in statement");
            return false;
        }

        if (AtRegNo < 1 || AtRegNo > 31) {
            reportParseError("unexpected token in statement");
            return false;
        }

        if (!Options.setATReg(AtRegNo)) {
            reportParseError("unexpected token in statement");
            return false;
        }
        getParser().Lex(); //eat reg

        if (getLexer().isNot(AsmToken::EndOfStatement)) {
            reportParseError("unexpected token in statement");
            return false;
        }
        Parser.Lex(); // Consume the EndOfStatement
        return false;
    } else {
        reportParseError("unexpected token in statement");
        return false;
    }
}

bool NewTargetAsmParser::parseSetReorderDirective() {
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        reportParseError("unexpected token in statement");
        return false;
    }
    Options.setReorder();
    Parser.Lex(); // Consume the EndOfStatement
    return false;
}

bool NewTargetAsmParser::parseSetNoReorderDirective() {
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        reportParseError("unexpected token in statement");
        return false;
    }
    Options.setNoreorder();
    Parser.Lex(); // Consume the EndOfStatement
    return false;
}

bool NewTargetAsmParser::parseSetMacroDirective() {
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        reportParseError("unexpected token in statement");
        return false;
    }
    Options.setMacro();
    Parser.Lex(); // Consume the EndOfStatement
    return false;
}

bool NewTargetAsmParser::parseSetNoMacroDirective() {
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        reportParseError("`noreorder' must be set before `nomacro'");
        return false;
    }
    if (Options.isReorder()) {
        reportParseError("`noreorder' must be set before `nomacro'");
        return false;
    }
    Options.setNomacro();
    Parser.Lex(); // Consume the EndOfStatement
    return false;
}

bool NewTargetAsmParser::parseDirectiveSet() {

    // get next token
    const AsmToken &Tok = Parser.getTok();

    if (Tok.getString() == "noat") {
        return parseSetNoAtDirective();
    } else if (Tok.getString() == "at") {
        return parseSetAtDirective();
    } else if (Tok.getString() == "reorder") {
        return parseSetReorderDirective();
    } else if (Tok.getString() == "noreorder") {
        return parseSetNoReorderDirective();
    } else if (Tok.getString() == "macro") {
        return parseSetMacroDirective();
    } else if (Tok.getString() == "nomacro") {
        return parseSetNoMacroDirective();
    } else if (Tok.getString() == "nomips16") {
        // ignore this directive for now
        Parser.eatToEndOfStatement();
        return false;
    } else if (Tok.getString() == "nomicromips") {
        // ignore this directive for now
        Parser.eatToEndOfStatement();
        return false;
    }

    return true;
}

/// parseDirectiveWord
///  ::= .word [ expression (, expression)* ]

bool NewTargetAsmParser::parseDirectiveWord(unsigned Size, SMLoc L) {
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
        for (;;) {
            const MCExpr *Value;
            if (getParser().parseExpression(Value))
                return true;

            getParser().getStreamer().EmitValue(Value, Size);

            if (getLexer().is(AsmToken::EndOfStatement))
                break;

            // FIXME: Improve diagnostic.
            if (getLexer().isNot(AsmToken::Comma))
                return Error(L, "unexpected token in directive");
            Parser.Lex();
        }
    }

    Parser.Lex();
    return false;
}

bool NewTargetAsmParser::ParseDirective(AsmToken DirectiveID) {

    StringRef IDVal = DirectiveID.getString();

    if (IDVal == ".ent") {
        // ignore this directive for now
        Parser.Lex();
        return false;
    }

    if (IDVal == ".end") {
        // ignore this directive for now
        Parser.Lex();
        return false;
    }

    if (IDVal == ".frame") {
        // ignore this directive for now
        Parser.eatToEndOfStatement();
        return false;
    }

    if (IDVal == ".set") {
        return parseDirectiveSet();
    }

    if (IDVal == ".fmask") {
        // ignore this directive for now
        Parser.eatToEndOfStatement();
        return false;
    }

    if (IDVal == ".mask") {
        // ignore this directive for now
        Parser.eatToEndOfStatement();
        return false;
    }

    if (IDVal == ".gpword") {
        // ignore this directive for now
        Parser.eatToEndOfStatement();
        return false;
    }

    if (IDVal == ".word") {
        parseDirectiveWord(4, DirectiveID.getLoc());
        return false;
    }

    return true;
}

extern "C" void LLVMInitializeNewTargetAsmParser() {
    RegisterMCAsmParser<NewTargetAsmParser> X(TheNewTarget);
}


#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "NewTargetGenAsmMatcher.inc"
