/*
 * NewTargetMachine.h
 *
 *  Created on: Mar 5, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETMACHINE_H_
#define NEWTARGETMACHINE_H_

#include "NewTargetInstrInfo.h"
#include "NewTargetISelLowering.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include "NewTargetSubtarget.h"
#include "NewTargetSelectionDAGInfo.h"
#include "NewTargetFrameLowering.h"
#include "NewTargetRegisterInfo.h"


namespace llvm {



class NewTargetMachine : public LLVMTargetMachine {
  NewTargetSubtarget Subtarget;
  const DataLayout DL;       // Calculates type size & alignment
  NewTargetInstrInfo InstrInfo;
  NewTargetFrameLowering    FrameLowering;
  NewTargetTargetLowering		TLInfo;
  NewTargetSelectionDAGInfo TSInfo;
  const InstrItineraryData* InstrItins;

protected:
  //virtual const TargetAsmInfo *createTargetAsmInfo() const;

public:
  NewTargetMachine(const Target &T, StringRef TT,
	  	  	  StringRef CPU, StringRef FS,
	  	  	  const TargetOptions &Options,
	  	  	  Reloc::Model RM, CodeModel::Model CM,
	  	  	  CodeGenOpt::Level OL);
  //TODO terminar register info
  virtual const NewTargetInstrInfo *getInstrInfo() const {return &InstrInfo; }

  virtual const TargetFrameLowering *getFrameLowering() const
  { return &FrameLowering; }

  virtual const TargetRegisterInfo *getRegisterInfo() const { return &InstrInfo.getRegisterInfo(); }

  virtual const NewTargetSubtarget *getSubtargetImpl() const { return &Subtarget; }

  virtual const DataLayout *getDataLayout() const { return &DL; }
  
  virtual const InstrItineraryData* getInstrItineraryData() const {
    return InstrItins;
  } 

  virtual const NewTargetTargetLowering *getTargetLowering() const {
    return &TLInfo;
  }
  
    virtual const NewTargetSelectionDAGInfo* getSelectionDAGInfo() const {
    return &TSInfo;
  }
    
  //static unsigned getModuleMatchQuality(const Module &M);

  // Pass Pipeline Configuration
 // virtual bool addInstSelector(PassManagerBase &PM, bool Fast);
 // virtual bool addPreEmitPass(PassManagerBase &PM, bool Fast);

  virtual bool addPassesForOptimizations(PassManagerBase &PM);
  // Pass Pipeline Configuration
  virtual TargetPassConfig *createPassConfig(PassManagerBase &PM);
};

}

#endif /* NEWTARGETMACHINE_H_ */
