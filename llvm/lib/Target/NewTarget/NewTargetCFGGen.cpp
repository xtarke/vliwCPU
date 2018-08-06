
#include "NewTargetCFGGen.h"
#include "llvm/MC/MCSymbol.h"
#include "NewTarget.h"
#include <cstdio>ore bui  
#include <sstream>

using namespace llvm;

enum predictor {
    NORMAL,
    CLAIRVOYANT,
    PESSIMISTIC
};

static unsigned ActualType = NORMAL;

static void GlueNodesAndFunction(CFGFunction* Function,
        CFGNode* NodeA, CFGNode* NodeB);

static bool isNotPredicted(MachineBasicBlock* MBB) {

    std::set<MachineBasicBlock*>::iterator IT;

    IT = llvm::NotPredictedMBBs.find(MBB);

    if (IT != llvm::NotPredictedMBBs.end()) {
        //std::cout << "Está na lista\n";
        return true;
    }
    //std::cout << "Não está na lista\n";
    return false;
}

static int32_t getRecDepth(const MachineFunction* MF) {

    int32_t depth = 0;
    const Function* parent = MF->getFunction();
    std::map<const Function*, int>::const_iterator IT;

    IT = llvm::RecursionDepths.find(parent);

    if (IT != llvm::RecursionDepths.end()) {
        int32_t actualDepth = IT->second;
        depth = actualDepth;
    }
    return depth;
}

void NewTargetCFGGen::processMachineFunction(MachineFunction &F) {

    F.RenumberBlocks();

    for (MachineFunction::iterator I = F.begin(), E = F.end(); I != E;) {
        splitMBB(I++, &F);
    }

    int depth = getRecDepth(&F);

    // start of recursion management
    if (depth > 0) {
        //std::cout << "recursive function found\n";

        int ActualInstructionOld = ActualInstruction;

        CFGFunction* RecFunction = new CFGFunction(F.getName());
        Functions.push_back(RecFunction);

        for (MachineFunction::iterator FI = F.begin(), FE = F.end();
                FI != FE; ++FI) {
            processMachineBasicBlock(*FI, true);
        }

        int ActualInstructionNew = ActualInstruction;

        RecFunction->Fixup();

        IndexCount += RecFunction->Nodes.size();

        for (int i = 0; i < depth; i++) {

            std::list<CFGNode*>::const_iterator NI;

            int size = RecFunction->Nodes.size();

            NI = RecFunction->Nodes.begin();

            for (int i = 0; i < size; i++) {

                CFGNode* Node = *NI;
                NI++;

                std::list<CFGColapseMarker*>::iterator CI;
                std::list<CFGColapseMarker*>* Markers = &Node->ColapseMarkers;
                CI = Markers->begin();

                while (CI != Markers->end()) {

                    CFGColapseMarker* Marker = *CI;
                    if (Marker->TargetFunction.equals(RecFunction->Name)) {

                        // create a new function
                        ActualInstruction = ActualInstructionOld;
                        CFGFunction* Rec2Function = new CFGFunction(F.getName());
                        Functions.push_back(Rec2Function);

                        // populate with basic blocks
                        for (MachineFunction::iterator FI = F.begin(), FE = F.end();
                                FI != FE; ++FI) {
                            processMachineBasicBlock(*FI, false);

                        }

                        Rec2Function->Fixup();

                        Functions.pop_back();

                        IndexCount += Rec2Function->Nodes.size();

                        //puts(Rec2Function->Name.data());
                        Markers->erase(CI);

                        CFGNode* NodeNext = Node->SplitNode(Marker->InstrIndex, Marker->EndMBB);
                        NodeNext->Index = IndexCount++;
                        //////////CFGFunction* FuncCopy = FuncToColapse->Duplicate();

                        if (!Marker->EndMBB) {
                            RecFunction->Nodes.push_back(NodeNext);
                        }

                        std::list<CFGNode*>::iterator ITemp = RecFunction->Nodes.end();
                        ITemp--;

                        RecFunction->Nodes.insert(ITemp, Rec2Function->Nodes.begin(), Rec2Function->Nodes.end());

                        GlueNodesAndFunction(Rec2Function, Node, NodeNext);

                        delete Marker;

                        break;
                    } else {
                        ++CI;
                    }
                }

            }

            //RecFunction = Rec2Function;
        }
        //while(1);

        std::list<CFGNode*>::const_iterator NI;
        for (NI = RecFunction->Nodes.begin(); NI != RecFunction->Nodes.end(); ++NI) {
            CFGNode* Node = *NI;

            std::list<CFGColapseMarker*>::iterator CI;
            std::list<CFGColapseMarker*>* Markers = &Node->ColapseMarkers;
            CI = Markers->begin();
            //Markers->clear();

            while (CI != Markers->end()) {
                CFGColapseMarker* Marker = *CI;
                if (Marker->TargetFunction.equals(RecFunction->Name)) {
                    Markers->erase(CI);
                    delete Marker;

                    break;
                } else {
                    ++CI;
                }
            }
        }

        ActualInstruction = ActualInstructionNew;
        // end of recursion management
    } else {


        CFGFunction* ActualFunction = new CFGFunction(F.getName());
        Functions.push_back(ActualFunction);

        //for (MachineFunction::iterator I = F.begin(), E = F.end(); I != E;) {
        //    splitMBB(I++, &F);
        //}

        for (MachineFunction::iterator FI = F.begin(), FE = F.end();
                FI != FE; ++FI) {
            processMachineBasicBlock(*FI, false);
        }

        IndexCount += ActualFunction->Nodes.size();

        // here we have only sucessors indexes. we must fixup this
        ActualFunction->Fixup();
    }
}

