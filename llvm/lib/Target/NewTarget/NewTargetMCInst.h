/* 
 * File:   NewTargetMCInst.h
 * Author: andreu
 *
 * Created on April 9, 2014, 3:02 PM
 */

#ifndef NEWTARGETMCINST_H
#define	NEWTARGETMCINST_H

#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCInst.h"

namespace llvm {
  class NewTargetMCInst: public MCInst {
    // Packet start and end markers
    bool startPacket; 
    bool endPacket;
    unsigned bundleSize;
    const MachineInstr *MachineI;
  public:
    explicit NewTargetMCInst(): MCInst(),
                              startPacket(false), endPacket(false), bundleSize(1) {}

    const MachineInstr* getMI() const { return MachineI; }

    void setMI(const MachineInstr *MI) { MachineI = MI; }

    bool isStartPacket() const { return (startPacket); }
    bool isEndPacket() const { return (endPacket);  }

    void setStartPacket() { startPacket = true; }
    void setEndPacket() { endPacket = true;}
    void setBundleSize(unsigned size) {bundleSize = size;};
    unsigned getBundleSize() const {return bundleSize;};
  };
}

#endif	/* NEWTARGETMCINST_H */

