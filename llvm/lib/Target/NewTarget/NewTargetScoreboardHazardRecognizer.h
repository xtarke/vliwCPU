/* 
 * File:   NewTargetScoreboardHazardRecognizer.h
 * Author: andreu
 *
 * Created on 29 de Maio de 2014, 13:25
 */

//===-- PPCHazardRecognizers.h - PowerPC Hazard Recognizers -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines hazard recognizers for scheduling on NewTarget processors.
//
//===----------------------------------------------------------------------===//


#ifndef NEWTARGETSCOREBOARDHAZARDRECOGNIZER_H
#define	NEWTARGETSCOREBOARDHAZARDRECOGNIZER_H

#include "NewTargetInstrInfo.h"
#include "llvm/CodeGen/ScheduleHazardRecognizer.h"
#include "llvm/CodeGen/ScoreboardHazardRecognizer.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"


namespace llvm {

/// NewTargetScoreboardHazardRecognizer - This class implements a scoreboard-based
/// hazard recognizer for NewTarget processors.
class NewTargetScoreboardHazardRecognizer : public ScoreboardHazardRecognizer {
  const ScheduleDAG *DAG;
public:
  NewTargetScoreboardHazardRecognizer(const InstrItineraryData *ItinData,
                         const ScheduleDAG *DAG_) :
    ScoreboardHazardRecognizer(ItinData, DAG_), DAG(DAG_) {}

  virtual HazardType getHazardType(SUnit *SU, int Stalls);
  virtual void EmitInstruction(SUnit *SU);
  virtual void AdvanceCycle();
  virtual void Reset();
};

} 

#endif	/* NEWTARGETSCOREBOARDHAZARDRECOGNIZER_H */

