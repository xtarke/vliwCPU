/*
 * NewTargetWCETEstimator.cpp
 *
 *  Created on: Mar 11, 2014
 *      Author: andreu
 */

#include "NewTarget.h"
#include "NewTargetWCETEstimator.h"
#include "NewTargetTargetObjectFile.h"
#include "NewTargetCFGGen.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include <llvm/CodeGen/MachineFunction.h>
#include <llvm/MC/MCStreamer.h>
#include <llvm/Support/TargetRegistry.h>
#include "MCTargetDesc/NewTargetMCTargetDesc.h"
#include "NewTargetMCInstLower.h"
#include <llvm/Support/raw_ostream.h>
#include <llvm/Support/FormattedStream.h>
#include <llvm/Pass.h>
#include <llvm/PassManager.h>
#include <llvm/CodeGen/GCMetadata.h>
#include <llvm/CodeGen/MachineModuleInfo.h>
#include <llvm/Target/TargetLoweringObjectFile.h>
#include <llvm/Target/Mangler.h>
#include <llvm/MC/MCAsmInfo.h>
#include <llvm/CodeGen/GCMetadataPrinter.h>
#include <llvm/MC/MCExpr.h>
#include <llvm/MC/MCStreamer.h>
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCAsmBackend.h"

#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/system_error.h"

#include "InstPrinter/NewTargetInstPrinter.h"

//#include <memory>
#include <iostream>
#include <vector>
#include <cstdlib>


using namespace llvm;



// static members 

//std::map<const Function*, MachineFunction*> NewTargetWCETEstimator::FToMFMap;

// public methods

void NewTargetWCETEstimator::prepareFreqCounters() {
    Module::iterator FT;

    for (FT = M.begin(); FT != M.end(); FT++) {

        Function* F = &(*FT);
        MachineFunction* MF = F->getMachineFunction();
        MachineFunction::const_iterator MFIt;

        if (!MF) {
            continue;
        }

        for (MFIt = MF->begin(); MFIt != MF->end(); MFIt++) {
            const MachineBasicBlock* MBB = &(*MFIt);
            MBBFreq.insert(std::pair<const MachineBasicBlock*, unsigned>(MBB, 0));
        }
    }
}

void NewTargetWCETEstimator::clearFreqCounters() {
    MBBFreq.clear();
}

void NewTargetWCETEstimator::runAnalyzer() {
    NewTargetCFGGen CFGGen;
    std::string Filename;

    Filename = M.getModuleIdentifier();

    //std::cout << "Filename: " << Filename << "\n";

    std::size_t found = Filename.find(".ll");
    if (found == std::string::npos) {
        found = Filename.find(".c");
        if (found == std::string::npos) {
            llvm_unreachable("cannot resolve module name!");
        }
    }

    std::string Filename2 = Filename.substr(0, found);
    std::string Filename3 = Filename.substr(0, found) + "-rtopt";

    std::string ElfFilename = Filename2 + "-rtopt.o";
    std::string BinFilename = Filename2 + "-rtopt.bin";
    std::string CFGFilename = Filename2 + "-rtopt.ll.cfg";
    std::string DOTFilename = Filename2 + "-rtopt.ll.dot";
    //std::string LBFilename = Filename2 + "-rtopt.lb";
    //std::string OrigLBFilename = Filename2 + ".lb";

    /*
    std::cout << "ElfFilename: " << ElfFilename << "\n";
    std::cout << "BinFilename: " << BinFilename << "\n";
    std::cout << "CFGFilename: " << CFGFilename << "\n";
    std::cout << "DOTFilename: " << DOTFilename << "\n";
     */


    sys::Path copy = sys::Program::FindProgramByName("cp");
    SmallVector<const char*, 8> Args;

    //Args.push_back("cp");
    //Args.push_back(OrigLBFilename.c_str());
    //Args.push_back(LBFilename.c_str());
    //Args.push_back(0);

    // std::string ErrMsg;
    //int Result = sys::Program::ExecuteAndWait(copy, Args.data(), 0, 0, 0, 0,
    //                                        &ErrMsg);
    //if (Result < 0) {
    //   errs() << "Error: " << ErrMsg << "\n";
    //  errs() << "Missing loop bound file!\n";
    //   return;
    // }

    generateFakeELF(ElfFilename.c_str(), true);
    //generateFakeELF("testeasm.s", false);
    generateCFG(CFGFilename.c_str(), DOTFilename.c_str());
    invokeAnalyzer(Filename3.c_str());
    clearFreqCounters();
    prepareFreqCounters();
    retriveWCETData();
}

