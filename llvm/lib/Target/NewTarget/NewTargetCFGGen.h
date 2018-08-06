#include "NewTarget.h"
#include "NewTargetInstrInfo.h"
#include "NewTargetMachine.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/CodeGen/MachineBranchProbabilityInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
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
#include <iomanip>

#include <iostream>
#include <list>

static int IndexCount = 0;

namespace {

    using namespace llvm;

    typedef MachineBasicBlock::iterator Iter;
    typedef MachineBasicBlock::reverse_iterator ReverseIter;
    typedef SmallDenseMap<MachineBasicBlock*, MachineInstr*, 2> BB2BrMap;

    // Class used to "inline" function calls inside the CFG

    class CFGColapseMarker {
    public:
        StringRef TargetFunction;
        StringRef ParentFunction;
        int InstrIndex;
        bool EndMBB;

        CFGColapseMarker(StringRef FunctionName_,
                StringRef ParentFunction_, int InstrIndex_, bool EndMBB_)
        : TargetFunction(FunctionName_), ParentFunction(ParentFunction_),
        InstrIndex(InstrIndex_), EndMBB(EndMBB_) {
        }
    };

    // Class to represent a CFG node, with lists of successors and
    // predecessors

    class CFGNode {
    public:

        enum SucessorType {
            PURE_FALLTHROUGH = 0,
            CONDITIONAL_FALLTHROUGH,
            CONDITIONAL_FALLTHROUGH_PRELOAD,
            CONDITIONAL,
            CONDITIONAL_PRELOAD,
            JUMP,
            CALL,
            RET
        };

        int Index;
        StringRef ParentName;
        std::list<int> SucessorsIndex;
        std::list<class CFGNode*> Sucessors;
        std::list<unsigned> SucessorType;
        std::list<int> PredecessorsIndex;
        std::list<class CFGNode*> Predecessors;
        std::list<class CFGColapseMarker*> ColapseMarkers;
        int FirstInst;
        int LastInst;
        const MachineBasicBlock* OrigBB;
        unsigned int count;

        CFGNode(int Index_, StringRef ParentName_, const MachineBasicBlock* BB)
        : Index(Index_), ParentName(ParentName_), FirstInst(0), LastInst(0) {
            OrigBB = BB;
        }

        // Copy constructor with a pointer.  Although the successors and predecessors
        // are copied integrally, they must be corrected to the nodes of the new graph

        CFGNode(CFGNode* other)
        : Index(other->Index), ParentName(other->ParentName),
        Sucessors(other->Sucessors), SucessorType(other->SucessorType), Predecessors(other->Predecessors),
        FirstInst(other->FirstInst), LastInst(other->LastInst) {
            OrigBB = other->OrigBB;
        }

        // To inline functions, we must break nodes after the function call, and pass
        // some colapse markers to the botton node.

        CFGNode* SplitNode(int InstrFrontier, bool endMBB) {

            // NULL to not account profile twice in the profiler.
            CFGNode* Next;
            unsigned NextType;

            if (endMBB) {

                std::list<CFGNode*>::iterator IT = Sucessors.begin();
                Next = Sucessors.front();
                while (IT != Sucessors.end()) {

                    CFGNode* SuccNode = *IT;
                    if (SuccNode == Next) {
                        IT = Sucessors.erase(IT);
                    } else {
                        IT++;
                    }
                }
                std::list<unsigned>::iterator ITType = SucessorType.begin();
                NextType = SucessorType.front();
                while (ITType != SucessorType.end()) {

                    unsigned SuccNodeType = *ITType;
                    if (SuccNodeType == NextType) {
                        ITType = SucessorType.erase(ITType);
                    } else {
                        ITType++;
                    }
                }

                IT = Next->Predecessors.begin();

                while (IT != Next->Predecessors.end()) {

                    CFGNode* PredNode = *IT;

                    if (PredNode == Next) {
                        IT = Next->Predecessors.erase(IT);
                    } else {
                        IT++;
                    }
                }

            } else {
                Next = new CFGNode(IndexCount++, ParentName, NULL);

                Next->FirstInst = InstrFrontier + 1;
                Next->LastInst = LastInst;

                LastInst = InstrFrontier;
            }

            //std::copy(Sucessors.begin(),
            //		  Sucessors.end(),
            //		  Next->Sucessors.begin());
            std::list<CFGNode*>::iterator IT1 = Sucessors.begin();
            while (IT1 != Sucessors.end()) {
                CFGNode* SuccNode = *IT1;
                IT1 = Sucessors.erase(IT1);
                Next->Sucessors.push_back(SuccNode);
            }
            std::list<unsigned>::iterator ITType = SucessorType.begin();
            NextType = SucessorType.front();
            while (ITType != SucessorType.end()) {

                unsigned SuccNodeType = *ITType;
                ITType = SucessorType.erase(ITType);
                Next->SucessorType.push_back(SuccNodeType);
            }


            //Sucessors.erase(Sucessors.begin(), Sucessors.end());

            std::list<CFGColapseMarker*>::iterator IT = ColapseMarkers.begin();

            while (IT != ColapseMarkers.end()) {
                CFGColapseMarker* Marker = *IT;
                if (Marker->InstrIndex > LastInst) {
                    IT = ColapseMarkers.erase(IT);
                    Next->ColapseMarkers.push_back(Marker);
                } else {
                    IT++;
                }
            }


            //std::copy(ColapseMarkers.begin(),
            //		ColapseMarkers.end(),
            //		  Next->ColapseMarkers.begin());


            return Next;
        }
    };

