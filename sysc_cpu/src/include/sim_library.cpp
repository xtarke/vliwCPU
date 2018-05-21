/*
 * sim_library.cpp
 *
 *  Created on: May 27, 2013
 *      Author: xtarke
 */

#include "sim_library.h"
#include "systemc.h"

//#define DEBUG

cpu_sim::cpu_sim(const char* file_name,  lib_pipeline_type pipe_mode) {
    cpu_info info;
    
    cache_index_size = INDEX_SIZE;
    cache_index_ini = INDEX_INI;
    cache_index_end = INDEX_END;

    cache_tag_ini = TAG_INI;

    cache_bk_offset_size = BK_OFFSET_SIZE;
    cache_bk_offset_ini = BK_OFFSET_INI;
    cache_bk_offset_end = BK_OFFSET_END;

    cache_blocks = CACHE_BLOCKS;
    cache_block_size = BLOCK_SIZE;
    cache_size = cache_blocks * cache_block_size;

    ram_size = RAM_SIZE;
    scratchpad_size = SCRATCHPAD_SIZE;

    rom_size = ROM_SIZE;

    mem_cycle_time = MEM_CYCLE_TIME;
    cpu_cycle_time = CPU_CYCLE_TIME;

    //number of cpu cycles in each cache miss
    //= (number of cache blocks to load + alignment frequency cycles) * mem_time
    //  -------------------------------------------------------------------------
    //                              cpu_time
    cache_penalty_cycles = info.get_cache_penalty_cycles();
    umem_access_cycles = info.get_umem_access_cycles();
    
    sim_pipe_mode = pipe_mode;
    
    
    FILE *file;
    size_t result;
    std::stringstream out;
    std::string msg;

#ifdef DEBUG
    out.clear();
    out << "Opening linked image: " << file_name;
    msg = out.str();
    
    SC_REPORT_INFO(1, msg.c_str());
#endif
    
    file = fopen(file_name, "rb");

    if (file != NULL) {
        // obtain file size:
        fseek(file, 0, SEEK_END);
        file_size = ftell(file);
        rewind(file);

#ifdef DEBUG
        out.str(std::string());
        out << "Binary file size: " << file_size / 4;
        msg = out.str();
        SC_REPORT_INFO(1, msg.c_str());
#endif
        sc_assert((file_size / 4) <= IMAGE_SIZE);

        result = fread(buffer, 1, file_size, file);

        if (result != file_size) {
            fputs("Reading error", stderr);
            exit(3);
        }
    }
}

