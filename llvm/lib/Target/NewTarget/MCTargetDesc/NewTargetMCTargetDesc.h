//===-- MBlazeMCTargetDesc.h - MBlaze Target Descriptions -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides MBlaze specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef NEWTARGETMCTARGETDESC_H
#define NEWTARGETMCTARGETDESC_H

#include "NewTarget.h"
#include <llvm/Support/DataTypes.h>
//#include <llvm/ADT/StringRef.h>

namespace llvm {

class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class StringRef;
class Target;
class raw_ostream;
class MCStreamer;
class MCELFStreamer;
class MCELFObjectTargetWriter;
class MCAsmInfo;

extern Target TheNewTargetTarget;

MCCodeEmitter *createNewTargetMCCodeEmitter(const MCInstrInfo &MCII,
                                               const MCRegisterInfo &MRI,
                                               const MCSubtargetInfo &STI,
                                               MCContext &Ctx);

MCStreamer* createNewTargetELFStreamer(const Target &T, StringRef TT,
										MCContext &Context, MCAsmBackend &TAB,
                                        raw_ostream &OS,
                                        MCCodeEmitter *Emitter,  bool RelaxAll,
                                        bool NoExecStack);

MCAsmBackend *createNewTargetAsmBackend(const Target &T, StringRef TT,
                                             StringRef CPU);

MCObjectWriter *createNewTargetELFObjectWriter(raw_ostream &OS,
        										uint8_t OSABI,
        										bool IsLittleEndian,
        										bool Is64Bit);

/*we have our own ELF writer*/
MCObjectWriter *createRelocatedELFObjectWriter(MCELFObjectTargetWriter *MOTW,
                                            raw_ostream &OS,
                                            bool IsLittleEndian, unsigned int BaseAddress);
                                            
MCAsmInfo *createMCAsmInfo(const Target &T, StringRef TT);                                             
                                            
MCInstrInfo *createNewTargetMCInstrInfo(); 

MCRegisterInfo *createNewTargetMCRegisterInfo(StringRef TT);


MCSubtargetInfo *createNewTargetMCSubtargetInfo(StringRef TT, StringRef CPU, StringRef FS);


extern MCContext* MachineCodeContext;
}





#define GET_REGINFO_ENUM
#include "NewTargetGenRegisterInfo.inc"

// Defines symbolic names for the Mips instructions.
#define GET_INSTRINFO_ENUM
#include "NewTargetGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "NewTargetGenSubtargetInfo.inc"

#endif
