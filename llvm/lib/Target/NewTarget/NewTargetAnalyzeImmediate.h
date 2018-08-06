/*
 * NewTargetAnalyzeImmediate.h
 *
 *  Created on: Apr 2, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETANALYZEIMMEDIATE_H_
#define NEWTARGETANALYZEIMMEDIATE_H_


#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/DataTypes.h"

namespace llvm {

  class NewTargetAnalyzeImmediate {
  public:
    struct Inst {
      unsigned Opc, ImmOpnd;
      Inst(unsigned Opc, unsigned ImmOpnd);
    };
    typedef SmallVector<Inst, 7 > InstSeq;

    /// Analyze - Get an instrucion sequence to load immediate Imm. The last
    /// instruction in the sequence must be an ADDi if LastInstrIsADDi is
    /// true;
    const InstSeq &Analyze(uint64_t Imm, unsigned Size, bool LastInstrIsADDi);
  //private:
    typedef SmallVector<InstSeq, 5> InstSeqLs;

    /// AddInstr - Add I to all instruction sequences in SeqLs.
    void AddInstr(InstSeqLs &SeqLs, const Inst &I);

    /// GetInstSeqLsADDi - Get instrucion sequences which end with an ADDi to
    /// load immediate Imm
    void GetInstSeqLsADDi(uint64_t Imm, unsigned RemSize, InstSeqLs &SeqLs);

    /// GetInstSeqLsORi - Get instrucion sequences which end with an ORi to
    /// load immediate Imm
    void GetInstSeqLsORi(uint64_t Imm, unsigned RemSize, InstSeqLs &SeqLs);

    /// GetInstSeqLsSLL - Get instrucion sequences which end with a SLL to
    /// load immediate Imm
    void GetInstSeqLsSLL(uint64_t Imm, unsigned RemSize, InstSeqLs &SeqLs);

    /// GetInstSeqLs - Get instrucion sequences to load immediate Imm.
    void GetInstSeqLs(uint64_t Imm, unsigned RemSize, InstSeqLs &SeqLs);

    /// ReplaceADDiSLLWithLUi - Replace an ADDi & SLL pair with a LUi.
    void ReplaceADDiSLLWithLUi(InstSeq &Seq);

    /// GetShortestSeq - Find the shortest instruction sequence in SeqLs and
    /// return it in Insts.
    void GetShortestSeq(InstSeqLs &SeqLs, InstSeq &Insts);

    unsigned Size;
    unsigned ADDi, ORi, SLL, LUi;
    InstSeq Insts;


  };

}
#endif

