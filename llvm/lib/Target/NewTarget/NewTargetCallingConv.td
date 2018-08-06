//===----------------------------------------------------------------------===//
// Mips O32 Calling Convention
//===----------------------------------------------------------------------===//

// Only the return rules are defined here for O32. The rules for argument
// passing are defined in MipsISelLowering.cpp.
def RetCC_NewTargetCC : CallingConv<[
  CCIfByVal<CCPassByVal<4, 4>>,

  // Promote i8/i16 arguments to i32.
  CCIfType<[i8, i16], CCPromoteToType<i32>>,

  CCIfType<[i32], CCAssignToReg<[R16, R17, R18, R19, R20, R21, R22, R23]>>

]>;

//===----------------------------------------------------------------------===//
// Mips Calling Convention Dispatch
//===----------------------------------------------------------------------===//

def RetCC_NewTarget : CallingConv<[
  CCDelegateTo<RetCC_NewTargetCC>
]>;

//===----------------------------------------------------------------------===//
// Callee-saved register lists.
//===----------------------------------------------------------------------===//

def NT : CalleeSavedRegs<(add LR, (sequence "R%u", 7, 1))>;
