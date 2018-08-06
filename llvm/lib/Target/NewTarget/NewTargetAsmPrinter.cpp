/*
 * NewTargetAsmPrinter.cpp
 *
 *  Created on: Mar 13, 2013
 *      Author: andreu
 */

#include "NewTarget.h"
#include "NewTargetAsmPrinter.h"
#include "NewTargetMCInst.h"
#include "InstPrinter/NewTargetInstPrinter.h"
#include "MCTargetDesc/NewTargetBaseInfo.h"
//#include "MCTargetDesc/NewTargetELFStreamer.h"

#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/Twine.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/Instructions.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ELF.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/Mangler.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/CodeGen/GCMetadataPrinter.h"
#include "llvm/MC/MCTargetAsmParser.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/MemoryBuffer.h"
#include <iostream>

using namespace llvm;

namespace {

    struct SrcMgrDiagInfo {
        const MDNode *LocInfo;
        LLVMContext::InlineAsmDiagHandlerTy DiagHandler;
        void *DiagContext;
    };
}

char NewTargetAsmPrinter::ID = 0;

bool NewTargetAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
    NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();
    AsmPrinter::runOnMachineFunction(MF);
    return true;
}

bool NewTargetAsmPrinter::lowerOperand(const MachineOperand &MO, MCOperand &MCOp) {
    MCOp = MCInstLowering.LowerOperand(MO);
    return MCOp.isValid();
    return true;
}

#include "NewTargetGenMCPseudoLowering.inc"

