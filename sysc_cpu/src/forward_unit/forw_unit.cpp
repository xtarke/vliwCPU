#include "forw_unit.h"
#include "rf_hilo.h"

void forw_unit::do_forward() {
    sc_logic local_reset;
    sc_logic local_mem_wb_reg_w_enable;
    sc_logic local_mem_wb_c_mov;
    sc_logic local_ex_mem_memory_read;
    sc_logic local_id_ex_hilo_read;
    sc_logic local_mem_wb_hilo_write;
    sc_logic local_mem_wb_rpred_write;
    sc_uint<2> local_id_ex_hilo_addr;
    sc_int<WORD_SIZE> local_ex_mem_lo;
    sc_int<WORD_SIZE> local_ex_mem_hi;
    sc_int<WORD_SIZE> local_id_ex_hilo;
    sc_int<WORD_SIZE> local_mem_wb_lo;
    sc_int<WORD_SIZE> local_mem_wb_hi;
    sc_int<WORD_SIZE> local_rpred_rs;
    sc_int<WORD_SIZE> local_rpred_rt;
    sc_int<WORD_SIZE> local_if_id_rs_out;
    sc_int<WORD_SIZE> local_mem_data;

    sc_logic local_id_pred_data;
    sc_logic local_mem_wb_pred_data;
    sc_int<WORD_SIZE> local_hilo_data;
    sc_int<WORD_SIZE> local_mem_wb_w_data;
    sc_int<WORD_SIZE> local_id_ex_alu;
    sc_int<WORD_SIZE> local_ex_mem_alu;
    sc_int<WORD_SIZE> local_alu_a;
    sc_int<WORD_SIZE> local_alu_b;
    sc_int<WORD_SIZE> local_mem_wb_ram_datain;
    sc_int<WORD_SIZE> local_ram_data;

    sc_uint<REG_ADDR_SIZE> local_id_ex_dest_reg;
    sc_uint<REG_ADDR_SIZE> local_ex_mem_dest_reg;
    sc_uint<REG_ADDR_SIZE> local_mem_wb_dest_reg;
    sc_uint<REG_ADDR_SIZE> local_if_id_rs;
    sc_uint<REG_ADDR_SIZE> local_id_ex_rs;
    sc_uint<REG_ADDR_SIZE> local_id_ex_rt;
    sc_uint<REG_ADDR_SIZE> local_ex_mem_rt;

    sc_uint<WORD_SIZE> local_instrunction;

    WbControl local_ex_mem_Wb_control;
    WbControl local_id_ex_Wb_control;

    //read all signals
    local_ex_mem_Wb_control = ex_mem_ctrl_wb_signals_in.read();
    local_ex_mem_dest_reg = ex_mem_dest_reg.read();
    local_mem_wb_dest_reg = mem_wb_dest_reg.read();

    local_ex_mem_rt = ex_mem_rt.read();
    local_ex_mem_lo = ex_mem_lo.read();
    local_ex_mem_hi = ex_mem_hi.read();

    local_id_ex_Wb_control = id_ex_ctrl_wb_signals_in.read();
    local_id_ex_hilo = hilo_data_in.read();
    local_id_ex_hilo_addr = id_ex_hilo_addr.read();
    local_id_ex_hilo_read = id_ex_hilo_r_enable.read();
    local_id_ex_dest_reg = id_ex_dest_reg.read();

    local_if_id_rs = if_id_rs.read();
    local_id_ex_rs = id_ex_rs.read();
    local_id_ex_rt = id_ex_rt.read();
    local_rpred_rs = rpred_rs_value_in.read();
    local_rpred_rt = rpred_rt_value_in.read();
    local_id_pred_data = rpred_if_rs_value_in.read();

    local_mem_wb_c_mov = mem_wb_cmov.read();
    local_mem_wb_reg_w_enable = mem_wb_reg_w_enable.read();
    local_mem_wb_hilo_write = mem_wb_hilo_w_enable.read();

    local_mem_data = memory_data.read();
    local_ex_mem_memory_read = ex_mem_memory_read.read();
    local_reset = reset.read();

    local_mem_wb_pred_data = mem_wb_pred_data_in.read();
    local_mem_wb_hi = mem_wb_hi.read();
    local_mem_wb_lo = mem_wb_lo.read();
    local_mem_wb_w_data = mem_wb_w_data.read();
    local_mem_wb_rpred_write = mem_wb_rpred_w_enable.read();
    local_ex_mem_alu = ex_mem_alu.read();
    local_id_ex_alu = id_ex_alu.read();
    local_alu_a = rf_rs_value.read();
    local_alu_b = rf_rt_value.read();

    local_hilo_data = local_id_ex_hilo;
    local_ram_data = ex_mem_ram_datain.read();
    local_mem_wb_ram_datain = mem_wb_ram_datain.read();

    local_if_id_rs_out = id_rs_value.read();

    if (local_reset == 1) {
        alu_a_out.write(0);
        alu_b_out.write(0);
        ram_data_out.write(0);
        rpred_rs_value_out.write(0);
        rpred_rt_value_out.write(0);
    } else {
        //ex_mem ALU forward
        if (local_ex_mem_Wb_control.reg_w_enable == sc_logic('1')) {// || local_ex_mem_Wb_control.cmov == sc_logic('1')) {
            //EX Hazard
            //cout << sc_time_stamp() << " Write:  " << local_ex_mem_dest_reg << endl;
            if ((local_ex_mem_dest_reg != 0) && (local_ex_mem_dest_reg == local_id_ex_rs)) {
                //                cout << sc_time_stamp() << " EX HAZARD: Forwarding A: "  << local_ex_mem_alu <<  endl;               
                local_alu_a = local_ex_mem_alu;
            }
            if ((local_ex_mem_dest_reg != 0) && (local_ex_mem_dest_reg == local_id_ex_rt)) {
                //				cout << "EX HAZARD: Forwarding B"  <<  endl;
                //							cout << "ex_mem.rd: " << local_ex_mem_rd << endl;
                //							cout << "id_rs.rt: " << local_id_ex_rt << endl;
                local_alu_b = local_ex_mem_alu;
            }
        }

        //especial CMOV forward
        if (local_ex_mem_Wb_control.cmov == sc_logic('1') && local_mem_wb_reg_w_enable == sc_logic('1')) {
            //EX Hazard

            if ((local_ex_mem_dest_reg != 0) && (local_ex_mem_dest_reg == local_id_ex_rs) &&
                    local_mem_wb_dest_reg == local_id_ex_rs) {

                local_alu_a = local_mem_wb_w_data;
            }
            
            if ((local_ex_mem_dest_reg != 0) && 
                    (local_ex_mem_dest_reg == local_id_ex_rt) &&
                    local_mem_wb_dest_reg == local_id_ex_rt) {

                local_alu_b = local_mem_wb_w_data;
            }
        }

        //ex_mem predicates forward
        //        if ((local_ex_mem_Wb_control.rf_predic_w_enable == sc_logic('1')) &&
        //                (local_id_ex_Wb_control.rf_predic_w_enable == sc_logic('1'))) {

        if (local_ex_mem_Wb_control.rf_predic_w_enable == sc_logic('1')) {

            //            cout << sc_time_stamp() << " Write:  " << local_ex_mem_dest_reg << endl;

            //EX Hazard
            if ((local_ex_mem_dest_reg == local_id_ex_rs)) {
                //                cout << sc_time_stamp() << " EX HAZARD: Predicate Forwarding A" << endl;

                if ((local_ex_mem_alu.range(0, 0) == 1))
                    local_rpred_rs = 1;
                else
                    local_rpred_rs = 0;
            }

            if ((local_ex_mem_dest_reg == local_id_ex_rt)) {
                //                cout << sc_time_stamp() << " EX HAZARD: Predicate Forwarding B" << endl;

                if ((local_ex_mem_alu.range(0, 0) == 1))
                    local_rpred_rt = 1;
                else
                    local_rpred_rt = 0;
            }
        }

        //ex_mem HI LO forward
        if (local_ex_mem_Wb_control.hilo_w_enable == sc_logic('1')) {
            if (local_id_ex_hilo_read == sc_logic('1')) {
                switch (local_id_ex_hilo_addr) {
                    case LO_RF_ADDR:
                        local_hilo_data = local_ex_mem_lo;
                        break;
                    case HI_RF_ADDR:
                        local_hilo_data = local_ex_mem_hi;
                        break;
                    default:
                        break;
                }
            }
        }

        //mem_wb forward
        if (local_mem_wb_reg_w_enable == sc_logic('1') || local_mem_wb_c_mov == sc_logic('1')) {
            // MEM Hazard
            if ((local_mem_wb_dest_reg != 0) &&
                    (local_ex_mem_dest_reg != local_id_ex_rs) && (local_mem_wb_dest_reg == local_id_ex_rs)) {
                //cout << sc_time_stamp() << " MEM HAZARD: Forwarding A: "  << local_mem_wb_w_data <<  endl;
                local_alu_a = local_mem_wb_w_data;
            }

            if ((local_mem_wb_dest_reg != 0) &&
                    (local_ex_mem_dest_reg != local_id_ex_rt) && (local_mem_wb_dest_reg == local_id_ex_rt)) {
                //cout << "MEM HAZARD: Forwarding B"  <<  endl;
                //cout << "local_alu_b: " << local_alu_b << " local_mem_wb_w_data: " << local_mem_wb_w_data << endl;
                local_alu_b = local_mem_wb_w_data;
            }

            //Memory ld/st forwarding
            if ((local_ex_mem_Wb_control.memory_w_enable == sc_logic('1')) &&
                    (local_mem_wb_dest_reg != 0) &&
                    local_mem_wb_dest_reg == local_ex_mem_rt) {

                // cout << "Memory ld/st forwarding " << sc_time_stamp() << " :" << local_mem_wb_ram_datain <<  "  " << local_ram_data << endl;
                local_ram_data = local_mem_wb_ram_datain;
            }
        }

        //mem_wb predicates forward
        //        if ((local_mem_wb_rpred_write == sc_logic('1')) &&
        //                (local_id_ex_Wb_control.rf_predic_w_enable == sc_logic('1'))) {
        if ((local_mem_wb_rpred_write == sc_logic('1'))) {
            // MEM Hazard
            if ((local_ex_mem_dest_reg != local_id_ex_rs) && (local_mem_wb_dest_reg == local_id_ex_rs)) {
                //cout << "MEM HAZARD: Predicate Forwarding A"  <<  endl;

                if (local_mem_wb_pred_data == sc_logic('1'))
                    local_rpred_rs = 1;
                else
                    local_rpred_rs = 0;

                //local_rpred_rs = local_mem_wb_pred_data;

            }

            if ((local_ex_mem_dest_reg != local_id_ex_rt) && (local_mem_wb_dest_reg == local_id_ex_rt)) {
                //cout << "MEM HAZARD: Predicate Forwarding A"  <<  endl;

                if (local_mem_wb_pred_data == sc_logic('1'))
                    local_rpred_rt = 1;
                else
                    local_rpred_rt = 0;

                //local_rpred_rt = local_mem_wb_pred_data;
            }
        }


        //mem_wb HI LO forward
        if (local_mem_wb_hilo_write == sc_logic('1')) {
            //ex_mem_Wb tested, move to register always new values
            if (local_id_ex_hilo_read == sc_logic('1') &&
                    (local_ex_mem_Wb_control.hilo_w_enable != sc_logic('1'))) {
                if (local_id_ex_hilo_read == sc_logic('1')) {
                    switch (local_id_ex_hilo_addr) {
                        case LO_RF_ADDR:
                            local_hilo_data = local_mem_wb_lo;
                            break;
                        case HI_RF_ADDR:
                            local_hilo_data = local_mem_wb_hi;
                            break;
                        default:
                            break;
                    }
                }
                //				cout << "mem_wb HILO forward" << endl;
            }
        }

        //Forward predicates to control unit (BRANCH and CMOV instructions) -- WB forward
        if (local_mem_wb_rpred_write == sc_logic('1')) {
            if ((local_if_id_rs == local_mem_wb_dest_reg)) {
                //cout << "WB pred forward" << endl;

                local_id_pred_data = local_mem_wb_pred_data;
            }
        }


        //Forward predicates to control unit (BRANCH and CMOV instructions) -- MEM forward
        if (local_ex_mem_Wb_control.rf_predic_w_enable == sc_logic('1')) {
            if ((local_if_id_rs == local_ex_mem_dest_reg)) {
                //cout << "MEM pred forward" << endl;

                if (local_ex_mem_alu.range(0, 0) == 1)
                    local_id_pred_data = sc_logic(sc_logic('1'));
                else
                    local_id_pred_data = sc_logic(sc_logic('0'));

            }
        }

        //Forward predicates to control unit (BRANCH and CMOV instructions) -- EX forward
        if (local_id_ex_Wb_control.rf_predic_w_enable == sc_logic('1')) {
            if ((local_if_id_rs == local_id_ex_dest_reg)) {
                //cout << "EX pred forward" << endl;

                if (local_id_ex_alu.range(0, 0) == 1)
                    local_id_pred_data = sc_logic(sc_logic('1'));
                else
                    local_id_pred_data = sc_logic(sc_logic('0'));

            }
        }

        //////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////
        /////////////       FORWARD to RS in ID stage     ////////////////
        //////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////


        //Forward rs to ID stage unit (JR instructions) -- WB forward
        if (local_mem_wb_reg_w_enable == sc_logic('1')) {
            if ((local_if_id_rs == local_mem_wb_dest_reg)) {
                //cout << "WB jmp forward" << endl;

                local_if_id_rs_out = local_mem_wb_w_data;
            }
        }

        //Forward rs to ID stage unit (JR instructions) -- EX_MEM forward
        if (local_ex_mem_Wb_control.reg_w_enable == sc_logic('1')) {
            if ((local_if_id_rs == local_ex_mem_dest_reg)) {
                //cout << "MEM jmp forward" << endl;

                if (local_ex_mem_Wb_control.memory_rd_enable == sc_logic('1'))
                    local_if_id_rs_out = local_mem_data;
                else
                    local_if_id_rs_out = local_ex_mem_alu;
            }
        }

        //Forward predicates to control unit (BRANCH and CMOV instructions) -- EX forward
        if (local_id_ex_Wb_control.reg_w_enable == sc_logic('1')) {
            if ((local_if_id_rs == local_id_ex_dest_reg)) {
                //cout << "EX jmp forward" << endl;

                local_if_id_rs_out = local_id_ex_alu;

            }
        }

        if_id_rs_out.write(local_if_id_rs_out);
        if_id_pred_s_out.write(local_id_pred_data);

        rpred_rs_value_out.write(local_rpred_rs);
        rpred_rt_value_out.write(local_rpred_rt);
        hilo_data_out.write(local_hilo_data);

        
        ram_data_out.write(local_ram_data);
        alu_a_out.write(local_alu_a);
        alu_b_out.write(local_alu_b);
    }
};
