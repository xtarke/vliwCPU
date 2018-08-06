##===- lib/Target/Sparc/Makefile ---------------------------*- Makefile -*-===##
#
#                     The LLVM Compiler Infrastructure
#
# This file is distributed under the University of Illinois Open Source
# License. See LICENSE.TXT for details.
#
##===----------------------------------------------------------------------===##

LEVEL = ../../..
LIBRARYNAME = LLVMNewTargetCodeGen
TARGET = NewTarget

# Make sure that tblgen is run, first thing.
BUILT_SOURCES = NewTargetGenRegisterInfo.inc NewTargetGenInstrInfo.inc \
                NewTargetGenAsmWriter.inc NewTargetGenCodeEmitter.inc \
                NewTargetGenDAGISel.inc NewTargetGenCallingConv.inc \
                NewTargetGenSubtargetInfo.inc NewTargetGenMCCodeEmitter.inc \
                NewTargetGenDisassemblerTables.inc \
                NewTargetGenMCPseudoLowering.inc NewTargetGenAsmMatcher.inc \
		NewTargetGenDFAPacketizer.inc

DIRS = TargetInfo MCTargetDesc InstPrinter AsmParser


include $(LEVEL)/Makefile.common
