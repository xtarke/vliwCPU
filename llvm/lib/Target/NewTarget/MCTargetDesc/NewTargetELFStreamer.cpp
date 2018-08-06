/*
 * NewTargetELFStreamer.cpp
 *
 *  Created on: Apr 11, 2013
 *      Author: andreu
 */

#include "llvm/MC/MCELFStreamer.h"
#include "MCTargetDesc/NewTargetMCTargetDesc.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/Twine.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCELF.h"
#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCELFSymbolFlags.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCObjectStreamer.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ELF.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {


class NewTargetELFStreamer : public MCELFStreamer {
public:
  NewTargetELFStreamer(MCContext &Context, MCAsmBackend &TAB,
                 raw_ostream &OS, MCCodeEmitter *Emitter)
    : MCELFStreamer(Context, TAB, OS, Emitter){  
		llvm::MachineCodeContext = &Context;
  }

  ~NewTargetELFStreamer() {}

  virtual void ChangeSection(const MCSection *Section) {

    MCELFStreamer::ChangeSection(Section);
  }

  /// This function is the one used to emit instruction data into the ELF
  /// streamer. We override it to add the appropriate mapping symbol if
  /// necessary.
  virtual void EmitInstruction(const MCInst& Inst) {
    //EmitNewTargetMappingSymbol();
    MCELFStreamer::EmitInstruction(Inst);
  }

  /// This is one of the functions used to emit data into an ELF section, so the
  /// NewTarget streamer overrides it to add the appropriate mapping symbol ($d)
  /// if necessary.
  virtual void EmitBytes(StringRef Data, unsigned AddrSpace) {
    //EmitDataMappingSymbol();
    MCELFStreamer::EmitBytes(Data, AddrSpace);
  }

  /// This is one of the functions used to emit data into an ELF section, so the
  /// NewTarget streamer overrides it to add the appropriate mapping symbol ($d)
  /// if necessary.
  virtual void EmitValueImpl(const MCExpr *Value, unsigned Size,
                             unsigned AddrSpace) {
    //EmitDataMappingSymbol();
    MCELFStreamer::EmitValueImpl(Value, Size, AddrSpace);
  }

private:


  /// @}
};
}




MCStreamer* llvm::createNewTargetELFStreamer(const Target &T, StringRef TT,
										MCContext &Context, MCAsmBackend &TAB,
                                        raw_ostream &OS,
                                        MCCodeEmitter *Emitter,
                                        bool RelaxAll,
                                        bool NoExecStack){
	return new NewTargetELFStreamer(Context, TAB, OS, Emitter);
}
