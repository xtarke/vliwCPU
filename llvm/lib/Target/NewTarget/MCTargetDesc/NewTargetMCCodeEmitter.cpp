/*
 * NewTargetMCCodeEmitter.cpp
 *
 *  Created on: Apr 3, 2013
 *      Author: andreu
 */

#define DEBUG_TYPE "mccodeemitter"
#include "NewTargetFixupKinds.h"
#include "NewTargetMCInst.h"
#include "MCTargetDesc/NewTargetBaseInfo.h"
#include "MCTargetDesc/NewTargetMCTargetDesc.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/raw_ostream.h"
#include <iostream>
#include <iomanip>

using namespace llvm;

namespace {

class NewTargetMCCodeEmitter : public MCCodeEmitter {
  NewTargetMCCodeEmitter(const NewTargetMCCodeEmitter &) LLVM_DELETED_FUNCTION;
  void operator=(const NewTargetMCCodeEmitter &) LLVM_DELETED_FUNCTION;
  const MCInstrInfo &MCII;
  MCContext &Ctx;

public:
  NewTargetMCCodeEmitter(const MCInstrInfo &mcii, MCContext &Ctx_,
                    const MCSubtargetInfo &sti):
    MCII(mcii), Ctx(Ctx_) {}

  ~NewTargetMCCodeEmitter() {}

  void EmitByte(unsigned char C, raw_ostream &OS) const {
    OS << (char)C;
    //std::cout <<  std::hex << std::setw(2) << std::setfill('0') << (int)C;
  }

  void EmitInstruction(uint64_t Val, unsigned Size, raw_ostream &OS) const {
    // Output the instruction encoding in little endian byte order.
	 //std::cout << "Size: " << Size << "\n";
    for (unsigned i = 0; i < Size; ++i) {
      unsigned Shift =  i * 8;
      //unsigned Shift =  (Size - 1 - i) * 8;
      EmitByte((Val >> Shift) & 0xff, OS);
    }
    //std::cout << "\n";
  }


  void EncodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups) const;

  // getBinaryCodeForInstr - TableGen'erated function for getting the
  // binary encoding for an instruction.
  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups) const;

  // getMachineOpValue - Return binary encoding of operand. If the machin
  // operand requires relocation, record the relocation and return zero.
 unsigned getMachineOpValue(const MCInst &MI,const MCOperand &MO,
                            SmallVectorImpl<MCFixup> &Fixups) const;
 
 unsigned StopBitEncoder(const MCInst &MI, unsigned Value) const;


 // getBranchJumpOpValue - Return binary encoding of the jump
 // target operand. If the machine operand requires relocation,
 // record the relocation and return zero.
  unsigned getJumpTargetOpValue(const MCInst &MI, unsigned OpNo,
                                SmallVectorImpl<MCFixup> &Fixups) const;

  // getBranchTargetOpValue - Return binary encoding of the branch
  // target operand. If the machine operand requires relocation,
  // record the relocation and return zero.
 unsigned getBranchTargetOpValue(const MCInst &MI, unsigned OpNo,
                                 SmallVectorImpl<MCFixup> &Fixups) const;

 unsigned getMemEncoding(const MCInst &MI, unsigned OpNo,
                         SmallVectorImpl<MCFixup> &Fixups) const;
  unsigned getMemEncodingEA(const MCInst &MI, unsigned OpNo,
                         SmallVectorImpl<MCFixup> &Fixups) const;
}; // class NewTargetMCCodeEmitter
}  // namespace

MCCodeEmitter *llvm::createNewTargetMCCodeEmitter(const MCInstrInfo &MCII,
                                               const MCRegisterInfo &MRI,
                                               const MCSubtargetInfo &STI,
                                               MCContext &Ctx)
{
  return new NewTargetMCCodeEmitter(MCII, Ctx, STI);
}

static int counter = 0;

/// EncodeInstruction - Emit the instruction.
/// Size the instruction (currently only 4 bytes
void NewTargetMCCodeEmitter::
EncodeInstruction(const MCInst &MI, raw_ostream &OS,
                  SmallVectorImpl<MCFixup> &Fixups) const
{
	  //std::cout << "Num opcodes: " << MCII.getNumOpcodes() << "\n";
	  //MCInst TmpInst = MI;


	  uint32_t Binary = getBinaryCodeForInstr(MI, Fixups);
          
          //std::cout << "" << std::dec << counter++ << " : " << std::hex << Binary << "\n";

	  // Check for unimplemented opcodes.
	  // Unfortunately in MIPS both NOP and SLL will come in with Binary == 0
	  // so we have to special check for them.
	  unsigned Opcode = MI.getOpcode();
	  if ((Opcode != NewTarget::NOP) && (Opcode != NewTarget::ADDi) && !Binary)
	    llvm_unreachable("unimplemented opcode in EncodeInstruction()");

	  const MCInstrDesc &Desc = MCII.get(MI.getOpcode());

	  // Get byte count of instruction
	  unsigned Size = Desc.getSize();
	  if (!Size)
	    llvm_unreachable("Desc.getSize() returns 0");

	  EmitInstruction(Binary, Size, OS);

}

