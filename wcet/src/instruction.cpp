#include "instruction.h"
#include "cfg.h"
#include "lpsolve/lp_types.h"

VLIW_instruction::~VLIW_instruction() {


    while (!output_regs.empty()) {
        VLIW_register* reg = output_regs.back();
        output_regs.pop_back();
        delete reg;
    }

    while (!input_regs.empty()) {
        VLIW_register* reg = input_regs.back();
        input_regs.pop_back();
        delete reg;
    }
}

VLIW_bundle::~VLIW_bundle() {

    while (!instructions.empty()) {
        VLIW_instruction* inst = instructions.back();
        instructions.pop_back();
        delete inst;
    }
}

bool VLIW_bundle::check_relation(unsigned mytype, unsigned othertype, VLIW_bundle* another) {

    std::vector<VLIW_instruction*>::const_iterator ITme;
    std::vector<VLIW_instruction*>::const_iterator ITother;

    for (ITme = instructions.begin(); ITme != instructions.end(); ITme++) {
        VLIW_instruction* inst1 = *ITme;

        for (ITother = another->instructions.begin(); ITother != another->instructions.end(); ITother++) {
            VLIW_instruction* inst2 = *ITother;
            if (inst1->is_this_type(mytype) && inst2->is_this_type(othertype)) {
                // check outputs
                std::vector<VLIW_register*>::const_iterator ITreg1;
                for (ITreg1 = inst1->output_regs.begin(); ITreg1 != inst1->output_regs.end(); ITreg1++) {
                    VLIW_register* reg1 = *ITreg1;

                    std::vector<VLIW_register*>::const_iterator ITreg2;
                    for (ITreg2 = inst2->input_regs.begin(); ITreg2 != inst2->input_regs.end(); ITreg2++) {
                        VLIW_register* reg2 = *ITreg2;
                        if (reg1->number == reg2->number && reg1->type == reg2->type) {
                            return true;
                        }
                    }
                }
            }
        }
    }
    return false;
}

bool VLIW_bundle::has_instruction_type(unsigned mytype) {
    std::vector<VLIW_instruction*>::const_iterator ITme;

    for (ITme = instructions.begin(); ITme != instructions.end(); ITme++) {
        VLIW_instruction* inst1 = *ITme;

        if (inst1->is_this_type(mytype)) {
            return true;
        }
    }
    return false;
}

bool VLIW_bundle::has_instruction_type_path(unsigned mytype, unsigned *bit_30) {
    std::vector<VLIW_instruction*>::const_iterator ITme;

    for (ITme = instructions.begin(); ITme != instructions.end(); ITme++) {
        VLIW_instruction* inst1 = *ITme;
	
	*bit_30 = inst1->bit_30;

        if (inst1->is_this_type(mytype)) {
            return true;
        }
    }
    return false;
}

// Int3R, Mul64R

static void parse_instruction_opsV1(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned dest, src1, src2;

    dest = (inst_data >> 12) & 0x0000003F;
    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    //std::cout << "dest: " << dest << " src2: " << src2 << " src1: " << src1 << "\n";

    VLIW_register* dest_reg = new VLIW_register(dest, VLIW_register::GENERAL);
    VLIW_register* src2_reg = new VLIW_register(src2, VLIW_register::GENERAL);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);

    inst->input_regs.push_back(src1_reg);
    inst->input_regs.push_back(src2_reg);
    inst->output_regs.push_back(dest_reg);

}
// Int3I Mul64I

static void parse_instruction_opsV2(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned idest, src1;

    idest = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    //std::cout << "dest: " << idest << " src1: " << src1 << "\n";

    VLIW_register* idest_reg = new VLIW_register(idest, VLIW_register::GENERAL);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);

    inst->input_regs.push_back(src1_reg);
    inst->output_regs.push_back(idest_reg);

}

static void parse_instruction_opsV3(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned ibdest, src1;

    ibdest = (inst_data >> 6) & 0x00000007;
    src1 = inst_data & 0x0000003F;

    // std::cout << "ibdest: " << ibdest << " src1: " << src1 << "\n";

    VLIW_register* ibdest_reg = new VLIW_register(ibdest, VLIW_register::BRANCH);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);

    inst->input_regs.push_back(src1_reg);
    inst->output_regs.push_back(ibdest_reg);

}

