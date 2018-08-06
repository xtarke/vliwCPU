/*
 * NewTargetFixupKinds.h
 *
 *  Created on: Apr 15, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETFIXUPKINDS_H_
#define NEWTARGETFIXUPKINDS_H_

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace NewTarget {
  // Although most of the current fixup types reflect a unique relocation
  // one can have multiple fixup types for a given relocation and thus need
  // to be uniquely named.
  //
  // This table *must* be in the save order of
  // MCFixupKindInfo Infos[Mips::NumTargetFixupKinds]
  // in MipsAsmBackend.cpp.
  //
  enum Fixups {
    // Branch fixups resulting in R_MIPS_16.
    fixup_NewTarget_16 = FirstTargetFixupKind,
    
    fixup_NewTarget_PC23GOTO,
    
    fixup_NewTarget_PC23CALL,
    
    fixup_NewTarget_IMM9,
    
    fixup_NewTarget_IMM23,
    
    fixup_NewTarget_32,
    
    fixup_NewTarget_PC23PRELOAD,
/*
    // Pure 32 bit data fixup resulting in - R_MIPS_32.
    fixup_NewTarget_32,

    // Full 32 bit data relative data fixup resulting in - R_MIPS_REL32.
    fixup_Mips_REL32,

    // Jump 26 bit fixup resulting in - R_MIPS_26.
    fixup_NewTarget_26,

    // Pure upper 16 bit fixup resulting in - R_MIPS_HI16.
    fixup_Mips_HI16,

    // Pure lower 16 bit fixup resulting in - R_MIPS_LO16.
    fixup_Mips_LO16,
    
    fixup_NewTarget_9,
    
    fixup_NewTarget_23shift9,

    // 16 bit fixup for GP offest resulting in - R_MIPS_GPREL16.
    fixup_Mips_GPREL16,

    // 16 bit literal fixup resulting in - R_MIPS_LITERAL.
    fixup_Mips_LITERAL,

    // Global symbol fixup resulting in - R_MIPS_GOT16.
    fixup_Mips_GOT_Global,

    // Local symbol fixup resulting in - R_MIPS_GOT16.
    fixup_Mips_GOT_Local,

    // PC relative branch fixup resulting in - R_MIPS_PC16.
    fixup_NewTarget_PC16,

    // resulting in - R_MIPS_CALL16.
    fixup_Mips_CALL16,

    // resulting in - R_MIPS_GPREL32.
    fixup_Mips_GPREL32,

    // resulting in - R_MIPS_SHIFT5.
    fixup_Mips_SHIFT5,

    // resulting in - R_MIPS_SHIFT6.
    fixup_Mips_SHIFT6,

    // Pure 64 bit data fixup resulting in - R_MIPS_64.
    fixup_Mips_64,

    // resulting in - R_MIPS_TLS_GD.
    fixup_Mips_TLSGD,

    // resulting in - R_MIPS_TLS_GOTTPREL.
    fixup_Mips_GOTTPREL,

    // resulting in - R_MIPS_TLS_TPREL_HI16.
    fixup_Mips_TPREL_HI,

    // resulting in - R_MIPS_TLS_TPREL_LO16.
    fixup_Mips_TPREL_LO,

    // resulting in - R_MIPS_TLS_LDM.
    fixup_Mips_TLSLDM,

    // resulting in - R_MIPS_TLS_DTPREL_HI16.
    fixup_Mips_DTPREL_HI,

    // resulting in - R_MIPS_TLS_DTPREL_LO16.
    fixup_Mips_DTPREL_LO,

    // PC relative branch fixup resulting in - R_MIPS_PC16
    fixup_Mips_Branch_PCRel,

    // resulting in - R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_HI16
    fixup_Mips_GPOFF_HI,

    // resulting in - R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_LO16
    fixup_Mips_GPOFF_LO,

    // resulting in - R_MIPS_PAGE
    fixup_Mips_GOT_PAGE,

    // resulting in - R_MIPS_GOT_OFST
    fixup_Mips_GOT_OFST,

    // resulting in - R_MIPS_GOT_DISP
    fixup_Mips_GOT_DISP,

    // resulting in - R_MIPS_GOT_HIGHER
    fixup_Mips_HIGHER,

    // resulting in - R_MIPS_HIGHEST
    fixup_Mips_HIGHEST,

    // resulting in - R_MIPS_GOT_HI16
    fixup_Mips_GOT_HI16,

    // resulting in - R_MIPS_GOT_LO16
    fixup_Mips_GOT_LO16,

    // resulting in - R_MIPS_CALL_HI16
    fixup_Mips_CALL_HI16,

    // resulting in - R_MIPS_CALL_LO16
    fixup_Mips_CALL_LO16,
*/
    // Marker
    LastTargetFixupKind,
    NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
  };
} // namespace Mips
} // namespace llvm





#endif /* NEWTARGETFIXUPKINDS_H_ */