unsigned NewTargetWCETEstimator::getWCET() {
    if (WCET == 0) {
        llvm_unreachable("WCET calculation pending!");
    }
    return WCET;
}

MBBSet* NewTargetWCETEstimator::getMFWorstCaseMBBSet(MachineFunction& MF) {
    if (WCET == 0) {
        llvm_unreachable("WCET calculation pending!");
    }
    llvm_unreachable("unimplemented");
    return NULL;
}

MBBSet* NewTargetWCETEstimator::getMWorstCaseMBBSet() {

    Module::iterator FT;

    if (WCET == 0) {
        llvm_unreachable("WCET calculation pending!");
    }

    MBBSet* mbbset = new MBBSet();

    for (FT = M.begin(); FT != M.end(); FT++) {
        Function* F = &(*FT);
        MachineFunction* MF = F->getMachineFunction();

        if (!MF) {
            continue;
        }

        BasicBlockListType::iterator IT;

        for (IT = MF->begin(); IT != MF->end(); IT++) {
            MachineBasicBlock* MBB = &(*IT);
            if (isInWCEP(MBB)) {
                mbbset->insert(MBB);
            }
        }
    }
    return mbbset;
}

bool NewTargetWCETEstimator::isInWCEP(MachineBasicBlock *MBB) {
    std::map<const MachineBasicBlock*, unsigned>::const_iterator IT;

    IT = MBBFreq.find(MBB);

    if (IT == MBBFreq.end()) {
        errs() << "Invalid basic block, assuming that is out of the WCEP\n";
        return false;
    }

    //std::cout << "contador: " << IT->second << "\n";

    if (IT->second > 0) {
        return true;
    }
    return false;
}

uint32_t NewTargetWCETEstimator::getMBBWCC(MachineBasicBlock* MBB) {

    std::map<const MachineBasicBlock*, unsigned>::const_iterator IT;

    IT = MBBFreq.find(MBB);

    if (IT == MBBFreq.end()) {
        errs() << "Invalid basic block, assuming that is out of the WCEP\n";
        return false;
    }

    return IT->second;
}

bool NewTargetWCETEstimator::isWCEPInvariant(MachineBasicBlock* MBB) {
    std::set<const MachineBasicBlock*>::const_iterator IT;

    IT = InvMBBs.find(MBB);

    if (IT != InvMBBs.end()) {
        return true;
    }

    return false;
}

// private methods

void NewTargetWCETEstimator::retrieveInvariantBlocks() {

}

