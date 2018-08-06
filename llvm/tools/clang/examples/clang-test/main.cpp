//===-- examples/clang-interpreter/main.cpp - Clang C Interpreter Example -===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "clang/CodeGen/CodeGenAction.h"
#include "llvm/CodeGen/CommandFlags.h"
#include "llvm/CodeGen/Passes.h"
#include "clang/Basic/DiagnosticOptions.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Tool.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/FrontendDiagnostic.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "llvm/ADT/OwningPtr.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Pass.h"
#include "llvm/PassManager.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Target/TargetLibraryInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Module.h"

using namespace clang;
using namespace clang::driver;
using namespace llvm;


//---------------------------------------------------

namespace {
  struct Hello : public FunctionPass {
    static char ID;
    Hello() : FunctionPass(ID) {}

    virtual bool runOnFunction(Function &F) {
      errs() << "Hello: ";
      errs().write_escaped(F.getName()) << '\n';
      return false;
    }
  };
}

char Hello::ID = 0;
static RegisterPass<Hello> X("hello", "Hello World Pass", false, false);

//---------------------------------------------------




static cl::opt<std::string>
InputFilename(cl::Positional, cl::desc("<input bitcode>"), cl::init("-"));

static cl::opt<std::string>
OutputFilename("o", cl::desc("Output filename"), cl::value_desc("filename"));

// This function isn't referenced outside its translation unit, but it
// can't use the "static" keyword because its address is used for
// GetMainExecutable (since some platforms don't support taking the
// address of main, and some platforms can't implement GetMainExecutable
// without being given the address of a function in the main executable).
llvm::sys::Path GetExecutablePath(const char *Argv0) {
  // This just needs to be some symbol in the binary; C++ doesn't
  // allow taking the address of ::main however.
  void *MainAddr = (void*) (intptr_t) GetExecutablePath;
  return llvm::sys::Path::GetMainExecutable(Argv0, MainAddr);
}


// GetFileNameRoot - Helper function to get the basename of a filename.
static inline std::string
GetFileNameRoot(const std::string &InputFilename) {
  std::string IFN = InputFilename;
  std::string outputFilename;
  int Len = IFN.length();
  if ((Len > 2) &&
      IFN[Len-3] == '.' &&
      ((IFN[Len-2] == 'b' && IFN[Len-1] == 'c') ||
       (IFN[Len-2] == 'l' && IFN[Len-1] == 'l'))) {
    outputFilename = std::string(IFN.begin(), IFN.end()-3); // s/.bc/.s/
  } else {
    outputFilename = IFN;
  }
  return outputFilename;
}


static tool_output_file *GetOutputStream(const char *TargetName,
                                         Triple::OSType OS,
                                         const char *ProgName) {
  // If we don't yet have an output filename, make one.
  if (OutputFilename.empty()) {
    if (InputFilename == "-")
      OutputFilename = "-";
    else {
      OutputFilename = GetFileNameRoot(InputFilename);

      switch (FileType) {
      case TargetMachine::CGFT_AssemblyFile:
        if (TargetName[0] == 'c') {
          if (TargetName[1] == 0)
            OutputFilename += ".cbe.c";
          else if (TargetName[1] == 'p' && TargetName[2] == 'p')
            OutputFilename += ".cpp";
          else
            OutputFilename += ".s";
        } else
          OutputFilename += ".s";
        break;
      case TargetMachine::CGFT_ObjectFile:
        if (OS == Triple::Win32)
          OutputFilename += ".obj";
        else
          OutputFilename += ".o";
        break;
      case TargetMachine::CGFT_Null:
        OutputFilename += ".null";
        break;
      }
    }
  }

  // Decide if we need "binary" output.
  bool Binary = true;
  switch (FileType) {
  case TargetMachine::CGFT_AssemblyFile:
    break;
  case TargetMachine::CGFT_ObjectFile:
  case TargetMachine::CGFT_Null:
    Binary = true;
    break;
  }

  // Open the file.
  std::string error;
  unsigned OpenFlags = 0;
  if (Binary) OpenFlags |= raw_fd_ostream::F_Binary;
  tool_output_file *FDOut = new tool_output_file(OutputFilename.c_str(), error,
                                                 OpenFlags);
  if (!error.empty()) {
    errs() << error << '\n';
    delete FDOut;
    return 0;
  }

  return FDOut;
}

