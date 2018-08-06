/*
 * NewTargetInstPrinter.cpp
 *
 *  Created on: Mar 13, 2013
 *      Author: andreu
 */

#define DEBUG_TYPE "asm-printer"
#include "NewTargetInstPrinter.h"
#include "NewTargetMCInst.h"
#include "NewTargetInstrInfo.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include <iostream>
using namespace llvm;

#define PRINT_ALIAS_INSTR
#include "NewTargetGenAsmWriter.inc"


void NewTargetInstPrinter::printRegName(raw_ostream &OS, unsigned RegNo) const {
  OS << '$' << StringRef(getRegisterName(RegNo)).lower();
}

void NewTargetInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                StringRef Annot) {

//std::cout << "NewTargetInstPrinter::printInst partially implemented\n";
    
  if (!printAliasInstr(MI, O)){
    printInstruction(MI, O);
  }   
  printAnnotation(O, Annot);
  
  const NewTargetMCInst* NewTargetMI = static_cast<const NewTargetMCInst*>(MI);
  
  if(NewTargetMI->isEndPacket()){
     O << "\n\t;\n"; 
  }
}

static void printExpr(const MCExpr *Expr, raw_ostream &OS) {

	//std::cout << "================================================\n";

  int Offset = 0;
  const MCSymbolRefExpr *SRE;

  if (const MCBinaryExpr *BE = dyn_cast<MCBinaryExpr>(Expr)) {
    SRE = dyn_cast<MCSymbolRefExpr>(BE->getLHS());
    const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(BE->getRHS());
    assert(SRE && CE && "Binary expression must be sym+const.");
    Offset = CE->getValue();
  }
  else if (!(SRE = dyn_cast<MCSymbolRefExpr>(Expr)))
    assert(false && "Unexpected MCExpr type.");

  MCSymbolRefExpr::VariantKind Kind = SRE->getKind();

  switch (Kind) {
  default:                                 llvm_unreachable("Invalid kind!");
  case MCSymbolRefExpr::VK_None:           break;
  //case MCSymbolRefExpr::VK_Mips_GPREL:     OS << "%gp_rel("; break;
  //case MCSymbolRefExpr::VK_Mips_GOT_CALL:  OS << "%call16("; break;
  //case MCSymbolRefExpr::VK_Mips_GOT16:     OS << "%got(";    break;
  //case MCSymbolRefExpr::VK_Mips_GOT:       OS << "%got(";    break;
  case MCSymbolRefExpr::VK_Mips_ABS_HI:    OS << "%hi(";     break;
  case MCSymbolRefExpr::VK_Mips_ABS_LO:    OS << "%lo(";     break;
  case MCSymbolRefExpr::VK_NewTarget_ABS:    OS << "%abs(";     break;
  //case MCSymbolRefExpr::VK_Mips_TLSGD:     OS << "%tlsgd(";  break;
  //case MCSymbolRefExpr::VK_Mips_TLSLDM:    OS << "%tlsldm(";  break;
  //case MCSymbolRefExpr::VK_Mips_DTPREL_HI: OS << "%dtprel_hi(";  break;
  //case MCSymbolRefExpr::VK_Mips_DTPREL_LO: OS << "%dtprel_lo(";  break;
  //case MCSymbolRefExpr::VK_Mips_GOTTPREL:  OS << "%gottprel("; break;
  //case MCSymbolRefExpr::VK_Mips_TPREL_HI:  OS << "%tprel_hi("; break;
  //case MCSymbolRefExpr::VK_Mips_TPREL_LO:  OS << "%tprel_lo("; break;
  //case MCSymbolRefExpr::VK_Mips_GPOFF_HI:  OS << "%hi(%neg(%gp_rel("; break;
  //case MCSymbolRefExpr::VK_Mips_GPOFF_LO:  OS << "%lo(%neg(%gp_rel("; break;
  //case MCSymbolRefExpr::VK_Mips_GOT_DISP:  OS << "%got_disp("; break;
  //case MCSymbolRefExpr::VK_Mips_GOT_PAGE:  OS << "%got_page("; break;
  //case MCSymbolRefExpr::VK_Mips_GOT_OFST:  OS << "%got_ofst("; break;
  //case MCSymbolRefExpr::VK_Mips_HIGHER:    OS << "%higher("; break;
  //case MCSymbolRefExpr::VK_Mips_HIGHEST:   OS << "%highest("; break;
  //case MCSymbolRefExpr::VK_Mips_GOT_HI16:  OS << "%got_hi("; break;
  //case MCSymbolRefExpr::VK_Mips_GOT_LO16:  OS << "%got_lo("; break;
  //case MCSymbolRefExpr::VK_Mips_CALL_HI16: OS << "%call_hi("; break;
  //case MCSymbolRefExpr::VK_Mips_CALL_LO16: OS << "%call_lo("; break;
  }

  OS << SRE->getSymbol();

  if (Offset) {
    if (Offset > 0)
      OS << '+';
    OS << Offset;
  }


  if ((Kind == MCSymbolRefExpr::VK_Mips_GPOFF_HI) ||
      (Kind == MCSymbolRefExpr::VK_Mips_GPOFF_LO))
    OS << ")))";
  else if (Kind != MCSymbolRefExpr::VK_None)
    OS << ')';

}

void NewTargetInstPrinter::printCPURegs(const MCInst *MI, unsigned OpNo,
                                   raw_ostream &O) {
  printRegName(O, MI->getOperand(OpNo).getReg());
}

void NewTargetInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                                   raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isReg()) {
    printRegName(O, Op.getReg());
    return;
  }

  if (Op.isImm()) {
    O << Op.getImm();
    return;
  }

  assert(Op.isExpr() && "unknown operand kind in printOperand");
  printExpr(Op.getExpr(), O);
}

void NewTargetInstPrinter::printUnsignedImm(const MCInst *MI, int opNum,
                                       raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(opNum);
  if (MO.isImm())
    O << (unsigned short int)MO.getImm();
  else
    printOperand(MI, opNum, O);
}

void NewTargetInstPrinter::
printMemOperand(const MCInst *MI, int opNum, raw_ostream &O) {
  // Load/Store memory operands -- imm($reg)
  // If PIC target the target is loaded as the
  // pattern lw $25,%call16($28)
  printOperand(MI, opNum+1, O);
  O << "[";
  printOperand(MI, opNum, O);
  O << "]";
}

void NewTargetInstPrinter::
printMemOperandEA(const MCInst *MI, int opNum, raw_ostream &O) {
  // when using stack locations for not load/store instructions
  // print the same way as all normal 3 operand instructions.
  printOperand(MI, opNum, O);
  O << ", ";
  printOperand(MI, opNum+1, O);
  return;
}

void NewTargetInstPrinter::
printFCCOperand(const MCInst *MI, int opNum, raw_ostream &O) {
	//std::cout << "NewTargetInstPrinter::printFCCOperand not implemented\n";
	/*
  const MCOperand& MO = MI->getOperand(opNum);
  O << FCCToString((Mips::CondCode)MO.getImm());
  */
}