void NewTargetAsmPrinter::EmitInstruction(const MachineInstr *MI) {

    //std::cout << "NewTargetAsmPrinter::EmitInstruction partially implemented\n";

    if (MI->isDebugValue()) {
        SmallString<128> Str;
        raw_svector_ostream OS(Str);

        PrintDebugValueComment(MI, OS);
        return;
    }

    if (MI->isBundle()) {
        //std::cout << "Bundle size: " << MI->getBundleSize() << "\n";
        std::list<const MachineInstr*> BundleMIs;

        const MachineBasicBlock *MBB = MI->getParent();
        MachineBasicBlock::const_instr_iterator MII = MI;
        ++MII;
        unsigned int IgnoreCount = 0;
        while (MII != MBB->end() && MII->isInsideBundle()) {
            const MachineInstr *MInst = MII;
            if (MInst->getOpcode() == TargetOpcode::DBG_VALUE ||
                    MInst->getOpcode() == TargetOpcode::IMPLICIT_DEF) {
                IgnoreCount++;
                ++MII;
                continue;
            }

            // control flow instructions must be at the begining of the bundle (first operation))
            // load and store operations must be defined as first or second ops in a bundle, so
            // we need to manages the instruction to follow that order.
            // we do this here because it is difficult to control operation orderings from
            // the VLIW packetizer point of view.
            if (MInst->isCall() || MInst->isBranch() || MInst->isReturn()) {
                BundleMIs.push_front(MInst);
            } else if (MInst->mayLoad() ||
                    MInst->mayStore() ||
                    (MInst->getOpcode() == NewTarget::MUL32) ||
                    (MInst->getOpcode() == NewTarget::MUL64h) ||
                    (MInst->getOpcode() == NewTarget::MUL64hi) ||
                    (MInst->getOpcode() == NewTarget::MUL64hu) ||
                    (MInst->getOpcode() == NewTarget::MUL64hui) ||
                    (MInst->getOpcode() == NewTarget::MUL32_p) ||
                    (MInst->getOpcode() == NewTarget::MUL64h_p) ||
                    (MInst->getOpcode() == NewTarget::MUL64hi_p) ||
                    (MInst->getOpcode() == NewTarget::MUL64hu_p) ||
                    (MInst->getOpcode() == NewTarget::MUL64hui_p) ||
                    // predicated instructions return false to mayLoad and mayStore
                    (MInst->getOpcode() == NewTarget::LB_p) ||
                    (MInst->getOpcode() == NewTarget::LBu_p) ||
                    (MInst->getOpcode() == NewTarget::LH_p) ||
                    (MInst->getOpcode() == NewTarget::LHu_p) ||
                    (MInst->getOpcode() == NewTarget::LW_p) ||
                    (MInst->getOpcode() == NewTarget::SB_p) ||
                    (MInst->getOpcode() == NewTarget::SH_p) ||
                    (MInst->getOpcode() == NewTarget::SW_p)) {

                if (!BundleMIs.empty()) {
                    const MachineInstr* MInstFront = BundleMIs.front();
                    if (MInstFront->isCall() || 
                            MInstFront->isBranch() || 
                            MInstFront->isReturn()) {
                        // exists an instruction that is a call call/branch/return 
                        // we must put this instruction after the call/branch/return 
                        std::list<const MachineInstr*>::iterator IT = BundleMIs.begin();
                        IT++;
                        BundleMIs.insert(IT, MInst);
                    } else {
                        //the first instruction is not a call, so we can put the instruction
                        // (load or store) at the beginning of the bundle
                        BundleMIs.push_front(MInst);
                    }
                } else {
                    // this is the first or the olny instruction of the bundle, so we
                    // can put the instruction directly on the front
                    BundleMIs.push_front(MInst);
                }
            } else {
                // other instruction at the original order.
                BundleMIs.push_back(MInst);
            }

            ++MII;
        }
        unsigned Size = BundleMIs.size();
        
        //std::cout << "->Bundle size: " << Size << "\n";
        
        assert((Size + IgnoreCount) == MI->getBundleSize() && "Corrupt Bundle!");
        std::list<const MachineInstr*>::iterator IT = BundleMIs.begin();
        for (unsigned Index = 0; Index < Size; Index++) {
            NewTargetMCInst MCI;
            MCI.setBundleSize(Size);

            if (Index == 0) {
                MCI.setStartPacket();
            }

            if (Index == (Size - 1)) {
                MCI.setEndPacket();
            }

            //MCI.setEndPacket(true);

            MCInstLowering.Lower(*IT, MCI);

            OutStreamer.EmitInstruction(MCI);
            IT++;
        }
    } else {

        // std::cout << "Bundle size: 1\n"; 
        // MI->dump();
        NewTargetMCInst MCI;
        NewTargetMCInst MCIImm;
        // immediate extension comes here
        if (MI->isBundledWithSucc()) {
            //std::cout << "@1\n";
            MCI.setStartPacket();
            MCIImm.setEndPacket();

            MCI.setBundleSize(2);
            MCIImm.setBundleSize(2);

            MCInstLowering.Lower(MI, MCI);
            OutStreamer.EmitInstruction(MCI);

            MCInstLowering.Lower(MI->getNextNode(), MCIImm);
            OutStreamer.EmitInstruction(MCIImm);
        } else {
            //std::cout << "@2\n";
            MCI.setStartPacket();
            MCI.setEndPacket();
            MCInstLowering.Lower(MI, MCI);
            OutStreamer.EmitInstruction(MCI);
        }
    }
}

//===----------------------------------------------------------------------===//
//
//  NewTarget Asm Directives
//
//  -- Frame directive "frame Stackpointer, Stacksize, RARegister"
//  Describe the stack frame.
//
//  -- Mask directives "(f)mask  bitmask, offset"
//  Tells the assembler which registers are saved and where.
//  bitmask - contain a little endian bitset indicating which registers are
//            saved on function prologue (e.g. with a 0x80000000 mask, the
//            assembler knows the register 31 (RA) is saved at prologue.
//  offset  - the position before stack pointer subtraction indicating where
//            the first saved register on prologue is located. (e.g. with a
//
//  Consider the following function prologue:
//
//    .frame  $fp,48,$ra
//    .mask   0xc0000000,-8
//       addiu $sp, $sp, -48
//       sw $ra, 40($sp)
//       sw $fp, 36($sp)
//
//    With a 0xc0000000 mask, the assembler knows the register 31 (RA) and
//    30 (FP) are saved at prologue. As the save order on prologue is from
//    left to right, RA is saved first. A -8 offset means that after the
//    stack pointer subtration, the first register in the mask (RA) will be
//    saved at address 48-8=40.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Mask directives
//===----------------------------------------------------------------------===//

// Create a bitmask with all callee saved registers for CPU or Floating Point
// registers. For CPU registers consider RA, GP and FP for saving if necessary.

