/*
 * NewTargetAsmBackend.cpp
 *
 *  Created on: Apr 11, 2013
 *      Author: andreu
 */

#include "MCTargetDesc/NewTargetMCTargetDesc.h"
#include "MCTargetDesc/NewTargetBaseInfo.h"
#include "NewTargetFixupKinds.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCDirectives.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/MC/MCExpr.h"
#include <iostream>

using namespace llvm;

// Prepare value for the target space for it

static unsigned adjustFixupValue(unsigned Kind, uint64_t Value) {

    // Add/subtract and shift
    switch (Kind) {
        default:
            return 0;
        case FK_GPRel_4:
        case FK_Data_4:
        case FK_Data_8:
        case NewTarget::fixup_NewTarget_IMM9:
        case NewTarget::fixup_NewTarget_PC23CALL:
            //case NewTarget::fixup_Mips_LO16:
            //case NewTarget::fixup_Mips_GPREL16:
            //case NewTarget::fixup_Mips_GPOFF_HI:
            //case NewTarget::fixup_Mips_GPOFF_LO:
            //Value += (NewTargetII::BASE_ADDRESS & 0x0000ffff);
            break;
        case NewTarget::fixup_NewTarget_PC23GOTO:
        case NewTarget::fixup_NewTarget_PC23PRELOAD:
            //std::cout << "Value: " << Value << " offset: " << offset << "\n";  
            // So far we are only using this type for branches.
            // For branches we start 1 instruction after the branch
            // so the displacement will be one instruction size less.
            Value -= 4;
            // The displacement is then divided by 4 to give us an 18 bit
            // address range.
            Value >>= 2;
            break;
        case NewTarget::fixup_NewTarget_IMM23:
            //Value += (NewTargetII::BASE_ADDRESS & 0xffff);
            // Get the 2nd 16-bits. Also add 1 if bit 15 is 1.
            //Value = ((Value + 0x8000) >> 16) & 0xffff;
            break;
    }

    //std::cout << "Value: " << Value << "\n";
    return Value;
}

namespace {

    class NewTargetAsmBackend : public MCAsmBackend {
        Triple::OSType OSType;


    public:

        NewTargetAsmBackend(Triple::OSType _OSType)
        : MCAsmBackend(), OSType(_OSType) {
        }

        MCObjectWriter *createObjectWriter(raw_ostream &OS) const {
            return createNewTargetELFObjectWriter(OS,
                    MCELFObjectTargetWriter::getOSABI(OSType), true, false);

        }

        /// ApplyFixup - Apply the \p Value for given \p Fixup into the provided
        /// data fragment, at the offset specified by the fixup and following the
        /// fixup kind as appropriate.

        void applyFixup(const MCFixup &Fixup, char *Data, unsigned DataSize,
                uint64_t Value) const {
            bool IsLittle = true;

            MCFixupKind Kind = Fixup.getKind();

            Value = adjustFixupValue((unsigned) Kind, Value);

            if (!Value)
                return; // Doesn't change encoding.

            // Where do we start in the object
            unsigned Offset = Fixup.getOffset();
            // Number of bytes we need to fixup
            unsigned NumBytes = (getFixupKindInfo(Kind).TargetSize + 7) / 8;
            // Used to point to big endian bytes
            unsigned FullSize;

            switch ((unsigned) Kind) {
                case NewTarget::fixup_NewTarget_16:
                    FullSize = 2;
                    break;
                default:
                    FullSize = 4;
                    break;
            }

            // Grab current value, if any, from bits.
            uint64_t CurVal = 0;

            for (unsigned i = 0; i != NumBytes; ++i) {
                unsigned Idx = IsLittle ? i : (FullSize - 1 - i);
                CurVal |= (uint64_t) ((uint8_t) Data[Offset + Idx]) << (i * 8);
            }

            uint64_t Mask = ((uint64_t) (-1) >>
                    (64 - getFixupKindInfo(Kind).TargetSize));

            // if we have a goto or a branch, we need to compensate the bundle size.
            if ((NewTarget::Fixups)Kind == NewTarget::fixup_NewTarget_PC23GOTO) {
                //uint64_t off = CurVal & Mask;
                int64_t newValue = (int32_t) Value;
                //std::cout << "NewTarget::fixup_NewTarget_PC23GOTO --: " << (int) Value << "\n";
                //newValue = newValue - off + 1;
                newValue = newValue + 1;
                Value = (uint32_t) newValue;
                // clear CurVal
                CurVal = CurVal & ~Mask;
                //std::cout << "NewTarget::fixup_NewTarget_PC23GOTO: " << (int) Value << "\n";
            } else if ((NewTarget::Fixups)Kind == NewTarget::fixup_NewTarget_PC23PRELOAD) {
                uint64_t off = CurVal & Mask;
                //off = off-1;
                //std::cout << "NewTarget::fixup_NewTarget_PC23PRELOAD --: " << (int) Value << "\n";
                int64_t newValue = (int32_t) Value;
                newValue = newValue + off;
                //newValue = newValue + 1;
                Value = (uint32_t) newValue;
                // clear CurVal
                CurVal = CurVal & ~Mask;
                //std::cout << "NewTarget::fixup_NewTarget_PC23PRELOAD: " << (int) Value << "\n";
            }

            CurVal |= Value & Mask;

            // Write out the fixed up bytes back to the code/data bits.
            for (unsigned i = 0; i != NumBytes; ++i) {
                unsigned Idx = IsLittle ? i : (FullSize - 1 - i);
                Data[Offset + Idx] = (uint8_t) ((CurVal >> (i * 8)) & 0xff);
            }

        }

