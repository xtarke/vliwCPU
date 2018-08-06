//===-- MipsSelectionDAGInfo.h - Mips SelectionDAG Info ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the Mips subclass for TargetSelectionDAGInfo.
//
//===----------------------------------------------------------------------===//

#ifndef NEWTARGETSELECTIONDAGINFO_H
#define NEWTARGETSELECTIONDAGINFO_H

#include "llvm/Target/TargetSelectionDAGInfo.h"

namespace llvm {

class NewTargetTargetMachine;

class NewTargetSelectionDAGInfo : public TargetSelectionDAGInfo {
public:
  explicit NewTargetSelectionDAGInfo(const NewTargetMachine &TM);
  ~NewTargetSelectionDAGInfo();
};

}

#endif
