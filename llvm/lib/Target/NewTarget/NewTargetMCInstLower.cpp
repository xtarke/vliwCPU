//===-- MipsMCInstLower.cpp - Convert Mips MachineInstr to MCInst ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower Mips MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//
#include "NewTargetMCInstLower.h"
#include "NewTargetMCInst.h"
#include "MCTargetDesc/NewTargetBaseInfo.h"
#include "NewTargetAsmPrinter.h"
#include "NewTargetInstrInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Target/Mangler.h"
#include "llvm/MC/MCSymbol.h"
#include <iostream>

using namespace llvm;


NewTargetMCInstLower::NewTargetMCInstLower(NewTargetAsmPrinter &asmprinter)
  : AsmPrinter(asmprinter) {}

void NewTargetMCInstLower::Initialize(Mangler *M, MCContext *C) {
  Mang = M;
  Ctx = C;
}

MCOperand NewTargetMCInstLower::LowerSymbolOperand(const MachineOperand &MO,
                                              MachineOperandType MOTy,
                                              unsigned Offset) const {

	//std::cout << "NewTargetMCInstLower::LowerSymbolOperand - partially implemented\n";
  MCSymbolRefExpr::VariantKind Kind;
  const MCSymbol *Symbol;

  Kind = MCSymbolRefExpr::VK_None;

  //std::cout << "Symbol:\n";
          
  //MO.getParent()->dump();
  
  switch(MO.getTargetFlags()) {
  default:                   llvm_unreachable("Invalid target flag!");
  case NewTargetII::MO_NO_FLAG:   Kind = MCSymbolRefExpr::VK_None; break;
  //case MipsII::MO_GPREL:     Kind = MCSymbolRefExpr::VK_Mips_GPREL; break;
  //case MipsII::MO_GOT_CALL:  Kind = MCSymbolRefExpr::VK_Mips_GOT_CALL; break;
  //case MipsII::MO_GOT16:     Kind = MCSymbolRefExpr::VK_Mips_GOT16; break;
  case NewTargetII::MO_GOT:       Kind = MCSymbolRefExpr::VK_Mips_GOT; break;
  case NewTargetII::MO_ABS_HI:    Kind = MCSymbolRefExpr::VK_Mips_ABS_HI; break;
  case NewTargetII::MO_ABS_LO:    Kind = MCSymbolRefExpr::VK_Mips_ABS_LO; break;
  case NewTargetII::MO_ABS:    Kind = MCSymbolRefExpr::VK_NewTarget_ABS; break;
  //case MipsII::MO_TLSGD:     Kind = MCSymbolRefExpr::VK_Mips_TLSGD; break;
  //case MipsII::MO_TLSLDM:    Kind = MCSymbolRefExpr::VK_Mips_TLSLDM; break;
  //case MipsII::MO_DTPREL_HI: Kind = MCSymbolRefExpr::VK_Mips_DTPREL_HI; break;
  //case MipsII::MO_DTPREL_LO: Kind = MCSymbolRefExpr::VK_Mips_DTPREL_LO; break;
  //case MipsII::MO_GOTTPREL:  Kind = MCSymbolRefExpr::VK_Mips_GOTTPREL; break;
  //case MipsII::MO_TPREL_HI:  Kind = MCSymbolRefExpr::VK_Mips_TPREL_HI; break;
  //case MipsII::MO_TPREL_LO:  Kind = MCSymbolRefExpr::VK_Mips_TPREL_LO; break;
  //case MipsII::MO_GPOFF_HI:  Kind = MCSymbolRefExpr::VK_Mips_GPOFF_HI; break;
  //case MipsII::MO_GPOFF_LO:  Kind = MCSymbolRefExpr::VK_Mips_GPOFF_LO; break;
  //case MipsII::MO_GOT_DISP:  Kind = MCSymbolRefExpr::VK_Mips_GOT_DISP; break;
  //case MipsII::MO_GOT_PAGE:  Kind = MCSymbolRefExpr::VK_Mips_GOT_PAGE; break;
  //case MipsII::MO_GOT_OFST:  Kind = MCSymbolRefExpr::VK_Mips_GOT_OFST; break;
  //case MipsII::MO_HIGHER:    Kind = MCSymbolRefExpr::VK_Mips_HIGHER; break;
  //case MipsII::MO_HIGHEST:   Kind = MCSymbolRefExpr::VK_Mips_HIGHEST; break;
  //case MipsII::MO_GOT_HI16:  Kind = MCSymbolRefExpr::VK_Mips_GOT_HI16; break;
  //case MipsII::MO_GOT_LO16:  Kind = MCSymbolRefExpr::VK_Mips_GOT_LO16; break;
  //case MipsII::MO_CALL_HI16: Kind = MCSymbolRefExpr::VK_Mips_CALL_HI16; break;
  //case MipsII::MO_CALL_LO16: Kind = MCSymbolRefExpr::VK_Mips_CALL_LO16; break;
  }

  switch (MOTy) {
  case MachineOperand::MO_MachineBasicBlock:
    Symbol = MO.getMBB()->getSymbol();
    break;

  case MachineOperand::MO_GlobalAddress:
	//std::cout << "NewTargetMCInstLower::LowerSymbolOperand - MachineOperand::MO_GlobalAddress\n";
    Symbol = Mang->getSymbol(MO.getGlobal());
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_BlockAddress:
    Symbol = AsmPrinter.GetBlockAddressSymbol(MO.getBlockAddress());
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_ExternalSymbol:
    Symbol = AsmPrinter.GetExternalSymbolSymbol(MO.getSymbolName());
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_JumpTableIndex:
    Symbol = AsmPrinter.GetJTISymbol(MO.getIndex());
    break;

  case MachineOperand::MO_ConstantPoolIndex:
    Symbol = AsmPrinter.GetCPISymbol(MO.getIndex());
    Offset += MO.getOffset();
    break;

  default:
    llvm_unreachable("<unknown operand type>");
  }

  const MCSymbolRefExpr *MCSym = MCSymbolRefExpr::Create(Symbol, Kind, *Ctx);

  //MCSym->dump();

  if (!Offset){
      MCOperand operand = MCOperand::CreateExpr(MCSym);
      ///std::cout << "operandddd: " << operand.
      return operand;
  }
    

  // Assume offset is never negative.
  assert(Offset > 0);

  const MCConstantExpr *OffsetExpr =  MCConstantExpr::Create(Offset, *Ctx);
  const MCBinaryExpr *Add = MCBinaryExpr::CreateAdd(MCSym, OffsetExpr, *Ctx);
  return MCOperand::CreateExpr(Add);
}