void NewTargetAsmPrinter::printSavedRegsBitmask(raw_ostream &O) {
    //TODO
    //std::cout << "NewTargetAsmPrinter::printSavedRegsBitmask not implemented\n";
}

// Print a 32 bit hex number with all numbers.

void NewTargetAsmPrinter::printHex32(unsigned Value, raw_ostream &O) {
    //TODO
    //std::cout << "NewTargetAsmPrinter::printHex32 not implemented\n";
}

//===----------------------------------------------------------------------===//
// Frame and Set directives
//===----------------------------------------------------------------------===//

/// Frame Directive

void NewTargetAsmPrinter::emitFrameDirective() {
    //TODO
    //std::cout << "NewTargetAsmPrinter::emitFrameDirective not implemented\n";
}

/// Emit Set directives.

const char *NewTargetAsmPrinter::getCurrentABIString() const {
    //TODO
    //std::cout << "NewTargetAsmPrinter::getCurrentABIString not implemented\n";
    return (char*) 0;
}

void NewTargetAsmPrinter::EmitFunctionEntryLabel() {
    //TODO
    //std::cout << "NewTargetAsmPrinter::EmitFunctionEntryLabel partially implemented\n";
    OutStreamer.EmitLabel(CurrentFnSym);
}

/// EmitFunctionBodyStart - Targets can override this to emit stuff before
/// the first basic block in the function.

void NewTargetAsmPrinter::EmitFunctionBodyStart() {

    //std::cout << "NewTargetAsmPrinter::EmitFunctionBodyStart partially implemented\n";
    MCInstLowering.Initialize(Mang, &MF->getContext());

    emitFrameDirective();

    if (OutStreamer.hasRawTextSupport()) {
        SmallString<128> Str;
        raw_svector_ostream OS(Str);
        printSavedRegsBitmask(OS);
        OutStreamer.EmitRawText(OS.str());
    }
}

/// EmitFunctionBodyEnd - Targets can override this to emit stuff after
/// the last basic block in the function.

void NewTargetAsmPrinter::EmitFunctionBodyEnd() {
    //TODO
    //std::cout << "NewTargetAsmPrinter::EmitFunctionBodyEnd not implemented\n";
}

/// isBlockOnlyReachableByFallthough - Return true if the basic block has
/// exactly one predecessor and the control transfer mechanism between
/// the predecessor and this block is a fall-through.

bool NewTargetAsmPrinter::isBlockOnlyReachableByFallthrough(const MachineBasicBlock*
        MBB) const {
    //TODO
    //std::cout << "NewTargetAsmPrinter::isBlockOnlyReachableByFallthrough not implemented\n";
    return false;
}

// Print out an operand for an inline asm expression.

bool NewTargetAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNum,
        unsigned AsmVariant, const char *ExtraCode,
        raw_ostream &O) {
    //TODO
    //std::cout << "NewTargetAsmPrinter::PrintAsmOperand not implemented\n";

    // Does this asm operand have a single letter operand modifier?
    if (ExtraCode && ExtraCode[0]) {
        if (ExtraCode[1] != 0) return true; // Unknown modifier.

        const MachineOperand &MO = MI->getOperand(OpNum);
        switch (ExtraCode[0]) {
            default:
                // See if this is a generic print operand
                return AsmPrinter::PrintAsmOperand(MI, OpNum, AsmVariant, ExtraCode, O);
            case 'X': // hex const int
                if ((MO.getType()) != MachineOperand::MO_Immediate)
                    return true;
                O << "0x" << StringRef(utohexstr(MO.getImm())).lower();
                return false;
            case 'x': // hex const int (low 16 bits)
                if ((MO.getType()) != MachineOperand::MO_Immediate)
                    return true;
                O << "0x" << StringRef(utohexstr(MO.getImm() & 0xffff)).lower();
                return false;
            case 'd': // decimal const int
                if ((MO.getType()) != MachineOperand::MO_Immediate)
                    return true;
                O << MO.getImm();
                return false;
            case 'm': // decimal const int minus 1
                if ((MO.getType()) != MachineOperand::MO_Immediate)
                    return true;
                O << MO.getImm() - 1;
                return false;
            case 'z':
            {
                // $0 if zero, regular printing otherwise
                if (MO.getType() != MachineOperand::MO_Immediate)
                    return true;
                int64_t Val = MO.getImm();
                if (Val)
                    O << Val;
                else
                    O << "$0";
                return false;
            }
        }
    }

    printOperand(MI, OpNum, O);
    return false;
    return false;
}