static int Execute(llvm::Module *Mod, const char **argv, char * const *envp) {

  //SMDiagnostic Err;
  Triple TheTriple;

   // Initialize targets first, so that --version shows registered targets.
  LLVMInitializeNewTargetTargetInfo();
  LLVMInitializeNewTargetTarget();
  LLVMInitializeNewTargetTargetMC();
  LLVMInitializeNewTargetAsmPrinter();
  
  
  // Initialize codegen and IR passes used by llc so that the -print-after,
  // -print-before, and -stop-after options work.
  PassRegistry *Registry = PassRegistry::getPassRegistry();
  initializeCore(*Registry);
  initializeCodeGen(*Registry);
  initializeLoopStrengthReducePass(*Registry);
  initializeLowerIntrinsicsPass(*Registry);
  initializeUnreachableBlockElimPass(*Registry);
  
  // set target as newtarget
  TheTriple = Triple("newtarget");
  
  if (TheTriple.getTriple().empty()){
	   errs() << "Triple locating error:" << "\n";
  } 
  
  // Get the newtarget specific parser.
  std::string Error;
  const Target *TheTarget = TargetRegistry::lookupTarget("newtarget", TheTriple, Error);
  if (!TheTarget) {
    errs() << ": " << Error;
    return 1;
  }	  
  
  // set module triple
  Mod->setTargetTriple(TheTriple.getTriple());
  
  // define codegen level
  CodeGenOpt::Level OLvl = CodeGenOpt::Default;
  
  // Package up features to be passed to target/subtarget
  std::string FeaturesStr;
  
  // Target options
  llvm::TargetOptions Options;
  
  std::auto_ptr<TargetMachine>
    target(TheTarget->createTargetMachine(TheTriple.getTriple(),
                                          MCPU, FeaturesStr, Options,
                                          RelocModel, CMModel, OLvl));
  assert(target.get() && "Could not allocate target machine!");
  TargetMachine &Target = *target.get(); 
  
  // Figure out where we are going to send the output.
  OwningPtr<tool_output_file> Out
    (GetOutputStream(TheTarget->getName(), TheTriple.getOS(), argv[0]));
  if (!Out) return 1;
  
  // Build up all of the passes that we want to do to the module.
  PassManager PM;

  // Add intenal analysis passes from the target machine.
  Target.addAnalysisPasses(PM);

  // Add the target data from the target machine
  const DataLayout *TD = Target.getDataLayout();
  PM.add(new DataLayout(*TD));
  
 /* 
  // TODO verificar isso
  //Mod->setDataLayout(TD);
  
  // Override default to generate verbose assembly.
  Target.setAsmVerbosityDefault(true);

  formatted_raw_ostream FOS(Out->os()); 
  
  AnalysisID StartAfterID = 0;
  AnalysisID StopAfterID = 0;

  // Ask the target to add backend passes as necessary.
  if (Target.addPassesToEmitFile(PM, FOS, FileType, true,
                                   StartAfterID, StopAfterID)) {
	  errs() << "target does not support generation of this"
             << " file type!\n";
      return 1;
  }
  */
  PM.add(new Hello());
  
  PM.run(*Mod);
  //PM.run(*Mod);
  
  // Declare success.
  //Out->keep();
  
  //Mod->dump();
  
  
  //PassManager PM2;
 // PM2.add(new DataLayout(*TD));
  
  //LLVMTargetMachine* LLVMTarget = static_cast<LLVMTargetMachine*>(&Target);
  
  //TargetPassConfig* TPM =  LLVMTarget->createPassConfig(PM2);
  
  //TPM->addPreEmitPass();
  //PM2.run(*Mod);
  

  return 0;
}