void NewTargetWCETEstimator::generateFakeELF(const char* filename, bool binary) {
    NewTargetAsmPrinter* asmPrinter;
    MCAsmBackend* asmBackend;
    MCStreamer* Streamer;
    const Target* target;
    const MCInstrInfo* MCII;
    const MCRegisterInfo* MRI;
    const MCSubtargetInfo* STI;
    const MCAsmInfo *MAI;
    NewTargetTargetObjectFile *MOFI;
    MCContext* Ctx;
    std::string errorStr;

    target = TargetRegistry::lookupTarget("newtarget", errorStr);
    asmBackend = createNewTargetAsmBackend(*target, "newtarget-redhat-linux-gnu", "");
    MCII = createNewTargetMCInstrInfo();
    MRI = createNewTargetMCRegisterInfo("newtarget-redhat-linux-gnu");
    STI = createNewTargetMCSubtargetInfo("newtarget-redhat-linux-gnu", "", "");
    MAI = createMCAsmInfo(*target, "newtarget-redhat-linux-gnu");
    MOFI = new NewTargetTargetObjectFile();
    Ctx = new MCContext(*MAI, *MRI, MOFI);

    if (Ctx == NULL) {
        llvm_unreachable("Ctx should not be NULL at his point!");
    }

    MCCodeEmitter* codeEmitter = createNewTargetMCCodeEmitter(*MCII, *MRI, *STI, *Ctx);
    std::string ErrorInfo;

    unsigned openFlags = 0;

    if (binary) openFlags |= raw_fd_ostream::F_Binary;

    raw_fd_ostream OS(filename, ErrorInfo, openFlags);
    formatted_raw_ostream FOS(OS);

    if (binary) {
        Streamer = createNewTargetELFStreamer(*target, "newtarget-redhat-linux-gnu",
                *Ctx, *asmBackend, FOS, codeEmitter,
                TM.hasMCRelaxAll(), TM.hasMCNoExecStack());
    } else {

        NewTargetInstPrinter* instrPrinter = new NewTargetInstPrinter(*MAI, *MCII, *MRI);

        Streamer = llvm::createAsmStreamer(*Ctx, FOS, true, true, true, true, instrPrinter, codeEmitter, asmBackend);
    }



    asmPrinter = new NewTargetAsmPrinter(TM, *Streamer);
    initializeAsmPrinter(asmPrinter);

    Module::iterator FT;
    // generate output code for each function
    for (FT = M.begin(); FT != M.end(); FT++) {
        Function* F = &(*FT);
        MachineFunction* MF = F->getMachineFunction();


        if (!MF) {
            continue;
        }
        //MCSymbol *GVSym = asmPrinter->Mang->getSymbol(F);
        MCSymbol *GVSym = asmPrinter->Mang->getSymbol(MF->getFunction());
        GVSym->setUndefined();

        //continue;

        MachineFunction::iterator MFIt;

        for (MFIt = MF->begin(); MFIt != MF->end(); MFIt++) {
            MachineBasicBlock* MBB = &(*MFIt);

            if (MBB->hasAddressTaken()) {
                const BasicBlock *BB = MBB->getBasicBlock();
                std::vector<MCSymbol*> Syms = asmPrinter->MMI->getAddrLabelSymbolToEmit(BB);
                for (unsigned i = 0, e = Syms.size(); i != e; ++i) {
                    Syms[i]->setUndefined();
                }
            }
            // Print the main label for the block.
            //if (MBB->pred_empty() || isBlockOnlyReachableByFallthrough(MBB)) {

            // } else {
            MBB->getSymbol()->setUndefined();
            // }             
        }
        asmPrinter->runOnMachineFunction(*MF);
    }
    finalizeAsmPrinter(asmPrinter);

    delete asmPrinter; // deletes Stramer
    //delete asmBackend; // deleted by Streamer	
    //delete codeEmitter; // deleted by Streamer
    //delete Streamer; deleted by asmPrinter

    delete Ctx;
    delete MOFI;
    delete MAI;
    delete STI;
    delete MRI;
    delete MCII;
}

void NewTargetWCETEstimator::generateCFG(const char* CFGfilename, const char* DOTfilename) {
    NewTargetCFGGen CFGGen;
    Module::iterator FT;

    // generate output code for each function
    for (FT = M.begin(); FT != M.end(); FT++) {
        Function* F = &(*FT);
        MachineFunction* MF = F->getMachineFunction();

        if (!MF) {
            continue;
        }
        CFGGen.processMachineFunction(*MF);
    }
    CFGGen.dump(CFGfilename, DOTfilename);
}

void NewTargetWCETEstimator::invokeAnalyzer(const char* name) {
    const char *WcetDir = ::getenv("WCETDIR");
    SmallVector<const char*, 8> Args;
    sys::Path Program;
    std::string ErrMsg;
    int Result;

    if (!WcetDir) {
        llvm_unreachable("ENVIRONMENT variable WCETDIR not found!");
    }

    std::string ExecPath(WcetDir);
    std::string ExecPathWithProg = ExecPath + "/wcet";
    Program = sys::Program::FindProgramByName(ExecPathWithProg);

    Args.push_back("wcet");
    Args.push_back("-a");
    Args.push_back(name);
    Args.push_back(0);

    Result = sys::Program::ExecuteAndWait(Program, Args.data(), 0, 0, 0, 0,
            &ErrMsg);
    if (Result < 0) {
        errs() << "Error: " << ErrMsg << "\n";
        return;
    }
}

void NewTargetWCETEstimator::retriveWCETData() {
    OwningPtr<MemoryBuffer> File;
    uint32_t NMBB;
    const char* buffer;

    if (error_code ec = MemoryBuffer::getFile("result.cfg", File)) {
        errs() << "Could not open input file: " + ec.message();
        llvm_unreachable("");
    }

    buffer = File->getBufferStart();

    // read the number of cfg nodes
    memcpy(&NMBB, buffer, sizeof (uint32_t));
    buffer += sizeof (uint32_t);

    // read the calculated wcet
    memcpy(&WCET, buffer, sizeof (uint32_t));
    buffer += sizeof (uint32_t);

    std::cout << "NBB " << NMBB << "\n";
    std::cout << "WCET " << WCET << "\n";

    for (unsigned i = 0; i < NMBB; i++) {

        MachineBasicBlock* MBB;
        uint32_t count;
        uint32_t id;

        memcpy(&id, buffer, sizeof (uint32_t));

        // skip irrelevant data
        buffer += 5 * sizeof (uint32_t);

        // read pointer to the MBB
        memcpy(&MBB, buffer, sizeof (uint64_t));
        buffer += sizeof (uint64_t);

        memcpy(&count, buffer, sizeof (uint32_t));
        buffer += sizeof (uint32_t);

        //std::cout << ">> " << MBB << ": " << id << "\n";

        if (MBB) {
            //std::cout << "MBB ID " << MBB-> getFullName() << "\n";
            //std::cout << "Count " << count << "\n";

            std::map<const MachineBasicBlock*, unsigned>::iterator FreqIT;

            FreqIT = MBBFreq.find(MBB);

            if (FreqIT == MBBFreq.end()) {
                errs() << "error with mbb count increment (possible wrong mbb pointer) \n";
                llvm_unreachable("error");
            }

            FreqIT->second += count;
            //FreqIT = MBBFreq.find(MBB);
            //std::cout << "hashed count " << FreqIT->second << "\n";
        }
    }
}