// Colapse is necessary to inline all function calls to have
// only one CFG to the entire program

static bool needColapse(const MachineInstr * MI) {


    switch (MI->getOpcode()) {
        case NewTarget::CALL:
            return true;
            break;
            //case NewTarget::GOTOLr:
            //    return true;
            //    break;
            //case NewTarget::JR:
            //	return true;
            //	break;
    }

    return false;
}

/// Iterate over list of Br's operands and search for a MachineBasicBlock
/// operand.

static MachineBasicBlock * getTargetMBB(const MachineInstr & Br) {
    for (unsigned I = 0, E = Br.getDesc().getNumOperands(); I < E; ++I) {
        const MachineOperand &MO = Br.getOperand(I);

        if (MO.isMBB())
            return MO.getMBB();
    }
    //Br.dump();
    assert(false && "This instruction does not have an MBB operand.");
    return 0;
}

// Traverse the list of instructions backwards until a non-debug instruction is
// found or it reaches E.

static ReverseIter getNonDebugInstr(ReverseIter B, ReverseIter E) {
    for (; B != E; ++B)
        if (!B->isDebugValue())
            return B;

    return E;
}

static CFGFunction * FindNonColapsableFunction(std::list<CFGFunction*>* List) {

    std::list<CFGFunction*>::const_iterator FI;
    for (FI = List->begin(); FI != List->end(); ++FI) {
        CFGFunction* Func = *FI;

        // dont extract main
        if (Func->Name.equals(StringRef("__main"))) {
            continue;
        }

        int Colapses = 0;

        std::list<CFGNode*>::const_iterator NI;
        for (NI = Func->Nodes.begin(); NI != Func->Nodes.end(); ++NI) {
            CFGNode* Node = *NI;
            Colapses += Node->ColapseMarkers.size();
        }
        if (Colapses == 0) {
            return Func;
        }
    }
    return NULL;
}

