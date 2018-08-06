/*
 * NewTargetFrameLowering.cpp
 *
 *  Created on: Mar 12, 2013
 *      Author: andreu
 */

#include "NewTargetFrameLowering.h"
#include "NewTargetMachineFunction.h"
#include "NewTargetInstrInfo.h"

#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"
#include <iostream>

using namespace llvm;

unsigned NewTargetFrameLowering::ehDataReg(unsigned I) const {
  static const unsigned EhDataReg[] = {
      NewTarget::R16, NewTarget::R17, NewTarget::R18, NewTarget::R19,
      NewTarget::R20, NewTarget::R21, NewTarget::R22, NewTarget::R23
  };

  return EhDataReg[I];
}


bool NewTargetFrameLowering::hasFP(const MachineFunction &MF) const {
	const MachineFrameInfo *MFI = MF.getFrameInfo();
			return MF.getTarget().Options.DisableFramePointerElim(MF) ||
	      MFI->hasVarSizedObjects() || MFI->isFrameAddressTaken();
}

uint64_t NewTargetFrameLowering::estimateStackSize(const MachineFunction &MF) const {
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  const TargetRegisterInfo &TRI = *MF.getTarget().getRegisterInfo();

  int64_t Offset = 0;

  // Iterate over fixed sized objects.
  for (int I = MFI->getObjectIndexBegin(); I != 0; ++I)
    Offset = std::max(Offset, -MFI->getObjectOffset(I));

  // Conservatively assume all callee-saved registers will be saved.
  for (const uint16_t *R = TRI.getCalleeSavedRegs(&MF); *R; ++R) {
    unsigned Size = TRI.getMinimalPhysRegClass(*R)->getSize();
    Offset = RoundUpToAlignment(Offset + Size, Size);
  }

  unsigned MaxAlign = MFI->getMaxAlignment();

  // Check that MaxAlign is not zero if there is a stack object that is not a
  // callee-saved spill.
  assert(!MFI->getObjectIndexEnd() || MaxAlign);

  // Iterate over other objects.
  for (unsigned I = 0, E = MFI->getObjectIndexEnd(); I != E; ++I)
    Offset = RoundUpToAlignment(Offset + MFI->getObjectSize(I), MaxAlign);

  // Call frame.
  if (MFI->adjustsStack() && hasReservedCallFrame(MF))
    Offset = RoundUpToAlignment(Offset + MFI->getMaxCallFrameSize(),
                                std::max(MaxAlign, getStackAlignment()));

  return RoundUpToAlignment(Offset, getStackAlignment());
}

bool NewTargetFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
	const MachineFrameInfo *MFI = MF.getFrameInfo();
	// Reserve call frame if the size of the maximum call frame fits into 16-bit
	// immediate field and there are no variable sized objects on the stack.
	return isInt<9>(MFI->getMaxCallFrameSize()) && !MFI->hasVarSizedObjects();
}