bool NewTargetWCETEstimator::initializeAsmPrinter(NewTargetAsmPrinter* asmPrinter) {
    // this is necessary to generate sections
    asmPrinter->OutStreamer.setAutoInitSections(true);
    asmPrinter->OutStreamer.InitStreamer();

    asmPrinter->MMI = MMI_;
    asmPrinter->MMI->AnalyzeModule(M);

    // Initialize TargetLoweringObjectFile.
    const_cast<TargetLoweringObjectFile&> (asmPrinter->getObjFileLowering())
            .Initialize(asmPrinter->OutContext, TM);

    asmPrinter->Mang = new Mangler(asmPrinter->OutContext, *TM.getDataLayout());

    // Allow the target to emit any magic that it wants at the start of the file.
    asmPrinter->EmitStartOfAsmFile(M);

    // Very minimal debug info. It is ignored if we emit actual debug info. If we
    // don't, this at least helps the user find where a global came from.
    if (asmPrinter->MAI->hasSingleParameterDotFile()) {
        // .file "foo.c"
        asmPrinter->OutStreamer.EmitFileDirective(M.getModuleIdentifier());
    }

    GCModuleInfo *MI = MI_;
    assert(MI && "AsmPrinter didn't require GCModuleInfo?");
    for (GCModuleInfo::iterator I = MI->begin(), E = MI->end(); I != E; ++I)
        if (GCMetadataPrinter * MP = asmPrinter->GetOrCreateGCPrinter_(*I))
            MP->beginAssembly(*asmPrinter);

    // Emit module-level inline asm if it exists.
    if (!M.getModuleInlineAsm().empty()) {
        asmPrinter->OutStreamer.AddComment("Start of file scope inline assembly");
        asmPrinter->OutStreamer.AddBlankLine();
        asmPrinter->EmitInlineAsm_(M.getModuleInlineAsm() + "\n");
        asmPrinter->OutStreamer.AddComment("End of file scope inline assembly");
        asmPrinter-> OutStreamer.AddBlankLine();
    }

    // if (asmPrinter->MAI->doesSupportDebugInformation())
    //   asmPrinter->DD = new DwarfDebug(this, &M);

    if (asmPrinter->MAI->getExceptionHandlingType() == asmPrinter->MAI->getExceptionHandlingType()) {
        return false;
    }

    /*
      switch (MAI->getExceptionHandlingType()) {
      case ExceptionHandling::None:
        return false;
      case ExceptionHandling::SjLj:
      case ExceptionHandling::DwarfCFI:
        DE = new DwarfCFIException(this);
        return false;
      case ExceptionHandling::ARM:
        DE = new ARMException(this);
        return false;
      case ExceptionHandling::Win64:
        DE = new Win64Exception(this);
        return false;
      }
     */
    llvm_unreachable("Unknown exception type.");
}