static void GlueNodesAndFunction(CFGFunction* Function,
        CFGNode* NodeA, CFGNode * NodeB) {

    std::list<CFGNode*>::iterator NI;

    for (NI = Function->Nodes.begin(); NI != Function->Nodes.end(); ++NI) {
        CFGNode* Node = *NI;
        if (Node->Predecessors.empty()) {
        }
        if (Node->Predecessors.empty() && Node->ParentName.equals(Function->Name)) {
            NodeA->Sucessors.push_back(Node);
            Node->Predecessors.push_back(NodeA);
            NodeA->SucessorType.push_back(CFGNode::CALL);
            assert(NodeA->Sucessors.size() == NodeA->SucessorType.size());
        }
        if (Node->Sucessors.empty()) {
            //nothing
        }
        // sucessors empty
        if ((Node->Sucessors.empty() ||
                // or the last node jumps or branches to itself
                ((Node->Sucessors.size() == 1) && (Node->Sucessors.front() == Node)))
                // and the name matches
                && Node->ParentName.equals(Function->Name)) {
            NodeB->Predecessors.push_back(Node);
            Node->Sucessors.push_back(NodeB);

            Node->SucessorType.push_back(CFGNode::RET);
            assert(Node->Sucessors.size() == Node->SucessorType.size());
        }
    }
}

static void InlineFunction(std::list<CFGFunction*>* List, CFGFunction * FuncToColapse) {

    std::list<CFGFunction*>::const_iterator FI;
    for (FI = List->begin(); FI != List->end(); ++FI) {
        CFGFunction* Func = *FI;

        std::list<CFGNode*>::iterator NI;
        for (NI = Func->Nodes.begin(); NI != Func->Nodes.end(); ++NI) {
            CFGNode* Node = *NI;
            if (Node->ColapseMarkers.size() == 0) {
                continue;
            }

            std::list<CFGColapseMarker*>* Markers = &Node->ColapseMarkers;
            std::list<CFGColapseMarker*>::iterator CI = Markers->begin();

            while (CI != Markers->end()) {
                CFGColapseMarker* Marker = *CI;
                if (Marker->TargetFunction.equals(FuncToColapse->Name)) {
                    Markers->erase(CI);

                    CFGNode* NodeNext = Node->SplitNode(Marker->InstrIndex, Marker->EndMBB);
                    NodeNext->Index = IndexCount++;
                    CFGFunction* FuncCopy = FuncToColapse->Duplicate();

                    if (!Marker->EndMBB) {
                        Func->Nodes.push_back(NodeNext);
                    }

                    std::list<CFGNode*>::iterator ITemp = Func->Nodes.end();
                    ITemp--;
                    Func->Nodes.insert(ITemp, FuncCopy->Nodes.begin(), FuncCopy->Nodes.end());

                    GlueNodesAndFunction(FuncCopy, Node, NodeNext);

                    delete Marker;

                    break;
                } else {
                    ++CI;
                }
            }
        }
    }
}

static int32_t getLoopBound(const MachineBasicBlock * MBB) {

    int32_t count = ~0;
    const BasicBlock* parent = MBB->getBasicBlock();
    std::map<const BasicBlock*, int>::const_iterator IT;

    IT = llvm::LoopBounds.find(parent);

    if (IT != llvm::LoopBounds.end()) {
        int32_t actualCount = IT->second;
        if (actualCount == 0) {
            llvm_unreachable("loop bound retrive failed");
        } else {
            count = actualCount;
        }
    }
    return count;
}