int main(int argc, const char **argv, char * const *envp) {
  void *MainAddr = (void*) (intptr_t) GetExecutablePath;
  llvm::sys::Path Path = GetExecutablePath(argv[0]);
  IntrusiveRefCntPtr<DiagnosticOptions> DiagOpts = new DiagnosticOptions();
  TextDiagnosticPrinter *DiagClient =
    new TextDiagnosticPrinter(llvm::errs(), &*DiagOpts);

  IntrusiveRefCntPtr<DiagnosticIDs> DiagID(new DiagnosticIDs());
  DiagnosticsEngine Diags(DiagID, &*DiagOpts, DiagClient);
  Driver TheDriver(Path.str(), llvm::sys::getProcessTriple(), "a.out", Diags);
  TheDriver.setTitle("clang test");

  // FIXME: This is a hack to try to force the driver to do something we can
  // recognize. We need to extend the driver library to support this use model
  // (basically, exactly one input, and the operation mode is hard wired).
  SmallVector<const char *, 16> Args(argv, argv + argc);
  Args.push_back("-fsyntax-only");
  OwningPtr<Compilation> C(TheDriver.BuildCompilation(Args));
  if (!C)
    return 0;

  // FIXME: This is copied from ASTUnit.cpp; simplify and eliminate.

  // We expect to get back exactly one command job, if we didn't something
  // failed. Extract that job from the compilation.
  const driver::JobList &Jobs = C->getJobs();
  if (Jobs.size() != 1 || !isa<driver::Command>(*Jobs.begin())) {
    SmallString<256> Msg;
    llvm::raw_svector_ostream OS(Msg);
    C->PrintJob(OS, C->getJobs(), "; ", true);
    Diags.Report(diag::err_fe_expected_compiler_job) << OS.str();
    return 1;
  }

  const driver::Command *Cmd = cast<driver::Command>(*Jobs.begin());
  if (llvm::StringRef(Cmd->getCreator().getName()) != "clang") {
    Diags.Report(diag::err_fe_expected_clang_command);
    return 1;
  }

  // Initialize a compiler invocation object from the clang (-cc1) arguments.
  const driver::ArgStringList &CCArgs = Cmd->getArguments();
  OwningPtr<CompilerInvocation> CI(new CompilerInvocation);
  CompilerInvocation::CreateFromArgs(*CI,
                                     const_cast<const char **>(CCArgs.data()),
                                     const_cast<const char **>(CCArgs.data()) +
                                       CCArgs.size(),
                                     Diags);

  // Show the invocation, with -v.
  if (CI->getHeaderSearchOpts().Verbose) {
    llvm::errs() << "clang invocation:\n";
    C->PrintJob(llvm::errs(), C->getJobs(), "\n", true);
    llvm::errs() << "\n";
  }

  // FIXME: This is copied from cc1_main.cpp; simplify and eliminate.

  // Create a compiler instance to handle the actual work.
  CompilerInstance Clang;
  Clang.setInvocation(CI.take());

  // Create the compilers actual diagnostics engine.
  Clang.createDiagnostics();
  if (!Clang.hasDiagnostics())
    return 1;

  // Infer the builtin include path if unspecified.
  if (Clang.getHeaderSearchOpts().UseBuiltinIncludes &&
      Clang.getHeaderSearchOpts().ResourceDir.empty())
    Clang.getHeaderSearchOpts().ResourceDir =
      CompilerInvocation::GetResourcesPath(argv[0], MainAddr);

  // Create and execute the frontend to generate an LLVM bitcode module.
  OwningPtr<CodeGenAction> Act(new EmitLLVMOnlyAction());
  if (!Clang.ExecuteAction(*Act))
    return 1;

  int Res = 255;
  if (llvm::Module *Module = Act->takeModule())
    Res = Execute(Module, argv, envp);

  // Shutdown.

  llvm::llvm_shutdown();

  return Res;
}
