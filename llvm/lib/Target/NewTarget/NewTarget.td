//include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register File, Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//


include "llvm/Target/Target.td"

include "NewTargetRegisterInfo.td"
include "NewTargetSchedule.td"
include "NewTargetInstrInfo.td"
include "NewTargetCallingConv.td"



def NewTargetInstrInfo : InstrInfo;


//===----------------------------------------------------------------------===//
// NewTarget processors supported.
//===----------------------------------------------------------------------===//

class Proc<string Name, SchedMachineModel Model,
           list<SubtargetFeature> Features>
 : ProcessorModel<Name, Model, Features>;

def : Proc<"newtarget", NewTargetModel,   []>;
//def : Proc<"newtarget2", NewTargetModel2,   []>;

def NewTargetAsmWriter : AsmWriter {
  string AsmWriterClassName  = "InstPrinter";
  bit isMCAsmWriter = 1;
}

def NewTargetAsmParser : AsmParser {
}

def NewTargetAsmParserVariant : AsmParserVariant {
  int Variant = 0;

}


def NewTarget : Target {
  let InstructionSet = NewTargetInstrInfo;
  let AssemblyWriters = [NewTargetAsmWriter];
  let AssemblyParsers = [NewTargetAsmParser];
  let AssemblyParserVariants = [NewTargetAsmParserVariant];
}