/// getMachineOpValue - Return binary encoding of operand. If the machine
/// operand requires relocation, record the relocation and return zero.
unsigned NewTargetMCCodeEmitter::
getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                  SmallVectorImpl<MCFixup> &Fixups) const {

	if (MO.isReg()) {
	   unsigned Reg = MO.getReg();
	   unsigned RegNo = Ctx.getRegisterInfo().getEncodingValue(Reg);
	   return RegNo;
	} else if (MO.isImm()) {
	   return static_cast<unsigned>(MO.getImm());
	}

	//llvm_unreachable("unimplemented part of getMachineOpValue");
	// MO must be an Expr.
	assert(MO.isExpr());

	const MCExpr *Expr = MO.getExpr();
	MCExpr::ExprKind Kind = Expr->getKind();

	if (Kind == MCExpr::Binary) {
	  Expr = static_cast<const MCBinaryExpr*>(Expr)->getLHS();
	  Kind = Expr->getKind();
	}

	assert (Kind == MCExpr::SymbolRef);

	NewTarget::Fixups FixupKind = NewTarget::Fixups(0);

	switch(cast<MCSymbolRefExpr>(Expr)->getKind()) {
	default: llvm_unreachable("Unknown fixup kind!");
	  break;
	  /*
	case MCSymbolRefExpr::VK_Mips_GPOFF_HI :
	  FixupKind = Mips::fixup_Mips_GPOFF_HI;
	  break;
	case MCSymbolRefExpr::VK_Mips_GPOFF_LO :
	  FixupKind = Mips::fixup_Mips_GPOFF_LO;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOT_PAGE :
	  FixupKind = Mips::fixup_Mips_GOT_PAGE;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOT_OFST :
	  FixupKind = Mips::fixup_Mips_GOT_OFST;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOT_DISP :
	  FixupKind = Mips::fixup_Mips_GOT_DISP;
	  break;
	case MCSymbolRefExpr::VK_Mips_GPREL:
	  FixupKind = Mips::fixup_Mips_GPREL16;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOT_CALL:
	  FixupKind = Mips::fixup_Mips_CALL16;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOT16:
	  FixupKind = Mips::fixup_Mips_GOT_Global;
	  break;
           */ 
	case MCSymbolRefExpr::VK_Mips_ABS_HI:
	  //FixupKind = NewTarget::fixup_Mips_HI16;
          llvm_unreachable("MCSymbolRefExpr::VK_Mips_ABS_HI");  
	  break;
	case MCSymbolRefExpr::VK_Mips_ABS_LO:
	  //FixupKind = NewTarget::fixup_Mips_LO16;
          llvm_unreachable("MCSymbolRefExpr::VK_Mips_ABS_LO");  
	  break;
        case MCSymbolRefExpr::VK_NewTarget_ABS:
          if(MI.getOpcode() == NewTarget::ADDi || MI.getOpcode() == NewTarget::ADDi_p){
              //std::cout << "MI->getNumOperands() == NewTarget::ADDi\n";
              FixupKind = NewTarget::fixup_NewTarget_IMM9;
          } else if(MI.getOpcode() == NewTarget::IMML){
              //std::cout << "MI->getOpcode() == NewTarget::IMML\n";
              FixupKind = NewTarget::fixup_NewTarget_IMM23;
          } 
	  break;  
	 /*
	case MCSymbolRefExpr::VK_Mips_TLSGD:
	  FixupKind = Mips::fixup_Mips_TLSGD;
	  break;
	case MCSymbolRefExpr::VK_Mips_TLSLDM:
	  FixupKind = Mips::fixup_Mips_TLSLDM;
	  break;
	case MCSymbolRefExpr::VK_Mips_DTPREL_HI:
	  FixupKind = Mips::fixup_Mips_DTPREL_HI;
	  break;
	case MCSymbolRefExpr::VK_Mips_DTPREL_LO:
	  FixupKind = Mips::fixup_Mips_DTPREL_LO;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOTTPREL:
	  FixupKind = Mips::fixup_Mips_GOTTPREL;
	  break;
	case MCSymbolRefExpr::VK_Mips_TPREL_HI:
	  FixupKind = Mips::fixup_Mips_TPREL_HI;
	  break;
	case MCSymbolRefExpr::VK_Mips_TPREL_LO:
	  FixupKind = Mips::fixup_Mips_TPREL_LO;
	  break;
	case MCSymbolRefExpr::VK_Mips_HIGHER:
	  FixupKind = Mips::fixup_Mips_HIGHER;
	  break;
	case MCSymbolRefExpr::VK_Mips_HIGHEST:
	  FixupKind = Mips::fixup_Mips_HIGHEST;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOT_HI16:
	  FixupKind = Mips::fixup_Mips_GOT_HI16;
	  break;
	case MCSymbolRefExpr::VK_Mips_GOT_LO16:
	  FixupKind = Mips::fixup_Mips_GOT_LO16;
	  break;
	case MCSymbolRefExpr::VK_Mips_CALL_HI16:
	  FixupKind = Mips::fixup_Mips_CALL_HI16;
	  break;
	case MCSymbolRefExpr::VK_Mips_CALL_LO16:
	  FixupKind = Mips::fixup_Mips_CALL_LO16;
	  break;
	  */
	} // switch

	Fixups.push_back(MCFixup::Create(0, MO.getExpr(), MCFixupKind(FixupKind)));
	//MO.dump();

	// All of the information is in the fixup.
	return 0;
}


