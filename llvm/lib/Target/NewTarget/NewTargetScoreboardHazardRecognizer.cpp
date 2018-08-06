/* 
 * File:   NewTargetScoreboardHazardRecognizer.cpp
 * Author: andreu
 * 
 * Created on 29 de Maio de 2014, 13:25
 */



#define DEBUG_TYPE "pre-RA-sched"
#include "NewTargetScoreboardHazardRecognizer.h"
#include "NewTarget.h"
#include "NewTargetInstrInfo.h"
#include "llvm/CodeGen/ScheduleDAG.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include <iostream>
using namespace llvm;


//===----------------------------------------------------------------------===//
// NewTarget Scoreboard Hazard Recognizer
void NewTargetScoreboardHazardRecognizer::EmitInstruction(SUnit *SU) {
  const MCInstrDesc *MCID = DAG->getInstrDesc(SU);
  if (!MCID)
    // This is a PPC pseudo-instruction.
    return;

  ScoreboardHazardRecognizer::EmitInstruction(SU);
}

ScheduleHazardRecognizer::HazardType
NewTargetScoreboardHazardRecognizer::getHazardType(SUnit *SU, int Stalls) {
    
    const MCInstrDesc *MCID = DAG->getInstrDesc(SU);
    
    if(MCID){
        if(MCID->getOpcode() == NewTarget::ADDi){
            std::cout <<  "addi\n";
            SU->getNode()->getPrevNode()->dump();
        }
       
    }
   //MachineInstr *MI = SU->getInstr(); 
    std::cout <<  "*****************************************************\n";
    SU->getNode()->dump();
    
   //if(SU->getInstr()->getOpcode() == NewTarget::CALL){
   //    return Hazard;
  // } 
    
  //  std::cout <<  "*****************************************************\n";
  // return Hazard; 
  return ScoreboardHazardRecognizer::getHazardType(SU, Stalls);
}

void NewTargetScoreboardHazardRecognizer::AdvanceCycle() {
  ScoreboardHazardRecognizer::AdvanceCycle();
}

void NewTargetScoreboardHazardRecognizer::Reset() {
  ScoreboardHazardRecognizer::Reset();
}