void NewTargetFrameLowering::emitPrologue(MachineFunction &MF) const {
	//std::cout << "NewTargetFrameLowering::emitPrologue not implemented\n";
	 MachineBasicBlock &MBB   = MF.front();
	 MachineFrameInfo *MFI    = MF.getFrameInfo();
	 NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();
	 const NewTargetRegisterInfo *RegInfo =
	   static_cast<const NewTargetRegisterInfo*>(MF.getTarget().getRegisterInfo());
	 const NewTargetInstrInfo &TII =
	   *static_cast<const NewTargetInstrInfo*>(MF.getTarget().getInstrInfo());
	 MachineBasicBlock::iterator MBBI = MBB.begin();
	 DebugLoc dl = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
	 unsigned SP = NewTarget::SP;
	 unsigned FP = NewTarget::R15;
	 unsigned ZERO = NewTarget::ZERO;
	 unsigned ADD = NewTarget::ADD;

	 // First, compute final stack size.
	 uint64_t StackSize = MFI->getStackSize();

	 // No need to allocate space on the stack.
	 if (StackSize == 0 && !MFI->adjustsStack()){
	  return;
	 }

	 MachineModuleInfo &MMI = MF.getMMI();
	 std::vector<MachineMove> &Moves = MMI.getFrameMoves();
	 MachineLocation DstML, SrcML;

	 // Adjust stack.
	 TII.adjustStackPtr(SP, -StackSize, MBB, MBBI);

	 
	 // emit ".cfi_def_cfa_offset StackSize"
	 MCSymbol *AdjustSPLabel = MMI.getContext().CreateTempSymbol();
	BuildMI(MBB, MBBI, dl,
	         TII.get(TargetOpcode::PROLOG_LABEL)).addSym(AdjustSPLabel);
	 DstML = MachineLocation(MachineLocation::VirtualFP);
	 SrcML = MachineLocation(MachineLocation::VirtualFP, -StackSize);
	 Moves.push_back(MachineMove(AdjustSPLabel, DstML, SrcML));
	 

	 const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();

	 if (CSI.size()) {
	   // Find the instruction past the last instruction that saves a callee-saved
	   // register to the stack.
	   for (unsigned i = 0; i < CSI.size(); ++i)
	     ++MBBI;

	   // Iterate over list of callee-saved registers and emit .cfi_offset
	   // directives.
           
	     MCSymbol *CSLabel = MMI.getContext().CreateTempSymbol();
	    // BuildMI(MBB, MBBI, dl,
	    //      TII.get(TargetOpcode::PROLOG_LABEL)).addSym(CSLabel);

	   for (std::vector<CalleeSavedInfo>::const_iterator I = CSI.begin(),
	           E = CSI.end(); I != E; ++I) {
	     int64_t Offset = MFI->getObjectOffset(I->getFrameIdx());
	     unsigned Reg = I->getReg();

	     // Reg is either in CPURegs or FGR32.
	     DstML = MachineLocation(MachineLocation::VirtualFP, Offset);
	     SrcML = MachineLocation(Reg);
	     Moves.push_back(MachineMove(CSLabel, DstML, SrcML));
	   }
	 }

	 if (NewTargetFI->callsEhReturn()) {
	   const TargetRegisterClass *RC = &NewTarget::CPURegsRegClass;

	   // Insert instructions that spill eh data registers.
	   for (int I = 0; I < 4; ++I) {
	     if (!MBB.isLiveIn(ehDataReg(I)))
	       MBB.addLiveIn(ehDataReg(I));
	     TII.storeRegToStackSlot(MBB, MBBI, ehDataReg(I), false,
	                             NewTargetFI->getEhDataRegFI(I), RC, RegInfo);
	   }

	   // Emit .cfi_offset directives for eh data registers.
	   MCSymbol *CSLabel2 = MMI.getContext().CreateTempSymbol();
           
	   BuildMI(MBB, MBBI, dl,
	            TII.get(TargetOpcode::PROLOG_LABEL)).addSym(CSLabel2);
           
	   for (int I = 0; I < 4; ++I) {
	     int64_t Offset = MFI->getObjectOffset(NewTargetFI->getEhDataRegFI(I));
	     DstML = MachineLocation(MachineLocation::VirtualFP, Offset);
	     SrcML = MachineLocation(ehDataReg(I));
	     Moves.push_back(MachineMove(CSLabel2, DstML, SrcML));
	   }

	  }

	 // if framepointer enabled, set it to point to the stack pointer.
	 if (hasFP(MF)) {
	   // Insert instruction "move $fp, $sp" at this location.
	   BuildMI(MBB, MBBI, dl, TII.get(ADD), FP).addReg(SP).addReg(ZERO);

	   // emit ".cfi_def_cfa_register $fp"
	   MCSymbol *SetFPLabel = MMI.getContext().CreateTempSymbol();
           
	   //BuildMI(MBB, MBBI, dl,
	     //      TII.get(TargetOpcode::PROLOG_LABEL)).addSym(SetFPLabel);
           
	   DstML = MachineLocation(FP);
	   SrcML = MachineLocation(MachineLocation::VirtualFP);
	   Moves.push_back(MachineMove(SetFPLabel, DstML, SrcML));

	  }
}

void NewTargetFrameLowering::emitEpilogue(MachineFunction &MF,
                                       MachineBasicBlock &MBB) const {
	  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
	  MachineFrameInfo *MFI            = MF.getFrameInfo();
	  NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();
	  const NewTargetRegisterInfo *RegInfo =
	    static_cast<const NewTargetRegisterInfo*>(MF.getTarget().getRegisterInfo());
	  const NewTargetInstrInfo &TII =
	    *static_cast<const NewTargetInstrInfo*>(MF.getTarget().getInstrInfo());
	  DebugLoc dl = MBBI->getDebugLoc();
	  unsigned SP = NewTarget::SP;
	  unsigned FP = NewTarget::R15;
	  unsigned ZERO =  NewTarget::ZERO;
	  unsigned ADD = NewTarget::ADD;

	  // if framepointer enabled, restore the stack pointer.
	  if (hasFP(MF)) {
	    // Find the first instruction that restores a callee-saved register.
	    MachineBasicBlock::iterator I = MBBI;

	    for (unsigned i = 0; i < MFI->getCalleeSavedInfo().size(); ++i)
	      --I;

	    // Insert instruction "move $sp, $fp" at this location.
	    BuildMI(MBB, I, dl, TII.get(ADD), SP).addReg(FP).addReg(ZERO);
	  }

	  if (NewTargetFI->callsEhReturn()) {
	    const TargetRegisterClass *RC = &NewTarget::CPURegsRegClass;

	    // Find first instruction that restores a callee-saved register.
	    MachineBasicBlock::iterator I = MBBI;
	    for (unsigned i = 0; i < MFI->getCalleeSavedInfo().size(); ++i)
	      --I;

	    // Insert instructions that restore eh data registers.
	    for (int J = 0; J < 4; ++J) {
	      TII.loadRegFromStackSlot(MBB, I, ehDataReg(J), NewTargetFI->getEhDataRegFI(J),
	                               RC, RegInfo);
	    }
	  }

	  // Get the number of bytes from FrameInfo
	  uint64_t StackSize = MFI->getStackSize();

	  if (!StackSize)
	    return;

	  // Adjust stack.
	  TII.adjustStackPtr(SP, StackSize, MBB, MBBI);
}

