/*
 * NewTargetFrameLowering.h
 *
 *  Created on: Mar 12, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETFRAMELOWERING_H_
#define NEWTARGETFRAMELOWERING_H_

#include "NewTarget.h"
#include "NewTargetSubtarget.h"
#include "llvm/Target/TargetFrameLowering.h"

namespace llvm {

class NewTargetMachine;

class NewTargetFrameLowering : public TargetFrameLowering {
protected:
  const NewTargetMachine &T;

public:
  explicit NewTargetFrameLowering(const NewTargetMachine &t)
  	//TODO ??
    : TargetFrameLowering(TargetFrameLowering::StackGrowsDown, 8, 0, 8), T(t) {}


  void emitPrologue(MachineFunction &MF) const;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const;

  void eliminateCallFramePseudoInstr(MachineFunction &MF,
                                     MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator I) const;

  bool spillCalleeSavedRegisters(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator MI,
                                 const std::vector<CalleeSavedInfo> &CSI,
                                 const TargetRegisterInfo *TRI) const;
  bool restoreCalleeSavedRegisters(MachineBasicBlock &MBB,
                                   MachineBasicBlock::iterator MI,
                                   const std::vector<CalleeSavedInfo> &CSI,
                                   const TargetRegisterInfo *TRI) const;

  bool hasFP(const MachineFunction &MF) const;
  bool hasReservedCallFrame(const MachineFunction &MF) const;
  //void processFunctionBeforeFrameFinalized(MachineFunction &MF) const;

  unsigned ehDataReg(unsigned I) const;

  
  void processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
                                     RegScavenger *RS) const;
protected:

  uint64_t estimateStackSize(const MachineFunction &MF) const;
};

} /* namespace llvm */
#endif /* NEWTARGETFRAMELOWERING_H_ */
