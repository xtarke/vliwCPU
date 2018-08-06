/* 
 * File:   NewTargetLoadStoreOffsetExpander.cpp
 * Author: andreu
 * 
 * Created on 27 de Junho de 2014, 14:03
 */

#include "NewTarget.h"
#include "NewTargetMFSaver.h"
#include "NewTargetWCETEstimator.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include <llvm/CodeGen/MachineFunction.h>
#include <llvm/CodeGen/GCMetadata.h>
#include <llvm/CodeGen/MachineModuleInfo.h>
#include "NewTargetInstrInfo.h"
#include "NewTargetRegisterInfo.h"

#include <iostream>

using namespace llvm;

namespace {

    class BundleDesc {
    public:

        BundleDesc(const TargetInstrInfo *tii, MachineBasicBlock &mbb, MachineBasicBlock::instr_iterator IT_,
                unsigned size_) :
        TII(tii), MBB(mbb), IT(IT_), size(size_) {
        };

        unsigned getSize() {
            unsigned count = 0;
            MachineBasicBlock::instr_iterator I = IT;

            // a solo instruction
            if (!I->isBundledWithSucc()) {
                return 1;
            }
            // a bundle
            while (I->isBundledWithSucc()) {
                ++I;
                if ((I->getOpcode() != TargetOpcode::BUNDLE) && !I->isLabel() && !I->isDebugValue() &&
                        (I->getOpcode() != TargetOpcode::IMPLICIT_DEF) ) {
                    count++;
                }
            }
            return count;
        }

        bool tryToInsertNOP(unsigned line) {

            // check if we can put another instruction
            if (getSize() >= 4) {
                return false;
            }

            MachineBasicBlock::iterator Iter;

            Iter = IT;

            if (IT->isInlineAsm())
                return false;

            if (IT->isLabel())
                return false;

            if (IT->isDebugValue())
                return false;

            if (IT->getOpcode() == TargetOpcode::IMPLICIT_DEF) {
                return false;
            }

            // we are dealing with a bundle, so append a nop
            if (IT->isBundle()) {
                MachineInstrBuilder MB;
                MB = BuildMI(*MBB.getParent(), Iter->getDebugLoc(), TII->get(NewTarget::ADDi), NewTarget::ZERO).addReg(NewTarget::ZERO).addImm(0);
                MIBundleBuilder(Iter).append(MB);
            } else {
                // we are dealing with a single instruction (or with an immediate extesion))
                MachineInstrBuilder MB;
                MB = BuildMI(*MBB.getParent(), Iter->getDebugLoc(), TII->get(NewTarget::ADDi), NewTarget::ZERO).addReg(NewTarget::ZERO).addImm(0);
                MIBundleBuilder(Iter).append(MB);
                // after we add a nop, we must build a complete bundle
                finalizeBundle(MBB, Iter.getInstrIterator());
                // decrements the iterator to poit ti the bundle marker
                IT--;
            }
            // increment size (we are not using size at this monent, but increment anyway))
            size++;
            return true;
        }

    private:
        const TargetInstrInfo *TII;
        MachineBasicBlock &MBB;
        MachineBasicBlock::instr_iterator IT;
        unsigned size;
    };

    class NewTargetBundleAligner : public MachineFunctionPass {
    public:

        NewTargetBundleAligner(const TargetInstrInfo *tii) : MachineFunctionPass(ID), TII(tii),
        inst_counter(0), cache_lines(1) {
        };

        virtual const char *getPassName() const {
            return "NewTarget bundle aligner";
        }

        void checkCacheLines() {
            cache_lines = inst_counter / 8 + 1;

        }

        void clearMachineFuncBundles() {
            while (!machineFuncBundles.empty()) {
                BundleDesc* desc = machineFuncBundles.back();
                machineFuncBundles.pop_back();
                delete desc;
            }
        }

        void doAlignment(unsigned amount) {

            std::list<BundleDesc*>::iterator IT;

            // iterate over the list of processed bundles
            for (IT = machineFuncBundles.begin(); IT != machineFuncBundles.end(); IT++) {
                BundleDesc* desc = *IT;
                // try to put much nos as possible in the bundle
                while ((amount > 0) && desc->tryToInsertNOP(cache_lines)) {
                    amount--;
                    inst_counter++;
                }
                // is some nops remains, continue, else stops
                if (amount > 0) {
                    continue;
                } else {
                    break;
                }
            }
        }