bool NewTargetAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI,
        unsigned OpNum, unsigned AsmVariant,
        const char *ExtraCode,
        raw_ostream &O) {
    //TODO
    std::cout << "NewTargetAsmPrinter::PrintAsmMemoryOperand not implemented\n";
    if (ExtraCode && ExtraCode[0])
        return true; // Unknown modifier.

    const MachineOperand &MO = MI->getOperand(OpNum);
    assert(MO.isReg() && "unexpected inline asm memory operand");
    O << "0[$" << NewTargetInstPrinter::getRegisterName(MO.getReg()) << "]";

    return false;
}

void NewTargetAsmPrinter::printOperand(const MachineInstr *MI, int opNum,
        raw_ostream &O) {

    //std::cout << "NewTargetAsmPrinter::printOperand not implemented\n";

    const MachineOperand &MO = MI->getOperand(opNum);
    bool closeP = false;

    if (MO.getTargetFlags())
        closeP = true;

    switch (MO.getTargetFlags()) {
            //case MipsII::MO_GPREL:    O << "%gp_rel("; break;
            //case MipsII::MO_GOT_CALL: O << "%call16("; break;
            //case MipsII::MO_GOT:      O << "%got(";    break;
        case NewTargetII::MO_ABS_HI: O << "%hi(";
            break;
        case NewTargetII::MO_ABS_LO: O << "%lo(";
            break;
            //case MipsII::MO_TLSGD:    O << "%tlsgd(";  break;
            //case MipsII::MO_GOTTPREL: O << "%gottprel("; break;
            //case MipsII::MO_TPREL_HI: O << "%tprel_hi("; break;
            //case MipsII::MO_TPREL_LO: O << "%tprel_lo("; break;
            //case MipsII::MO_GPOFF_HI: O << "%hi(%neg(%gp_rel("; break;
            //case MipsII::MO_GPOFF_LO: O << "%lo(%neg(%gp_rel("; break;
            //case MipsII::MO_GOT_DISP: O << "%got_disp("; break;
            //case MipsII::MO_GOT_PAGE: O << "%got_page("; break;
            //case MipsII::MO_GOT_OFST: O << "%got_ofst("; break;
    }

    switch (MO.getType()) {
        case MachineOperand::MO_Register:
            O << '$'
                    << StringRef(NewTargetInstPrinter::getRegisterName(MO.getReg())).lower();
            break;

        case MachineOperand::MO_Immediate:
            O << MO.getImm();
            break;

        case MachineOperand::MO_MachineBasicBlock:
            O << *MO.getMBB()->getSymbol();
            return;

        case MachineOperand::MO_GlobalAddress:
            O << *Mang->getSymbol(MO.getGlobal());
            break;

        case MachineOperand::MO_BlockAddress:
        {
            MCSymbol *BA = GetBlockAddressSymbol(MO.getBlockAddress());
            O << BA->getName();
            break;
        }

        case MachineOperand::MO_ExternalSymbol:
            O << *GetExternalSymbolSymbol(MO.getSymbolName());
            break;

        case MachineOperand::MO_JumpTableIndex:
            O << MAI->getPrivateGlobalPrefix() << "JTI" << getFunctionNumber()
                    << '_' << MO.getIndex();
            break;

        case MachineOperand::MO_ConstantPoolIndex:
            O << MAI->getPrivateGlobalPrefix() << "CPI"
                    << getFunctionNumber() << "_" << MO.getIndex();
            if (MO.getOffset())
                O << "+" << MO.getOffset();
            break;

        default:
            llvm_unreachable("<unknown operand type>");
    }

    if (closeP) O << ")";
}

void NewTargetAsmPrinter::printUnsignedImm(const MachineInstr *MI, int opNum,
        raw_ostream &O) {
    const MachineOperand &MO = MI->getOperand(opNum);
    if (MO.isImm())
        O << (unsigned short int) MO.getImm();
    else
        printOperand(MI, opNum, O);
}

