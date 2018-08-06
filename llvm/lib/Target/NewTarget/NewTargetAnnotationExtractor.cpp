
#include "NewTarget.h"
#include "NewTargetInstrInfo.h"
#include "NewTargetMachine.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/CodeGen/MachineBranchProbabilityInfo.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include <iomanip>
#include "NewTargetCFGGen.h"
#include "llvm/DebugInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/system_error.h"
#include <sstream>

#include <iostream>
#include <list>
#include <cstdio>

using namespace llvm;

namespace {

    class LoopBoundExtractor : public LoopPass {
    public:

        static char ID;

        explicit LoopBoundExtractor() : LoopPass(ID) {
        }

        ~LoopBoundExtractor() {
        }

        virtual bool runOnLoop(Loop *L, LPPassManager &LPM);

        virtual void getAnalysisUsage(AnalysisUsage &AU) const {
            AU.setPreservesAll(); // We don't modify the program, so we preserve all analyses
            AU.addRequiredID(LoopSimplifyID);
            AU.addRequired<LoopInfo>();
            AU.addRequired<ScalarEvolution>();
            AU.addPreserved<ScalarEvolution>();
            //AU.addRequiredTransitive<AliasAnalysis>();
            //AU.addPreserved<AliasAnalysis>();
            //AU.addRequiredTransitive<TargetData>();
        }

    };

    class RecursionDepthExtractor : public FunctionPass {
    public:
        static char ID;

        explicit RecursionDepthExtractor() : FunctionPass(ID) {
        }

        ~RecursionDepthExtractor() {
        }

        virtual bool runOnFunction(Function &F);
    };

    class ProfileAuthorizationExtractor : public FunctionPass {
    public:
        static char ID;

        explicit ProfileAuthorizationExtractor() : FunctionPass(ID) {
        }

        ~ProfileAuthorizationExtractor() {
        }

        virtual bool runOnFunction(Function &F);
    };
}

char LoopBoundExtractor::ID = 0;
RegisterPass<LoopBoundExtractor> X("loop-be", "Loop Bound Extractor");

char RecursionDepthExtractor::ID = 0;
RegisterPass<RecursionDepthExtractor> Y("rec-d", "Recursion Depth Extractor");

char ProfileAuthorizationExtractor::ID = 0;
RegisterPass<ProfileAuthorizationExtractor> Z("prof-d", "Profile auth. Extractor");

static int32_t readLoopBoundFromArchive(const BasicBlock* bb) {
    const Instruction* I = &bb->back();
    int32_t bound;

    if (MDNode * N = I->getMetadata("dbg")) { // Here I is an LLVM instruction
        DILocation Loc(N); // DILocation is in DebugInfo.h
        unsigned Line = Loc.getLineNumber();
        StringRef File = Loc.getFilename();
        StringRef Dir = Loc.getDirectory();

        std::string filename(Dir);
        filename += "/";
        filename += File;

        OwningPtr<MemoryBuffer> Filename;
        if (MemoryBuffer::getFile(filename.c_str(), Filename)) {
            report_fatal_error("Error on opening, source code file not found.");
        }
        const char* buffer = Filename.get()->getBufferStart();

        unsigned TargetLine = Line - 2;

        // go to the line of the annotation
        while (TargetLine > 0) {
            while (*(buffer++) != '\n') {
            }
            TargetLine--;
        }
        // skip tabs and spaces
        while (true) {
            if (*buffer != ' ' && *buffer != '\t') {
                break;
            }
            buffer++;
        }
        if (strncmp(buffer, "//@loop-bound:", strlen("//@loop-bound:"))) {

            std::string errorMessage = "Loop annotation missing for the following unbounded loop:\n";

            TargetLine = Line - 1;
            //reset buffer
            buffer = Filename.get()->getBufferStart();
            // go to the line of the loop
            while (TargetLine > 0) {
                while (*(buffer++) != '\n') {
                    // std::cout << "" << *buffer;
                }
                TargetLine--;
            }

            char* bufferEnd = (char*) buffer;

            while (bufferEnd[0] != '\n') {
                errorMessage += bufferEnd[0];
                bufferEnd++;
            }

            errorMessage += "\nIn:";
            errorMessage += filename;
            errorMessage += ":";

            std::stringstream LineStr;
            LineStr << Line;

            errorMessage += LineStr.str();

            //std::cout << "linha: " << Line << "\n";

            report_fatal_error(errorMessage);
        } else {
            buffer += strlen("//@loop-bound:");
            // skip tabs and spaces
            while (true) {
                if (*buffer != ' ' && *buffer != '\t') {
                    break;
                }
                buffer++;
            }
            std::string temp;
            while (isdigit(*buffer)) {
                temp += *buffer;
                buffer++;
            }
            std::istringstream stream(temp);
            stream >> bound;
        }
    } else {
        report_fatal_error("To extract loop bound info from annotations, you must compile the code with debug information (-g on clang).");
    }
    return bound;
}

