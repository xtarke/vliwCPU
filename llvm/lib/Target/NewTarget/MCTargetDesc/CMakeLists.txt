add_llvm_library(LLVMNewTargetDesc
	NewTargetMCTargetDesc.cpp
	NewTargetMCAsmInfo.cpp
	NewTargetELFStreamer.cpp
	NewTargetMCCodeEmitter.cpp
	NewTargetAsmBackend.cpp
	NewTargetELFObjectWriter.cpp
	RelocatedELFObjectWriter.cpp
  )

add_dependencies(LLVMNewTargetDesc NewTargetCommonTableGen)