// FIXME: Can we eleminate these in favour of generic code?
bool
NewTargetFrameLowering::spillCalleeSavedRegisters(MachineBasicBlock &MBB,
                                           MachineBasicBlock::iterator MI,
                                        const std::vector<CalleeSavedInfo> &CSI,
                                        const TargetRegisterInfo *TRI) const {

  MachineFunction *MF = MBB.getParent();
  MachineBasicBlock *EntryBlock = MF->begin();
  const TargetInstrInfo &TII = *MF->getTarget().getInstrInfo();
  for (unsigned i = 0, e = CSI.size(); i != e; ++i) {
    // Add the callee-saved register as live-in. Do not add if the register is
    // RA and return address is taken, because it has already been added in
    // method MipsTargetLowering::LowerRETURNADDR.
    // It's killed at the spill, unless the register is RA and return address
    // is taken.
    unsigned Reg = CSI[i].getReg();
    bool IsRAAndRetAddrIsTaken = (Reg == NewTarget::LR)
        && MF->getFrameInfo()->isReturnAddressTaken();
    if (!IsRAAndRetAddrIsTaken)
      EntryBlock->addLiveIn(Reg);

    // Insert the spill to the stack frame.
    bool IsKill = !IsRAAndRetAddrIsTaken;
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);
    TII.storeRegToStackSlot(*EntryBlock, MI, Reg, IsKill,
                            CSI[i].getFrameIdx(), RC, TRI);
  }

  return true;

}

bool
NewTargetFrameLowering::restoreCalleeSavedRegisters(MachineBasicBlock &MBB,
                                                 MachineBasicBlock::iterator MI,
                                        const std::vector<CalleeSavedInfo> &CSI,
                                        const TargetRegisterInfo *TRI) const {

	/*if we return false, generic CodeGen code constructs the restore =)*/
	return false;
}

void NewTargetFrameLowering::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {

	  const NewTargetInstrInfo &TII =
	    *static_cast<const NewTargetInstrInfo*>(MF.getTarget().getInstrInfo());

	  if (!hasReservedCallFrame(MF)) {
	    int64_t Amount = I->getOperand(0).getImm();

	    if (I->getOpcode() == NewTarget::ADJCALLSTACKDOWN)
	      Amount = -Amount;

	    unsigned SP = NewTarget::SP;
	    TII.adjustStackPtr(SP, Amount, MBB, I);
	  }

	  MBB.erase(I);
}

void NewTargetFrameLowering::
processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
                                     RegScavenger *RS) const {
  MachineRegisterInfo &MRI = MF.getRegInfo();
  NewTargetFunctionInfo *NewTargetFI = MF.getInfo<NewTargetFunctionInfo>();
  unsigned FP = NewTarget::R15;

  // Mark $fp as used if function has dedicated frame pointer.
  if (hasFP(MF))
    MRI.setPhysRegUsed(FP);

  // Create spill slots for eh data registers if function calls eh_return.
  if (NewTargetFI->callsEhReturn())
    NewTargetFI->createEhDataRegsFI();

  // Set scavenging frame index if necessary.
  uint64_t MaxSPOffset = MF.getInfo<NewTargetFunctionInfo>()->getIncomingArgSize() +
    estimateStackSize(MF);

  if (isInt<16>(MaxSPOffset))
    return;

  const TargetRegisterClass *RC = &NewTarget::CPURegsRegClass;
  int FI = MF.getFrameInfo()->CreateStackObject(RC->getSize(),
                                                RC->getAlignment(), false);
  RS->setScavengingFrameIndex(FI);
}

/*
void
NewTargetFrameLowering::processFunctionBeforeFrameFinalized(MachineFunction &MF)
                                                                         const {
	//TODO
	std::cout << "NewTargetFrameLowering::processFunctionBeforeFrameFinalized not implemented\n";
}
*/
