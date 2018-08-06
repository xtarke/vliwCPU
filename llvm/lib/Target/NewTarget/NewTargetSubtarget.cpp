/*
 * NewTargetSubtarget.cpp
 *
 *  Created on: Mar 7, 2013
 *      Author: andreu
 */

#include "NewTargetSubtarget.h"
#include "NewTarget.h"
#include "llvm/Support/TargetRegistry.h"
#include <iostream>

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "NewTargetGenSubtargetInfo.inc"

using namespace llvm;

void NewTargetSubtarget::anchor() { }

NewTargetSubtarget::NewTargetSubtarget(const std::string &TT,
                                 const std::string &CPU,
                                 const std::string &FS) :
  NewTargetGenSubtargetInfo(TT, "newtarget", FS) {
  std::string CPUName = "newtarget";

  // Parse features string.
  ParseSubtargetFeatures(CPUName, FS);
  
  InstrItins = getInstrItineraryForCPU(CPUName);
  
  //if(InstrItins.isEmpty()){
      
      //std::cout << "nenhum itinerario\n";
  //} else {
      
      //std::cout << "sim\n";
  //}
  
}
