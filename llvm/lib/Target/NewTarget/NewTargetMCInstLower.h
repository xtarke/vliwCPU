/*
 * NewTargetMCInstLower.h
 *
 *  Created on: Mar 27, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETMCINSTLOWER_H_
#define NEWTARGETMCINSTLOWER_H_
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/Support/Compiler.h"

namespace llvm {
  class MCContext;
  class MCInst;
  class MCOperand;
  class MachineInstr;
  class MachineFunction;
  class Mangler;
  class NewTargetAsmPrinter;
  class NewTargetMCInst;

/// MipsMCInstLower - This class is used to lower an MachineInstr into an
//                    MCInst.
class LLVM_LIBRARY_VISIBILITY NewTargetMCInstLower {
  typedef MachineOperand::MachineOperandType MachineOperandType;
  MCContext *Ctx;
  Mangler *Mang;
  NewTargetAsmPrinter &AsmPrinter;
public:
  NewTargetMCInstLower(NewTargetAsmPrinter &asmprinter);
  void Initialize(Mangler *mang, MCContext *C);
  void Lower(const MachineInstr *MI, NewTargetMCInst &OutMI) const;
  MCOperand LowerOperand(const MachineOperand& MO, unsigned offset = 0) const;
  

private:
  MCOperand LowerSymbolOperand(const MachineOperand &MO,
                               MachineOperandType MOTy, unsigned Offset) const;
};
}

#endif /* NEWTARGETMCINSTLOWER_H_ */
