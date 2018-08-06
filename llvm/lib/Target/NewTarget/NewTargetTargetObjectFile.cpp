/*
 * NewTargetTargetObjectFile.cpp
 *
 *  Created on: Apr 23, 2013
 *      Author: andreu
 */

#include "NewTargetTargetObjectFile.h"
#include "NewTargetSubtarget.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ELF.h"
#include "llvm/Target/TargetMachine.h"
#include <iostream>
using namespace llvm;

static cl::opt<unsigned>
SSThreshold("newtarget-ssection-threshold", cl::Hidden,
        cl::desc("Small data and bss section threshold size (default=8)"),
        cl::init(8));

void NewTargetTargetObjectFile::Initialize(MCContext &Ctx, const TargetMachine &TM) {
    TargetLoweringObjectFileELF::Initialize(Ctx, TM);
    InitializeELF(TM.Options.UseInitArray);

    SmallDataSection =
            getContext().getELFSection(".sdata", ELF::SHT_PROGBITS,
            ELF::SHF_WRITE | ELF::SHF_ALLOC,
            SectionKind::getDataRel());

    SmallBSSSection =
            getContext().getELFSection(".sbss", ELF::SHT_NOBITS,
            ELF::SHF_WRITE | ELF::SHF_ALLOC,
            SectionKind::getBSS());

    // Register info information
    ReginfoSection =
            getContext().getELFSection(".reginfo",
            ELF::SHT_MIPS_REGINFO,
            ELF::SHF_ALLOC,
            SectionKind::getMetadata());
}

bool NewTargetTargetObjectFile::IsGlobalInSmallSection(const GlobalValue *GV,
        const TargetMachine &TM) const {
    if (GV->isDeclaration() || GV->hasAvailableExternallyLinkage())
        return false;

    return IsGlobalInSmallSection(GV, TM, getKindForGlobal(GV, TM));
}

/// IsGlobalInSmallSection - Return true if this global address should be
/// placed into small data/bss section.

bool NewTargetTargetObjectFile::
IsGlobalInSmallSection(const GlobalValue *GV, const TargetMachine &TM,
        SectionKind Kind) const {

    /*no bbs yet*/
    return false;
    /*
      const MipsSubtarget &Subtarget = TM.getSubtarget<MipsSubtarget>();

      // Return if small section is not available.
      if (!Subtarget.useSmallSection())
        return false;

      // Only global variables, not functions.
      const GlobalVariable *GVA = dyn_cast<GlobalVariable>(GV);
      if (!GVA)
        return false;

      // We can only do this for datarel or BSS objects for now.
      if (!Kind.isBSS() && !Kind.isDataRel())
        return false;

      // If this is a internal constant string, there is a special
      // section for it, but not in small data/bss.
      if (Kind.isMergeable1ByteCString())
        return false;

      Type *Ty = GV->getType()->getElementType();
      return IsInSmallSection(TM.getDataLayout()->getTypeAllocSize(Ty));
     */
}

const MCSection *NewTargetTargetObjectFile::
SelectSectionForGlobal(const GlobalValue *GV, SectionKind Kind,
        Mangler *Mang, const TargetMachine &TM) const {
    // TODO: Could also support "weak" symbols as well with ".gnu.linkonce.s.*"
    // sections?


    // Handle Small Section classification here.
    if (Kind.isBSS() && IsGlobalInSmallSection(GV, TM, Kind))
        return SmallBSSSection;
    if (Kind.isDataNoRel() && IsGlobalInSmallSection(GV, TM, Kind))
        return SmallDataSection;

    // Otherwise, we work the same as ELF.
    return TargetLoweringObjectFileELF::SelectSectionForGlobal(GV, Kind, Mang, TM);
}

const MCSection *NewTargetTargetObjectFile::getSectionForConstant(SectionKind Kind) const {

    
    return TargetLoweringObjectFileELF::getSectionForConstant(Kind);
}