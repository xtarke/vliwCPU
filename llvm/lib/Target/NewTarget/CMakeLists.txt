set(LLVM_TARGET_DEFINITIONS NewTarget.td)

tablegen(LLVM NewTargetGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM NewTargetInstrInfo.inc -gen-instr-info)
tablegen(LLVM NewTargetGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM NewTargetGenDisassemblerTables.inc -gen-disassembler)
tablegen(LLVM NewTargetGenCodeEmitter.inc -gen-emitter)
tablegen(LLVM NewTargetGenMCCodeEmitter.inc -gen-emitter -mc-emitter)
tablegen(LLVM NewTargetGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM NewTargetGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM NewTargetGenCallingConv.inc -gen-callingconv)
tablegen(LLVM NewTargetGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM NewTargetGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM NewTargetGenDFAPacketizer.inc -gen-dfa-packetizer)

add_public_tablegen_target(NewTargetCommonTableGen)


add_llvm_target(NewTargetCodeGen
  NewTargetMachine.cpp
  NewTargetSubtarget.cpp
  NewTargetRegisterInfo.cpp
  NewTargetFrameLowering.cpp
  NewTargetRegisterInfo.cpp
  NewTargetInstrInfo.cpp
  NewTargetLoweringInfo.cpp
  NewTargetAsmPrinter.cpp
  NewTargetMachineFunction.cpp
  NewTargetISelDAGToDAG.cpp
  NewTargetISelLowering.cpp
  NewTargetMCInstLower.cpp
  NewTargetAnalyzeImmediate.cpp
  NewTargetTargetObjectFile.cpp
  NewTargetDelaySlotFiller.cpp
  NewTargetCFGExtractor.cpp
  NewTargetWCETEstimator.cpp
  NewTargetRTOptimizer.cpp
  NewTargetMFSaver.cpp
  NewTargetCGFGen.cpp
  NewTargetVLIWPacketizer.cpp
  NewTargetScoreboardHazardRecognizer.cpp
  NewTargetBundleAligner.cpp
  NewTargetAnnotationExtractor.cpp
  NewTargetBranchPreloader.cpp
  NewTargetSelectionDAGInfo.cpp
  NewTargetPredicatedPathMerger.cpp
  )

add_dependencies(LLVMNewTargetCodeGen intrinsics_gen)

add_subdirectory(InstPrinter)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
add_subdirectory(AsmParser)


