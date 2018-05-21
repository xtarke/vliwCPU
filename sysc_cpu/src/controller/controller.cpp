#include "controller.h"
#include "instrunctions.h"
#include "alu.h"
#include "mem_wb/mem_wb.h"
#include "mem_cont/mem_cont.h"
#include "../cpu.h"

void controller::do_clk_state() {
    sc_logic local_reset;

    local_reset = reset.read();

    if (local_reset == 1) {
        //data = 0;
        cpu_stage.write(STOP);
        //cout << "@ " << sc_time_stamp() << " cpu on reset: " << STOP << endl;
    } else if (clk.posedge() == true) {
        cpu_stage.write(RUN);

    }
}

void controller::enable_fetch() {
    cpu_stage_type local_cpu_stage = cpu_stage.read();

    //rom_rd.write(sc_logic('0'));
    rom_enable.write(sc_logic('0'));


    if (local_cpu_stage == RUN) {
        //cout << "CPU ENABLE" << endl;

        //--------------------------
        //fetch all the time
        //rom_rd.write(sc_logic('1'));
        rom_enable.write(sc_logic('1'));
    }

}

void controller::do_output_logic() {
    sc_logic local_reset;
    sc_logic local_hazd_in;
    sc_logic cache_hazd_in;
    sc_logic mem_hazd_in;

    cpu_stage_type local_cpu_stage;

    sc_uint<OPCODE_SIZE> local_insopcode;
    sc_uint<SHAMT_SIZE> local_shamt;
    sc_uint<FUNCT_SIZE> local_funct;
    sc_uint<WORD_SIZE> local_j_target;

    sc_int<WORD_SIZE> local_imediate;
    sc_logic local_rpred_rs_value;

    WbControl Wb_control(sc_logic('0'), "XX", sc_logic('0'),
            0, sc_logic('0'), sc_logic('0'), sc_logic('0'));

    local_reset = reset.read();
    local_insopcode = insopcode.read();
    local_shamt = shamt.read();
    local_funct = funct.read();
    local_imediate = immediate_in.read();
    local_rpred_rs_value = rpred_rs_value_in.read();
    local_hazd_in = hazd_in.read();
    cache_hazd_in = i_cache_stall_in.read();
    mem_hazd_in = mem_stall.read();

    local_cpu_stage = cpu_stage.read();

    //clear all outputs
    pred_rd_enable.write(sc_logic('0'));
    pc_load.write(sc_logic('0'));
    pc_inc.write(sc_logic('0'));
    pipeline_load.write(sc_logic('0'));
    if_id_load.write(sc_logic('0'));
    ra_rd_enable.write(sc_logic('0'));
    rb_rd_enable.write(sc_logic('0'));
    ram_enable.write(sc_logic('0'));
    pipe_flush.write(sc_logic('0'));
    reg_write_sel.write(0);
    reg_w_addr.write(0);
    reg_w_enable.write(sc_logic('0'));
    hi_lo_address_out.write(0);
    hi_lo_enable.write(sc_logic('0'));
    pc_adder_enable.write(sc_logic('0'));

    dest_reg_out.write(0);
    mem_adder_enable.write(sc_logic('0'));

    //alu control
    alu_pa_sel.write(0);
    alu_pb_sel.write(0);
    alu_op_out.write(0);

    //pc control
    j_target_sel.write(0);

    Wb_control.reset();
    ctrl_wb_signals_out.write(Wb_control);

    if (local_cpu_stage == STOP)
        pipe_flush.write(sc_logic('1'));


    if (local_cpu_stage == RUN) {
        //--enable instrunction register
        pipeline_load.write(sc_logic('1'));
        if_id_load.write(sc_logic('1'));
        pc_inc.write(sc_logic('1'));

        rom_rd.write(sc_logic('1'));

        //enable register read
        pred_rd_enable.write(sc_logic('1'));
        ra_rd_enable.write(sc_logic('1'));
        rb_rd_enable.write(sc_logic('1'));

        //enable RAM
        ram_enable.write(sc_logic('1'));
        //disalbe pipeline flush
        pipe_flush.write(sc_logic('0'));

        //normal instructions alu_ra value is always from RS register file
        //it is different to predicated instructions
        alu_pa_sel.write(RF_RS);

        if ((local_insopcode == 0) && (local_shamt == 0) && (local_funct == 0)
                && (local_imediate == 0)) {
            //cout << "@ " << sc_time_stamp() <<  " NOP" << endl;
            return;
        }

        if (local_hazd_in == sc_logic('1') || cache_hazd_in == sc_logic('1') || mem_hazd_in == sc_logic('1')) {
            // cout << "@ " << sc_time_stamp() <<  " hazard" << endl;

            if (local_insopcode == HLT) {
                Wb_control.halt = sc_logic('1');
                Wb_control.hazard = sc_logic('1');
                ctrl_wb_signals_out.write(Wb_control);
            } else {
                Wb_control.hazard = sc_logic('1');
                ctrl_wb_signals_out.write(Wb_control);
            }

            return;
        }

        switch (local_insopcode) {
            case HLT:
                ////cout << "HALT @" << sc_time_stamp() << endl;
                //stop in WB stage
                Wb_control.halt = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case J: //J instrunction
                ////cout << "J " << local_imediate << endl;

                //enable pc write
                pc_load.write(sc_logic('1'));
                pc_inc.write(sc_logic('0'));
                j_target_sel.write(JUMP);

                break;

            case JAL:
                //cout << "JAL " << local_imediate << endl;
                //use ALU
                alu_op_out.write(ALU_ADD);
                alu_pa_sel.write(PC_OFFSET);
                alu_pb_sel.write(PC_PB);


                //enable pc write
                pc_load.write(sc_logic('1'));
                pc_inc.write(sc_logic('0'));
                j_target_sel.write(JUMP);

                //store pc in R31 ($ra)
                dest_reg_out.write(31);

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1'); //enable write
                Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                ctrl_wb_signals_out.write(Wb_control);

                break;

            case BR:
                ////cout << "BR " << local_imediate << endl;

                if (local_rpred_rs_value == sc_logic('1')) {
                    //enable pc write
                    pc_load.write(sc_logic('1'));
                    pc_inc.write(sc_logic('0'));
                    j_target_sel.write(BRANCH);
                    pc_adder_enable.write(sc_logic('1'));
                }
                break;
            case BRF:
                ////cout << "BRF " << local_imediate << endl;

                if (local_rpred_rs_value == sc_logic('0')) {
                    //enable pc write
                    pc_load.write(sc_logic('1'));
                    pc_inc.write(sc_logic('0'));
                    j_target_sel.write(BRANCH);
                    pc_adder_enable.write(sc_logic('1'));
                }
                break;

            case LUI: //I type instrunction

                //Rt = Im << 16
                ////cout << "LUI " << local_imediate << endl;
                alu_op_out.write(ALU_SHIFTL_B);
                alu_shamt_out.write(16);
                alu_pb_sel.write(INS_IMM_ZEROEXT);

                //LUI writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);

                break;
            case ADDI: //I type instrunction plus NOP
                //Rt = Rs + Im
                //todo: overflow
                //cout << "ADDI " << local_imediate << endl;
                alu_op_out.write(ALU_ADD);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case ADDIU: //I type instrunction plus NOP
                //Rt = Rs + Im
                //cout << "ADDIU " << local_imediate << endl;
                alu_op_out.write(ALU_ADD);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case ANDI: //I type instrunction plus NOP
                //Rt = Rs & Im
                //cout << "ANDI " << local_imediate << endl;
                alu_op_out.write(ALU_AND);
                alu_pb_sel.write(INS_IMM_ZEROEXT);

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case ORI: //I type instrunction plus NOP
                //Rt = Rs & Im
                //cout << "ORI " << local_imediate << endl;
                alu_op_out.write(ALU_OR);
                alu_pb_sel.write(INS_IMM_ZEROEXT);

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case XORI: //I type instrunction plus NOP
                //Rt = Rs & Im
                //cout << "ORI " << local_imediate << endl;
                alu_op_out.write(ALU_XOR);
                alu_pb_sel.write(INS_IMM_ZEROEXT);

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case SLTI: //I type instrunction plus NOP
                //Rt = 1 if Rs < Im, else 0
                //cout << "SLTI " << local_imediate << endl;
                alu_op_out.write(ALU_SLT);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case SLTIU: //I type instrunction plus NOP
                //Rt = 1 if Rs < Im, else 0
                //cout << "SLTIU " << local_imediate << endl;
                alu_op_out.write(ALU_SLTU);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.reg_w_enable = sc_logic('1');
                Wb_control.reg_w_select = "00";
                Wb_control.hilo_w_enable = sc_logic('0');
                Wb_control.access_width = 0;
                Wb_control.memory_rd_enable = sc_logic('0');
                Wb_control.memory_w_enable = sc_logic('0');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case SW:
                //cout << "SW " << local_imediate << endl;
                mem_adder_enable.write(sc_logic('1'));

                Wb_control.access_width = WORD_ACC_SEL;
                Wb_control.memory_w_enable = sc_logic('1'); //enable memory
                Wb_control.unsigned_load = sc_logic('0'); //signed load

                ctrl_wb_signals_out.write(Wb_control);

                break;

            case SB:
                //cout << "SB " << local_imediate << endl;
                mem_adder_enable.write(sc_logic('1'));

                Wb_control.access_width = BYTE_ACC_SEL;
                Wb_control.memory_w_enable = sc_logic('1'); //enable memory
                Wb_control.memory_rd_enable = sc_logic('1'); //enable memory
                Wb_control.unsigned_load = sc_logic('0'); //signed load

                ctrl_wb_signals_out.write(Wb_control);

                break;

            case SH:
                //cout << "SH " << local_imediate << endl;
                mem_adder_enable.write(sc_logic('1'));

                Wb_control.access_width = HALF_WORD_ACC_SEL;
                Wb_control.memory_w_enable = sc_logic('1'); //enable memory
                Wb_control.memory_rd_enable = sc_logic('1'); //enable memory
                Wb_control.unsigned_load = sc_logic('0'); //signed load

                ctrl_wb_signals_out.write(Wb_control);

                break;

            case LW:
                // Rt = MEM [Rs + Immediate]
                //cout << "LW " << local_imediate << endl;
                mem_adder_enable.write(sc_logic('1'));

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.access_width = WORD_ACC_SEL; //select controller to load a WORD from mem
                Wb_control.unsigned_load = sc_logic('0'); //signed load
                Wb_control.memory_rd_enable = sc_logic('1'); //enable memory read
                Wb_control.reg_w_enable = sc_logic('1'); //enable register write
                Wb_control.reg_w_select = TO_BIN(WB_MUX_MEMORY); //select source to register write

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case LBU:
                // Rt = MEM [Rs + Immediate] (byte)
                //cout << "LBU " << local_imediate << endl;
                mem_adder_enable.write(sc_logic('1'));

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.access_width = BYTE_ACC_SEL; //select controller to load a WORD from mem
                Wb_control.unsigned_load = sc_logic('1'); //unsigned load
                Wb_control.memory_rd_enable = sc_logic('1'); //enable memory read
                Wb_control.reg_w_enable = sc_logic('1'); //enable register write
                Wb_control.reg_w_select = TO_BIN(WB_MUX_MEMORY); //select source to register write

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case LB:
                // Rt = MEM [Rs + Immediate] (byte)
                //cout << "LBU " << local_imediate << endl;
                mem_adder_enable.write(sc_logic('1'));

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.access_width = BYTE_ACC_SEL; //select controller to load a WORD from mem
                Wb_control.unsigned_load = sc_logic('0'); //signed load
                Wb_control.memory_rd_enable = sc_logic('1'); //enable memory read
                Wb_control.reg_w_enable = sc_logic('1'); //enable register write
                Wb_control.reg_w_select = TO_BIN(WB_MUX_MEMORY); //select source to register write

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case LHU:
                mem_adder_enable.write(sc_logic('1'));

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.access_width = HALF_WORD_ACC_SEL; //select controller to load a WORD from mem
                Wb_control.unsigned_load = sc_logic('1'); //unsigned load
                Wb_control.memory_rd_enable = sc_logic('1'); //enable memory read
                Wb_control.reg_w_enable = sc_logic('1'); //enable register write
                Wb_control.reg_w_select = TO_BIN(WB_MUX_MEMORY); //selec source to register write

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case LH:
                // Rt = MEM [Rs + Immediate] (byte)
                //cout << "LHU " << local_imediate << endl;
                mem_adder_enable.write(sc_logic('1'));

                //writes on instruction rt address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.access_width = HALF_WORD_ACC_SEL; //select controller to load a WORD from mem
                Wb_control.unsigned_load = sc_logic('0'); //signed load
                Wb_control.memory_rd_enable = sc_logic('1'); //enable memory read
                Wb_control.reg_w_enable = sc_logic('1'); //enable register write
                Wb_control.reg_w_select = TO_BIN(WB_MUX_MEMORY); //selec source to register write

                ctrl_wb_signals_out.write(Wb_control);
                break;

                //PREDICATE Instrunctions
            case CMPEQI:
                //RT(P) = RS == Im

                //cout << "CMPEQI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPEQ);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPGEI:
                //RT(P) = RS >= Im

                //cout << "CMPGEI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPGE);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPGEUI:
                //RT(P) = RS > Im
                //cout << "CMPGEUI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPGEU);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPGTI:
                //RT(P) = RS > Im
                //cout << "CMPGTI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPGT);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPGTUI:
                //RT(P) = RS > Im
                //cout << "CMPGTUI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPGTU);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPLEI:
                //RT(P) = RS <= Im
                //cout << "CMPLEI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPLE);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPLEUI:
                //RT(P) = RS <= Im
                //cout << "CMPLEUI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPLEU);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPLTI:
                //RT(P) = RS < Im
                //cout << "CMPLTI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPLT);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPLTUI:
                //RT(P) = RS < Im
                //cout << "CMPLTUI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPLTU);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;
            case CMPNEI:
                //RT(P) = RS != Im
                //cout << "CMPLTUI " << local_imediate << endl;
                alu_op_out.write(ALU_CMPNE);
                alu_pb_sel.write(INS_IMM_SIGEXT);

                //CMPEQ writes on instruction rd address
                dest_reg_out.write(rt_in.read());

                //write the WB signals
                Wb_control.rf_predic_w_enable = sc_logic('1');

                ctrl_wb_signals_out.write(Wb_control);
                break;

            case SPEC_ARIT:
                switch (local_funct) {
                    case MUL:
                        //Rd = Rs * Rt; (low order 32-bit)
                        alu_op_out.write(ALU_MUL);
                        alu_pb_sel.write(RF_RT);

                        //MUL writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = "00";

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    default:
                        cout << "@ " << sc_time_stamp() << " Invalid opcode: " << local_insopcode << endl;
                        sc_assert(0);
                        break;
                }

                break;

            case NORM_ARIT: //R type instrunctions
                switch (local_funct) {
                    case ADD:
                        //Rd = Rs + Rt;
                        //todo: overflow detection
                        //cout << "ADD " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_ADD);
                        alu_pb_sel.write(RF_RT);

                        //ADD writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = "00";

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case ADDU:
                        //Rd = Rs + Rt;
                        //cout << "ADDU " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_ADD);
                        alu_pb_sel.write(RF_RT);

                        //ADD writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case SUB:
                        //Rd = Rs - Rt;
                        //todo: overflow detection
                        //cout << "SUB  " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SUB);
                        alu_pb_sel.write(RF_RT);

                        //ADD writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case SUBU:
                        //Rd = Rs - Rt;
                        //cout << "SUB  " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SUB);
                        alu_pb_sel.write(RF_RT);

                        //ADD writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case AND:
                        //Rd = Rs & Rt;
                        //cout << "AND " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_AND);
                        alu_pb_sel.write(RF_RT);

                        //ADD writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case NOR:
                        //Rd = ~(Rs | Rt);
                        //cout << "NOR " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_NOR);
                        alu_pb_sel.write(RF_RT);

                        //NOR writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case XOR:
                        //Rd = (Rs ^ Rt);
                        //cout << "XOR " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_XOR);
                        alu_pb_sel.write(RF_RT);

                        //NOR writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case OR:
                        //Rd = (Rs | Rt);
                        //cout << "OR " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_OR);
                        alu_pb_sel.write(RF_RT);

                        //NOR writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case SLT:
                        //Rd = 1, if Rs > Rt else 0
                        //cout << "SLT " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SLT);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case SLTU:
                        //Rd = 1, if Rs > Rt else 0
                        //cout << "SLTU " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SLTU);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case SLL:
                        //Rd = Rt << SHAMT
                        //cout << "SLL " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SLL);
                        alu_shamt_out.write(local_shamt);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case SLLV:
                        //Rd = Rt << SHAMT
                        //cout << "SLL " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SLLV);
                        alu_pb_sel.write(RF_RS);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case SRA:
                        //Rd = Rt >> SHAMT
                        //cout << "SLA " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SRA);
                        alu_shamt_out.write(local_shamt);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case SRAV:
                        //Rd = Rt >> SHAMT
                        //cout << "SLA " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SRAV);
                        alu_pa_sel.write(RF_RS);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case SRL:
                        //Rd = Rt >> SHAMT
                        //cout << "SLR " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SRL);
                        alu_shamt_out.write(local_shamt);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case SRLV:
                        //Rd = Rt >> SHAMT
                        //cout << "SLR " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_SRLV);
                        alu_pa_sel.write(RF_RS);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case DIV:
                        //lo = Rs / Rt;
                        //hi = Rs / Rt;
                        //cout << "DIV " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_DIV);
                        alu_pb_sel.write(RF_RT);

                        //ADD writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals, write hi and lo
                        Wb_control.hilo_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case DIVU:
                        //lo = Rs / Rt;
                        //hi = Rs / Rt;
                        //cout << "DIVU" << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_DIV);
                        alu_pb_sel.write(RF_RT);

                        //ADD writes on instruction rd address
                        //dest_reg_out.write(rd_in.read());

                        //write the WB signals, write hi and lo
                        Wb_control.hilo_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case MULT:
                        //hi = Rs * Rt; (high order 32 bits)
                        //lo = Rs * Rt; (low order 32 bits)
                        //cout << "MULT" << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_MULT);
                        alu_pb_sel.write(RF_RT);

                        //write the WB signals, write hi and lo
                        Wb_control.hilo_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case MULTU:
                        //hi = Rs * Rt; (high order 32 bits)
                        //lo = Rs * Rt; (low order 32 bits)
                        //cout << "MULTU " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_MULTU);
                        alu_pb_sel.write(RF_RT);

                        //write the WB signals, write hi and lo
                        Wb_control.hilo_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case MFHI:
                        //Rd = Rs & Rt;
                        //cout << "MFHI " << rd_in.read() << endl;

                        //select HI on HI_LO register file
                        hi_lo_address_out.write(1);
                        hi_lo_enable.write(sc_logic('1'));
                        //hi read is done via ALU due forward logic
                        alu_op_out.write(ALU_ADD);
                        alu_pa_sel.write(RHILO);
                        alu_pb_sel.write(ZERO_PB);

                        //MFHI writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case MFLO:
                        //Rd = Rs & Rt;
                        //cout << "MFLO " << rd_in.read() << endl;

                        //select HI on HI_LO register file
                        hi_lo_address_out.write(0);
                        hi_lo_enable.write(sc_logic('1'));
                        //lo read is done via ALU due forward logic
                        alu_op_out.write(ALU_ADD);
                        alu_pa_sel.write(RHILO);
                        alu_pb_sel.write(ZERO_PB);

                        //MFHI writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case JR:
                        //cout << "JR " << local_imediate << endl;

                        //enable pc write
                        pc_load.write(sc_logic('1'));
                        pc_inc.write(sc_logic('0'));
                        j_target_sel.write(RS_VALUE);

                        break;


                    case JALR:
                        //cout << "JAL " << local_imediate << endl;
                        //use ALU
                        alu_op_out.write(ALU_ADD);
                        alu_pa_sel.write(PC_OFFSET);
                        alu_pb_sel.write(PC_PB);

                        //enable pc write
                        pc_load.write(sc_logic('1'));
                        pc_inc.write(sc_logic('0'));
                        j_target_sel.write(JUMP);

                        //JALR writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1'); //enable write
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                        //PREDICATES instructions
                    case CMPEQ:
                        //Rd(P) = (Rs == Rt);
                        //cout << "CMPEQ " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPEQ);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case CMPGE:
                        //Rd(P) = (Rs >= Rt);
                        //cout << "CMPGE " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPGE);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPGEU:
                        //Rd(P) = (Rs > Rt);
                        //cout << "CMPGEU " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPGEU);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPGT:
                        //Rd(P) = (Rs > Rt);
                        //cout << "CMPGT " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPGT);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPGTU:
                        //Rd(P) = (Rs > Rt);
                        //cout << "CMPGTU " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPGTU);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPLE:
                        //Rd(P) = (Rs <= Rt);
                        //cout << "CMPLE " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPLE);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPLEU:
                        //Rd(P) = (Rs <= Rt);
                        //cout << "CMPLEU " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPLEU);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPLT:
                        //Rd(P) = (Rs < Rt);
                        //cout << "CMPLT " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPLT);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPLTU:
                        //Rd(P) = (Rs < Rt);
                        //cout << "CMPLTU " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPLTU);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMPNE:
                        //Rd(P) = (Rs != Rt);
                        //cout << "CMPNE " << rd_in.read() << endl;

                        alu_op_out.write(ALU_CMPNE);
                        alu_pb_sel.write(RF_RT);

                        //CMPEQ writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case NANDL:
                        //Rd(P) = !(Rs(P) && Rt(P));
                        //cout << "NANDL " << rd_in.read() << endl;

                        alu_op_out.write(ALU_NANDL);
                        alu_pa_sel.write(RFP_RS);
                        alu_pb_sel.write(RFP_RT);

                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case ANDL:
                        //Rd(P) = !(Rs(P) && Rt(P));
                        //cout << "NANDL " << rd_in.read() << endl;

                        alu_op_out.write(ALU_AND);
                        alu_pa_sel.write(RFP_RS);
                        alu_pb_sel.write(RFP_RT);

                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case XORL:
                        //Rd(P) = !(Rs(P) && Rt(P));
                        //cout << "NANDL " << rd_in.read() << endl;

                        alu_op_out.write(ALU_XOR);
                        alu_pa_sel.write(RFP_RS);
                        alu_pb_sel.write(RFP_RT);

                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case NORL:
                        //Rd(P) = !(Rs(P) || Rt(P));
                        //cout << "NORL " << rd_in.read() << endl;

                        alu_op_out.write(ALU_NOR);
                        alu_pa_sel.write(RFP_RS);
                        alu_pb_sel.write(RFP_RT);


                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case ORL:
                        //Rd(P) = !(Rs(P) || Rt(P));
                        //cout << "ORL " << rd_in.read() << endl;

                        alu_op_out.write(ALU_OR);
                        alu_pa_sel.write(RFP_RS);
                        alu_pb_sel.write(RFP_RT);

                        dest_reg_out.write(rd_in.read());

                        //write the WB signals
                        Wb_control.rf_predic_w_enable = sc_logic('1');

                        ctrl_wb_signals_out.write(Wb_control);
                        break;
                    case CMOV:
                        //RD = RS, if RT(P) == 1
                        //cout << "CMOV " << rd_in.read() << ",x,x" << endl;

                        alu_op_out.write(ALU_ADD);
                        alu_pa_sel.write(ZERO_PA);
                        alu_pb_sel.write(RF_RT);

                        //writes on instruction rd address
                        dest_reg_out.write(rd_in.read());

                        //signal the forward unit that it is a cmov instruction
                        Wb_control.cmov = sc_logic('1');

                        if (local_rpred_rs_value == sc_logic('1')) {
                            //write the WB signals
                            //reset the cmov flag to the forward unit to use normal forward
                            Wb_control.cmov = sc_logic('0');
                            Wb_control.reg_w_enable = sc_logic('1');
                            Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);
                        }

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    case PMOV:
                        //RD = RS, if RT(P) == 1
                        // cout << "PMOV " << rd_in.read() << ",x,x" << endl;
                        alu_op_out.write(ALU_ADD);
                        alu_pa_sel.write(RFP_RS);
                        alu_pb_sel.write(ZERO_PB);

                        //writes on instruction rd address
                        dest_reg_out.write(rt_in.read());

                        //write the WB signals
                        Wb_control.reg_w_enable = sc_logic('1');
                        Wb_control.reg_w_select = TO_BIN(WB_MUX_ALU);

                        ctrl_wb_signals_out.write(Wb_control);
                        break;

                    default:
                        cout << "@ " << sc_time_stamp() << " Invalid opcode: " << local_insopcode << endl;
                        cout << this->name() << endl;
                        sc_assert(0);
                        break;
                }

                break;
            default:
                cout << this->name() << endl;
                cout << "@ " << sc_time_stamp() << " Invalid opcode: " << local_insopcode << endl;
                sc_assert(0);
                break;
        }
    }
}

void controller::do_debug() {
    int_cpu_stage.write(cpu_stage);
}
