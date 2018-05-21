#include <systemc.h>
#include "cpu.h"
#include "j_b_mux.h"

void cpu::do_stall_halt() {
    sc_logic local_ctrl_rom_rd;
    sc_logic local_ctrl_pc_inc;
    sc_logic local_ctrl_if_id_load;
    sc_logic local_hazard_stall;
    sc_logic local_cache_stall;
    sc_logic local_mem_stall;
    sc_logic no_stall;
    sc_logic local_halted;

    local_ctrl_if_id_load = ctrl_if_id_load.read();
    local_ctrl_rom_rd = ctrl_rom_rd.read();
    local_ctrl_pc_inc = ctrl_pc_inc.read();
    local_hazard_stall = hazd_stall.read();
    local_cache_stall = i_cache_stall.read();
    local_mem_stall = mem_stall.read();
    local_halted = stop.read();

    no_stall = (local_hazard_stall | local_cache_stall | local_mem_stall);

    if (local_hazard_stall == sc_logic('1') || local_cache_stall == sc_logic('1')) {
        //stop PC increment, IF ID register and ROM
        pc_inc.write(sc_logic('0'));
        rom_rd.write(sc_logic('0'));

        if_id_load.write(sc_logic('0'));
    }

    if (local_mem_stall == sc_logic('1')) {
        pc_inc.write(sc_logic('0'));
        rom_rd.write(sc_logic('0'));

        if_id_load.write(sc_logic('0'));
        id_ex_load.write(sc_logic('0'));
        ex_mem_load.write(sc_logic('0'));
        mem_wb_load.write(sc_logic('0'));
    } else {
        id_ex_load.write(sc_logic('1'));
        ex_mem_load.write(sc_logic('1'));
        mem_wb_load.write(sc_logic('1'));
    }


    if (no_stall == sc_logic('0')) {
        pc_inc.write(local_ctrl_pc_inc);
        rom_rd.write(local_ctrl_rom_rd);

        id_ex_load.write(sc_logic('1'));
        if_id_load.write(local_ctrl_if_id_load);
        ex_mem_load.write(sc_logic('1'));
    }


    if (local_halted == sc_logic('1')) {
        pc_inc.write(sc_logic('0'));
        rom_rd.write(sc_logic('0'));

        if_id_load.write(sc_logic('0'));
        id_ex_load.write(sc_logic('0'));
        ex_mem_load.write(sc_logic('0'));

        halted.write(sc_logic('1'));
        //cout << "Stop @ " << sc_time_stamp() << endl;
    }

}

void cpu::calc_halt_time() {
    sc_logic local_halted = stop.read();

    if (local_halted == sc_logic('1')) {
        sc_time cpu_time = sc_time_stamp()
                - sc_time(INIT_RESET_TIME, SC_NS)
                + sc_time(CPU_CYCLE_TIME, SC_NS);

        cycles =cpu_time.value() / 20e3;
    }
}

void cpu::do_neg_clock() {
    if (clk.read() == 1)
        neg_clk.write(false);
    else
        neg_clk.write(true);
}

void cpu::do_pc_signed() {
    pc_register_signed.write(pc_register.read().to_int());
    pc_adder_result_int.write(pc_adder_result.read().to_int());
    j_target.write(j_target_int.read().to_uint());
}

void cpu::do_zero() {
    jal_offset.write(1);
    zero.write(0);
    u_zero.write(0);

    if (single_cycle_fetch == 1)
        i_cache_stall.write(sc_logic('0'));
}

void cpu_hmonitor::do_monitor() {
    if (in.read() == sc_logic('1'))
        sc_stop();
}

int cpu::get_ini_address() {
    return ini_address;
}

int cpu::get_end_address() {
    return end_address;
}