void NewTargetAsmPrinter::
printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &O) {
    // Load/Store memory operands -- imm($reg)
    // If PIC target the target is loaded as the
    // pattern lw $25,%call16($28)
    printOperand(MI, opNum + 1, O);
    O << "[";
    printOperand(MI, opNum, O);
    O << "]";
}

void NewTargetAsmPrinter::
printMemOperandEA(const MachineInstr *MI, int opNum, raw_ostream &O) {
    //TODO
    //std::cout << "NewTargetAsmPrinter::printMemOperandEA not implemented\n";
    return;
}

void NewTargetAsmPrinter::
printFCCOperand(const MachineInstr *MI, int opNum, raw_ostream &O,
        const char *Modifier) {
    //TODO
    //std::cout << "NewTargetAsmPrinter::printFCCOperand not implemented\n";
}

void NewTargetAsmPrinter::EmitStartOfAsmFile(Module &M) {
    //TODO
    //std::cout << "NewTargetAsmPrinter::EmitStartOfAsmFile not implemented\n";
}

void NewTargetAsmPrinter::EmitEndOfAsmFile(Module &M) {
    //TODO
    //std::cout << "NewTargetAsmPrinter::EmitEndOfAsmFile not implemented\n";
}


MachineLocation
NewTargetAsmPrinter::getDebugValueLocation(const MachineInstr *MI) const {
  // Handles frame addresses emitted in MipsInstrInfo::emitFrameIndexDebugValue.
  assert(MI->getNumOperands() == 4 && "Invalid no. of machine operands!");
  assert(MI->getOperand(0).isReg() && MI->getOperand(1).isImm() &&
         "Unexpected MachineOperand types");
  return MachineLocation(MI->getOperand(0).getReg(),
                         MI->getOperand(1).getImm());
}
 

void NewTargetAsmPrinter::PrintDebugValueComment(const MachineInstr *MI,
        raw_ostream &OS) {
    // TODO: implement
    //std::cout << "NewTargetAsmPrinter::PrintDebugValueComment not implemented\n";
}

GCMetadataPrinter *NewTargetAsmPrinter::GetOrCreateGCPrinter_(GCStrategy *S) {
    if (!S->usesMetadata())
        return 0;

    /*
      gcp_map_type &GCMap = getGCMap(GCMetadataPrinters);
      gcp_map_type::iterator GCPI = GCMap.find(S);
      if (GCPI != GCMap.end())
        return GCPI->second;

      const char *Name = S->getName().c_str();

      for (GCMetadataPrinterRegistry::iterator
             I = GCMetadataPrinterRegistry::begin(),
             E = GCMetadataPrinterRegistry::end(); I != E; ++I)
        if (strcmp(Name, I->getName()) == 0) {
          GCMetadataPrinter *GMP = I->instantiate();
          GMP->S = S;
          GCMap.insert(std::make_pair(S, GMP));
          return GMP;
        }
     */
    report_fatal_error("no GCMetadataPrinter registered for GC: ");
}

/// srcMgrDiagHandler - This callback is invoked when the SourceMgr for an
/// inline asm has an error in it.  diagInfo is a pointer to the SrcMgrDiagInfo
/// struct above.

static void srcMgrDiagHandler(const SMDiagnostic &Diag, void *diagInfo) {
    SrcMgrDiagInfo *DiagInfo = static_cast<SrcMgrDiagInfo *> (diagInfo);
    assert(DiagInfo && "Diagnostic context not passed down?");

    // If the inline asm had metadata associated with it, pull out a location
    // cookie corresponding to which line the error occurred on.
    unsigned LocCookie = 0;
    if (const MDNode * LocInfo = DiagInfo->LocInfo) {
        unsigned ErrorLine = Diag.getLineNo() - 1;
        if (ErrorLine >= LocInfo->getNumOperands())
            ErrorLine = 0;

        if (LocInfo->getNumOperands() != 0)
            if (const ConstantInt * CI =
                    dyn_cast<ConstantInt>(LocInfo->getOperand(ErrorLine)))
                LocCookie = CI->getZExtValue();
    }

    DiagInfo->DiagHandler(Diag, DiagInfo->DiagContext, LocCookie);
}


/// EmitInlineAsm - Emit a blob of inline asm to the output streamer.