bool NewTargetWCETEstimator::finalizeAsmPrinter(NewTargetAsmPrinter* asmPrinter) {
    // Emit global variables.
    for (Module::const_global_iterator I = M.global_begin(), E = M.global_end();
            I != E; ++I) {
        MCSymbol *GVSym = asmPrinter->Mang->getSymbol(I);
        GVSym->setUndefined();
        asmPrinter->EmitGlobalVariable(I);
    }

    // Emit visibility info for declarations
    for (Module::const_iterator I = M.begin(), E = M.end(); I != E; ++I) {
        const Function &F = *I;
        if (!F.isDeclaration())
            continue;
        GlobalValue::VisibilityTypes V = F.getVisibility();
        if (V == GlobalValue::DefaultVisibility)
            continue;

        MCSymbol *Name = asmPrinter->Mang->getSymbol(&F);
        asmPrinter->EmitVisibility_(Name, V, false);
    }

    // Emit module flags.
    SmallVector<Module::ModuleFlagEntry, 8> ModuleFlags;
    M.getModuleFlagsMetadata(ModuleFlags);
    if (!ModuleFlags.empty())
        asmPrinter->getObjFileLowering().emitModuleFlags(asmPrinter->OutStreamer, ModuleFlags, asmPrinter->Mang, TM);

    /*
      // Finalize debug and EH information.
      if (asmPrinter->DE) {
        {
          NamedRegionTimer T(EHTimerName, DWARFGroupName, TimePassesIsEnabled);
          asmPrinter->DE->EndModule();
        }
        delete DE; DE = 0;
      }
      if (asmPrinter->DD) {
        {
          NamedRegionTimer T(DbgTimerName, DWARFGroupName, TimePassesIsEnabled);
          asmPrinter->DD->endModule();
        }
        delete asmPrinter->DD; asmPrinter->DD = 0;
      }
     */

    // If the target wants to know about weak references, print them all.
    if (asmPrinter->MAI->getWeakRefDirective()) {
        // FIXME: This is not lazy, it would be nice to only print weak references
        // to stuff that is actually used.  Note that doing so would require targets
        // to notice uses in operands (due to constant exprs etc).  This should
        // happen with the MC stuff eventually.

        // Print out module-level global variables here.
        for (Module::const_global_iterator I = M.global_begin(), E = M.global_end();
                I != E; ++I) {
            if (!I->hasExternalWeakLinkage()) continue;
            asmPrinter->OutStreamer.EmitSymbolAttribute(asmPrinter->Mang->getSymbol(I), MCSA_WeakReference);
        }

        for (Module::const_iterator I = M.begin(), E = M.end(); I != E; ++I) {
            if (!I->hasExternalWeakLinkage()) continue;
            asmPrinter->OutStreamer.EmitSymbolAttribute(asmPrinter->Mang->getSymbol(I), MCSA_WeakReference);
        }
    }

    if (asmPrinter->MAI->hasSetDirective()) {
        asmPrinter->OutStreamer.AddBlankLine();
        for (Module::const_alias_iterator I = M.alias_begin(), E = M.alias_end();
                I != E; ++I) {
            MCSymbol *Name = asmPrinter->Mang->getSymbol(I);

            const GlobalValue *GV = I->getAliasedGlobal();
            MCSymbol *Target = asmPrinter->Mang->getSymbol(GV);

            if (I->hasExternalLinkage() || !asmPrinter->MAI->getWeakRefDirective())
                asmPrinter->OutStreamer.EmitSymbolAttribute(Name, MCSA_Global);
            else if (I->hasWeakLinkage())
                asmPrinter->OutStreamer.EmitSymbolAttribute(Name, MCSA_WeakReference);
            else
                assert(I->hasLocalLinkage() && "Invalid alias linkage");

            asmPrinter->EmitVisibility_(Name, I->getVisibility());

            // Emit the directives as assignments aka .set:
            asmPrinter->OutStreamer.EmitAssignment(Name,
                    MCSymbolRefExpr::Create(Target, asmPrinter->OutContext));
        }
    }

    GCModuleInfo *MI = MI_;
    assert(MI && "AsmPrinter didn't require GCModuleInfo?");
    for (GCModuleInfo::iterator I = MI->end(), E = MI->begin(); I != E;)
        if (GCMetadataPrinter * MP = asmPrinter->GetOrCreateGCPrinter_(*--I))
            MP->finishAssembly(*asmPrinter);

    // If we don't have any trampolines, then we don't require stack memory
    // to be executable. Some targets have a directive to declare this.
    Function *InitTrampolineIntrinsic = M.getFunction("llvm.init.trampoline");
    if (!InitTrampolineIntrinsic || InitTrampolineIntrinsic->use_empty())
        if (const MCSection * S = asmPrinter->MAI->getNonexecutableStackSection(asmPrinter->OutContext))
            asmPrinter->OutStreamer.SwitchSection(S);

    // Allow the target to emit any magic that it wants at the end of the file,
    // after everything else has gone out.
    asmPrinter->EmitEndOfAsmFile(M);

    delete asmPrinter->Mang;
    asmPrinter->Mang = 0;
    asmPrinter->MMI = 0;

    asmPrinter->OutStreamer.Finish();
    asmPrinter->OutStreamer.reset();

    return false;
}