static void WriteCFGRaw(raw_fd_ostream &File, CFGFunction * Main) {

    std::list<CFGNode*>* List = &Main->Nodes;
    uint32_t NNodes = List->size();
    uint32_t WCET = 0;

    // write the number of nodes
    File.write((const char*) &NNodes, sizeof (uint32_t));
    // write wcet = 0
    File.write((const char*) &WCET, sizeof (uint32_t));

    std::list<CFGNode*>::const_iterator NI;

    //write nodes
    for (NI = List->begin(); NI != List->end(); ++NI) {
        CFGNode* Node = *NI;

        uint32_t NodeIndex = Node->Index;
        uint32_t NodeNSucessors = Node->Sucessors.size();
        uint32_t FirstInst = Node->FirstInst;
        uint32_t LastInst = Node->LastInst;
        uint64_t OrigBB = (uint64_t) Node->OrigBB;
        uint32_t Count = 0;
        int32_t loopBound = ~0;
        char buffer_file[100];
        memset(buffer_file, 0, 100);

        if (Node->OrigBB) {

            if (Node->OrigBB->getBasicBlock() != NULL) {
                loopBound = getLoopBound(Node->OrigBB);
                //std::cout << Node->OrigBB->getBasicBlock()->getParent()->getName().data() << ":" <<  Node->OrigBB->getBasicBlock()->getName().data() << "\n";
                //std::string str(Node->OrigBB->getBasicBlock()->getParent()->getName().data + ":" + Node->OrigBB->getBasicBlock()->getName());
                std::string str;
                if(Node->OrigBB->getBasicBlock()->getParent()->getName().compare("main_app") == 0){
                    str = std::string("main");
                } else {
                    str = std::string(Node->OrigBB->getBasicBlock()->getParent()->getName());
                }
                
                str.append(":");
                str.append(Node->OrigBB->getBasicBlock()->getName());

                std::cout << "Verificando: " << str << "\n";
                if (AllowedToUseProfileInfo.find((BasicBlock*) Node->OrigBB->getBasicBlock()) != AllowedToUseProfileInfo.end()) {
                    strcpy(buffer_file, str.c_str());
                    std::cout << "Autorizado para: " << str << "\n";
                }
            }

        }

        File.write(buffer_file, 100);

        File.write((const char*) &NodeIndex, sizeof (uint32_t));
        File.write((const char*) &NodeNSucessors, sizeof (uint32_t));
        File.write((const char*) &FirstInst, sizeof (uint32_t));
        File.write((const char*) &LastInst, sizeof (uint32_t));
        File.write((const char*) &loopBound, sizeof (int32_t));
        //to get info back later

        File.write((const char*) &OrigBB, sizeof (uint64_t));
        File.write((const char*) &Count, sizeof (uint32_t));
    }

    //write sucessors
    for (NI = List->begin(); NI != List->end(); ++NI) {
        CFGNode* Node = *NI;

        std::list<CFGNode*>::const_iterator SI;
        std::list<unsigned>::const_iterator SIType;
        for (SI = Node->Sucessors.begin(), SIType = Node->SucessorType.begin();
                SI != Node->Sucessors.end();
                ++SI, ++SIType) {
            CFGNode* SNode = *SI;
            unsigned type = *SIType;

            uint32_t NodeSucessorIndex = SNode->Index;

            File.write((const char*) &NodeSucessorIndex, sizeof (uint32_t));
            File.write((const char*) &type, sizeof (unsigned));
        }
    }
}