void NewTargetAsmPrinter::EmitInlineAsm_(StringRef Str, const MDNode *LocMDNode,
        InlineAsm::AsmDialect Dialect) const {
    assert(!Str.empty() && "Can't emit empty inline asm block");

    std::cout << "EmitInlineAsm\n";
    // Remember if the buffer is nul terminated or not so we can avoid a copy.
    bool isNullTerminated = Str.back() == 0;
    if (isNullTerminated)
        Str = Str.substr(0, Str.size() - 1);

    // If the output streamer is actually a .s file, just emit the blob textually.
    // This is useful in case the asm parser doesn't handle something but the
    // system assembler does.
    // if (OutStreamer.hasRawTextSupport()) {
    //     OutStreamer.EmitRawText(Str);
    //     return;
    // }

    SourceMgr SrcMgr;
    SrcMgrDiagInfo DiagInfo;

    // If the current LLVMContext has an inline asm handler, set it in SourceMgr.
    LLVMContext &LLVMCtx = MMI->getModule()->getContext();
    bool HasDiagHandler = false;
    if (LLVMCtx.getInlineAsmDiagnosticHandler() != 0) {
        // If the source manager has an issue, we arrange for srcMgrDiagHandler
        // to be invoked, getting DiagInfo passed into it.
        DiagInfo.LocInfo = LocMDNode;
        DiagInfo.DiagHandler = LLVMCtx.getInlineAsmDiagnosticHandler();
        DiagInfo.DiagContext = LLVMCtx.getInlineAsmDiagnosticContext();
        SrcMgr.setDiagHandler(srcMgrDiagHandler, &DiagInfo);
        HasDiagHandler = true;
    }

    MemoryBuffer *Buffer;
    if (isNullTerminated)
        Buffer = MemoryBuffer::getMemBuffer(Str, "<inline asm>");
    else
        Buffer = MemoryBuffer::getMemBufferCopy(Str, "<inline asm>");

    // Tell SrcMgr about this buffer, it takes ownership of the buffer.
    SrcMgr.AddNewSourceBuffer(Buffer, SMLoc());

    OwningPtr<MCAsmParser> Parser(createMCAsmParser(SrcMgr,
            OutContext, OutStreamer,
            *MAI));

    // FIXME: It would be nice if we can avoid createing a new instance of
    // MCSubtargetInfo here given TargetSubtargetInfo is available. However,
    // we have to watch out for asm directives which can change subtarget
    // state. e.g. .code 16, .code 32.
    OwningPtr<MCSubtargetInfo>
            STI(TM.getTarget().createMCSubtargetInfo(TM.getTargetTriple(),
            TM.getTargetCPU(),
            TM.getTargetFeatureString()));
    OwningPtr<MCTargetAsmParser>
            TAP(TM.getTarget().createMCAsmParser(*STI, *Parser));
    if (!TAP) {
        report_fatal_error("Inline asm not supported by this streamer because"
                " we don't have an asm parser for this target\n");
    }
    Parser->setAssemblerDialect(Dialect);
    Parser->setTargetParser(*TAP.get());

    // Don't implicitly switch to the text section before the asm.
    int Res = Parser->Run(/*NoInitialTextSection*/ true,
            /*NoFinalize*/ true);
    if (Res && !HasDiagHandler)
        report_fatal_error("Error parsing inline asm\n");
}

void NewTargetAsmPrinter::EmitVisibility_(MCSymbol *Sym, unsigned Visibility,
        bool IsDefinition) const {
    MCSymbolAttr Attr = MCSA_Invalid;

    switch (Visibility) {
        default: break;
        case GlobalValue::HiddenVisibility:
            if (IsDefinition)
                Attr = MAI->getHiddenVisibilityAttr();
            else
                Attr = MAI->getHiddenDeclarationVisibilityAttr();
            break;
        case GlobalValue::ProtectedVisibility:
            Attr = MAI->getProtectedVisibilityAttr();
            break;
    }

    if (Attr != MCSA_Invalid)
        OutStreamer.EmitSymbolAttribute(Sym, Attr);
}


// Force static initialization.

extern "C" void LLVMInitializeNewTargetAsmPrinter() {
    //std::cout << "LLVMInitializeNewTargetAsmPrinter\n";
    RegisterAsmPrinter<NewTargetAsmPrinter> X(TheNewTarget);

}
