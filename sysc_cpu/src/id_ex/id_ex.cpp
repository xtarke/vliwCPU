#include "id_ex.h"

void id_ex::id_ex_write() {
    sc_logic local_reset;
    sc_logic local_load;
    sc_logic local_bubble;

    sc_logic local_mem_adder;
    sc_logic local_if_id_reset;
    sc_logic local_hilo_rd_enable;
    sc_uint<2> local_hilo_addr;
    sc_int<WORD_SIZE> local_hilo_rf_data;
    WbControl local_Wb_control;
    sc_uint<REG_ADDR_SIZE> local_dest_reg;
    sc_uint<WORD_SIZE> local_pc;
    sc_uint<WORD_SIZE> local_instrunction;
    sc_int<WORD_SIZE> local_rs_value;
    sc_int<WORD_SIZE> local_rt_value;
    sc_logic local_p_rs;
    sc_logic local_p_rt;
    sc_int<WORD_SIZE> local_imediate_sig;
    sc_int<WORD_SIZE> local_imediate_zero;
    sc_uint<MAX_MUX_PORTS> local_alu_pa_sel;
    sc_uint<MAX_MUX_PORTS> local_alu_pb_sel;
    sc_uint<ALUOPS> local_alu_op;
    sc_uint<SHAMT_SIZE> local_alu_shamt;

    local_reset = reset.read();
    local_load = load.read();
    local_bubble = bubble_in.read();

    //ra_value and rb_value is assync read because RF updates the value in neg
    //edge that is the same edge ID_EX read the new inputs
    local_rs_value = rs_value_in.read();
    local_rt_value = rt_value_in.read();
    local_p_rs = rpred_rs_value_in.read();
    local_p_rt = rpred_rt_value_in.read();

    local_mem_adder = mem_adder.read();
    local_if_id_reset = if_id_reset.read();
    local_hilo_rd_enable = hilo_rd_enable.read();
    local_hilo_addr = hilo_addr.read();
    local_hilo_rf_data = hilo_rf_data_in.read();
    local_Wb_control = Wb_control.read();
    local_dest_reg = dest_reg.read();
    local_pc = pc.read();
    local_instrunction = instrunction.read();
    local_imediate_sig = immediate_sigext.read();
    local_imediate_zero = immediate_zeroext.read();
    local_alu_pa_sel = alu_pa_sel.read();
    local_alu_pb_sel = alu_pb_sel.read();
    local_alu_op = alu_op.read();
    local_alu_shamt = alu_shamt.read();

    if (local_reset == 1) {
        pc_out.write(0);
        pc_out.write(0);
        rs_out.write(0);
        rd_out.write(0);
        rt_out.write(0);
        instrunction_out.write(0);
        bubble_out.write(sc_logic('0'));
        alu_op_out.write(0);
        alu_shamt_out.write(0);
        alu_pa_sel_out.write(0);
        alu_pb_sel_out.write(0);

        hilo_rd_enable_out.write(sc_logic('0'));
        hilo_addr_out.write(0);
        hilo_rf_data_out.write(0);

        if_id_reset_out.write(sc_logic('0'));
        mem_adder_enable_out.write(sc_logic('0'));

        dest_reg_out.write(0);
        local_Wb_control.reset();
        ctrl_wb_signals_out.write(local_Wb_control);
    } else if (local_load == 1 && clk.posedge()) {

        bubble_out.write(local_bubble);
        pc_out.write(local_pc.to_int());
        immed_sigext_out.write(local_imediate_sig);
        immed_zeroext_out.write(local_imediate_zero);

        rs_value_out.write(local_rs_value);
        rt_value_out.write(local_rt_value);

        //ALU is 32bits
        if (local_p_rs == sc_logic('1'))
            rpred_rs_value_out.write(1);
        else
            rpred_rs_value_out.write(0);

        if (local_p_rt == sc_logic('1'))
            rpred_rt_value_out.write(1);
        else
            rpred_rt_value_out.write(0);

        if_id_reset_out.write(local_if_id_reset);

        rs_out.write(local_instrunction.range(RS_INI, RS_END));
        rd_out.write(local_instrunction.range(RD_INI, RD_END));
        rt_out.write(local_instrunction.range(RT_INI, RT_END));

        alu_op_out.write(local_alu_op);
        alu_shamt_out.write(local_alu_shamt);
        alu_pa_sel_out.write(local_alu_pa_sel);
        alu_pb_sel_out.write(local_alu_pb_sel);

        hilo_rd_enable_out.write(local_hilo_rd_enable);
        hilo_addr_out.write(local_hilo_addr);
        hilo_rf_data_out.write(local_hilo_rf_data);

        mem_adder_enable_out.write(local_mem_adder);

        dest_reg_out.write(local_dest_reg);
        ctrl_wb_signals_out.write(local_Wb_control);

        //debug
        instrunction_out.write(local_instrunction);
    }
};

void id_ex::id_ex_read() {
    sc_logic local_mem_adder;
    sc_logic local_if_id_reset;
    sc_logic local_hilo_rd_enable;

    sc_uint<2> local_hilo_addr;
    sc_int<WORD_SIZE> local_hilo_rf_data;
    WbControl local_Wb_control;
    sc_uint<REG_ADDR_SIZE> local_dest_reg;
    sc_uint<WORD_SIZE> local_pc;
    sc_uint<WORD_SIZE> local_instrunction;

    sc_int<WORD_SIZE> local_immediate_sig;
    sc_int<WORD_SIZE> local_immediate_zero;
    sc_uint<MAX_MUX_PORTS> local_alu_pa_sel;
    sc_uint<MAX_MUX_PORTS> local_alu_pb_sel;
    sc_uint<ALUOPS> local_alu_op;
    sc_uint<SHAMT_SIZE> local_alu_shamt;

    local_pc = pc_in.read();
    local_instrunction = instrunction_in.read();
    local_immediate_sig = immed_sigext_in.read();
    local_immediate_zero = immed_zeroext_in.read();
    local_alu_op = alu_op_in.read();
    local_alu_pa_sel = alu_pa_sel_in.read();
    local_alu_pb_sel = alu_pb_sel_in.read();
    local_alu_shamt = alu_shamt_in.read();

    local_hilo_rd_enable = hilo_rd_enable_in.read();
    local_hilo_addr = hilo_addr_in.read();
    //local_hilo_rf_data = hilo_rf_data_in.read();

    local_Wb_control = ctrl_wb_signals_in.read();
    local_dest_reg = dest_reg_in.read();

    local_if_id_reset = if_id_reset_in.read();
    local_mem_adder = mem_adder_enable_in.read();

    if (clk.negedge()) {
        pc.write(local_pc);
        instrunction.write(local_instrunction);
        immediate_sigext.write(local_immediate_sig);
        immediate_zeroext.write(local_immediate_zero);
        alu_op.write(local_alu_op);
        alu_pa_sel.write(local_alu_pa_sel);
        alu_pb_sel.write(local_alu_pb_sel);
        alu_shamt.write(local_alu_shamt);

        hilo_rd_enable.write(local_hilo_rd_enable);
        hilo_addr.write(local_hilo_addr);
        //hilo_rf_data.write(local_hilo_rf_data);

        Wb_control.write(local_Wb_control);
        dest_reg = dest_reg_in.read();

        if_id_reset.write(local_if_id_reset);
        mem_adder.write(local_mem_adder);
    }
}
