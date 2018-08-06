/*
 * NewTargetMachineFunction.cpp
 *
 *  Created on: Mar 14, 2013
 *      Author: andreu
 */


#include "NewTargetMachineFunction.h"
//#include "MCTargetDesc/MipsBaseInfo.h"
#include "NewTargetInstrInfo.h"
#include "NewTargetSubtarget.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include <iostream>

using namespace llvm;

static cl::opt<bool>
FixGlobalBaseReg("newtarget-fix-global-base-reg", cl::Hidden, cl::init(true),
                 cl::desc("Always use $gp as the global base register."));

bool NewTargetFunctionInfo::globalBaseRegSet() const {
	//std::cout << "NewTargetFunctionInfo::globalBaseRegSet not implemented\n";
  return true;
}

unsigned NewTargetFunctionInfo::getGlobalBaseReg() {
	//std::cout << "NewTargetFunctionInfo::getGlobalBaseReg not implemented\n";
	return 0;
}

bool NewTargetFunctionInfo::mips16SPAliasRegSet() const {
	//std::cout << "NewTargetFunctionInfo::mips16SPAliasRegSet not implemented\n";
  return true;
}
unsigned NewTargetFunctionInfo::getMips16SPAliasReg() {
	//std::cout << "NewTargetFunctionInfo::getMips16SPAliasReg not implemented\n";
	return 0;
}

void NewTargetFunctionInfo::createEhDataRegsFI() {
	//std::cout << "NewTargetFunctionInfo::createEhDataRegsFI not implemented\n";
}

bool NewTargetFunctionInfo::isEhDataRegFI(int FI) const {
	  return CallsEhReturn && (FI == EhDataRegFI[0] || FI == EhDataRegFI[1]
	                        || FI == EhDataRegFI[2] || FI == EhDataRegFI[3]);
}

void NewTargetFunctionInfo::anchor() { }


