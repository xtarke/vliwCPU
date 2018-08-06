//===-- MipsTargetInfo.cpp - Mips Target Implementation -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "NewTarget.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

Target llvm::TheNewTarget;

extern "C" void LLVMInitializeNewTargetTargetInfo() {
  RegisterTarget<Triple::newtarget, /*HasJIT=*/false>
    X(TheNewTarget, "newtarget", "NewTarget");
}

