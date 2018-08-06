/*
 * NewTargetTargetObjectFile.h
 *
 *  Created on: Apr 23, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETTARGETOBJECTFILE_H_
#define NEWTARGETTARGETOBJECTFILE_H_

#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {

  class NewTargetTargetObjectFile : public TargetLoweringObjectFileELF {
    const MCSection *SmallDataSection;
    const MCSection *SmallBSSSection;
    const MCSection *ReginfoSection;
  public:

    void Initialize(MCContext &Ctx, const TargetMachine &TM);


    /// IsGlobalInSmallSection - Return true if this global address should be
    /// placed into small data/bss section.
    bool IsGlobalInSmallSection(const GlobalValue *GV,
                                const TargetMachine &TM, SectionKind Kind)const;
    bool IsGlobalInSmallSection(const GlobalValue *GV,
                                const TargetMachine &TM) const;

    const MCSection *SelectSectionForGlobal(const GlobalValue *GV,
                                            SectionKind Kind,
                                            Mangler *Mang,
                                            const TargetMachine &TM) const;

    // TODO: Classify globals as mips wishes.
    const MCSection *getReginfoSection() const { return ReginfoSection; }
    
    const MCSection *getSectionForConstant(SectionKind Kind) const;
  };
} // end namespace llvm

#endif /* NEWTARGETTARGETOBJECTFILE_H_ */
