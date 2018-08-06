//===-- MipsSchedule.td - Mips Scheduling Definitions ------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Functional units across Mips chips sets. Based on GCC/Mips backend files.
//===----------------------------------------------------------------------===//
def PIPE0 : FuncUnit;
def PIPE1 : FuncUnit;
def PIPE2 : FuncUnit;
def PIPE3 : FuncUnit;


//===----------------------------------------------------------------------===//
// Instruction Itinerary classes used for Mips
//===----------------------------------------------------------------------===//
def IIAluWriteFlag            : InstrItinClass;
def IIAlu              : InstrItinClass;
def IILoad             : InstrItinClass;
def IIStore            : InstrItinClass;
def IIXfer             : InstrItinClass;
def IIBranch           : InstrItinClass;
def IIHiLo             : InstrItinClass;
def IIImul             : InstrItinClass;
def IIIdiv             : InstrItinClass;
def IIPseudo           : InstrItinClass;

//===----------------------------------------------------------------------===//
// Mips Generic instruction itineraries.
//===----------------------------------------------------------------------===//
def NewTargetGenericItineraries : ProcessorItineraries<[PIPE0, PIPE1, PIPE2, PIPE3], [], [
  InstrItinData<IIAluWriteFlag     , [InstrStage<1,  [PIPE0, PIPE1, PIPE2, PIPE3]>]>,
  InstrItinData<IIAlu              , [InstrStage<1,  [PIPE0, PIPE1, PIPE2, PIPE3]>]>,
  InstrItinData<IILoad             , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIStore            , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIXfer             , [InstrStage<1,  [PIPE0, PIPE1, PIPE2, PIPE3]>]>,
  InstrItinData<IIBranch           , [InstrStage<1,  [PIPE0]>]>,
  //InstrItinData<IIHiLo             , [InstrStage<1,  [PIPE0, PIPE1, PIPE2, PIPE3]>]>,
  InstrItinData<IIImul             , [InstrStage<4,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIIdiv             , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIPseudo           , [InstrStage<1,  [PIPE0, PIPE1, PIPE2, PIPE3]>]>
]>;

def NewTargetGenericItineraries2 : ProcessorItineraries<[PIPE0, PIPE1], [], [
  InstrItinData<IIAluWriteFlag     , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIAlu              , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IILoad             , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIStore            , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIXfer             , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIBranch           , [InstrStage<1,  [PIPE0]>]>,
  InstrItinData<IIImul             , [InstrStage<4,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIIdiv             , [InstrStage<1,  [PIPE0, PIPE1]>]>,
  InstrItinData<IIPseudo           , [InstrStage<1,  [PIPE0, PIPE1]>]>
]>;


def NewTargetModel : SchedMachineModel {
  // Max issue per cycle == bundle width.
  let IssueWidth = 4;
  let Itineraries = NewTargetGenericItineraries;
  let LoadLatency = 1;
}

def NewTargetModel2 : SchedMachineModel {
  // Max issue per cycle == bundle width.
  let IssueWidth = 2;
  let Itineraries = NewTargetGenericItineraries2;
  let LoadLatency = 1;
}