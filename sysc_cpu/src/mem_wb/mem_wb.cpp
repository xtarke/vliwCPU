#include "mem_wb.h"
#include "controller_types.h"

void mem_wb::mem_wb_write() {
    sc_logic local_reset;
    sc_logic local_load;
    sc_logic local_mem_stall;

    WbControl local_Wb_control;
    sc_uint<REG_ADDR_SIZE> local_dest_reg;
    sc_int<WORD_SIZE> local_hi;
    sc_int<WORD_SIZE> local_lo;
    sc_int<WORD_SIZE> local_memory_w_data;
    sc_uint<WORD_SIZE> local_memory_addr;
    sc_int<WORD_SIZE> local_alu;
    sc_int<WORD_SIZE> local_hilo_rf_data;
    sc_int<WORD_SIZE> local_memory_data;
    sc_int<WORD_SIZE> local_pc;
    sc_logic local_reg_w_enable;
    sc_lv<2> local_reg_w_select;
    sc_logic local_hilo_w_enable;
    sc_int<3> local_reg_w_select_uint;
    sc_uint<WORD_SIZE> local_ins;

    //assync read
    local_reset = reset.read();
    local_load = load.read();
    local_mem_stall = mem_stall.read();
    local_memory_w_data = memory_w_data_in.read();
    local_memory_data = memory_data_in.read();

    //sync read
    local_Wb_control = Wb_control.read();
    local_reg_w_enable = local_Wb_control.reg_w_enable;
    local_reg_w_select = local_Wb_control.reg_w_select;
    local_hilo_w_enable = local_Wb_control.hilo_w_enable;
    local_dest_reg = dest_reg.read();
    local_hi = hi.read();
    local_lo = lo.read();
    local_memory_addr = memory_addr.read();
    local_alu = alu.read();
    local_hilo_rf_data = hilo_rf_data.read();
    local_pc = pc.read().to_int();
    local_ins = ins.read();

    if (local_reset == 1) {
        memory_w_enable_out.write(sc_logic('0'));
        reg_w_enable_out.write(sc_logic('0'));
        reg_w_data_out.write(0);
        memory_w_data_out.write(0);
        memory_addr_out.write(0);
        pred_wr_enable.write(sc_logic('0'));
        halt_out.write(sc_logic('0'));
        cmov_out.write(sc_logic('0'));
    } else if (local_load == 1 && clk.posedge()) {
        //memory data is read here because RAM ouput
        //is in neg edgde, so data is ready only here
        //same occurs when forwarding ALU inputs thats comes
        //from memory
        //		local_memory_data = memory_data_in.read();
        //		local_hi = hi_in.read();
        //		local_lo = lo_in.read();
        //		local_alu = alu_in.read();

        //stop simulation
        // -- halt instruction
        if (local_Wb_control.halt == sc_logic('1'))
            halt_out.write(sc_logic('1'));
        // -- single fetch mode
        if (((final_address == local_pc)) && (local_Wb_control.hazard == sc_logic('0')) &&
                (single_cycle_fetch == 1))
            halt_out.write(sc_logic('1'));
        // -- no cache and no single fetch mode
        if ((final_address == local_pc) && (single_cycle_fetch == 0))
        {
        //    cout << sc_time_stamp();
            halt_out.write(sc_logic('1'));
        }


        cmov_out.write(local_Wb_control.cmov);
        dest_reg_out.write(local_dest_reg);
        reg_w_enable_out.write(local_reg_w_enable);
        hilo_w_enable_out.write(local_hilo_w_enable);

        hi_out.write(local_hi);
        lo_out.write(local_lo);

        memory_w_data_out.write(local_memory_w_data);
        memory_addr_out.write(local_memory_addr);

        instrunction_out.write(ins.read());

        pred_wr_enable = local_Wb_control.rf_predic_w_enable;

        if (local_alu.range(0, 0) == 0)
            pred_data_out = sc_logic('0');
        else
            pred_data_out = sc_logic('1');

        if (local_Wb_control.memory_w_enable == sc_logic('1'))
            memory_w_enable_out.write(sc_logic('1'));
        else
            memory_w_enable_out.write(sc_logic('0'));

        //implemented to reduce warning when local_reg_w_select is 'X or Z'
        if ((local_reg_w_select.get_bit(0) != sc_logic('0')) &&
                (local_reg_w_select.get_bit(0) != sc_logic('1')))
            return;

        local_reg_w_select_uint = local_reg_w_select.to_uint();

        //		cout << "local_reg_w_select_uint: " << local_reg_w_select_uint << endl;
        //		cout << "local_reg_w_select: " << local_reg_w_select << endl;

        // internal mux: selects data from HILO rf, alu or memory
        switch (local_reg_w_select_uint) {
            case TO_NUMBER(WB_MUX_ALU):
                reg_w_data_out.write(local_alu);
                break;
            case TO_NUMBER(WB_MUX_HILO_RF):
                reg_w_data_out.write(local_hilo_rf_data);
                break;
            case TO_NUMBER(WB_MUX_MEMORY):
                reg_w_data_out.write(local_memory_data);
                break;
            default:
                break;
        }

    }
};

void mem_wb::mem_wb_read() {
    WbControl local_Wb_control;
    sc_uint<REG_ADDR_SIZE> local_dest_reg;
    sc_int<WORD_SIZE> local_hi;
    sc_int<WORD_SIZE> local_lo;
    sc_uint<WORD_SIZE> local_memory_addr;
    sc_int<WORD_SIZE> local_alu;
    sc_int<WORD_SIZE> local_hilo_rf_data;
    sc_int<WORD_SIZE> local_pc;
    sc_uint<WORD_SIZE> local_ins;
    sc_int<WORD_SIZE> local_memory_data;

    //read all Wb controll bits
    local_Wb_control = ctrl_wb_signals_in.read();
    local_dest_reg = dest_reg_in.read();
    local_hi = hi_in.read();
    local_lo = lo_in.read();
    local_memory_addr = memory_addr_in.read();
    local_alu = alu_in.read();
    local_hilo_rf_data = hilo_rf_data_in.read();
    local_pc = pc_in.read().to_int();

    local_ins = instrunction_in.read();

    if (clk.negedge()) {
        Wb_control.write(local_Wb_control);

        dest_reg.write(local_dest_reg);
        hi.write(local_hi);
        lo.write(local_lo);
        memory_addr.write(local_memory_addr);
        alu.write(local_alu);
        hilo_rf_data.write(local_hilo_rf_data);
        pc.write(local_pc);

        ins.write(local_ins);

    }
}
