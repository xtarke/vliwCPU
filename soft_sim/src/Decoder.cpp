/*
 * File:   Decodify.cpp
 * Author: Renan Augusto Starke
 *
 * Created on 25th March 2015, 14:25
 */

#include "Decoder.h"
#include "Slot.h"
#include <assert.h>
#include  <iomanip>
#include "ULACodeName.h"
#include "logger.h"

#define HEX_8F uppercase << setfill('0') << setw(8) << hex


Decoder::Decoder(std::ofstream* file_)
{
    file = file_;
}

void Decoder::Decode(Slot* slots)
{
  int ops = 0;
  
  for (int i = 0; i < 4 ; i++) {
    ops += inst_parse(&slots[i]);
  }
  
  slots[0].ops = ops;
    
  *file << ";;\n\n";
}

// Int3R, Mul64R

static void parse_instruction_opsV1(Slot* slot, uint32_t inst_data)
{

    unsigned dest, src1, src2;

    dest = (inst_data >> 12) & 0x0000003F;
    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    //std::*file << "dest: " << dest << " src2: " << src2 << " src1: " << src1 << "\n";
    slot->dest = dest;
    slot->src1 = src1;
    slot->src2 = src2;


}
// Int3I Mul64I

static void parse_instruction_opsV2(Slot* slot, uint32_t inst_data)
{

    unsigned idest, src1;

    idest = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

//     std::*file << "dest: " << idest << " src1: " << src1 << "\n";

    slot->dest = idest;
    slot->src1 = src1;

}

//
static void parse_instruction_opsV3(Slot* slot, uint32_t inst_data)
{

    unsigned ibdest, src1;

    ibdest = (inst_data >> 6) & 0x00000007;
    src1 = inst_data & 0x0000003F;

    // std::*file << "ibdest: " << ibdest << " src1: " << src1 << "\n";
    slot->bdest = ibdest;
    slot->src1 = src1;

}
//
static void parse_instruction_opsV4(Slot* slot, uint32_t inst_data)
{

    unsigned bdest, src1, src2;

    bdest = (inst_data >> 18) & 0x00000007;
    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    //std::*file << "bdest: " << bdest << " src2: " << src2 << " src1: " << src1 << "\n";
    slot->bdest = bdest;
    slot->src2 = src2;
    slot->src1 = src1;

}
//
static void parse_instruction_opsV5(Slot* slot, uint32_t inst_data)
{

    unsigned scond, dest, src1, src2, bdest;

    scond = (inst_data >> 21) & 0x00000007;
    bdest = (inst_data >> 18) & 0x00000007;

    dest = (inst_data >> 12) & 0x0000003F;
    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    slot->bdest = bdest;
    slot->scond = scond;
    slot->dest = dest;
    slot->src2 = src2;
    slot->src1 = src1;

}
//
static void parse_instruction_opsV6(Slot* slot, uint32_t inst_data)
{

    unsigned scond, idest, src1;

    scond = (inst_data >> 21) & 0x00000007;

    idest = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    slot->scond = scond;
    slot->dest = idest;
    slot->src1 = src1;


}
//
static void parse_instruction_opsV7(Slot* slot, uint32_t inst_data)
{

    unsigned bcond;
    int32_t btarg;

    btarg = inst_data & 0x3FFFFF;

    //signal extension
    if (inst_data & BIT_22)
        btarg = btarg | ~0x3FFFFF;

    //bcond = (inst_data >> 21) & 0x00000007;
    bcond = (inst_data >> 23) & 0x00000007;

    slot->bcond = bcond;
    slot->btarg = btarg;

}
//
static void parse_instruction_opsV8(Slot* slot, uint32_t inst_data)
{

    unsigned src1, src2;
    int32_t btarg;

    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;
    btarg = inst_data & 0x3FFFFF;

    //signal extension
    if (inst_data & BIT_22)
        btarg = btarg | ~0x3FFFFF;

    slot->src1 = src1;
    slot->src2 = src2;
    slot->btarg = btarg;
}
//
static void parse_instruction_opsV9(Slot* slot, uint32_t inst_data)
{

    unsigned src1, src2;

    src2 = (inst_data >> 6) & 0x0000003F;
    src1 = inst_data & 0x0000003F;

    slot->src1 = src1;
    slot->src2 = src2;
}