static void parse_instruction_opsV4(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned bdest, src1, src2;

    bdest = (inst_data >> 18) & 0x00000007;
    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    // std::cout << "bdest: " << bdest << " src2: " << src2 << " src1: " << src1 << "\n";

    VLIW_register* bdest_reg = new VLIW_register(bdest, VLIW_register::BRANCH);
    VLIW_register* src2_reg = new VLIW_register(src2, VLIW_register::GENERAL);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);

    inst->input_regs.push_back(src1_reg);
    inst->input_regs.push_back(src2_reg);
    inst->output_regs.push_back(bdest_reg);
}

static void parse_instruction_opsV5(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned scond, dest, src1, src2;

    scond = (inst_data >> 21) & 0x00000007;
    dest = (inst_data >> 12) & 0x0000003F;
    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    VLIW_register* scond_reg = new VLIW_register(scond, VLIW_register::BRANCH);
    VLIW_register* dest_reg = new VLIW_register(dest, VLIW_register::GENERAL);
    VLIW_register* src2_reg = new VLIW_register(src2, VLIW_register::GENERAL);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);

    inst->input_regs.push_back(scond_reg);
    inst->input_regs.push_back(src1_reg);
    inst->input_regs.push_back(src2_reg);
    inst->output_regs.push_back(dest_reg);
}

static void parse_instruction_opsV6(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned scond, idest, src1;

    scond = (inst_data >> 21) & 0x00000007;
    idest = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    VLIW_register* scond_reg = new VLIW_register(scond, VLIW_register::BRANCH);
    VLIW_register* idest_reg = new VLIW_register(idest, VLIW_register::GENERAL);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);

    inst->input_regs.push_back(scond_reg);
    inst->input_regs.push_back(src1_reg);
    inst->output_regs.push_back(idest_reg);
}

static void parse_instruction_opsV7(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned bcond, idest, src1;

    //bcond = (inst_data >> 21) & 0x00000007;
    bcond = (inst_data >> 23) & 0x00000007;

    VLIW_register* bcond_reg = new VLIW_register(bcond, VLIW_register::BRANCH);

    //std::cout << "bcond: " << bcond << "\n";    

    inst->input_regs.push_back(bcond_reg);
}

static void parse_instruction_opsV8(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned rtarget;

    rtarget = inst_data & 0x0000003F;

    VLIW_register* rtarget_reg = new VLIW_register(rtarget, VLIW_register::GENERAL);
    
    inst->input_regs.push_back(rtarget_reg);
    
}

static void parse_instruction_opsV9(VLIW_instruction* inst, uint32_t inst_data) {

    unsigned src1, src2;

    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    VLIW_register* src2_reg = new VLIW_register(src2, VLIW_register::GENERAL);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);

    inst->input_regs.push_back(src1_reg);
    inst->input_regs.push_back(src2_reg);
}

static void parse_instruction_opsV10(VLIW_instruction* inst, uint32_t inst_data) {

}

static void parse_instruction_opsV11(VLIW_instruction* inst, uint32_t inst_data) {
    unsigned scond, bdest, dest, src1, src2;

    scond = (inst_data >> 21) & 0x00000007;
    bdest = (inst_data >> 18) & 0x00000007;
    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;
    dest = (inst_data >> 12) & 0x0000003F;

    // std::cout << "bdest: " << bdest << " src2: " << src2 << " src1: " << src1 << "\n";

    VLIW_register* bdest_reg = new VLIW_register(bdest, VLIW_register::BRANCH);
    VLIW_register* scond_reg = new VLIW_register(scond, VLIW_register::BRANCH);
    VLIW_register* src2_reg = new VLIW_register(src2, VLIW_register::GENERAL);
    VLIW_register* src1_reg = new VLIW_register(src1, VLIW_register::GENERAL);
    VLIW_register* dest_reg = new VLIW_register(dest, VLIW_register::GENERAL);

    inst->input_regs.push_back(src1_reg);
    inst->input_regs.push_back(src2_reg);
    inst->input_regs.push_back(scond_reg);
    
    inst->output_regs.push_back(bdest_reg);
    inst->output_regs.push_back(dest_reg);

}