    // CFGFunction holds a collection of nodes of a function

    class CFGFunction {
    public:
        StringRef Name;
        std::list<class CFGNode*> Nodes;

        CFGFunction(StringRef Name_)
        : Name(Name_) {
        }

        ~CFGFunction() {
            std::list<class CFGNode*>::const_iterator IT;
            for (IT = Nodes.begin(); IT != Nodes.end(); ++IT) {
                CFGNode* Node = *IT;
                delete Node;
            }
        }

        // TODO: implement this as a copy constructor.
        // A map is used to map nodes from original graph to
        // new grap

        CFGFunction* Duplicate() {
            CFGFunction* Function = new CFGFunction(Name);
            std::list<CFGNode*>::const_iterator IT;

            std::map<CFGNode*, CFGNode*> NewNodesMap;

            for (IT = Nodes.begin(); IT != Nodes.end(); IT++) {
                CFGNode* Node = *IT;
                CFGNode* NewNode = new CFGNode(Node);
                NewNode->Index = IndexCount++;
                // insert the new node pointer using the old node pointer
                // as key
                NewNodesMap.insert(std::pair<CFGNode*, CFGNode*>(Node, NewNode));
                Function->Nodes.push_back(NewNode);
            }

            // Fix the pointers of the new grap. CFGNode copy successors and
            // predecessors integrally, so we must use these values to get the
            // new pointers.
            for (IT = Function->Nodes.begin(); IT != Function->Nodes.end(); IT++) {
                CFGNode* Node = *IT;

                // First for successors
                for (std::list<CFGNode*>::iterator SI = Node->Sucessors.begin(),
                        SE = Node->Sucessors.end();
                        SI != SE; ++SI) {
                    CFGNode* OldNode = *SI;
                    //CFGNode* NewNode;

                    std::map<CFGNode*, CFGNode*>::iterator ITMap;
                    ITMap = NewNodesMap.find(OldNode);
                    *SI = ITMap->second;
                }

                // Nest for predecessors
                for (std::list<CFGNode*>::iterator PI = Node->Predecessors.begin(),
                        PE = Node->Predecessors.end();
                        PI != PE; ++PI) {
                    CFGNode* OldNode = *PI;
                    //CFGNode* NewNode;

                    std::map<CFGNode*, CFGNode*>::iterator ITMap;
                    ITMap = NewNodesMap.find(OldNode);
                    *PI = ITMap->second;
                }
            }

            return Function;
        }

        // For a recently constructed graph (runOnFunction), we only have indexes
        // of successors and predecessors. We must find the links (pointers).

        void Fixup() {

            std::list<CFGNode*>::const_iterator NI;
            for (NI = Nodes.begin(); NI != Nodes.end(); ++NI) {
                CFGNode* Node = *NI;
                for (std::list<int>::const_iterator SI = Node->SucessorsIndex.begin(),
                        SE = Node->SucessorsIndex.end();
                        SI != SE; ++SI) {
                    int index = *SI;
                    CFGNode* CFGSucc = FindNode(index);
                    Node->Sucessors.push_back(CFGSucc);

                }

                // we dont't need successors index anymore
                Node->SucessorsIndex.erase(Node->SucessorsIndex.begin(), Node->SucessorsIndex.end());

                for (std::list<int>::const_iterator PI = Node->PredecessorsIndex.begin(),
                        PE = Node->PredecessorsIndex.end();
                        PI != PE; ++PI) {
                    int index = *PI;
                    CFGNode* CFGPred = FindNode(index);
                    Node->Predecessors.push_back(CFGPred);
                }

                // we also dont't need predecessors
                Node->PredecessorsIndex.erase(Node->PredecessorsIndex.begin(), Node->PredecessorsIndex.end());
            }
        }

        CFGNode* FindNode(int Index) {

            std::list<CFGNode*>::const_iterator iterator;
            for (iterator = Nodes.begin(); iterator != Nodes.end(); ++iterator) {
                CFGNode* Node = *iterator;

                if (Node->Index == Index) {
                    return Node;
                }
            }
            return NULL;
        }

        // It is good to have linear indexes on a graph

        void LinearizeNodes() {
            int count = 0;

            std::list<CFGNode*>::const_iterator iterator;
            for (iterator = Nodes.begin(); iterator != Nodes.end(); ++iterator) {
                CFGNode* Node = *iterator;
                Node->Index = count++;
            }
        }
    };
}

namespace llvm {

    class NewTargetCFGGen {
    public:

        NewTargetCFGGen() : ActualInstruction(0) {
        };
        virtual ~NewTargetCFGGen();

        void processMachineFunction(MachineFunction &F);
        void dump(const char* cfgFilename, const char* dotFilename);
    private:
        void processMachineBasicBlock(MachineBasicBlock &MBB, bool recs);
        void splitMBB(MachineBasicBlock *MBB, MachineFunction *MF);
        std::list<class CFGFunction*> Functions;
        int ActualInstruction;
    };


}