/*
static void CreateMCInst(MCInst& Inst, unsigned Opc, const MCOperand &Opnd0,
                         const MCOperand &Opnd1,
                         const MCOperand &Opnd2 = MCOperand()) {
  Inst.setOpcode(Opc);
  Inst.addOperand(Opnd0);
  Inst.addOperand(Opnd1);
  if (Opnd2.isValid())
    Inst.addOperand(Opnd2);
}
*/

MCOperand NewTargetMCInstLower::LowerOperand(const MachineOperand &MO,
                                        unsigned offset) const {
  MachineOperandType MOTy = MO.getType();
  
  

  switch (MOTy) {
  default: {
      llvm_unreachable("unknown operand type");
  }    
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit()) break;
    return MCOperand::CreateReg(MO.getReg());
  case MachineOperand::MO_Immediate:
    return MCOperand::CreateImm(MO.getImm() + offset);
  case MachineOperand::MO_MachineBasicBlock:
  case MachineOperand::MO_GlobalAddress:
  case MachineOperand::MO_ExternalSymbol:
  case MachineOperand::MO_JumpTableIndex:
  case MachineOperand::MO_ConstantPoolIndex:
  case MachineOperand::MO_BlockAddress:
    return LowerSymbolOperand(MO, MOTy, offset);
  case MachineOperand::MO_RegisterMask:
    break;
 }

  return MCOperand();
}

void NewTargetMCInstLower::Lower(const MachineInstr *MI, NewTargetMCInst &OutMI) const {
  OutMI.setOpcode(MI->getOpcode());
  //std::cout << "Opcode: " << MI->getOpcode() << "\n";
  //MI->dump();

  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = MI->getOperand(i);
    //std::cout << "Operand: " << MO.getSymbolName() << "\n";
    
    MCOperand MCOp = LowerOperand(MO);
    //MCOp.dump();

    if (MCOp.isValid())
      OutMI.addOperand(MCOp);
  }
}
