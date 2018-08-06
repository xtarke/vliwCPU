

class NewTargetPredicateReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "NewTarget";
}

// We have banks of 32 registers each (NewTarget based).
class NewTargetReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "NewTarget";
}

// Flags Registers.
class NewTargetBranchReg<string n, bits<16> Enc> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "NewTarget";
}

// Mips CPU Registers
class NewTargetGPRReg<bits<16> Enc, string n> : NewTargetReg<Enc, n>;

let Namespace = "NewTarget" in {
  // General Purpose Registers
  // always zero
  def ZERO : NewTargetGPRReg< 0, "zero">, DwarfRegNum<[0]>;

  //preserved
  def R1   : NewTargetGPRReg< 1, "r1">,    DwarfRegNum<[1]>;
  def R2   : NewTargetGPRReg< 2, "r2">,    DwarfRegNum<[2]>;
  def R3   : NewTargetGPRReg< 3, "r3">,    DwarfRegNum<[3]>;
  def R4   : NewTargetGPRReg< 4, "r4">,    DwarfRegNum<[4]>;
  def R5   : NewTargetGPRReg< 5, "r5">,    DwarfRegNum<[5]>;
  def R6   : NewTargetGPRReg< 6, "r6">,    DwarfRegNum<[6]>;
  def R7   : NewTargetGPRReg< 7, "r7">,    DwarfRegNum<[7]>;

  // scratch
  def R8   : NewTargetGPRReg< 8, "r8">,    DwarfRegNum<[8]>;
  def R9   : NewTargetGPRReg< 9, "r9">,    DwarfRegNum<[9]>;
  def R10   : NewTargetGPRReg< 10, "r10">,  DwarfRegNum<[10]>;
  def R11   : NewTargetGPRReg< 11, "r11">,  DwarfRegNum<[11]>;

  // stack pointer
  def SP   : NewTargetGPRReg< 12, "sp">,  DwarfRegNum<[12]>;

  // thread pointer
  def TP   : NewTargetGPRReg< 13, "tp">,  DwarfRegNum<[13]>;

  // global pointer
  def GP   : NewTargetGPRReg< 14, "gp">,  DwarfRegNum<[14]>;

  //struct/union return pointer register
  def R15   : NewTargetGPRReg< 15, "r15">,  DwarfRegNum<[15]>;

  // procedure argument/return value
  def R16   : NewTargetGPRReg< 16, "r16">,  DwarfRegNum<[16]>;
  def R17   : NewTargetGPRReg< 17, "r17">,  DwarfRegNum<[17]>;
  def R18   : NewTargetGPRReg< 18, "r18">,  DwarfRegNum<[18]>;
  def R19   : NewTargetGPRReg< 19, "r19">,  DwarfRegNum<[19]>;
  def R20   : NewTargetGPRReg< 20, "r20">,  DwarfRegNum<[20]>;
  def R21   : NewTargetGPRReg< 21, "r21">,  DwarfRegNum<[21]>;
  def R22   : NewTargetGPRReg< 22, "r22">,  DwarfRegNum<[22]>;
  def R23   : NewTargetGPRReg< 23, "r23">,  DwarfRegNum<[23]>;

  // scratch
  def R24   : NewTargetGPRReg< 24, "r24">,  DwarfRegNum<[24]>;
  def R25   : NewTargetGPRReg< 25, "r25">,  DwarfRegNum<[25]>;
  def R26   : NewTargetGPRReg< 26, "r26">,  DwarfRegNum<[26]>;
  def R27   : NewTargetGPRReg< 27, "r27">,  DwarfRegNum<[27]>;
  def R28   : NewTargetGPRReg< 28, "r28">,  DwarfRegNum<[28]>;
  def R29   : NewTargetGPRReg< 29, "r29">,  DwarfRegNum<[29]>;
  def R30   : NewTargetGPRReg< 30, "r30">,  DwarfRegNum<[30]>;
  def R31   : NewTargetGPRReg< 31, "r31">,  DwarfRegNum<[31]>;
  def R32   : NewTargetGPRReg< 32, "r32">,  DwarfRegNum<[32]>;
  def R33   : NewTargetGPRReg< 33, "r33">,  DwarfRegNum<[33]>;
  def R34   : NewTargetGPRReg< 34, "r34">,  DwarfRegNum<[34]>;
  def R35   : NewTargetGPRReg< 35, "r35">,  DwarfRegNum<[35]>;
  def R36   : NewTargetGPRReg< 36, "r36">,  DwarfRegNum<[36]>;
  def R37   : NewTargetGPRReg< 37, "r37">,  DwarfRegNum<[37]>;
  def R38   : NewTargetGPRReg< 38, "r38">,  DwarfRegNum<[38]>;
  def R39   : NewTargetGPRReg< 39, "r39">,  DwarfRegNum<[39]>;
  def R40   : NewTargetGPRReg< 40, "r40">,  DwarfRegNum<[41]>;
  def R41   : NewTargetGPRReg< 41, "r41">,  DwarfRegNum<[41]>;
  def R42   : NewTargetGPRReg< 42, "r42">,  DwarfRegNum<[42]>;
  def R43   : NewTargetGPRReg< 43, "r43">,  DwarfRegNum<[43]>;
  def R44   : NewTargetGPRReg< 44, "r44">,  DwarfRegNum<[44]>;
  def R45   : NewTargetGPRReg< 45, "r45">,  DwarfRegNum<[45]>;
  def R46   : NewTargetGPRReg< 46, "r46">,  DwarfRegNum<[46]>;
  def R47   : NewTargetGPRReg< 47, "r47">,  DwarfRegNum<[47]>;
  def R48   : NewTargetGPRReg< 48, "r48">,  DwarfRegNum<[48]>;
  def R49   : NewTargetGPRReg< 49, "r49">,  DwarfRegNum<[49]>;
  def R50   : NewTargetGPRReg< 50, "r50">,  DwarfRegNum<[50]>;
  def R51   : NewTargetGPRReg< 51, "r51">,  DwarfRegNum<[51]>;
  def R52   : NewTargetGPRReg< 52, "r52">,  DwarfRegNum<[52]>;
  def R53   : NewTargetGPRReg< 53, "r53">,  DwarfRegNum<[53]>;
  def R54   : NewTargetGPRReg< 54, "r54">,  DwarfRegNum<[54]>;
  def R55   : NewTargetGPRReg< 55, "r55">,  DwarfRegNum<[55]>;
  def R56   : NewTargetGPRReg< 56, "r56">,  DwarfRegNum<[56]>;
  def R57   : NewTargetGPRReg< 57, "r57">,  DwarfRegNum<[57]>;
  def R58   : NewTargetGPRReg< 58, "r58">,  DwarfRegNum<[58]>;
  def R59   : NewTargetGPRReg< 59, "r59">,  DwarfRegNum<[59]>;
  def R60   : NewTargetGPRReg< 60, "r60">,  DwarfRegNum<[60]>;

  def MAR1   : NewTargetGPRReg< 61, "mar1">,  DwarfRegNum<[61]>;
  def MAR2   : NewTargetGPRReg< 62, "mar2">,  DwarfRegNum<[62]>;

  // link register (Also known as LR)
  def LR   : NewTargetGPRReg< 63, "lr">,  DwarfRegNum<[63]>;

  
  def HI   : Register<"hi">, DwarfRegNum<[64]>;
  def LO   : Register<"lo">, DwarfRegNum<[65]>;
  
 }