bool LoopBoundExtractor::runOnLoop(Loop *L, LPPassManager &LPM) {

    //const BasicBlock* ExitingBlock = L->getExitingBlock();
    const BasicBlock* ExitingBlock = L->getHeader();
    const BasicBlock* cExitingBlock = L->getLoopPredecessor();
    bool isExact = true;

    //if(ExitingBlock == NULL){
    //llvm_unreachable("testeeeeeeeeeeee");
    //L->getHeader();
    //    ExitingBlock = L->getHeader();
    //}

    ScalarEvolution *SE = &getAnalysis<ScalarEvolution>();
    int count = SE->getSmallConstantTripCount(L, (BasicBlock*) ExitingBlock);

    // hack to deal with the boot loader loop
    if (!strcmp(L->getHeader()->getParent()->getName().data(), "load_data_to_ram")) {
        count = 0xCACACACA;
        isExact = false;
    }

    if (count == 0) {
        //count = readLoopBoundFromArchive(ExitingBlock) + 1;
        count = readLoopBoundFromArchive(cExitingBlock) + 1;
        isExact = false;
    }

    llvm::LoopBounds.insert(std::make_pair((const BasicBlock*) ExitingBlock, count));
    llvm::IsLoopBoundExact.insert(std::make_pair((const BasicBlock*) ExitingBlock, isExact));


    return false;
}

bool RecursionDepthExtractor::runOnFunction(Function &F) {

    const Instruction* I = &F.getEntryBlock().front();
    int32_t depth;

    if (MDNode * N = I->getMetadata("dbg")) { // Here I is an LLVM instruction
        DILocation Loc(N); // DILocation is in DebugInfo.h
        unsigned Line = Loc.getLineNumber();
        StringRef File = Loc.getFilename();
        StringRef Dir = Loc.getDirectory();

        std::string filename(Dir);
        filename += "/";
        filename += File;

        OwningPtr<MemoryBuffer> Filename;
        if (MemoryBuffer::getFile(filename.c_str(), Filename)) {
            report_fatal_error("Error on opening, source code file not found.");
        }
        const char* buffer = Filename.get()->getBufferStart();

        unsigned TargetLine = Line - 2;

        // go to the line of the annotation
        while (TargetLine > 0) {
            while (*(buffer++) != '\n') {
            }
            TargetLine--;
        }

        if (strncmp(buffer, "//@recursion-depth:", strlen("//@recursion-depth:")) == 0) {


            buffer += strlen("//@recursion-depth:");
            // skip tabs and spaces
            while (true) {
                if (*buffer != ' ' && *buffer != '\t') {
                    break;
                }
                buffer++;
            }
            std::string temp;
            while (isdigit(*buffer)) {
                temp += *buffer;
                buffer++;
            }
            std::istringstream stream(temp);
            stream >> depth;

            llvm::RecursionDepths.insert(std::make_pair((const Function*) &F, depth));
        }

    }

    return false;
}

bool ProfileAuthorizationExtractor::runOnFunction(Function &F) {


    for (Function::iterator FI = F.begin(), FE = F.end();
            FI != FE; ++FI) {
        BasicBlock &BB = *FI;
        std::string name(BB.getParent()->getName());
        name.append(":");
        name.append(BB.getName());
        //std::cout << ">>" << name << "\n";

        const Instruction* I = &BB.front();

        if (MDNode * N = I->getMetadata("dbg")) { // Here I is an LLVM instruction
            DILocation Loc(N); // DILocation is in DebugInfo.h
            unsigned Line = Loc.getLineNumber();
            StringRef File = Loc.getFilename();
            StringRef Dir = Loc.getDirectory();

            std::string filename(Dir);
            filename += "/";
            filename += File;

            OwningPtr<MemoryBuffer> Filename;
            if (MemoryBuffer::getFile(filename.c_str(), Filename)) {
                report_fatal_error("Error on opening, source code file not found.");
            }
            const char* buffer = Filename.get()->getBufferStart();

            unsigned TargetLine = Line - 2;

            // go to the line of the annotation
            while (TargetLine > 0) {
                while (*(buffer++) != '\n') {
                }
                TargetLine--;
            }

            // skip tabs and spaces
            while (true) {
                if (*buffer != ' ' && *buffer != '\t') {
                    break;
                }
                buffer++;
            }

            //std::cout << "---------\n";
            std::cout << name << "\n";
            //std::cout << ">>>>" << buffer;
            if (strncmp(buffer, "//@allow-profile", strlen("//@allow-profile")) == 0) {

                ///std::cout << "+++++++++\n";
                llvm::AllowedToUseProfileInfo.insert(&BB);
            }
        }
        
    }
    return false;
}

Pass * llvm::createLoopBoundExtractor() {
    return new LoopBoundExtractor();
}

FunctionPass * llvm::createRecursionDepthExtractor() {
    return new RecursionDepthExtractor();
}

FunctionPass * llvm::createProfileAuthorizationExtractor() {
    return new ProfileAuthorizationExtractor();
}