static void WriteCFG(raw_fd_ostream &File, CFGFunction * Main) {

    File << "digraph CFG {\n";

    File << "\t" << "node [shape=record,width=.1,height=.1];\n";
    std::list<CFGNode*>* List = &Main->Nodes;

    std::list<CFGNode*>::const_iterator NI;
    for (NI = List->begin(); NI != List->end(); ++NI) {
        CFGNode* Node = *NI;

        std::list<CFGNode*>::const_iterator SI;
        std::list<unsigned>::const_iterator SIType;

        int32_t loopBound = ~0;

        if (Node->OrigBB) {
            loopBound = getLoopBound(Node->OrigBB);
        }

        for (SI = Node->Sucessors.begin(), SIType = Node->SucessorType.begin();
                SI != Node->Sucessors.end() && SIType != Node->SucessorType.end();
                ++SI, ++SIType) {
            CFGNode* SNode = *SI;
            unsigned NodeType = *SIType;



            File << "\t\"" << Node->ParentName.data() << "[" << Node->FirstInst
                    << "," << Node->LastInst << "]" << ":" << Node->Index;

            if (loopBound != ~0) {
                File << "\\n header bound: " << loopBound;
            }

            File << "\"" << " -> " <<
                    "\"" << SNode->ParentName.data() << "[" << SNode->FirstInst
                    << "," << SNode->LastInst << "]" << ":" << SNode->Index;

            int32_t loopBoundSucc = ~0;

            if (SNode->OrigBB) {
                loopBoundSucc = getLoopBound(SNode->OrigBB);
                if (loopBoundSucc != ~0) {
                    File << "\\n header bound: " << loopBoundSucc;
                }
            }

            File << "\" ";


            if (NodeType == CFGNode::CONDITIONAL) {
                File << "[label = \"cond\"]";
            } else if (NodeType == CFGNode::CONDITIONAL_FALLTHROUGH) {
                File << "[label = \"cond_ft\"]";
            } else if (NodeType == CFGNode::PURE_FALLTHROUGH) {
                File << "[label = \"ft\"]";
            } else if (NodeType == CFGNode::JUMP) {
                File << "[label = \"jump\"]";
            } else if (NodeType == CFGNode::CALL) {
                File << "[label = \"call\"]";
            } else if (NodeType == CFGNode::RET) {
                File << "[label = \"ret\"]";
            } else if (NodeType == CFGNode::CONDITIONAL_PRELOAD) {
                File << "[label = \"cond_preload\"]";
            } else if (NodeType == CFGNode::CONDITIONAL_FALLTHROUGH_PRELOAD) {
                File << "[label = \"cond_ft_preload\"]";
            }


            File << ";\n";
        }
    }


    File << "}\n";
}

static void ColapseCFG(std::list<CFGFunction*>* List) {
    CFGFunction* Func = NULL;

    Func = FindNonColapsableFunction(List);

    //if(!Func){
    //std::cout << "Is not necessasy colapse\n";
    //}

    while (Func && List->size() > 1) {
        //std::cout << "Found one colapse\n";
        List->remove(Func);
        InlineFunction(List, Func);
        delete Func;
        Func = FindNonColapsableFunction(List);
    }

}

static bool hasBranchPreload(MachineBasicBlock &MBB) {

    //std::cout << "hasBranchPreload: ";

    MachineBasicBlock::iterator PrevMI = MBB.end();
    MachineBasicBlock::iterator PrevPrevMI = MBB.end();
    MachineBasicBlock::iterator PrevPrevPrevMI = MBB.end();


    for (MachineBasicBlock::iterator MI = MBB.begin(), ME = MBB.end();
            MI != ME; ++MI) {

        //MI->dump();
        PrevPrevPrevMI = PrevPrevMI;
        PrevPrevMI = PrevMI;
        PrevMI = MI;
    }

    if (PrevPrevPrevMI == MBB.end()) {
        //std::cout << "no1\n";
        return false;
    }

    if (!PrevPrevPrevMI->isBundle()) {
        //std::cout << "teste\n";
        if (PrevPrevPrevMI->getOpcode() == NewTarget::PRELD) {
            //std::cout << "yes1\n";
            return true;
        }
    } else {
        MachineBasicBlock::instr_iterator MII = PrevPrevPrevMI.getInstrIterator();
        ++MII;
        while (MII != MBB.end() && MII->isInsideBundle()) {
            ++MII;
            if (MII->getOpcode() == NewTarget::PRELD) {
                //std::cout << "yes2\n";
                return true;
            }
        }
    }
    //std::cout << "no2\n";
    return false;
}

