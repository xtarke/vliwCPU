/*
 * NewTargetMachineFunction.h
 *
 *  Created on: Mar 14, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETMACHINEFUNCTION_H_
#define NEWTARGETMACHINEFUNCTION_H_



#include "NewTargetSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include <utility>

namespace llvm {

/// MipsFunctionInfo - This class is derived from MachineFunction private
/// Mips target-specific information for each MachineFunction.
class NewTargetFunctionInfo : public MachineFunctionInfo {
  virtual void anchor();

  /// SRetReturnReg - Some subtargets require that sret lowering includes
  /// returning the value of the returned struct in a register. This field
  /// holds the virtual register into which the sret argument is passed.
  unsigned SRetReturnReg;

  /// VarArgsFrameIndex - FrameIndex for start of varargs area.
  int VarArgsFrameIndex;

  /// True if function has a byval argument.
  bool HasByvalArg;

  /// Size of incoming argument area.
  unsigned IncomingArgSize;

  /// CallsEhReturn - Whether the function calls llvm.eh.return.
  bool CallsEhReturn;

  /// Frame objects for spilling eh data registers.
  int EhDataRegFI[4];

public:
  NewTargetFunctionInfo(MachineFunction& MF)
   : SRetReturnReg(0), VarArgsFrameIndex(0), CallsEhReturn(false)
  {}

  unsigned getSRetReturnReg() const { return SRetReturnReg; }
  void setSRetReturnReg(unsigned Reg) { SRetReturnReg = Reg; }

  bool globalBaseRegSet() const;
  unsigned getGlobalBaseReg();

  bool mips16SPAliasRegSet() const;
  unsigned getMips16SPAliasReg();

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

  bool hasByvalArg() const { return HasByvalArg; }
  void setFormalArgInfo(unsigned Size, bool HasByval) {
    IncomingArgSize = Size;
    HasByvalArg = HasByval;
  }

  unsigned getIncomingArgSize() const { return IncomingArgSize; }

  bool callsEhReturn() const { return CallsEhReturn; }
  void setCallsEhReturn() { CallsEhReturn = true; }

  void createEhDataRegsFI();
  int getEhDataRegFI(unsigned Reg) const { return EhDataRegFI[Reg]; }
  bool isEhDataRegFI(int FI) const;

};

} // end of namespace llvm

#endif
