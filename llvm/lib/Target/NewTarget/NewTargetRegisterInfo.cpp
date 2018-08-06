/*
 * NewTargetRegisterInfo.cpp
 *
 *  Created on: Mar 11, 2013
 *      Author: andreu
 */

#include "NewTargetMachine.h"
#include "NewTargetRegisterInfo.h"
#include "NewTargetMachineFunction.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/DebugInfo.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include <iostream>

#define GET_REGINFO_TARGET_DESC

#include "NewTargetGenRegisterInfo.inc"

using namespace llvm; /* namespace llvm */

NewTargetRegisterInfo::NewTargetRegisterInfo(const NewTargetMachine &T, const NewTargetInstrInfo &I)
		: NewTargetGenRegisterInfo(NewTarget::LR), TM(T), TII(I) {}

/*
unsigned
NewTargetRegisterInfo::getRegPressureLimit(const TargetRegisterClass *RC,
                                      MachineFunction &MF) const {
	// 64 - getReservedRegs
	return 64 - 7;
}
 */


/// Mips Callee Saved Registers
const uint16_t* NewTargetRegisterInfo::
getCalleeSavedRegs(const MachineFunction *MF) const {

  return NT_SaveList;
}

const uint32_t*
NewTargetRegisterInfo::getCallPreservedMask(CallingConv::ID) const {

  return NT_RegMask;
}

BitVector NewTargetRegisterInfo::
getReservedRegs(const MachineFunction &MF) const {
  static const uint16_t ReservedCPURegs[] = {
    NewTarget::ZERO, NewTarget::SP, NewTarget::R15, NewTarget::TP,
    NewTarget::GP, NewTarget::MAR1, NewTarget::MAR2, NewTarget::LR
  };

  BitVector Reserved(getNumRegs());
  typedef TargetRegisterClass::const_iterator RegIter;

  for (unsigned I = 0; I < array_lengthof(ReservedCPURegs); ++I)
    Reserved.set(ReservedCPURegs[I]);

  return Reserved;
}

unsigned NewTargetRegisterInfo::
getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();

  return TFI->hasFP(MF) ? NewTarget::R15 : NewTarget::SP;
}

unsigned NewTargetRegisterInfo::
getEHExceptionRegister() const {
  llvm_unreachable("What is the exception register");
}

unsigned NewTargetRegisterInfo::
getEHHandlerRegister() const {
  llvm_unreachable("What is the exception handler register");
}

void
NewTargetRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                        int SPAdj, unsigned FIOperandNum,
                                        RegScavenger *RS) const {

	  //std::cout << "--------- NewTargetRegisterInfo::eliminateFrameIndex ----------\n";


	  MachineInstr &MI = *II;
	  MachineFunction &MF = *MI.getParent()->getParent();
	  MachineFrameInfo *MFI = MF.getFrameInfo();
	  NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();

	  DEBUG(errs() << "\nFunction : " << MF.getName() << "\n";
	        errs() << "<--------->\n" << MI);

	  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
	  uint64_t stackSize = MF.getFrameInfo()->getStackSize();
	  int64_t spOffset = MF.getFrameInfo()->getObjectOffset(FrameIndex);

	  DEBUG(errs() << "FrameIndex : " << FrameIndex << "\n"
	               << "spOffset   : " << spOffset << "\n"
	               << "stackSize  : " << stackSize << "\n");

	  //eliminateFI(MI, FIOperandNum, FrameIndex, stackSize, spOffset);

	  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();
      int MinCSFI = 0;
	  int MaxCSFI = -1;

      if (CSI.size()) {
	     MinCSFI = CSI[0].getFrameIdx();
	     MaxCSFI = CSI[CSI.size() - 1].getFrameIdx();
	  }

	  bool EhDataRegFI = NewTargetFI->isEhDataRegFI(FrameIndex);

	  // The following stack frame objects are always referenced relative to $sp:
	  //  1. Outgoing arguments.
	  //  2. Pointer to dynamically allocated stack space.
	  //  3. Locations for callee-saved registers.
	  //  4. Locations for eh data registers.
	  // Everything else is referenced relative to whatever register
	  // getFrameRegister() returns.
	  unsigned FrameReg;
          
          //std::cout << "MinCSFI: " << MinCSFI << "\n";
          //std::cout << "FrameIndex: " << FrameIndex << "\n";
          //std::cout << "MaxCSFI: " << MaxCSFI << "\n";
          //std::cout << "EhDataRegFI: " << EhDataRegFI << "\n";

	  if ((FrameIndex >= MinCSFI && FrameIndex <= MaxCSFI) || EhDataRegFI){
              //std::cout << "usando SP como registrador\n";
              FrameReg = NewTarget::SP;
          } else{
              FrameReg = getFrameRegister(MF);
              //std::cout << "usando FP como registrador: " << FrameReg << "\n";
          }
	    

	  // Calculate final offset.
	  // - There is no need to change the offset if the frame object is one of the
	  //   following: an outgoing argument, pointer to a dynamically allocated
	  //   stack space or a $gp restore location,
	  // - If the frame object is any of the following, its offset must be adjusted
	  //   by adding the size of the stack:
	  //   incoming argument, callee-saved register location or local variable.
	  bool IsKill = false;
	  int64_t Offset;

	  Offset = spOffset + (int64_t)stackSize;
	  Offset += MI.getOperand(FIOperandNum + 1).getImm();

	  DEBUG(errs() << "Offset     : " << Offset << "\n" << "<--------->\n");

	  // If MI is not a debug value, make sure Offset fits in the 16-bit immediate
	  // field.
	  if (!MI.isDebugValue() && !isInt<9>(Offset)) {
	    MachineBasicBlock &MBB = *MI.getParent();
	    DebugLoc DL = II->getDebugLoc();
	    unsigned ADD = NewTarget::ADD;
	    unsigned NewImm;

	    unsigned Reg = TII.loadImmediate(Offset, MBB, II, DL, &NewImm);
	    BuildMI(MBB, II, DL, TII.get(ADD), Reg).addReg(FrameReg)
	      .addReg(Reg, RegState::Kill);

	    FrameReg = Reg;
	    Offset = SignExtend64<9>(NewImm);
	    IsKill = true;
	  }
          
          //std::cout << "->>>>>>SP: " << NewTarget::SP << "\n";
          //std::cout << "FrameReg: " << FrameReg << "\n";
	  MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false, false, IsKill);
	  MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
}

bool NewTargetRegisterInfo::
requiresFrameIndexScavenging(const MachineFunction &MF) const {
  return true;
}

bool
NewTargetRegisterInfo::requiresRegisterScavenging(const MachineFunction &MF) const {
 //   std::cout << "NewTargetRegisterInfo::requiresRegisterScavenging alterado alterado para false\n";
  return true;
}

bool
NewTargetRegisterInfo::trackLivenessAfterRegAlloc(const MachineFunction &MF) const {
  return true;
}