void NewTargetCFGGen::processMachineBasicBlock(MachineBasicBlock & MBB, bool recursion_sentitive) {
    //std::cout << "CFGExtractor::runOnMachineBasicBlock: " << MBB.getNumber() << "\n";
    CFGFunction* Function = Functions.back();
    CFGNode* Node = new CFGNode(MBB.getNumber(), MBB.getParent()->getName(), &MBB);
    int Instructions = 0;

    //std::cout << "processing mbb: " << MBB.getNumber() << " ";
    for (MachineBasicBlock::iterator MI = MBB.begin(), ME = MBB.end();
            MI != ME; ++MI) {

        std::list<const MachineInstr*> MIs;

        if (MI->isLabel() || MI->isDebugValue()) {
            continue;
        }


        int bundleSize = 0;
        bool isMBBEnd = false;
        const MachineInstr *MInst;

        MachineBasicBlock::iterator MINext = MI;
        MINext++;

        if (MINext == ME) {
            isMBBEnd = true;
            //std::cout << "============fim de bloco basico\n";
        }

        if (MI->isBundle()) {
            MachineBasicBlock::instr_iterator MII = MI.getInstrIterator();
            ++MII;
            while (MII != MBB.end() && MII->isInsideBundle()) {
                MInst = MII;
                ++MII;
                if (MInst->isDebugValue() || (MInst->getOpcode() == TargetOpcode::IMPLICIT_DEF)) {
                    continue;
                }

                MIs.push_back(MInst);
                bundleSize++;
            }

        } else {
            MIs.push_back(MI);
            if (MI->isBundledWithSucc()) {
                MIs.push_back(MI->getNextNode());
            }
        }

        unsigned Size = MIs.size();
        std::list<const MachineInstr*>::iterator IT = MIs.begin();
        for (unsigned Index = 0; Index < Size; Index++) {
            const MachineInstr* Instr = *IT;
            //Instr->dump();
            if (needColapse(Instr)) {
                //std::cout << " [colapse marker at instr: " << ActualInstruction + Instructions << ":" << isMBBEnd << "] ";

                StringRef name;

                if (Instr->getOperand(0).isSymbol()) {
                    name = Instr->getOperand(0).getSymbolName();
                } else if (Instr->getOperand(0).isGlobal()) {
                    name = Instr->getOperand(0).getGlobal()->getName();
                } else {
                    llvm_unreachable("unknown operand type");
                }

                CFGColapseMarker* CMarker = new CFGColapseMarker(
                        name, MBB.getParent()->getName(), ActualInstruction + Instructions, isMBBEnd);
                Node->ColapseMarkers.push_back(CMarker);
            }
            Instructions++;
            ++IT;
        }

    }

    Function->Nodes.push_back(Node);


    // get successors indexes (pointers come later)
    for (MachineBasicBlock::succ_iterator SI = MBB.succ_begin(), SE = MBB.succ_end();
            SI != SE; ++SI) {
        MachineBasicBlock* MBBSucc = *SI;
        Node->SucessorsIndex.push_back(MBBSucc->getNumber());

        unsigned type;

        if (MBB.isLayoutSuccessor(MBBSucc)) {

            if (MBB.succ_size() > 1) {
                if (hasBranchPreload(MBB)) {
                    type = CFGNode::CONDITIONAL_FALLTHROUGH_PRELOAD;
                } else {
                    if (isNotPredicted(&MBB)) {
                        // penalize not predicted nodes or if it is in 
                        // pessimistic way
                        //std::cout << "aqui\n";

                        type = CFGNode::CONDITIONAL_FALLTHROUGH_PRELOAD;

                        //clairvoyant
                        //type = CFGNode::CONDITIONAL_FALLTHROUGH;   
                    } else {

                        switch (ActualType) {
                            case NORMAL:
                            case CLAIRVOYANT:
                                type = CFGNode::CONDITIONAL_FALLTHROUGH;
                                break;
                            case PESSIMISTIC:
                                type = CFGNode::CONDITIONAL_FALLTHROUGH_PRELOAD;
                                break;
                        }
                    }
                }
            } else {
                type = CFGNode::PURE_FALLTHROUGH;
            }
        } else {
            if (MBB.succ_size() > 1) {
                if (hasBranchPreload(MBB)) {
                    type = CFGNode::CONDITIONAL_PRELOAD;
                } else {
                    // penalize not predicted nodes or if it is in 

                    // pessimistic and normal
                    switch (ActualType) {
                        case NORMAL:
                        case PESSIMISTIC:
                            type = CFGNode::CONDITIONAL;
                            break;
                        case CLAIRVOYANT:
                            type = CFGNode::CONDITIONAL_PRELOAD;
                            break;
                    }
                }
            } else {
                type = CFGNode::JUMP;
            }
        }
        Node->SucessorType.push_back(type);
    }

    // get predecessors indexes also
    for (MachineBasicBlock::pred_iterator PI = MBB.pred_begin(), PE = MBB.pred_end();
            PI != PE; ++PI) {
        MachineBasicBlock* MBBSPred = *PI;
        Node->PredecessorsIndex.push_back(MBBSPred->getNumber());

    }

    Node->FirstInst = ActualInstruction;
    Node->LastInst = ActualInstruction + Instructions - 1;

    //std::cout << "instructions[" << Node->FirstInst << "," << Node->LastInst << "]\n";
    //if(!recursion_sentitive){
    ActualInstruction += Instructions;
    //}


}

