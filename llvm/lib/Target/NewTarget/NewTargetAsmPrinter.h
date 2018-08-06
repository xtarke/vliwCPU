/*
 * NewTargetAsmPrinter.h
 *
 *  Created on: Mar 13, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETASMPRINTER_H_
#define NEWTARGETASMPRINTER_H_

#include "NewTargetMCInstLower.h"
#include "NewTargetSubtarget.h"
#include "NewTargetMachineFunction.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/MC/MCInst.h"

namespace llvm {

class LLVM_LIBRARY_VISIBILITY NewTargetAsmPrinter : public AsmPrinter {

  void EmitInstrWithMacroNoAT(const MachineInstr *MI);

private:
  // tblgen'erated function.
  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);

  // lowerOperand - Convert a MachineOperand into the equivalent MCOperand.
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp);

public:

  static char ID; // Class identification, replacement for typeinfo

  const NewTargetSubtarget *Subtarget;
  const NewTargetFunctionInfo *NewTargetFI;
  NewTargetMCInstLower MCInstLowering;

  explicit NewTargetAsmPrinter(TargetMachine &TM,  MCStreamer &Streamer)
    : AsmPrinter(TM, Streamer), MCInstLowering(*this) {
    Subtarget = &TM.getSubtarget<NewTargetSubtarget>();
  }

  virtual const char *getPassName() const {
    return "NewTarget Assembly Printer";
  }

  virtual bool runOnMachineFunction(MachineFunction &MF);

  void EmitInstruction(const MachineInstr *MI);
  void printSavedRegsBitmask(raw_ostream &O);
  void printHex32(unsigned int Value, raw_ostream &O);
  void emitFrameDirective();
  const char *getCurrentABIString() const;
  virtual void EmitFunctionEntryLabel();
  virtual void EmitFunctionBodyStart();
  virtual void EmitFunctionBodyEnd();
  virtual bool isBlockOnlyReachableByFallthrough(const MachineBasicBlock*
                                                 MBB) const;
  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       unsigned AsmVariant, const char *ExtraCode,
                       raw_ostream &O);
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNum,
                             unsigned AsmVariant, const char *ExtraCode,
                             raw_ostream &O);
  void printOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printUnsignedImm(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printMemOperandEA(const MachineInstr *MI, int opNum, raw_ostream &O);
  void printFCCOperand(const MachineInstr *MI, int opNum, raw_ostream &O,
                       const char *Modifier = 0);
  void EmitStartOfAsmFile(Module &M);
  void EmitEndOfAsmFile(Module &M);
  virtual MachineLocation getDebugValueLocation(const MachineInstr *MI) const;
  void PrintDebugValueComment(const MachineInstr *MI, raw_ostream &OS);
  GCMetadataPrinter *GetOrCreateGCPrinter_(GCStrategy *C);
  
    /// EmitInlineAsm - Emit a blob of inline asm to the output streamer.
    void EmitInlineAsm_(StringRef Str, const MDNode *LocMDNode = 0,
                    InlineAsm::AsmDialect AsmDialect = InlineAsm::AD_ATT) const;
                    
        /// EmitVisibility - This emits visibility information about symbol, if
    /// this is suported by the target.
    void EmitVisibility_(MCSymbol *Sym, unsigned Visibility,
                        bool IsDefinition = true) const;                
};

} /* namespace llvm */
#endif /* NEWTARGETASMPRINTER_H_ */