        unsigned getNumFixupKinds() const {
            return NewTarget::NumTargetFixupKinds;
        }

        const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const {
            const static MCFixupKindInfo Infos[NewTarget::NumTargetFixupKinds] = {
                // This table *must* be in same the order of fixup_* kinds in
                // MipsFixupKinds.h.
                //
                // name                       offset  bits  flags
                { "fixup_NewTarget_16", 0, 16, 0},
                { "fixup_NewTarget_PC23GOTO", 0, 23, MCFixupKindInfo::FKF_IsPCRel},
                { "fixup_NewTarget_PC23CALL", 0, 23, 0},
                { "fixup_NewTarget_IMM9", 12, 9, 0},
                { "fixup_NewTarget_IMM23", 0, 23, 0},
                { "fixup_NewTarget_32", 0, 32, 0},
                { "fixup_NewTarget_PC23PRELOAD", 0, 23, MCFixupKindInfo::FKF_IsPCRel},
            };

            if (Kind < FirstTargetFixupKind)
                return MCAsmBackend::getFixupKindInfo(Kind);

            assert(unsigned(Kind - FirstTargetFixupKind) < getNumFixupKinds() &&
                    "Invalid kind!");
            return Infos[Kind - FirstTargetFixupKind];

        }

        /// @name Target Relaxation Interfaces
        /// @{

        /// MayNeedRelaxation - Check whether the given instruction may need
        /// relaxation.
        ///
        /// \param Inst - The instruction to test.

        bool mayNeedRelaxation(const MCInst &Inst) const {
            return false;
        }

        /// fixupNeedsRelaxation - Target specific predicate for whether a given
        /// fixup requires the associated instruction to be relaxed.

        bool fixupNeedsRelaxation(const MCFixup &Fixup,
                uint64_t Value,
                const MCRelaxableFragment *DF,
                const MCAsmLayout &Layout) const {
            // FIXME.
            assert(0 && "RelaxInstruction() unimplemented");
            return false;
        }

        /// RelaxInstruction - Relax the instruction in the given fragment
        /// to the next wider instruction.
        ///
        /// \param Inst - The instruction to relax, which may be the same
        /// as the output.
        /// \param [out] Res On return, the relaxed instruction.

        void relaxInstruction(const MCInst &Inst, MCInst &Res) const {
        }

        /// @}

        /// WriteNopData - Write an (optimal) nop sequence of Count bytes
        /// to the given output. If the target cannot generate such a sequence,
        /// it should return an error.
        ///
        /// \return - True on success.

        bool writeNopData(uint64_t Count, MCObjectWriter *OW) const {
            // Check for a less than instruction size number of bytes
            // FIXME: 16 bit instructions are not handled yet here.
            // We shouldn't be using a hard coded number for instruction size.

            return true;

        }
    }; // class NewTargetAsmBackend

} // namespace

// MCAsmBackend

MCAsmBackend *llvm::createNewTargetAsmBackend(const Target &T, StringRef TT,
        StringRef CPU) {
    return new NewTargetAsmBackend(Triple(TT).getOS());
}




