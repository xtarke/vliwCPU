/*
 * debug.cpp
 *
 *  Created on: Apr 17, 2013
 *      Author: xtarke
 */

#include "debug.h"
#include "../instrunctions.h"
#include "../alu/alu.h"
#include "../mem_wb/mem_wb.h"
#include "../mem_cont/mem_cont.h"
#include "../cpu.h"

void debug::do_run_history() {
    sc_logic local_reset;

    sc_uint<SHAMT_SIZE> local_shamt;
    sc_uint<FUNCT_SIZE> local_funct;
    sc_uint<WORD_SIZE> local_j_target;

    sc_int<WORD_SIZE> local_pc;
    sc_int<WORD_SIZE> immediate_32;
    sc_int<WORD_SIZE> immediate_32_double;

    sc_uint<IMEDIATE_SIZE> local_immediate;

    sc_uint<REG_ADDR_SIZE> rs;
    sc_uint<REG_ADDR_SIZE> rd;
    sc_uint<REG_ADDR_SIZE> rt;

    sc_uint<WORD_SIZE> local_instrunction;
    sc_uint<OPCODE_SIZE> local_insopcode;

    local_reset = reset.read();
    local_pc = pc_in.read().to_int();
    local_instrunction = instrunction_in.read();


    //	opcode_out.write(local_data.range(OPCODE_INI, OPCODE_END));
    //		funct_out.write(local_data.range(FUNCT_INI, FUNCT_END));
    //		shamt_out.write(local_data.range(SHAMT_INI, SHAMT_END));

    local_insopcode = local_instrunction.range(OPCODE_INI, OPCODE_END);
    local_funct = local_instrunction.range(FUNCT_INI, FUNCT_END);
    immediate_32 = local_instrunction.range(IMEDIATE_INI, IMEDIATE_END);
    local_immediate = local_instrunction.range(IMEDIATE_INI, IMEDIATE_END);
    local_shamt = local_instrunction.range(SHAMT_INI, SHAMT_END);

    rs = local_instrunction.range(RS_INI, RS_END);
    rd = local_instrunction.range(RD_INI, RD_END);
    rt = local_instrunction.range(RT_INI, RT_END);

    //singal extension
    if (immediate_32.bit(IMEDIATE_SIZE - 1) == 1) {
        immediate_32_double = immediate_32.to_int();
        immediate_32_double = immediate_32_double | 0xFFFF0000;

        immediate_32 = immediate_32_double.to_int();
    } else
        immediate_32 = immediate_32.to_int();

    if (local_reset == sc_logic('0')) {
        if (local_instrunction == 0) {
            cout << ">" << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "NOP" << endl;
            return;
        }
        
        cout << ">";

        switch (local_insopcode) {
            case HLT:
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "HALT @" << sc_time_stamp() << endl;
                break;

            case J: //J instrunction
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "J " << immediate_32 << endl;
                cout << endl;
                break;

            case JAL:
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "JAL " << immediate_32 << endl;
                cout << endl;
                break;

            case BR:
                //RS(P), offset
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "BR " << rs << "," << immediate_32 << endl;
                cout << endl;
                break;
            case BRF:
                //RS(P), offset
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "BRF " << rs << "," << immediate_32 << endl;
                cout << endl;
                break;

            case LUI: //I type instrunction
                //Rt = Im << 16
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "LUI " << rt << "," << immediate_32 << endl;
                break;
            case ADDI: //I type instrunction plus NOP
                //Rt = Rs + Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ADDI " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case ADDIU: //I type instrunction plus NOP
                //Rt = Rs + Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ADDIU " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case ANDI: //I type instrunction plus NOP
                //Rt = Rs & Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ANDI " << rt << "," << rs << "," << local_immediate << endl;
                break;

            case ORI: //I type instrunction plus NOP
                //Rt = Rs & Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ORI " << rt << "," << rs << "," << local_immediate << endl;
                break;
            case XORI: //I type instrunction plus NOP
                //Rt = Rs & Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "XORI " << rt << "," << rs << "," << local_immediate << endl;
                break;

            case SLTI: //I type instrunction plus NOP
                //Rt = 1 if Rs < Im, else 0
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SLTI " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case SLTIU: //I type instrunction plus NOP
                //Rt = 1 if Rs < Im, else 0
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SLTIU " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case SW:
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SW " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case SB:
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SB " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case SH:
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SH " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case LW:
                // Rt = MEM [Rs + Immediate]
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "LW " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case LB:
                // Rt = MEM [Rs + Immediate] (byte)
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "LB " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case LBU:
                // Rt = MEM [Rs + Immediate] (byte)
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "LBU " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case LHU:
                // Rt = MEM [Rs + Immediate] (byte)
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "LHU " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case LH:
                // Rt = MEM [Rs + Immediate] (byte)
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "LH " << rt << "," << rs << "," << immediate_32 << endl;
                break;
                //PREDICATE Instrunctions
            case CMPEQI:
                //RT(P) = RS == Im

                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPEQI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPGEI:
                //RT(P) = RS >= Im

                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGEI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPGEUI:
                //RT(P) = RS > Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGEUI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPGTI:
                //RT(P) = RS > Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGTI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPGTUI:
                //RT(P) = RS > Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGTUI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPLEI:
                //RT(P) = RS <= Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLEI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPLEUI:
                //RT(P) = RS <= Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLEUI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPLTI:
                //RT(P) = RS < Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLTI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPLTUI:
                //RT(P) = RS < Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLTUI " << rt << "," << rs << "," << immediate_32 << endl;
                break;
            case CMPNEI:
                //RT(P) = RS != Im
                cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLTUI " << rt << "," << rs << "," << immediate_32 << endl;
                break;

            case SPEC_ARIT:
                switch (local_funct) {
                    case MUL:
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "MUL " << rd << "," << rs << "," << rt << endl;
                        break;
                    default:
                        break;
                }

                break;

            case 0: //R type instrunctions
                switch (local_funct) {
                    case ADD:
                        //Rd = Rs + Rt;
                        //todo: overflow detection
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ADD " << rd << "," << rs << "," << rt << endl;
                        break;

                    case ADDU:
                        //Rd = Rs + Rt;
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ADDU " << rd << "," << rs << "," << rt << endl;
                        break;
                    case SUB:
                        //Rd = Rs - Rt;
                        //todo: overflow detection
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SUB  " << rd << "," << rs << "," << rt << endl;
                        break;
                    case SUBU:
                        //Rd = Rs - Rt;
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SUB  " << rd << "," << rs << "," << rt << endl;
                        break;

                    case AND:
                        //Rd = Rs & Rt;
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "AND " << rd << "," << rs << "," << rt << endl;
                        break;
                    case NOR:
                        //Rd = ~(Rs | Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "NOR " << rd << "," << rs << "," << rt << endl;
                        break;
                    case XOR:
                        //Rd = (Rs ^ Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "XOR " << rd << "," << rs << "," << rt << endl;
                        break;

                    case OR:
                        //Rd = (Rs | Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "OR " << rd << "," << rs << "," << rt << endl;
                        break;
                    case SLT:
                        //Rd = 1, if Rs > Rt else 0
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SLT " << rd << "," << rs << "," << rt << endl;
                        break;
                    case SLTU:
                        //Rd = 1, if Rs > Rt else 0
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SLTU " << rd << "," << rs << "," << rt << endl;
                        break;

                    case SLL:
                        //Rd = Rt << SHAMT
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SLL " << rd << "," << rt << "," << local_shamt << endl;
                        break;
                    case SLLV:
                        //Rd = Rt << SHAMT
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SLLV " << rd << "," << rs << "," << rt << endl;
                        break;
 
                    case SRA:
                        //Rd = Rt >> SHAMT
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SRA " << rd << "," << rt << "," << local_shamt << endl;   
                        break;
                    case SRAV:
                        //Rd = Rt >> SHAMT
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SRAV " << rd << "," << rs << "," << rt << endl;
                        break;

                    case SRL:
                        //Rd = Rt >> SHAMT
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SRL " << rd << "," << rt << "," << local_shamt << endl;
                        break;
                    case SRLV:
                        //Rd = Rt >> SHAMT
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "SRLV " << rd << "," << rs << "," << rt << endl;
                        break;

                    case DIV:
                        //lo = Rs / Rt;
                        //hi = Rs / Rt;
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "DIV " << rs << "," << rt << endl;
                        break;

                    case DIVU:
                        //lo = Rs / Rt;
                        //hi = Rs / Rt;
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "DIVU " << rs << "," << rt << endl;
                        break;

                    case MULT:
                        //hi = Rs * Rt; (high order 32 bits)
                        //lo = Rs * Rt; (low order 32 bits)
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "MULT" << rd << "," << rs << "," << rt << endl;
                        break;

                    case MULTU:
                        //hi = Rs * Rt; (high order 32 bits)
                        //lo = Rs * Rt; (low order 32 bits)
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "MULTU " << rd << "," << rs << "," << rt << endl;
                        break;

                    case MFHI:
                        //Rd = Rs & Rt;
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "MFHI " << rd << "," << rs << "," << rt << endl;

                        break;
                    case MFLO:
                        //Rd = Rs & Rt;
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "MFLO " << rd << "," << rs << "," << rt << endl;
                        break;

                    case JR:
                        //PC = RS
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "JR " << rs << endl;

                        break;

                    case JALR:
                        //PC = RS / rd = pc
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "JALR " << rs << "," << rd << endl;

                        break;


                        //PREDICATES instructions
                    case CMPEQ:
                        //Rd(P) = (Rs == Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPEQ " << rd << "," << rs << "," << rt << endl;
                        break;

                    case CMPGE:
                        //Rd(P) = (Rs >= Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGE " << rd << "," << rs << "," << rt << endl;
                        break;
                    case CMPGEU:
                        //Rd(P) = (Rs > Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGEU " << rd << "," << rs << "," << rt << endl;
                        break;
                    case CMPGT:
                        //Rd(P) = (Rs > Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGT " << rd << "," << rs << "," << rt << endl;
                        break;
                    case CMPGTU:
                        //Rd(P) = (Rs > Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPGTU " << rd << "," << rs << "," << rt << endl;

                        break;
                    case CMPLE:
                        //Rd(P) = (Rs <= Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLE " << rd << "," << rs << "," << rt << endl;
                        break;
                    case CMPLEU:
                        //Rd(P) = (Rs <= Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLEU " << rd << "," << rs << "," << rt << endl;
                        break;
                    case CMPLT:
                        //Rd(P) = (Rs < Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLT " << rd << "," << rs << "," << rt << endl;
                        break;
                    case CMPLTU:
                        //Rd(P) = (Rs < Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPLTU " << rd << "," << rs << "," << rt << endl;

                        break;
                    case CMPNE:
                        //Rd(P) = (Rs != Rt);
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMPNE " << rd << "," << rs << "," << rt << endl;
                        break;
                    case NANDL:
                        //Rd(P) = !(Rs(P) && Rt(P));
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "NANDL " << rd << "," << rs << "," << rt << endl;

                        break;
                    case ANDL:
                        //Rd(P) = !(Rs(P) || Rt(P));
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ANDL " << rd << "," << rs << "," << rt << endl;
                        break;

                    case XORL:
                        //Rd(P) = !(Rs(P) || Rt(P));
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "XORL " << rd << "," << rs << "," << rt << endl;
                        break;

                    case NORL:
                        //Rd(P) = !(Rs(P) || Rt(P));
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "NORL " << rd << "," << rs << "," << rt << endl;

                        break;
                    case ORL:
                        //Rd(P) = !(Rs(P) || Rt(P));
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "ORL " << rd << "," << rs << "," << rt << endl;

                        break;
                    case CMOV:
                        //RD = RS, if RT(P) == 1
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "CMOV " << rd << "," << rs << "," << rt << endl;
                        break;
                    case PMOV:
                        //RD = RT(P)
                        cout << local_pc << "  :   " << hex << local_instrunction << " -->  " << dec << "PMOV " << rt << "," << rs << endl;
                        break;

                    default:
                        break;
                }

                break;
            default:
                break;
        }
    }
}