void VLIW_bundle_parser::create_bundle_seq(std::vector<VLIW_bundle*> &bundles, uint32_t *inst_buffer, unsigned fi, unsigned li) {

    bool new_bundle = true;

    for (unsigned i = fi; i < li + 1; i++) {

        if (new_bundle) {
            VLIW_bundle* n_bundle = new VLIW_bundle(i);
            bundles.push_back(n_bundle);
            new_bundle = false;
        }

        VLIW_bundle* actual_bundle = bundles.back();
        uint32_t inst_data = inst_buffer[i];

        VLIW_instruction* new_inst = new VLIW_instruction();
        new_inst->type = 0;
	new_inst->bit_30 = (inst_data & BIT_30);

        if (inst_data == 0x9FE00000 || inst_data == 0x88000000 || inst_data == 0x8000000) {
            // halt and nop
            new_inst->type = VLIW_instruction::SPECIAL;
        } else if (inst_data & BIT_29) {
            //1...
            if (inst_data & BIT_28) {
                //11...
                if (inst_data & BIT_27) {
                    //111..
                    //Branch"
                    parse_instruction_opsV7(new_inst, inst_data);
                    new_inst->type = VLIW_instruction::BRANCH;
                } else {
                    //Call (direct - without register operands)
                    uint32_t opcode = (inst_data >> 23) & 0x000000F;

                    // indirect call or goto (have register operand)
                    switch (opcode) {
                        case VLIW_instruction::CALLR_OP:
                            new_inst->type = VLIW_instruction::CALL;
                            parse_instruction_opsV10(new_inst, inst_data);
                            break;
			case VLIW_instruction::GOTO_OP:
                            new_inst->type = VLIW_instruction::GOTO;
                            parse_instruction_opsV10(new_inst, inst_data);
                            break;
                        case VLIW_instruction::ICALL_OP:
			    new_inst->type = VLIW_instruction::CALL;
                            parse_instruction_opsV8(new_inst, inst_data);
                            break;
                        case VLIW_instruction::IGOTO_OP:                     
                            new_inst->type = VLIW_instruction::GOTO;
                            parse_instruction_opsV8(new_inst, inst_data);
                            break;
                       
			case VLIW_instruction::PRELD_OP:
                            new_inst->type = VLIW_instruction::PRELOAD;
                            parse_instruction_opsV10(new_inst, inst_data);
                            break;
                    }
                }
            } else {
                uint32_t opcode = (inst_data >> 23) & 0x0000001F;

                switch (opcode) {
                    case VLIW_instruction::LDW:
                    case VLIW_instruction::LDH:
                    case VLIW_instruction::LDHu:
                    case VLIW_instruction::LDB:
                    case VLIW_instruction::LDBu:
                        parse_instruction_opsV2(new_inst, inst_data);
                        new_inst->type = VLIW_instruction::LOAD;
                        break;
                    case VLIW_instruction::STW:
                    case VLIW_instruction::STH:
                    case VLIW_instruction::STB:
                        parse_instruction_opsV9(new_inst, inst_data);
                        new_inst->type = VLIW_instruction::STORE;
                        break;
                }
                //Load&Store;
            }
        } else {
            //0...
            if (inst_data & BIT_28) {
                //01...
		if (inst_data & BIT_27) {
		  //011
		  uint32_t opcode = (inst_data >> 24) & 0x00000007;

		  //SelectI
		  switch (opcode) {
		    case VLIW_instruction::SLCT_OP:
		    case VLIW_instruction::SLCTF_OP:
		      parse_instruction_opsV6(new_inst, inst_data);
		      new_inst->type = VLIW_instruction::SELECT;
                    break;
		  }
		} else
		//010
		{
		  uint32_t opcode = (inst_data >> 24) & 0x00000007;

                //*file << "opcode: " << opcode << endl;

		  switch (opcode) {
		    case VLIW_instruction::SLCT_OP:
		    case VLIW_instruction::SLCTF_OP:
		      parse_instruction_opsV5(new_inst, inst_data);
		      new_inst->type = VLIW_instruction::SELECT;
		      break;
		    
		    case VLIW_instruction::ADDCG_OP:                    
		    case VLIW_instruction::SUBCG_OP:
		      parse_instruction_opsV11(new_inst, inst_data);
		      new_inst->type = VLIW_instruction::ALU;
		      break;

		    case VLIW_instruction::IMM_OP:
		      new_inst->type = VLIW_instruction::IMM;
		      break;

		    case VLIW_instruction::PAR_ON_OP:
                      parse_instruction_opsV10(new_inst, inst_data);
		      new_inst->type = VLIW_instruction::PRED_ON;
		      break;

		    case VLIW_instruction::PAR_OFF_OP:
		      parse_instruction_opsV10(new_inst, inst_data);
		       new_inst->type = VLIW_instruction::PRED_OFF;
		      break;
		  
		  default:
		    break; 
		  }		  
		}

//                 if ((inst_data >> 23) & 0xA) {
//                     //Imm (without register operands)
//                     new_inst->type = VLIW_instruction::IMM;
//                 } else if ((inst_data >> 23) & 0xB) {
//                     //"Imm (without register operands)
//                     new_inst->type = VLIW_instruction::IMM;
//                 } else if (inst_data & BIT_27) {
//                     //011...
//                     //SelectI
//                     parse_instruction_opsV6(new_inst, inst_data);
//                     new_inst->type = VLIW_instruction::SELECT;
//                 } else {
//                     //010...
//                     //SelectR
//                     parse_instruction_opsV5(new_inst, inst_data);
//                     new_inst->type = VLIW_instruction::SELECT;
//                 }
            } else {
                //00...
                if (inst_data & BIT_27) {
                    //001...
                    if (inst_data & BIT_26) {
                        //0011...
                        if (inst_data & BIT_25) {
                            //00111...
                            //Cmp3I_Br
                            parse_instruction_opsV3(new_inst, inst_data);
                            new_inst->type = VLIW_instruction::ALU;

                        } else {
                            //00110...
                            //Cmp3I_Reg
                            parse_instruction_opsV2(new_inst, inst_data);
                            new_inst->type = VLIW_instruction::ALU;
                        }

                        uint32_t opcode = (inst_data >> 21) & 0x0000001F;

                        //Mul64I
                        switch (opcode) {
                            case VLIW_instruction::MUL32:
                            case VLIW_instruction::MUL64H:
                                parse_instruction_opsV2(new_inst, inst_data);
                                new_inst->type = VLIW_instruction::MULT;
                                break;
                        }

                    } else {
                        //0010...
                        //Int3I
                        parse_instruction_opsV2(new_inst, inst_data);
                        new_inst->type = VLIW_instruction::ALU;
                    }
                } else {
                    //000...
                    if (inst_data & BIT_26) {
                        //0001
                        if (inst_data & BIT_25) {
                            //00011...
                            //Cmp3R_Br
                            parse_instruction_opsV4(new_inst, inst_data);
                            new_inst->type = VLIW_instruction::ALU;
                        } else {
                            //00010...
                            //Cmp3R_Reg
                            parse_instruction_opsV1(new_inst, inst_data);
                            new_inst->type = VLIW_instruction::ALU;
                        }

                        uint32_t opcode = (inst_data >> 21) & 0x0000001F;

                        ////Mul64R
                        switch (opcode) {
                            case VLIW_instruction::MUL32:
                            case VLIW_instruction::MUL64H:
                                parse_instruction_opsV1(new_inst, inst_data);
                                new_inst->type = VLIW_instruction::MULT;
                                break;
                        }

                    } else {
                        //0000...
                        //Int3R		      
                        uint32_t opcode = (inst_data >> 21) & 0x0000001F;

			switch (opcode)
			{
			    case VLIW_instruction::MULL_OP:
			       parse_instruction_opsV1(new_inst, inst_data);
                               new_inst->type = VLIW_instruction::MULT;
			       break;
			    case VLIW_instruction::DIVRU_OP:
			    case VLIW_instruction::DIVQU_OP:
			    case VLIW_instruction::DIVR_OP:
			    case VLIW_instruction::DIVQ_OP:
			      parse_instruction_opsV1(new_inst, inst_data);
                              new_inst->type = VLIW_instruction::DIV;
			      break;
			    default:
			      parse_instruction_opsV1(new_inst, inst_data);
			      new_inst->type = VLIW_instruction::ALU; 			  
			}
                    }
                }
            }
        }
        assert(new_inst->type != 0 && "Operation decoding error");

        actual_bundle->instructions.push_back(new_inst);

        //cout << actual_bundle->instructions.size();
        //assert(actual_bundle->instructions.size() <= 4);


        if (inst_data & STOP_BIT) {
            new_bundle = true;
        }
    }
}