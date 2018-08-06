/*
 * NewTargetSelLowering.h
 *
 *  Created on: Mar 12, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETISELLOWERING_H_
#define NEWTARGETISELLOWERING_H_

#include "NewTarget.h"
#include "NewTargetSubtarget.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/Target/TargetLowering.h"
#include <deque>
#include <string>

namespace llvm {

    namespace NewTargetISD {

        enum NodeType {
            // Start the numbering from where ISD NodeType finishes.
            FIRST_NUMBER = ISD::BUILTIN_OP_END,

            // Jump and link (call)
            JmpLink,

            // Tail call
            TailCall,

            // Get the Higher 16 bits from a 32-bit immediate
            // No relation with Mips Hi register
            Hi,

            // Get the Lower 16 bits from a 32-bit immediate
            // No relation with Mips Lo register
            Lo,

            //Get the absolute address of a variable/data
            Abs,

            // Handle gp_rel (small data/bss sections) relocation.
            GPRel,

            // Thread Pointer
            ThreadPointer,

            // Floating Point Branch Conditional
            FPBrcond,

            // Floating Point Compare
            FPCmp,

            // Floating Point Conditional Moves
            CMovFP_T,
            CMovFP_F,

            // Floating Point Rounding
            FPRound,

            // Return
            Ret,

            BranchBR,

            Immediate32,

            EH_RETURN,

            // MAdd/Sub nodes
            MAdd,
            MAddu,
            MSub,
            MSubu,

            ADDC,
            ADDE,
            SUBC,
            SUBE,

            // DivRem(u)
            DivRem,
            DivRemU,

            BuildPairF64,
            ExtractElementF64,

            Wrapper,

            DynAlloc,

            Sync,

            Ext,
            Ins,

            // EXTR.W instrinsic nodes.
            EXTP,
            EXTPDP,
            EXTR_S_H,
            EXTR_W,
            EXTR_R_W,
            EXTR_RS_W,
            SHILO,
            MTHLIP,

            // DPA.W intrinsic nodes.
            MULSAQ_S_W_PH,
            MAQ_S_W_PHL,
            MAQ_S_W_PHR,
            MAQ_SA_W_PHL,
            MAQ_SA_W_PHR,
            DPAU_H_QBL,
            DPAU_H_QBR,
            DPSU_H_QBL,
            DPSU_H_QBR,
            DPAQ_S_W_PH,
            DPSQ_S_W_PH,
            DPAQ_SA_L_W,
            DPSQ_SA_L_W,
            DPA_W_PH,
            DPS_W_PH,
            DPAQX_S_W_PH,
            DPAQX_SA_W_PH,
            DPAX_W_PH,
            DPSX_W_PH,
            DPSQX_S_W_PH,
            DPSQX_SA_W_PH,
            MULSA_W_PH,

            MULT,
            MULTU,
            MADD_DSP,
            MADDU_DSP,
            MSUB_DSP,
            MSUBU_DSP,

            // Load/Store Left/Right nodes.
            LWL = ISD::FIRST_TARGET_MEMORY_OPCODE,
            LWR,
            SWL,
            SWR,
            LDL,
            LDR,
            SDL,
            SDR


        };
    }

    class NewTargetTargetLowering : public TargetLowering {
    private:
        const NewTargetSubtarget &Subtarget;
        const DataLayout *TD;

        /// ByValArgInfo - Byval argument information.

        struct ByValArgInfo {
            unsigned FirstIdx; // Index of the first register used.
            unsigned NumRegs; // Number of registers used for this argument.
            unsigned Address; // Offset of the stack area used to pass this argument.

            ByValArgInfo() : FirstIdx(0), NumRegs(0), Address(0) {
            }
        };

        SDValue LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerSELECT(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerBRCOND(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerEH_RETURN(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerADD(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerLOAD(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerSTORE(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerSETCC(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerJumpTable(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerShiftLeftParts(SDValue Op, SelectionDAG &DAG) const;
        SDValue LowerShiftRightParts(SDValue Op, SelectionDAG &DAG, bool IsSRA) const;
        // SDValue LowerGlobalTLSAddress(SDValue Op, SelectionDAG &DAG) const;

        /// MipsCC - This class provides methods used to analyze formal and call
        /// arguments and inquire about calling convention information.

        class NewTargetCC {
        public:
            NewTargetCC(CallingConv::ID CallConv, CCState &Info);

            void analyzeCallOperands(const SmallVectorImpl<ISD::OutputArg> &Outs,
                    bool IsVarArg);
            void analyzeFormalArguments(const SmallVectorImpl<ISD::InputArg> &Ins);

            const CCState &getCCInfo() const {
                return CCInfo;
            }

            /// hasByValArg - Returns true if function has byval arguments.

            bool hasByValArg() const {
                return !ByValArgs.empty();
            }

            /// regSize - Size (in number of bits) of integer registers.

            unsigned regSize() const {
                return 4;
            }

            /// numIntArgRegs - Number of integer registers available for calls.
            unsigned numIntArgRegs() const;

            /// reservedArgArea - The size of the area the caller reserves for
            /// register arguments. This is 16-byte if ABI is O32.
            unsigned reservedArgArea() const;

            /// Return pointer to array of integer argument registers.
            const uint16_t *intArgRegs() const;

            typedef SmallVector<ByValArgInfo, 2>::const_iterator byval_iterator;

            byval_iterator byval_begin() const {
                return ByValArgs.begin();
            }

            byval_iterator byval_end() const {
                return ByValArgs.end();
            }

        private:
            void handleByValArg(unsigned ValNo, MVT ValVT, MVT LocVT,
                    CCValAssign::LocInfo LocInfo,
                    ISD::ArgFlagsTy ArgFlags);

            /// useRegsForByval - Returns true if the calling convention allows the
            /// use of registers to pass byval arguments.

            bool useRegsForByval() const {
                return CallConv != CallingConv::Fast;
            }

            /// Return the function that analyzes fixed argument list functions.
            llvm::CCAssignFn *fixedArgFn() const;

            /// Return the function that analyzes variable argument list functions.
            llvm::CCAssignFn *varArgFn() const;

            const uint16_t *shadowRegs() const;

            void allocateRegs(ByValArgInfo &ByVal, unsigned ByValSize,
                    unsigned Align);

            CCState &CCInfo;
            CallingConv::ID CallConv;
            SmallVector<ByValArgInfo, 2> ByValArgs;
        };

        /// copyByValArg - Copy argument registers which were used to pass a byval
        /// argument to the stack. Create a stack frame object for the byval
        /// argument.
        void copyByValRegs(SDValue Chain, DebugLoc DL,
                std::vector<SDValue> &OutChains, SelectionDAG &DAG,
                const ISD::ArgFlagsTy &Flags,
                SmallVectorImpl<SDValue> &InVals,
                const Argument *FuncArg,
                const NewTargetCC &CC, const ByValArgInfo &ByVal) const;

        /// passByValArg - Pass a byval argument in registers or on stack.
        void passByValArg(SDValue Chain, DebugLoc DL,
                std::deque< std::pair<unsigned, SDValue> > &RegsToPass,
                SmallVector<SDValue, 8> &MemOpChains, SDValue StackPtr,
                MachineFrameInfo *MFI, SelectionDAG &DAG, SDValue Arg,
                const NewTargetCC &CC, const ByValArgInfo &ByVal,
                const ISD::ArgFlagsTy &Flags, bool isLittle) const;
        /// writeVarArgRegs - Write variable function arguments passed in registers
        /// to the stack. Also create a stack frame object for the first variable
        /// argument.
        void writeVarArgRegs(std::vector<SDValue> &OutChains, const NewTargetCC &CC,
                SDValue Chain, DebugLoc DL, SelectionDAG &DAG) const;

        SDValue passArgOnStack(SDValue StackPtr, unsigned Offset, SDValue Chain,
                SDValue Arg, DebugLoc DL, bool IsTailCall,
                SelectionDAG &DAG) const;

        // Lower Operand helpers
        SDValue LowerCallResult(SDValue Chain, SDValue InFlag,
                CallingConv::ID CallConv, bool isVarArg,
                const SmallVectorImpl<ISD::InputArg> &Ins,
                DebugLoc dl, SelectionDAG &DAG,
                SmallVectorImpl<SDValue> &InVals) const;

        // Inline asm support
        ConstraintType getConstraintType(const std::string &Constraint) const;

        /// Examine constraint string and operand type and determine a weight value.
        /// The operand object must already have been set up with the operand type.
        ConstraintWeight getSingleConstraintMatchWeight(
                AsmOperandInfo &info, const char *constraint) const;

        std::pair<unsigned, const TargetRegisterClass*>
        getRegForInlineAsmConstraint(const std::string &Constraint,
                EVT VT) const;

        /// LowerAsmOperandForConstraint - Lower the specified operand into the Ops
        /// vector.  If it is invalid, don't add anything to Ops. If hasMemory is
        /// true it means one of the asm constraint of the inline asm instruction
        /// being processed is 'm'.
        virtual void LowerAsmOperandForConstraint(SDValue Op,
                std::string &Constraint,
                std::vector<SDValue> &Ops,
                SelectionDAG &DAG) const;

        virtual bool isLegalAddressingMode(const AddrMode &AM, Type *Ty) const;

        virtual bool isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const;

        virtual unsigned getJumpTableEncoding() const;

    public:
        explicit NewTargetTargetLowering(NewTargetMachine &TM);
        //
        virtual void LowerOperationWrapper(SDNode *N,
                SmallVectorImpl<SDValue> &Results,
                SelectionDAG &DAG) const;

        /// LowerOperation - Provide custom lowering hooks for some operations.
        virtual SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const;

        /// ReplaceNodeResults - Replace the results of node with an illegal result
        /// type with new values built out of custom code.
        ///
        virtual void ReplaceNodeResults(SDNode *N, SmallVectorImpl<SDValue>&Results,
                SelectionDAG &DAG) const;

        virtual SDValue
        LowerFormalArguments(SDValue Chain,
                CallingConv::ID CallConv, bool isVarArg,
                const SmallVectorImpl<ISD::InputArg> &Ins,
                DebugLoc dl, SelectionDAG &DAG,
                SmallVectorImpl<SDValue> &InVals) const;
        virtual SDValue
        LowerCall(TargetLowering::CallLoweringInfo &CLI,
                SmallVectorImpl<SDValue> &InVals) const;

        virtual SDValue
        LowerReturn(SDValue Chain,
                CallingConv::ID CallConv, bool isVarArg,
                const SmallVectorImpl<ISD::OutputArg> &Outs,
                const SmallVectorImpl<SDValue> &OutVals,
                DebugLoc dl, SelectionDAG &DAG) const;

        virtual bool
        CanLowerReturn(CallingConv::ID CallConv, MachineFunction &MF,
                bool isVarArg,
                const SmallVectorImpl<ISD::OutputArg> &Outs,
                LLVMContext &Context) const;
        /// getTargetNodeName - This method returns the name of a target specific
        //  DAG node.
        virtual const char *getTargetNodeName(unsigned Opcode) const;

        /// getSetCCResultType - get the ISD::SETCC result ValueType
        EVT getSetCCResultType(EVT VT) const;

        virtual SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const;
    };

} /* namespace llvm */
#endif /* NEWTARGETISELLOWERING_H_ */