void cpu_sim::sim() {
    // Clock
#ifndef DEBUG
    sc_report_handler::set_actions(SC_WARNING, SC_DO_NOTHING);
    sc_report_handler::set_actions(SC_INFO, SC_DO_NOTHING);
#endif

    sc_clock clk("clk", CPU_CYCLE_TIME, SC_NS);
    //mem clock, must be multiple of clk
    sc_clock mem_clk("mem_clk", MEM_CYCLE_TIME, SC_NS);
    sc_signal<sc_logic> reset;

    sc_signal<sc_logic> *halted;

#ifdef DEBUG
    sc_trace_file *tf = sc_create_vcd_trace_file("trace");
    tf->set_time_unit(1, SC_PS);
#endif

    stimuli *STI;
    siml_hmonitor *HALT_MON;

    // Module instantiations and Mapping
    STI = new stimuli("STIMULUS", INIT_RESET_TIME);
    STI->reset(reset);

    HALT_MON = new siml_hmonitor("HALT_MONITOR", sim_datalist.size());

    halted = new sc_signal<sc_logic> [sim_datalist.size()];

#ifdef DEBUG
    sc_trace(tf, clk, "clk");
    sc_trace(tf, mem_clk, "mem_clk");
    sc_trace(tf, reset, "reset");
#endif

    for (unsigned int i = 0; i < sim_datalist.size(); i++) {
        sim_data *data = sim_datalist[i];

        data->CPU_CORE->clk(clk);
        data->CPU_CORE->mem_clk(mem_clk);
        data->CPU_CORE->reset(reset);
        data->CPU_CORE->halted(halted[i]);

        HALT_MON->in[i](halted[i]);

        //cout << "cpu: " << i << endl;

        //CPU memory initialization
        for (unsigned int j = 1; j < file_size / 4; j++) {
            data->CPU_CORE->MEMORY->memory_data[j-1] = (buffer[j]);
            //fake rom, simulation ignores instruction cache
            if (sim_pipe_mode == SINGLE_CYC_FETCH)
                data->CPU_CORE->ROM->memory_data[j-1] = (buffer[j]);
        }

#ifdef DEBUG
        sc_trace(tf, data->CPU_CORE->rom_data_out, "F");
        sc_trace(tf, data->CPU_CORE->if_id_instrunction, "D");
        sc_trace(tf, data->CPU_CORE->id_ex_instrunction, "E");
        sc_trace(tf, data->CPU_CORE->ex_mem_instrunction, "M");
        sc_trace(tf, data->CPU_CORE->mem_wb_instrunction, "WB");
        sc_trace(tf, data->CPU_CORE->ctrl_pc_load, "pc_ld");
        sc_trace(tf, data->CPU_CORE->pc_register, "pc");
        sc_trace(tf, data->CPU_CORE->j_target, "j_target");

        sc_trace(tf, data->CPU_CORE->forward_id_rs, "for_r31");


        sc_trace(tf, data->CPU_CORE->RF->register_banc[0]->reg_out, "r0");
        sc_trace(tf, data->CPU_CORE->RF->register_banc[1]->reg_out, "r1");
        sc_trace(tf, data->CPU_CORE->RF->register_banc[2]->reg_out, "r2");
        sc_trace(tf, data->CPU_CORE->RF->register_banc[3]->reg_out, "r3");
        sc_trace(tf, data->CPU_CORE->RF->register_banc[4]->reg_out, "r4");
        sc_trace(tf, data->CPU_CORE->RF->register_banc[5]->reg_out, "r5");
        sc_trace(tf, data->CPU_CORE->RF->register_banc[30]->reg_out, "r30");
        sc_trace(tf, data->CPU_CORE->RF->register_banc[31]->reg_out, "r31");

        sc_trace(tf, data->CPU_CORE->spram_dataout, "sram");

        sc_trace(tf, data->CPU_CORE->forward_ram_datain, "forward_ram_datain");

        sc_trace(tf, data->CPU_CORE->mem_wb_memory_enable, "wr");
        sc_trace(tf, data->CPU_CORE->mem_ctrl_spram_rd, "rd");

        sc_trace(tf, data->CPU_CORE->mem_wb_spram_w_data, "r_data_in");
        sc_trace(tf, data->CPU_CORE->mem_ctrl_spram_w_data, "m_ctr");


        sc_trace(tf, data->CPU_CORE->MEM_WB->halt_out, "halt");
#endif

    }

    sc_start(100000, SC_NS);

#ifdef DEBUG
    sc_close_vcd_trace_file(tf);

    for (unsigned int i = 0; i < sim_datalist.size(); i++) {
        cout << "cpu_" << dec << i << ":" <<  sim_datalist[i]->CPU_CORE->get_ini_address() << ":" 
                <<  sim_datalist[i]->CPU_CORE->get_end_address() << ": " << 
                sim_datalist[i]->CPU_CORE->cycles << endl;
    }
#endif

    //delete[] halted;

}

void cpu_sim::add_block(int id, uint32_t ini_addr, uint32_t end_addr) {
    sim_data *new_data = new sim_data(id, ini_addr, end_addr, sim_pipe_mode);

    sc_assert(ini_addr <= end_addr);

    sim_datalist.push_back(new_data);
}

void siml_hmonitor::do_monitor() {
    int halted = 0;

    for (int i = 0; i < n_inputs; i++) {
        status[i] = in[i].read();
        if (status[i] == sc_logic('1'))
            halted++;
    }

    if (halted == n_inputs)
        sc_stop();
}
