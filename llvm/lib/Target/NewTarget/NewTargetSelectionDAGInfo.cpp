//===-- NewTargetSelectionDAGInfo.cpp - Mips SelectionDAG Info -----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the MipsSelectionDAGInfo class.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "newtarget-selectiondag-info"
#include "NewTargetMachine.h"
using namespace llvm;

NewTargetSelectionDAGInfo::NewTargetSelectionDAGInfo(const NewTargetMachine &TM)
  : TargetSelectionDAGInfo(TM) {
}

NewTargetSelectionDAGInfo::~NewTargetSelectionDAGInfo() {
}