unsigned NewTargetMCCodeEmitter::
StopBitEncoder(const MCInst &MI, unsigned Value) const {
    
    
   const NewTargetMCInst& NewTargetMI = static_cast<const NewTargetMCInst&>(MI);
  
  if(NewTargetMI.isEndPacket()){
      // enable stop bit
      Value |= 0x80000000; 
  } else {
      // disable stop bit
      Value &= ~(0x80000000);
  }
 
    
    return Value;
}

/// getJumpTargetOpValue - Return binary encoding of the jump
/// target operand. If the machine operand requires relocation,
/// record the relocation and return zero.
unsigned NewTargetMCCodeEmitter::
getJumpTargetOpValue(const MCInst &MI, unsigned OpNo,
                     SmallVectorImpl<MCFixup> &Fixups) const {

	const MCOperand &MO = MI.getOperand(OpNo);
        
        const NewTargetMCInst& NewTargetMI = static_cast<const NewTargetMCInst&>(MI);
        
        uint32_t offset = NewTargetMI.getBundleSize();
        
	// If the destination is an immediate, we have nothing to do.
	if (MO.isImm()) return MO.getImm();
        
	assert(MO.isExpr() &&
	         "getJumpTargetOpValue expects only expressions or an immediate");

	const MCExpr *Expr = MO.getExpr();
	Fixups.push_back(MCFixup::Create(0, Expr,
	                                 MCFixupKind(NewTarget::fixup_NewTarget_PC23CALL)));
	return offset;
}

/// getBranchTargetOpValue - Return binary encoding of the branch
/// target operand. If the machine operand requires relocation,
/// record the relocation and return zero.
unsigned NewTargetMCCodeEmitter::
getBranchTargetOpValue(const MCInst &MI, unsigned OpNo,
                       SmallVectorImpl<MCFixup> &Fixups) const {
	const MCOperand &MO = MI.getOperand(OpNo);
        
        const NewTargetMCInst& NewTargetMI = static_cast<const NewTargetMCInst&>(MI);
        
        uint32_t offset = NewTargetMI.getBundleSize();
        
	// If the destination is an immediate, we have nothing to do.
	if (MO.isImm()){
                std::cout << "==== " << MO.getImm() << "\n";
		std::cout << "aqui o erro\n";
		return MO.getImm();
	}
        
	assert(MO.isExpr() &&
	       "getBranchTargetOpValue expects only expressions or immediates");

	const MCExpr *Expr = MO.getExpr();
        //std::cout << "getBranchTargetOpValue: " << offset << "\n";
        //MO.getExpr()->dump();
        
        if(MI.getOpcode() == NewTarget::PRELD){
            Fixups.push_back(MCFixup::Create(0, Expr,
                                   MCFixupKind(NewTarget::fixup_NewTarget_PC23PRELOAD)));
        } else {
            Fixups.push_back(MCFixup::Create(0, Expr,
                                   MCFixupKind(NewTarget::fixup_NewTarget_PC23GOTO)));
        }

	
	return offset;
}

/// getMemEncoding - Return binary encoding of memory related operand.
/// If the offset operand requires relocation, record the relocation.
unsigned
NewTargetMCCodeEmitter::getMemEncoding(const MCInst &MI, unsigned OpNo,
                                  SmallVectorImpl<MCFixup> &Fixups) const {
	// Base register is encoded in bits 5-0, offset is encoded in bits 20-12 (st200).
	assert(MI.getOperand(OpNo).isReg());
	unsigned RegBits = getMachineOpValue(MI, MI.getOperand(OpNo),Fixups);
	unsigned OffBits = getMachineOpValue(MI, MI.getOperand(OpNo+1), Fixups) << 12;

        
        //std::cout << "Mem offset: " << OffBits << "\n";
    return OffBits | (RegBits & 0x3F);
}


/// getMemEncodingEA - Return binary encoding of memory related operand.
/// If the offset operand requires relocation, record the relocation.
unsigned
NewTargetMCCodeEmitter::getMemEncodingEA(const MCInst &MI, unsigned OpNo,
                                  SmallVectorImpl<MCFixup> &Fixups) const {
	// Base register is encoded in bits 5-0, offset is encoded in bits 20-12 (st200).
	assert(MI.getOperand(OpNo).isReg());
	unsigned RegBits = getMachineOpValue(MI, MI.getOperand(OpNo),Fixups);
	unsigned OffBits = getMachineOpValue(MI, MI.getOperand(OpNo+1), Fixups) << 6;
        
        //std::cout << "Mem offset: " << OffBits << "\n";
    return OffBits | (RegBits & 0x3F);
}

#include "NewTargetGenMCCodeEmitter.inc"



