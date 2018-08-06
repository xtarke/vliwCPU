//===-- MBlazeMCTargetDesc.cpp - MBlaze Target Descriptions ---------------===//
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

#include "NewTargetMCTargetDesc.h"
#include "NewTargetMCAsmInfo.h"
#include "llvm/MC/MCCodeGenInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"
#include "InstPrinter/NewTargetInstPrinter.h"


#define GET_INSTRINFO_MC_DESC
#include "NewTargetGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "NewTargetGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "NewTargetGenRegisterInfo.inc"

using namespace llvm;

MCContext* llvm::MachineCodeContext = NULL;

MCAsmInfo* llvm::createMCAsmInfo(const Target &T, StringRef TT) {
  Triple TheTriple(TT);
  switch (TheTriple.getOS()) {
  default:
    return new NewTargetMCAsmInfo();
  }
}

static MCCodeGenInfo *createNewTargetMCCodeGenInfo(StringRef TT, Reloc::Model RM,
                                                CodeModel::Model CM,
                                                CodeGenOpt::Level OL) {
  MCCodeGenInfo *X = new MCCodeGenInfo();
  if (RM == Reloc::Default)
    RM = Reloc::Static;
  if (CM == CodeModel::Default)
    CM = CodeModel::Small;
  X->InitMCCodeGenInfo(RM, CM, OL);
  return X;
}

MCInstrInfo* llvm::createNewTargetMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  //TODO
  InitNewTargetMCInstrInfo(X);
  return X;
}

MCRegisterInfo* llvm::createNewTargetMCRegisterInfo(StringRef TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  //TODO
  InitNewTargetMCRegisterInfo(X, NewTarget::LR);
  return X;
}


MCSubtargetInfo* llvm::createNewTargetMCSubtargetInfo(StringRef TT, StringRef CPU, StringRef FS) {
  MCSubtargetInfo *X = new MCSubtargetInfo();
  //TODO
  return X;
}

static MCInstPrinter *createNewTargetMCInstPrinter(const Target &T,
                                              unsigned SyntaxVariant,
                                              const MCAsmInfo &MAI,
                                              const MCInstrInfo &MII,
                                              const MCRegisterInfo &MRI,
                                              const MCSubtargetInfo &STI) {
  return new NewTargetInstPrinter(MAI, MII, MRI);
}


// Force static initialization.
extern "C" void LLVMInitializeNewTargetTargetMC() {
   //Register the MC asm info.
  RegisterMCAsmInfoFn X(TheNewTarget, createMCAsmInfo);

  // Register the MC codegen info.
  TargetRegistry::RegisterMCCodeGenInfo(TheNewTarget,
                                       createNewTargetMCCodeGenInfo);

  // Register the MC instruction info.
   TargetRegistry::RegisterMCInstrInfo(TheNewTarget, createNewTargetMCInstrInfo);

  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(TheNewTarget,
                                    createNewTargetMCRegisterInfo);

  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(TheNewTarget,
                                          createNewTargetMCSubtargetInfo);

  // Register the MC code emitter
  TargetRegistry::RegisterMCCodeEmitter(TheNewTarget,
                                       createNewTargetMCCodeEmitter);

  // Register the asm backend
  TargetRegistry::RegisterMCAsmBackend(TheNewTarget,
		  	  	  	  	  	  	  	  createNewTargetAsmBackend);

  // Register the object streamer
  TargetRegistry::RegisterMCObjectStreamer(TheNewTarget,
	  	  	  	  	  	  	  	  createNewTargetELFStreamer);

  // Register the MCInstPrinter.
  TargetRegistry::RegisterMCInstPrinter(TheNewTarget,
                                        createNewTargetMCInstPrinter);
}