static void parse_instruction_opsV10(Slot* slot, uint32_t inst_data)
{

    int32_t btarg;

    btarg = inst_data & 0x3FFFFF;

    //signal extension
    if (inst_data & BIT_22)
        btarg = btarg | ~0x3FFFFF;

    slot->btarg = btarg;
    slot->dest = RA_REGISTER;
}

int Decoder::inst_parse(Slot* slot)
{
    string f_pre = "";
    bool activated = true;
    bool bit_30 = false;

    uint32_t inst_data = slot->op_raw_data;

    bool implemented = false;
    bool nop = false;

    // reset control flags
    slot->ula_code = ALU_IDLE;
    slot->src1 = 0;
    slot->src2 = 0;
    slot->dest = 0;
    slot->reg_wr = false;
    slot->pred_wr = false;
    slot->mem_rd = false;
    slot->mem_wr = false;
    slot->mem_sigext = false;
    slot->ctrl_flow = false;
    slot->ctrl_flow_type = 0;
    slot->preload = false;
    
    *file << dec;

    //full predication logic
    if (par_on_off == false) {
        if (inst_data & BIT_30) {
            //for debug
            f_pre = " (p) ";
	    //logic
            activated = slot->f_pred_val; 	    
        }
    } else {
      //for debug
      //f_pre = " (p)";
      //logic
      bit_30 = (inst_data & BIT_30);  
      
      (bit_30 == true) ? f_pre = " (1)" : f_pre = " (0)";
      
      if ((bit_30 == true && slot->f_pred_val == true) || ((bit_30 == false && slot->f_pred_val == false)))
	activated = true;
      else 
	activated = false;      
//       *file << activated << endl;      
    }


    if (inst_data == 0x9FE00000 || inst_data == 0x88000000 || inst_data == 0x8000000 || inst_data == 0) {
        implemented = true;
	nop = true;

        // halt and nop
        if (inst_data == 0x9FE00000) {
            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " BREAK" << endl;
	    nop = false;
            slot->halt = 1;
        }
        if (inst_data == 0x88000000 || inst_data == 0x8000000)
            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " add $r0 = $r0, 0" << endl;


    } else if (inst_data & BIT_29) {
        //1...
        if (inst_data & BIT_28) {
            //11...
            if (inst_data & BIT_27) {
                //111..
                //Branch"
                parse_instruction_opsV7(slot, inst_data);
                slot->ctrl_flow = true;
                slot->ctrl_flow_mux = BTARG_TARGET;

                implemented = true;

                if (inst_data & BIT_26) {
                    slot->ctrl_flow_type = CONDIT_FALSE;
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " brf $br" << slot->bcond << ", " << dec << slot->btarg << endl;
                } else {
                    slot->ctrl_flow_type = CONDIT_TRUE;
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " br $br" << slot->bcond << ", " << dec << slot->btarg << endl;
                }
            } else {
                //Call (direct - without register operands)
                uint32_t opcode = (inst_data >> 23) & 0x000001F;
                slot->ctrl_flow_type = DIRECT;

                // indirect call or goto (have register operand)
                switch (opcode) {
                case Decoder::ICALL_OP:
                    implemented = true;
                    slot->write_back_mux = CALL_FT;
                    slot->reg_wr = true;
                    slot->ctrl_flow = true;
                    slot->ctrl_flow_mux = BTARG_TARGET;
                    parse_instruction_opsV10(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " icall " << dec << slot->btarg << endl;
                    break;

                case Decoder::CALL_OP:
                    parse_instruction_opsV8(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " call " << dec << slot->Imm << endl;
                    break;
                case Decoder::IGOTO_OP:
                    implemented = true;
                    parse_instruction_opsV8(slot, inst_data);
                    slot->ctrl_flow = true;
                    slot->ctrl_flow_mux = REG_TARGET;
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " goto $r" << dec << slot->src1 << endl;
                    break;

                case Decoder::GOTO_OP:
                    implemented = true;
                    parse_instruction_opsV8(slot, inst_data);
                    slot->ctrl_flow = true;
                    slot->ctrl_flow_mux = BTARG_TARGET;
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " igoto " << dec << slot->btarg  << endl;
                    break;
                case Decoder::PRELD:
                    parse_instruction_opsV8(slot, inst_data);
                    implemented = true;
                    slot->preload = true;
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " preld " << dec << slot->btarg  << endl;

                }
            }
        } else {
            //10...
            uint32_t opcode = (inst_data >> 23) & 0x0000001F;

            switch (opcode) {
            case Decoder::LDW_OP:
                implemented = true;
                parse_instruction_opsV2(slot, inst_data);
                slot->mem_rd = true & activated;
                slot->reg_wr = true & activated;
                slot->mem_byteen = WORD_ACC;
                slot->write_back_mux = MEM_FT;
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " ldw $r" << dec << slot->dest << " = " << slot->Imm << "[$r" << slot->src1 << "]" << endl;
                break;

            case Decoder::LDH_OP:
                implemented = true;
                parse_instruction_opsV2(slot, inst_data);
                slot->mem_rd = true & activated;
                slot->reg_wr = true & activated;
                slot->mem_byteen = HWORD_ACC;
                slot->mem_sigext = true;
                slot->write_back_mux = MEM_FT;
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " ldh $r" << dec << slot->dest << " = " << slot->Imm << "[$r" << slot->src1 << "]" << endl;
                break;
            case Decoder::LDHU_OP:
                implemented = true;
                parse_instruction_opsV2(slot, inst_data);
                slot->mem_rd = true & activated;
                slot->reg_wr = true & activated;
                slot->mem_byteen = HWORD_ACC;
                slot->mem_sigext = false;
                slot->write_back_mux = MEM_FT;
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " ldhu $r" << dec << slot->dest << " = " << slot->Imm << "[$r" << slot->src1 << "]" << endl;
                break;
            case Decoder::LDB_OP:
                parse_instruction_opsV2(slot, inst_data);
                implemented = true;
                parse_instruction_opsV2(slot, inst_data);
                slot->mem_rd = true & activated;
                slot->reg_wr = true & activated;
                slot->mem_byteen = BYTE_ACC;
                slot->mem_sigext = true;
                slot->write_back_mux = MEM_FT;
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " ldb $r" << dec << slot->dest << " = " << slot->Imm << "[$r" << slot->src1 << "]" << endl;
                break;

            case Decoder::LDBU_OP:
                implemented = true;
                parse_instruction_opsV2(slot, inst_data);
                slot->mem_rd = true & activated;
                slot->reg_wr = true & activated;
                slot->mem_byteen = BYTE_ACC;
                slot->write_back_mux = MEM_FT;
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " ldbu $r" << dec << slot->dest << " = " << slot->Imm << "[$r" << slot->src1 << "]" << endl;
                break;

            case Decoder::STW_OP:
                implemented = true;
                parse_instruction_opsV9(slot, inst_data);
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " stw " << dec << slot->Imm << "[$r" << slot->src1 << "] = " << "$r" << slot->src2 << endl;
                slot->mem_wr = true & activated;
                slot->mem_byteen = WORD_ACC;
                break;

            case Decoder::STB_OP:
                implemented = true;
                parse_instruction_opsV9(slot, inst_data);
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " stb " << dec << slot->Imm << "[$r" << slot->src1 << "] = " << "$r" << slot->src2 << endl;
                slot->mem_wr = true & activated;
                slot->mem_byteen = BYTE_ACC;
                break;
            case Decoder::STH_OP:
                implemented = true;
                parse_instruction_opsV9(slot, inst_data);
                *file << slot->pc << " " << hex << slot->op_raw_data << f_pre << " sth " << dec << slot->Imm << "[$r" << slot->src1 << "] = " << "$r" << slot->src2 << endl;
                slot->mem_wr = true & activated;
                slot->mem_byteen = HWORD_ACC;
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

                switch (opcode) {
                case SLCT_OP:
                    implemented = true;
                    parse_instruction_opsV6(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " slct $r" << dec << slot->dest << " = $br" << slot->scond << ", $r" << slot->src1 << ", " << slot->Imm << endl;

                    slot->ula_code = ALU_SLCT;
                    slot->ula_src_sel = SEL_IMM;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr =  true & activated;

                    break;

                case SLCTF_OP:
                    implemented = true;
                    parse_instruction_opsV6(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " slctf $r" << dec << slot->dest << " = $br" << slot->scond << ", $r" << slot->src1 << ", " << slot->Imm << endl;

                    slot->ula_code = ALU_SLCTF;
                    slot->ula_src_sel = SEL_IMM;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr =  true & activated;

                    break;
                }

            } else
            //010
            {
                uint32_t opcode = (inst_data >> 24) & 0x00000007;

                //*file << "opcode: " << opcode << endl;

                switch (opcode) {
                case SLCT_OP:
                    implemented = true;
                    parse_instruction_opsV5(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " slct $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << ", $br" << slot->scond << endl;

                    slot->ula_code = ALU_SLCT;
                    slot->ula_src_sel = SEL_SRC2;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr = true & activated;
                    break;

                case SLCTF_OP:
                    implemented = true;
                    parse_instruction_opsV5(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " slctf $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << ", $br" << slot->scond << endl;

                    slot->ula_code = ALU_SLCTF;
                    slot->ula_src_sel = SEL_SRC2;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr =  true & activated;
                    break;

                case ADDCG_OP:
                    implemented = true;
                    parse_instruction_opsV5(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " addcg $r" << dec << slot->dest << ", $br" << slot->bdest <<  " = $r" << slot->src1 << ", $r" << slot->src2 << ", $br" << slot->scond << endl;

                    slot->ula_code = ALU_ADDCG;
                    slot->ula_src_sel = SEL_SRC2;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr = true & activated;
                    slot->pred_wr = true & activated;
                    break;
                case SUBCG_OP:
                    implemented = true;
                    parse_instruction_opsV5(slot, inst_data);
                    *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " subcg $r" << dec << slot->dest << ", $br" << slot->bdest <<  " = $r" << slot->src1 << ", $r" << slot->src2 << ", $br" << slot->scond << endl;

                    slot->ula_code = ALU_SUBCG;
                    slot->ula_src_sel = SEL_SRC2;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr = true & activated;
                    slot->pred_wr = true & activated;
                    break;

                case IMM_OP:
                    implemented = true;
                    if (inst_data & BIT_23)
                        *file << slot->pc << " " << hex << slot->op_raw_data << " immr " << dec << (inst_data & 0x7FFFFF) << endl;
                    else
                        *file << slot->pc << " " << hex << slot->op_raw_data << " imml " << dec << (inst_data & 0x7FFFFF) << endl;
                    break;

                case PAR_ON_OP:
                    implemented = true;
                    par_on_off = true;
                    *file << slot->pc << " " << hex << slot->op_raw_data << " par on " << endl;
                    break;

                case PAR_OFF_OP:
                    implemented = true;
                    par_on_off = false;
                    *file << slot->pc << " " << hex << slot->op_raw_data << " par off " << endl;
                    break;

                default:
                    break;
                }

            }
        } else {
            //00...
            if (inst_data & BIT_27) {
                //001...
                if (inst_data & BIT_26) {
                    //0011...
                    if (inst_data & BIT_25) {
                        //00111...
                        //Cmp3I_Br
                        uint32_t opcode = (inst_data >> 21) & 0x0000000F;
                        slot->ula_src_sel = SEL_IMM;
                        slot->write_back_mux = ALU_FT;
                        slot->pred_wr = true & activated;
                        parse_instruction_opsV3(slot, inst_data);

                        switch (opcode) {
                        case CMPEQ_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPEQ;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpeq $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPNE_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPNE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpne $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPGE_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPGE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpge $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                            break;
                        case CMPGEU_OP:
                            implemented = true;
                            slot->ula_code = CMPGEU_OP;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgeu $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPGT_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGT;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgt $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPGTU_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGTU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgtu $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPLE_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPLE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmple $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                            break;
                        case CMPLEU_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPLEU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpleu $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                        case CMPLT_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPLT;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmplt $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPLTU_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPLTU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpltu $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                            break;
                        case ANDL_OP:
			   implemented = true;
                           slot->ula_code = ALU_ANDL;
                           *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " andl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                           break;                            
                        case NANDL_OP:
                           implemented = true;
                           slot->ula_code = ALU_NANDL;
                           *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " nandl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                           break;                            
                        case ORL_OP:
                           implemented = true;
                           slot->ula_code = ALU_ORL;
                           *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " orl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                           break;                            
                        case NORL_OP:
                           implemented = true;
                           slot->ula_code = ALU_NORL;
                           *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " norl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                           break; 
                        };
                    } else {
                        //00110...
                        //Cmp3I_Reg

                        uint32_t opcode = (inst_data >> 21) & 0x0000000F;
                        slot->ula_src_sel = SEL_IMM;
                        slot->write_back_mux = ALU_FT;
                        slot->reg_wr = true & activated;
                        parse_instruction_opsV2(slot, inst_data);

                        switch (opcode) {
                        case CMPEQ_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPEQ;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpeq $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPNE_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPNE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpne $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPGE_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPGE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpge $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPGEU_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPGEU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgeu $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPGT_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGT;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgt $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPGTU_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGTU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " cmpgtu $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPLE_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPLE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " cmple $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                            break;
                        case CMPLEU_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPLEU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << " cmpleu $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                            break;
                        case CMPLT_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPLT;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmplt $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                            break;
                        case CMPLTU_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPLTU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpltu $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                            
                            break;
                        case ANDL_OP:
			    implemented = true;
                            slot->ula_code = ALU_ANDL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " andl $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                                               
                            break;
                        case NANDL_OP:
			    implemented = true;
                            slot->ula_code = ALU_NANDL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " nandl $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                                                                           
                            break;
                        case ORL_OP:
                            implemented = true;
                            slot->ula_code = ALU_ORL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " orl $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                                                                           
                            break;
                        case NORL_OP:
			    implemented = true;
                            slot->ula_code = ALU_NORL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " norl $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;                                                                                                       
                            break;
                        };
                    }

                } else {
                    //0010...
                    //Int3I
                    uint32_t opcode = (inst_data >> 21) & 0x0000001F;

                    parse_instruction_opsV2(slot, inst_data);
                    slot->ula_src_sel = SEL_IMM;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr = true & activated;

                    switch (opcode) {
                    case Decoder::ADD_OP:
                        implemented = true;
                        slot->ula_code = ALU_ADD;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " add $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                    case Decoder::SUB_OP:
                        implemented = true;
                        slot->ula_code = ALU_SUB;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " sub $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                        break;
                    case Decoder::SHL_OP:
                        implemented = true;
                        slot->ula_code = ALU_SHL;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " shl $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                    case Decoder::SHR_OP:
                        implemented = true;
                        slot->ula_code = ALU_SHR;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " shr $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                    case Decoder::SHRU_OP:
                        implemented = true;
                        slot->ula_code = ALU_SHRU;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " shru $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                    case Decoder::SH1ADD_OP:
                        break;
                    case Decoder::SH2ADD_OP:
                        break;
                    case Decoder::SH3ADD_OP:
                        break;
                    case Decoder::SH4ADD_OP:
                        break;

                    case Decoder::AND_OP:
                        implemented = true;
                        slot->ula_code = ALU_AND;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " and $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                    case Decoder::ANDC_OP:
                        break;
                    case Decoder::OR_OP:
                        implemented = true;
                        slot->ula_code = ALU_OR;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " or $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                    case Decoder::ORC_OP:
                        break;
                    case Decoder::XOR_OP:
                        implemented = true;
                        slot->ula_code = ALU_XOR;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " xor $r" << dec << slot->dest << " = $r" << slot->src1 << ", " << slot->Imm << endl;
                        break;
                    case Decoder::MAX_OP:
                        break;
                    case Decoder::MAXU_OP:
                        break;
                    case Decoder::MIN_OP:
                        break;
                    case Decoder::MINU_OP:
                        break;
                    }
                    
                    // desativate ULA
                    if (activated == false)
                        slot->ula_code == ALU_IDLE;

                    //*file << slot->pc << " " << std::hex << slot->bundle <<

                }
            } else {
                //000...
                if (inst_data & BIT_26) {
                    //0001
                    if (inst_data & BIT_25) {
                        //00011...
                        //Cmp3R_Br

                        uint32_t opcode = (inst_data >> 21) & 0x0000000F;
                        slot->ula_src_sel = SEL_SRC2;
                        slot->write_back_mux = ALU_FT;
                        slot->pred_wr = true & activated;

                        switch (opcode) {
                        case CMPEQ_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPEQ;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpeq $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPNE_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPNE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpne $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGE_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPGE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpge $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGEU_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPGEU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgeu $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGT_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPGT;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgt $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGTU_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPGTU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgt $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPLE_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPLE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmple $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPLEU_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPLEU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpleu $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPLT_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPLT;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmplt $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPLTU_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_CMPLTU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpltu $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case ANDL_OP:
			    implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_ANDL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " andl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;                             
                            break;
                        case NANDL_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_NANDL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " nandl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;                             
                            break;
                        case ORL_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_ORL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " orl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case NORL_OP:
                            implemented = true;
                            parse_instruction_opsV4(slot, inst_data);
                            slot->ula_code = ALU_NORL;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " norl $br" << dec << slot->bdest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case MUL64HU_OP:
                            implemented = true;
                            parse_instruction_opsV1(slot, inst_data);

                            slot->pred_wr = false;

                            slot->reg_wr = true;
                            slot->ula_code = ALU_MULL64HU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " mul64hu $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                            break;

                        };

                    } else {
                        //00010...
                        //Cmp3R_Reg

                        uint32_t opcode = (inst_data >> 21) & 0x0000000F;
                        slot->ula_src_sel = SEL_SRC2;
                        slot->write_back_mux = ALU_FT;
                        slot->reg_wr = true & activated;
                        parse_instruction_opsV1(slot, inst_data);

                        switch (opcode) {
			  			  
			 case CMPNE_OP:
			    implemented = true;
                            slot->ula_code = ALU_CMPNE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpne $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;	
			 case CMPLT_OP:
			   implemented = true;
                           slot->ula_code = ALU_CMPLT;
                           *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmplt $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                           break;   
			 case CMPLTU_OP:
			  implemented = true;
                          slot->ula_code = ALU_CMPLTU;
                          *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpltu $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                          break;			  
                        case CMPLE_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPLE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmple $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGT_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGT;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgt $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGTU_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGTU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgtu $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGEU_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGEU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpgeu $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPGE_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPGE;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpge $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPEQ_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPEQ;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpeq $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
                        case CMPLEU_OP:
                            implemented = true;
                            slot->ula_code = ALU_CMPLEU;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " cmpleu $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                            break;
			    
			case ANDL_OP:
			  implemented = true;
                          slot->ula_code = ALU_ANDL;
                          *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " andl $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                          break;	
			case NANDL_OP:
			  implemented = true;
                          slot->ula_code = ALU_NANDL;
                          *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " nandl $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                          break;
			
			case ORL_OP:
			  implemented = true;
                          slot->ula_code = ALU_ORL;
                          *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " orl $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                          break;
			  
			case NORL_OP: 
			  implemented = true;
                          slot->ula_code = ALU_NORL;
                          *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " norl $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2  << endl;
                          break;

                        case MUL64H_OP:
                            implemented = true;
                            slot->ula_code = ALU_MULL64H;
                            *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " mul64h $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                            break;  

                        }
                        
                        // desativate ULA
			if (activated == false)
			  slot->ula_code == ALU_IDLE;
                    }

                } else {
                    //0000...
                    //Int3R
                    uint32_t opcode = (inst_data >> 21) & 0x0000001F;


                    parse_instruction_opsV1(slot, inst_data);
                    slot->ula_src_sel = SEL_SRC2;
                    slot->write_back_mux = ALU_FT;
                    slot->reg_wr = true & activated;

//        *file << "opcode: " << opcode << endl;

                    switch (opcode) {
                    case Decoder::ADD_OP:
                        implemented = true;
                        slot->ula_code = ALU_ADD;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " add $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    case Decoder::SUB_OP:
                        implemented = true;
                        slot->ula_code = ALU_SUB;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " sub $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    case Decoder::SHL_OP:
                        implemented = true;
                        slot->ula_code = ALU_SHL;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " shl $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                        break;
                    case Decoder::SHR_OP:
                        implemented = true;
                        slot->ula_code = ALU_SHR;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " shr $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    case Decoder::SHRU_OP:
                        implemented = true;
                        slot->ula_code = ALU_SHRU;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " shru $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;

                    case Decoder::SH1ADD_OP:
                        break;
                    case Decoder::SH2ADD_OP:
                        break;
                    case Decoder::SH3ADD_OP:
                        break;
                    case Decoder::SH4ADD_OP:
                        break;

                    case Decoder::AND_OP:
                        implemented = true;
                        slot->ula_code = ALU_AND;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " and $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;

                    case Decoder::ANDC_OP:
                        break;
                    case Decoder::OR_OP:
                        implemented = true;
                        slot->ula_code = ALU_OR;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " or $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    case Decoder::ORC_OP:
                        break;
                    case Decoder::XOR_OP:
                        implemented = true;
                        slot->ula_code = ALU_XOR;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " xor $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    case Decoder::MAX_OP:
                        break;
                    case Decoder::MAXU_OP:
                        break;
                    case Decoder::MIN_OP:
                        break;
                    case Decoder::MINU_OP:
                        break;
                    case Decoder::MULL_OP:
                        implemented = true;
                        slot->ula_code = ALU_MULL;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " mull $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;

                    case Decoder::DIVRU_OP:
                        implemented = true;
                        slot->ula_code = ALU_DIVRU;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " divru $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;

                    case Decoder::DIVQU_OP:
                        implemented = true;
                        slot->ula_code = ALU_DIVQU;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " divqu $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    case Decoder::DIVR_OP:
                        implemented = true;
                        slot->ula_code = ALU_DIVR;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " divr $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    case Decoder::DIVQ_OP:
                        implemented = true;
                        slot->ula_code = ALU_DIVQ;
                        *file << slot->pc << " " << HEX_8F << slot->op_raw_data << f_pre << " divq $r" << dec << slot->dest << " = $r" << slot->src1 << ", $r" << slot->src2 << endl;
                        break;
                    }

                    // desativate ULA
                    if (activated == false)
                        slot->ula_code == ALU_IDLE;

                }
            }
        }
    }

    if (implemented == false) {
        *file << "PC: " << slot->pc << " : " << hex << slot->op_raw_data << endl;
        assert(0);
    }
    
    
    if (nop == false && activated == true)        
      return 1;
    else
      return 0;
}