// Branch flags registers
def BRFLAG0 : NewTargetBranchReg<"br0", 0>;
def BRFLAG1 : NewTargetBranchReg<"br1", 1>;
def BRFLAG2 : NewTargetBranchReg<"br2", 2>;
def BRFLAG3 : NewTargetBranchReg<"br3", 3>;
def BRFLAG4 : NewTargetBranchReg<"br4", 4>;
def BRFLAG5 : NewTargetBranchReg<"br5", 5>;
def BRFLAG6 : NewTargetBranchReg<"br6", 6>;
def BRFLAG7 : NewTargetBranchReg<"br7", 7>;
 

// Status flags registers.
def BRFLAG : RegisterClass<"NewTarget", [i1], 32, (sequence "BRFLAG%u", 0, 7)> {
  let CopyCost = -1;  // Don't allow copying of status registers.
  let isAllocatable = 0;
}

  
//class CPURegsClass<list<ValueType> regTypes> :
//  RegisterClass<"NewTarget", regTypes, 32, (add
//  // Reserved
//  ZERO,
//  // Return Values and Arguments
//  R1, R2, R3, R4, R5, R6, R7,
//  // Not preserved across procedure calls
//  T0, T1, T2, T3, T4, T5, T6, T7,
//  // Callee save
//  S0, S1, S2, S3, S4, S5, S6, S7,
//  // Not preserved across procedure calls
//  T8, T9,
//  // Reserved
//  K0, K1, GP, SP, FP, LR)>;


class CPURegsClass<list<ValueType> regTypes> :
  RegisterClass<"NewTarget", regTypes, 32, (add
  // Reserved
  ZERO,
  // preserved
  R1, R2, R3, R4, R5, R6, R7,
  // scratch
  R8, R9, R10, R11,
  // reserved
  SP, TP, GP,
  //struct/union return pointer register
  R15,
  // procedure argument/return value
  R16, R17, R18, R19, R20, R21, R22, R23,
  // scratch
  R24, R25, R26, R27, R28, R29, R30, R31, R32, R33, R34, R35,
  R36, R37, R38, R39, R40, R41, R42, R43, R44, R45, R46, R47, 
  R48, R49, R50, R51, R52, R53, R54, R55, R56, R57, R58, R59,
  R60,
  // reserved
  MAR1, MAR2, 
  LR
)>;


def CPURegs : CPURegsClass<[i32]>;

class CPUPredRegsClass<list<ValueType> regTypes> :
  RegisterClass<"NewTarget", regTypes, 8, (add
  BRFLAG0, BRFLAG1, BRFLAG2, BRFLAG3, BRFLAG4, BRFLAG5, BRFLAG6, BRFLAG7
)>;

def CPUPredRegs : CPUPredRegsClass<[i1]>;

def CPULRReg : RegisterClass<"NewTarget", [i32], 32, (add LR)>;

def CPUSPReg : RegisterClass<"NewTarget", [i32], 32, (add SP)>;

def CPURegsAsmOperand : AsmOperandClass {
  let Name = "CPURegsAsm";
  let ParserMethod = "parseCPURegs";
}

def CPURegsOpnd : RegisterOperand<CPURegs, "printCPURegs"> {
  let ParserMatchClass = CPURegsAsmOperand;
}

def CPUPredRegsOpnd : RegisterOperand<CPUPredRegs, "printCPURegs"> {
  let ParserMatchClass = CPURegsAsmOperand;
}

// Hi/Lo Registers
def HILO : RegisterClass<"NewTarget", [i32], 32, (add HI, LO)>;