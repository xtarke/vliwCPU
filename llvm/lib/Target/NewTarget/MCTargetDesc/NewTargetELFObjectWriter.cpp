/*
 * .cpp
 *
 *  Created on: Apr 12, 2013
 *      Author: andreu
 */

#include "llvm/MC/MCELFObjectWriter.h"
#include "MCTargetDesc/NewTargetBaseInfo.h"
#include "MCTargetDesc/NewTargetFixupKinds.h"
#include "MCTargetDesc/NewTargetRelocTypes.h"
#include "MCTargetDesc/NewTargetMCTargetDesc.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"
#include <list>
#include <iostream>

using namespace llvm;

namespace {
  struct RelEntry {
    RelEntry(const ELFRelocationEntry &R, const MCSymbol *S, int64_t O) :
      Reloc(R), Sym(S), Offset(0) {}
    ELFRelocationEntry Reloc;
    const MCSymbol *Sym;
    int64_t Offset;
  };

  typedef std::list<RelEntry> RelLs;
  typedef RelLs::iterator RelLsIter;

  class NewTargetELFObjectWriter : public MCELFObjectTargetWriter {
  public:
    NewTargetELFObjectWriter(bool _is64Bit, uint8_t OSABI,
                        bool _isN64, bool IsLittleEndian);

    virtual ~NewTargetELFObjectWriter();

    virtual unsigned GetRelocType(const MCValue &Target, const MCFixup &Fixup,
                                  bool IsPCRel, bool IsRelocWithSymbol,
                                  int64_t Addend) const;
    virtual const MCSymbol *ExplicitRelSym(const MCAssembler &Asm,
                                           const MCValue &Target,
                                           const MCFragment &F,
                                           const MCFixup &Fixup,
                                           bool IsPCRel) const;
    virtual void sortRelocs(const MCAssembler &Asm,
                            std::vector<ELFRelocationEntry> &Relocs);
  };
}

NewTargetELFObjectWriter::NewTargetELFObjectWriter(bool _is64Bit, uint8_t OSABI,
                                         bool _isN64, bool IsLittleEndian)
  : MCELFObjectTargetWriter(_is64Bit, OSABI, ELF::EM_NONE,
                            /*HasRelocationAddend*/ true,
                            /*IsN64*/ _isN64) {}

NewTargetELFObjectWriter::~NewTargetELFObjectWriter() {}

const MCSymbol *NewTargetELFObjectWriter::ExplicitRelSym(const MCAssembler &Asm,
                                                    const MCValue &Target,
                                                    const MCFragment &F,
                                                    const MCFixup &Fixup,
                                                    bool IsPCRel) const {
  assert(Target.getSymA() && "SymA cannot be 0.");
  const MCSymbol &Sym = Target.getSymA()->getSymbol().AliasedSymbol();
  
  if (Sym.getSection().getKind().isMergeableCString() ||
      Sym.getSection().getKind().isMergeableConst())
    return &Sym;

  //std::cout << "Vai retornar NULLL\n";
  
  return NULL;
}

unsigned NewTargetELFObjectWriter::GetRelocType(const MCValue &Target,
                                           const MCFixup &Fixup,
                                           bool IsPCRel,
                                           bool IsRelocWithSymbol,
                                           int64_t Addend) const {
	// determine the type of the relocation
	unsigned Type = (unsigned)NewTarget::R_NONE;
	unsigned Kind = (unsigned)Fixup.getKind();

        //std::cout << "\n\n----------NewTargetELFObjectWriter::GetRelocType---------\n\n";
        
	switch (Kind) {

	  default:
	    llvm_unreachable("invalid fixup kind!");
                case FK_Data_4:
                        Type = NewTarget::R_32;
                        break;
		case NewTarget::fixup_NewTarget_PC23GOTO:
			Type = NewTarget::R_PC23GOTO;
			break;
                case NewTarget::fixup_NewTarget_PC23PRELOAD:
			Type = NewTarget::R_PC23PRELOAD;
			break;        
		case NewTarget::fixup_NewTarget_PC23CALL:
			Type = NewTarget::R_PC23CALL;
			break;
		case NewTarget::fixup_NewTarget_IMM9:
			Type = NewTarget::R_IMM9;
			break;
                case NewTarget::fixup_NewTarget_IMM23:
			Type = NewTarget::R_IMM23;
			break;                           
	}

	return Type;
}

/*
// Return true if R is either a GOT16 against a local symbol or HI16.
static bool NeedsMatchingLo(const MCAssembler &Asm, const RelEntry &R) {
	return false;
}

static bool HasMatchingLo(const MCAssembler &Asm, RelLsIter I, RelLsIter Last) {
	return false;
}

static bool HasSameSymbol(const RelEntry &R0, const RelEntry &R1) {
  return R0.Sym == R1.Sym;
}

static int CompareOffset(const RelEntry &R0, const RelEntry &R1) {
  return (R0.Offset > R1.Offset) ? 1 : ((R0.Offset == R1.Offset) ? 0 : -1);
}
*/

void NewTargetELFObjectWriter::sortRelocs(const MCAssembler &Asm,
                                     std::vector<ELFRelocationEntry> &Relocs) {

}


MCObjectWriter *llvm::createNewTargetELFObjectWriter(raw_ostream &OS,
                                                uint8_t OSABI,
                                                bool IsLittleEndian,
                                                bool Is64Bit) {


  MCELFObjectTargetWriter *MOTW = new NewTargetELFObjectWriter(Is64Bit, OSABI,
                                                (Is64Bit) ? true : false,
                                                IsLittleEndian);

  //return createELFObjectWriter(MOTW, OS, IsLittleEndian);
  //we have our own ELF writer
  return createRelocatedELFObjectWriter(MOTW, OS, IsLittleEndian, NewTargetII::BASE_ADDRESS);
}