        unsigned isMissaligned(MachineBasicBlock &MBB, MachineBasicBlock::iterator &IT) {
            uint32_t counter = 0;
            uint32_t total;

            if (IT == MBB.end()) {
                return 0;
            }

            MachineBasicBlock::iterator IT2 = IT;
            IT2++;

            MachineBasicBlock::instr_iterator MI;

            // count the number of instruction in the current bundle
            for (MI = IT.getInstrIterator(); MI != IT2.getInstrIterator(); MI++) {
                if ((MI->getOpcode() != TargetOpcode::BUNDLE) && !MI->isLabel() && !MI->isDebugValue() &&
                        (MI->getOpcode() != TargetOpcode::IMPLICIT_DEF)) {
                    counter++;
                }
            }
            total = counter + inst_counter;

            // we have more instructions than space in this cache line
            if (total > cache_lines * 8) {
                // this is the ofset to align this bundle to the next line
                unsigned offset = (cache_lines * 8) - inst_counter;
                return offset;
            }
            // we are aligned
            return 0;
        }

        bool runOnMachineBasicBlock(MachineFunction &MF, MachineBasicBlock &MBB) {


            MachineBasicBlock::iterator IT;
            MachineBasicBlock::instr_iterator MI;
            MachineBasicBlock::iterator IT2;

            for (IT = MBB.begin(); IT != MBB.end(); IT++) {

                uint32_t count = 0;
                IT2 = IT;
                IT2++;
                // current bundle
                for (MI = IT.getInstrIterator(); MI != IT2.getInstrIterator(); MI++) {
                    if ((MI->getOpcode() != TargetOpcode::BUNDLE) &&
                            !MI->isLabel() && !MI->isDebugValue() &&
                            (MI->getOpcode() != TargetOpcode::IMPLICIT_DEF)) {
                        count++;
                    }
                }
                // update the number of instruction processed;
                inst_counter += count;
                //check if we fill this cache line
                checkCacheLines();

                BundleDesc* desc = new BundleDesc(TII, MBB, IT.getInstrIterator(), count);
                machineFuncBundles.push_front(desc);

                // next bundle is aligned?
                unsigned amount = isMissaligned(MBB, IT2);

                if (amount) {
                    // inser nops to align the previos bundle
                    doAlignment(amount);
                }
                checkCacheLines();
            }

            unsigned MBBalignment = (cache_lines * 8) - inst_counter;
            // 8 means that this function ends in the end of a cacheline
            if (MBBalignment < 8 && MBBalignment != 4) {

                if (MBBalignment > 4) {
                    MBBalignment -= 4;
                }

                doAlignment(MBBalignment);
            }

            return false;
        }

        bool runOnMachineFunction(MachineFunction &MF) {


            MachineFunction::iterator IT;

            //if (MF.getName().equals("main_app")) {
            //    std::cout << ">aqui\n";
            //    std::cout << ">cache lines: " << cache_lines << "\n";
            //    std::cout << ">words: " << cache_lines*8 << "\n";
            //} else {
            //    std::cout << MF.getName().data() << "\n";
            //}

            for (IT = MF.begin(); IT != MF.end(); IT++) {
                runOnMachineBasicBlock(MF, *IT);
            }

            // we keep functions aligned.
            // if we process a function that is unaligned, may occur some situation,
            // where aligment is not possible.
            unsigned MFalignment = (cache_lines * 8) - inst_counter;

            // 8 means that this function ends in the end of a cacheline
            if (MFalignment < 8 && MFalignment != 4) {

                if (MFalignment > 4) {
                    MFalignment -= 4;
                }
                doAlignment(MFalignment);
            }

            checkCacheLines();

            clearMachineFuncBundles();
            //MF.viewCFG();
            return false;
        }

    private:

        static char ID;
        const TargetInstrInfo *TII;
        uint32_t inst_counter;
        uint32_t cache_lines;

        std::list<BundleDesc*> machineFuncBundles;
    };
    char NewTargetBundleAligner::ID = 0;
}

FunctionPass *llvm::createNewTargetBundleAligner(NewTargetMachine &TM, const TargetInstrInfo *TII) {

    return new NewTargetBundleAligner(TII);
}
