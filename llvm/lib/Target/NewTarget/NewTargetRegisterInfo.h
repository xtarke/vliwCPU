/*
 * NewTargetRegisterInfo.h
 *
 *  Created on: Mar 11, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETREGISTERINFO_H_
#define NEWTARGETREGISTERINFO_H_

#include "llvm/Target/TargetRegisterInfo.h"


#define GET_REGINFO_HEADER
#include "NewTargetGenRegisterInfo.inc"

namespace llvm {

class NewTargetMachine;
class NewTargetInstrInfo;

class NewTargetRegisterInfo : public NewTargetGenRegisterInfo {

protected:
	const NewTargetMachine &TM;
	const NewTargetInstrInfo &TII;

public:

	NewTargetRegisterInfo(const NewTargetMachine &T, const NewTargetInstrInfo &TI);

	/// getRegisterNumbering - Given the enum value for some register, e.g.
	/// Mips::RA, return the number that it corresponds to (e.g. 31).
	static unsigned getRegisterNumbering(unsigned RegEnum);

	//unsigned getRegPressureLimit(const TargetRegisterClass *RC,
	//                               MachineFunction &MF) const;
        
	const uint16_t *getCalleeSavedRegs(const MachineFunction *MF = 0) const;
	const uint32_t *getCallPreservedMask(CallingConv::ID) const;
	BitVector getReservedRegs(const MachineFunction &MF) const;

	  /// Debug information queries.
	unsigned getFrameRegister(const MachineFunction &MF) const;

	  /// Exception handling queries.
	unsigned getEHExceptionRegister() const;
	unsigned getEHHandlerRegister() const;

	void eliminateFrameIndex(MachineBasicBlock::iterator II,
	                           int SPAdj, unsigned FIOperandNum,
	                           RegScavenger *RS = NULL) const;
        bool requiresRegisterScavenging(const MachineFunction &MF) const;
        bool requiresFrameIndexScavenging(const MachineFunction &MF) const;
        bool trackLivenessAfterRegAlloc(const MachineFunction &MF) const;
};

} /* namespace llvm */
#endif /* NEWTARGETREGISTERINFO_H_ */