void NewTargetCFGGen::splitMBB(MachineBasicBlock *MBB, MachineFunction * MF) {
    ReverseIter End = MBB->rend();
    ReverseIter LastBr = getNonDebugInstr(MBB->rbegin(), End);

    // Return if MBB has no branch instructions.
    if ((LastBr == End) ||
            (!LastBr->isConditionalBranch() && !LastBr->isUnconditionalBranch()))
        return;

    ReverseIter FirstBr = getNonDebugInstr(llvm::next(LastBr), End);

    // MBB has only one branch instruction if FirstBr is not a branch
    // instruction.
    if ((FirstBr == End) ||
            (!FirstBr->isConditionalBranch() && !FirstBr->isUnconditionalBranch()))
        return;

    assert(!FirstBr->isIndirectBranch() && "Unexpected indirect branch found.");

    // Create a new MBB. Move instructions in MBB to the newly created MBB.
    MachineBasicBlock *NewMBB =
            MF->CreateMachineBasicBlock(MBB->getBasicBlock());

    const MachineInstr* branch = &(*FirstBr);

    if (FirstBr->isBundle()) {
        branch = branch->getNextNode();
        while (!(branch->isConditionalBranch() || branch->isUnconditionalBranch())) {
            branch = branch->getNextNode();
        }
        //branch->dump();
    }

    // Insert NewMBB and fix control flow.
    MachineBasicBlock *Tgt = getTargetMBB(*branch);
    NewMBB->transferSuccessors(MBB);
    NewMBB->removeSuccessor(Tgt);
    MBB->addSuccessor(NewMBB);
    MBB->addSuccessor(Tgt);
    MF->insert(llvm::next(MachineFunction::iterator(MBB)), NewMBB);



    NewMBB->splice(NewMBB->end(), MBB, (++LastBr).base(), MBB->end());

    //MBB->dump();
    //NewMBB->dump();
}

void NewTargetCFGGen::dump(const char* cfgFilename, const char* dotFilename) {
    ColapseCFG(&Functions);
    CFGFunction* Main = Functions.front();
    //Main = Main->Duplicate();
    Main->LinearizeNodes();

    //std::list<CFGNode*>* List = &Main->Nodes;

    std::string Filename;
    std::string ErrorInfo;

    // dot
    // Filename = M.getModuleIdentifier() + ".dot";


    raw_fd_ostream FileDot(dotFilename, ErrorInfo);

    if (ErrorInfo.empty()) {
        WriteCFG(FileDot, Main);
    } else {
        errs() << " error opening file for writing!";
        errs() << "\n";
    }

    //raw
    // Filename = M.getModuleIdentifier() + ".cfg";

    raw_fd_ostream FileRaw(cfgFilename, ErrorInfo);

    if (ErrorInfo.empty()) {
        WriteCFGRaw(FileRaw, Main);
    } else {
        errs() << " error opening file for writing!";
        errs() << "\n";
    }
}

NewTargetCFGGen::~NewTargetCFGGen() {

    while (!Functions.empty()) {
        CFGFunction* F = Functions.front();
        Functions.pop_front();
        delete F;
    }
}

