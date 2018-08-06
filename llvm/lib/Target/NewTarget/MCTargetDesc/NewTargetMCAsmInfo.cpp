/*
 * NewTargetMCAsmInfo.cpp
 *
 *  Created on: Mar 7, 2013
 *      Author: andreu
 */

#include "NewTargetMCAsmInfo.h"
using namespace llvm;

void NewTargetMCAsmInfo::anchor() { }

NewTargetMCAsmInfo::NewTargetMCAsmInfo() {
  IsLittleEndian              = true;
  StackGrowsUp                = false;
  SupportsDebugInformation    = true;
  AlignmentIsInBytes          = false;
  PrivateGlobalPrefix         = "$";
  GPRel32Directive            = "\t.gpword\t";
}




