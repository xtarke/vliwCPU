/*
 * NewTargetInstrInfo.h
 *
 *  Created on: Mar 8, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETINSTRINFO_H_
#define NEWTARGETINSTRINFO_H_

#include "NewTarget.h"
#include "NewTarget.h"
#include "NewTargetRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "NewTargetGenInstrInfo.inc"

namespace llvm {

    class NewTargetMachine;

    struct BooleanAlternator {
        bool val;

        void setTrue() {
            val = true;
        };

        void setFalse() {
            val = false;
        };
    };

    class NewTargetInstrInfo : public NewTargetGenInstrInfo {
        const NewTargetRegisterInfo RI;
        static struct BooleanAlternator MarRegAlternator;
    public:

        enum BranchType {
            BT_None, // Couldn't analyze branch.
            BT_NoBranch, // No branches found.
            BT_Uncond, // One unconditional branch.
            BT_Cond, // One conditional branch.
            BT_CondUncond, // A conditional branch followed by an unconditional branch.
            BT_Indirect // One indirct branch.
        };
        explicit NewTargetInstrInfo(NewTargetMachine &TM);

        virtual const NewTargetRegisterInfo &getRegisterInfo() const {
            return RI;
        }

        ScheduleHazardRecognizer *
        CreateTargetHazardRecognizer(const TargetMachine *TM,
                const ScheduleDAG *DAG) const;
        ScheduleHazardRecognizer *
        CreateTargetPostRAHazardRecognizer(const InstrItineraryData *II,
                const ScheduleDAG *DAG) const;

        static const NewTargetInstrInfo *create(NewTargetMachine &TM);

        virtual bool expandPostRAPseudo(MachineBasicBlock::iterator MI) const;

        /// Adjust SP by Amount bytes.
        void adjustStackPtr(unsigned SP, int64_t Amount, MachineBasicBlock &MBB,
                MachineBasicBlock::iterator I) const;

        virtual void storeRegToStackSlot(MachineBasicBlock &MBB,
                MachineBasicBlock::iterator MBBI,
                unsigned SrcReg, bool isKill, int FrameIndex,
                const TargetRegisterClass *RC,
                const TargetRegisterInfo *TRI) const;

        virtual void loadRegFromStackSlot(MachineBasicBlock &MBB,
                MachineBasicBlock::iterator MBBI,
                unsigned DestReg, int FrameIndex,
                const TargetRegisterClass *RC,
                const TargetRegisterInfo *TRI) const;

        /// Emit a series of instructions to load an immediate. If NewImm is a
        /// non-NULL parameter, the last instruction is not emitted, but instead
        /// its immediate operand is returned in NewImm.
        unsigned loadImmediate(int64_t Imm, MachineBasicBlock &MBB,
                MachineBasicBlock::iterator II, DebugLoc DL,
                unsigned *NewImm) const;

        void copyPhysReg(MachineBasicBlock &MBB,
                MachineBasicBlock::iterator I, DebugLoc DL,
                unsigned DestReg, unsigned SrcReg,
                bool KillSrc) const;

        bool ReverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const;

        virtual DFAPacketizer*
        CreateTargetScheduleState(const TargetMachine *TM,
                const ScheduleDAG *DAG) const;

        virtual bool isSchedulingBoundary(const MachineInstr *MI,
                const MachineBasicBlock *MBB,
                const MachineFunction &MF) const;

        unsigned GetAnalyzableBrOpc(unsigned Opc) const;

        void BuildCondBr(MachineBasicBlock &MBB,
                MachineBasicBlock *TBB, DebugLoc DL,
                const SmallVectorImpl<MachineOperand>& Cond)
        const;

        unsigned InsertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                MachineBasicBlock *FBB,
                const SmallVectorImpl<MachineOperand> &Cond,
                DebugLoc DL) const;

        unsigned RemoveBranch(MachineBasicBlock &MBB) const;

        bool AnalyzeBranch(MachineBasicBlock &MBB,
                MachineBasicBlock *&TBB,
                MachineBasicBlock *&FBB,
                SmallVectorImpl<MachineOperand> &Cond,
                bool AllowModify) const;

        BranchType AnalyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
                MachineBasicBlock *&FBB,
                SmallVectorImpl<MachineOperand> &Cond,
                bool AllowModify,
                SmallVectorImpl<MachineInstr*> &BranchInstrs) const;

        void AnalyzeCondBr(const MachineInstr *Inst, unsigned Opc,
                MachineBasicBlock *&BB,
                SmallVectorImpl<MachineOperand> &Cond) const;

        virtual MachineInstr* emitFrameIndexDebugValue(MachineFunction &MF,
                int FrameIx, uint64_t Offset,
                const MDNode *MDPtr,
                DebugLoc DL) const;

        bool isExtended(const MachineInstr *Inst) const;
        
        unsigned getPredicatedOpcode(unsigned opcode) const;
        bool isPredicatedOpcode(MachineInstr *Inst) const;
        bool isMemoryInstr(MachineInstr *Inst) const;
        
        void buildPredicatedInstrCopy(MachineBasicBlock::instr_iterator &,
                MachineBasicBlock *MBB, MachineBasicBlock::instr_iterator &Iter) const;
        
        void buildInstrCopy(MachineBasicBlock::instr_iterator &,
                MachineBasicBlock *MBB, MachineBasicBlock::instr_iterator &Iter) const;

        unsigned GetInstSizeInBytes(const MachineInstr *MI) const;

        bool canInsertSelect(const MachineBasicBlock &MBB,
                const SmallVectorImpl<MachineOperand> &Cond,
                unsigned TrueReg, unsigned FalseReg,
                int &CondCycles,
                int &TrueCycles, int &FalseCycles) const;

        void insertSelect(MachineBasicBlock &MBB,
                MachineBasicBlock::iterator I, DebugLoc DL,
                unsigned DstReg,
                const SmallVectorImpl<MachineOperand> &Cond,
                unsigned TrueReg, unsigned FalseReg) const;
        
        bool isCmpReg(MachineBasicBlock::iterator I, unsigned reg) const;
        unsigned cmpRegToFlag(MachineBasicBlock::iterator I) const;

    protected:

        MachineMemOperand *GetMemOperand(MachineBasicBlock &MBB, int FI,
                unsigned Flag) const;


    private:
        void ExpandRet(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                unsigned Opc) const;
        void ExpandSelect(MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
        void ExpandBranchBR(MachineBasicBlock &MBB, MachineBasicBlock::iterator I, bool br) const;
        void ExpandArithCarryInst(MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
        void ExpandImmediateConstant32(MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
        unsigned GetMarReg() const;
    };

    const NewTargetInstrInfo *createNewTargetSEInstrInfo(NewTargetMachine &TM);

} /* namespace llvm */
#endif /* NEWTARGETINSTRINFO_H_ */
