#include "systemc.h"
#include "cpu.h"
#include "stimuli.h"
#include <sys/types.h>
#include <getopt.h>
#include "include/sim_library.h"

static int parse_command_line(int argc, char** argv, int*type);
static void print_help();
static void print_cpu_info();

static const struct option long_options[] = {
    { "file", required_argument, NULL, 'f'},
    { "no-cache", no_argument, NULL, 'c'},
    { "s-fetch", no_argument, NULL, 's'},
    { "ini", required_argument, NULL, 'i'},
    { "end", required_argument, NULL, 'e'},
    //    { "prlse-points", required_argument, NULL, 'p'},
    { "quiet", no_argument, NULL, 'q'},
    { "info", no_argument, NULL, 'p'},
    { "dump", no_argument, NULL, 'd'},
    { "help", no_argument, NULL, 'h'},
    { NULL, no_argument, NULL, 0}
};

static char* filename;
static int nocache = 0;
static int single_cycle_fecth = 0;
static unsigned int ini_address = 0;
static unsigned int end_address = ROM_INI + ROM_SIZE;
static int quiet = 0;
static int dump = 0;

int sc_main(int argc, char *argv[]) {
    FILE *file;
    size_t result;
    uint32_t buffer[MEMORY_SIZE_WORDS];

    unsigned long file_size;
    int type = -1;

    // Signals
    sc_signal<sc_logic> reset;
    sc_signal<sc_logic> halt;

    // Clock
    sc_clock clk("clk", CPU_CYCLE_TIME, SC_NS);
    //mem clock, must be multiple of clk
    sc_clock mem_clk("mem_clk", MEM_CYCLE_TIME, SC_NS);

    // Module
    cpu *CPU0;
    stimuli *STI;
    cpu_hmonitor *HALT_MON;

    parse_command_line(argc, argv, &type);

    if (ini_address > 0 || end_address > 0)
        sc_assert(ini_address <= end_address);

    if (quiet == 1) {
        sc_report_handler::set_actions(SC_WARNING, SC_DO_NOTHING);
        sc_report_handler::set_actions(SC_INFO, SC_DO_NOTHING);
    }

    //Parameterized Module instantiations
    //Configurable address simulation
    if (ini_address != 0 && end_address != ROM_INI + ROM_SIZE) {
        cout << "WCET MODE" << endl;
        if (single_cycle_fecth == 1) {
            //Single fetch mode
            //single cycle fetch implies no cache and basic rom
            nocache = 1;
            CPU0 = new cpu("CPU0", 1, ini_address, end_address, WCET, quiet, 1);
        } else {
            CPU0 = new cpu("CPU0", nocache, ini_address, end_address, WCET, quiet, 0);
        }
    } else
        //Normal simulation (all binary file)
    {
        if (single_cycle_fecth == 1) {
            //single fetch mode
            //single cycle fetch implies no cache and basic rom
            nocache = 1;
            CPU0 = new cpu("CPU0", 1, ini_address, end_address, NORMAL, quiet, 1);
        } else if (nocache == 1) {
            //slow memory fetch mode
            CPU0 = new cpu("CPU0", nocache, ini_address, end_address, NORMAL, quiet);
        } else
            //normal mode
            CPU0 = new cpu("CPU0", nocache, ini_address, end_address, NORMAL, quiet);

    }
    
    // Standard Module instantiations and Mapping
    STI = new stimuli("STIMULUS", INIT_RESET_TIME);
    STI->reset(reset);

    HALT_MON = new cpu_hmonitor("halt_monitor");
    HALT_MON->in(halt);

    CPU0->clk(clk);
    CPU0->mem_clk(mem_clk);
    CPU0->reset(reset);
    CPU0->halted(halt);

    if (quiet == 0) {
        // trace file
        sc_trace_file *tf = sc_create_vcd_trace_file("trace");
        tf->set_time_unit(1, SC_PS);
        sc_trace(tf, clk, "clk");
        sc_trace(tf, mem_clk, "mem_clk");
        sc_trace(tf, reset, "reset");

        sc_trace(tf, CPU0->RF->register_banc[0]->reg_out, "r0");
        sc_trace(tf, CPU0->RF->register_banc[1]->reg_out, "r1");
        sc_trace(tf, CPU0->RF->register_banc[2]->reg_out, "r2");
        sc_trace(tf, CPU0->RF->register_banc[3]->reg_out, "r3");
        sc_trace(tf, CPU0->RF->register_banc[4]->reg_out, "r4");
        sc_trace(tf, CPU0->RF->register_banc[5]->reg_out, "r5");
        sc_trace(tf, CPU0->RF->register_banc[6]->reg_out, "r6");
        sc_trace(tf, CPU0->RF->register_banc[7]->reg_out, "r7");
        sc_trace(tf, CPU0->RF->register_banc[8]->reg_out, "r8");
        sc_trace(tf, CPU0->RF->register_banc[9]->reg_out, "r9");
        sc_trace(tf, CPU0->RF->register_banc[10]->reg_out, "r10");
        sc_trace(tf, CPU0->RF->register_banc[11]->reg_out, "r11");
        sc_trace(tf, CPU0->RF->register_banc[12]->reg_out, "r12");
        sc_trace(tf, CPU0->RF->register_banc[13]->reg_out, "r13");
        sc_trace(tf, CPU0->RF->register_banc[14]->reg_out, "r14");
        sc_trace(tf, CPU0->RF->register_banc[15]->reg_out, "r15");


        sc_trace(tf, CPU0->RF->register_banc[28]->reg_out, "r28");

        sc_trace(tf, CPU0->RF->register_banc[29]->reg_out, "r29");
        sc_trace(tf, CPU0->RF->register_banc[30]->reg_out, "r30");
        sc_trace(tf, CPU0->RF->register_banc[31]->reg_out, "r31");
        sc_trace(tf, CPU0->HI_LO->register_banc[0]->reg_out, "lo");
        sc_trace(tf, CPU0->HI_LO->register_banc[1]->reg_out, "hi");

        sc_trace(tf, CPU0->mem_stall, "stall_mem");
        sc_trace(tf, CPU0->hazd_stall, "stall_hzd");
        sc_trace(tf, CPU0->i_cache_stall, "stall_cac");
        sc_trace(tf, CPU0->ctrl_pc_load, "pc_ld");
        sc_trace(tf, CPU0->pc_register, "pc");

        sc_trace(tf, CPU0->rom_data_out, "F");
        sc_trace(tf, CPU0->if_id_instrunction, "D");
        sc_trace(tf, CPU0->id_ex_instrunction, "E");
        sc_trace(tf, CPU0->ex_mem_instrunction, "M");
        sc_trace(tf, CPU0->mem_wb_instrunction, "W");

        sc_trace(tf, CPU0->mem_ctrl_ram_data, "um_data");

        sc_trace(tf, CPU0->pc_adder_result, "j_targ");


        sc_trace(tf, CPU0->alu_pa_value, "alu_a");
        sc_trace(tf, CPU0->alu_pb_value, "alu_b");
        sc_trace(tf, CPU0->id_ex_shamt, "shamt");
        sc_trace(tf, CPU0->alu_out, "alu_out");
        sc_trace(tf, CPU0->alu_lo, "alu_lo");
        sc_trace(tf, CPU0->alu_hi, "alu_hi");
        sc_trace(tf, CPU0->id_ex_alu_op, "id_ex_alu_op");


        sc_trace(tf, CPU0->alu_pa_value, "alu_pa_value");
        sc_trace(tf, CPU0->id_ex_immed_sigext, "id_ex_immed_sigext");
        sc_trace(tf, CPU0->id_ex_immed_zeroext, "id_ex_immed_zeroext");
        sc_trace(tf, CPU0->mem_adder_result, "mem_adder_result");

        sc_trace(tf, CPU0->ex_mem_mem_address, "ex_mem_mem_address");


        sc_trace(tf, CPU0->MEM_CTRL->mem_addr, "mem_addr");

        sc_trace(tf, CPU0->mem_ctrl_ram_r_data, "ram_data_f");


        sc_trace(tf, CPU0->forward_alu_ra_value, "f_alu_ra");

        sc_trace(tf, CPU0->mem_wb_dest_reg, "mem_wb_dest_reg");
        sc_trace(tf, CPU0->id_ex_mem_adder_enable, "id_ex_mem_adder_enable");

        sc_trace(tf, CPU0->mem_wb_memory_enable, "sp_w");
        sc_trace(tf, CPU0->mem_ctrl_spram_rd, "sp_rd");
        sc_trace(tf, CPU0->spram_dataout, "sp_data");
        sc_trace(tf, CPU0->mem_wb_spram_w_data, "sp_data_in");

        sc_trace(tf, CPU0->MEM_CLK_pB->counter, "counter");
        sc_trace(tf, CPU0->mem_clk_pb, "clk_pb");
        sc_trace(tf, CPU0->mem_clk_pa, "clk_pa");

        sc_trace(tf, CPU0->MEM_CTRL->debug_state, "debug_state");

        if (nocache == 1 && single_cycle_fecth == 0) {
            sc_trace(tf, CPU0->SLOW_FETCH->debug_state, "fet_debug");
            sc_trace(tf, CPU0->SLOW_FETCH->done, "fet_done");

        }

        sc_trace(tf, CPU0->mem_ctrl_ram_rd, "ram_rd");
        sc_trace(tf, CPU0->mem_ctrl_ram_wr, "ram_wr");
        sc_trace(tf, CPU0->mem_ctrl_ram_addr, "ram_addr");
        sc_trace(tf, CPU0->ram_dataout, "ram_data");

        sc_trace(tf, CPU0->ctrl_wb_signals, "C_ctrl");
        sc_trace(tf, CPU0->id_ex_wb_signals, "X_ctrl");
        sc_trace(tf, CPU0->ex_mem_ctrl_wb_signals, "M_d_reg");

        sc_trace(tf, CPU0->mem_wb_reg_w_enable, "WB_reg_X");
        sc_trace(tf, CPU0->mem_wb_reg_w_data, "WB_data_R");

        sc_trace(tf, CPU0->id_ex_rs_value, "id_ex_rs_value");

        sc_trace(tf, CPU0->forward_hilo_data, "forward_hilo_data");

        sc_trace(tf, CPU0->mem_wb_lo, "mem_wb_lo");
        sc_trace(tf, CPU0->mem_wb_hilo_w_enable, "mem_wb_hilo_w");

        sc_trace(tf, CPU0->hilo_rf_data, "hilo_rf_data");

        sc_trace(tf, CPU0->ctrl_hilo_addr, "ctrl_hilo_addr");
        sc_trace(tf, CPU0->ctrl_hilo_rd_enable, "ctrl_hilo_rd_enable");

        sc_trace(tf, CPU0->id_ex_load, "id_ex_ld");

        sc_trace(tf, CPU0->id_ex_bubble, "id_ex_b");

        sc_trace(tf, CPU0->ctrl_mem_adder_enable, "ctrl_add_en");

        sc_trace(tf, CPU0->forward_ram_datain, "fram_datain");


        sc_trace(tf, CPU0->MEM_CTRL->pipe_read, "pipe_rd");
        sc_trace(tf, CPU0->MEM_CTRL->pipe_data, "pipe_data");


        sc_trace(tf, CPU0->cache_ram_clk_en, "cr_en");
        sc_trace(tf, CPU0->cache_rd_enable, "cache_rd_enable");
        sc_trace(tf, CPU0->cache_rd_addr, "cache_rd_addr");
        sc_trace(tf, CPU0->inst_mem_data_out, "inst_mem_data_out");

        sc_trace(tf, CPU0->ALU->result_doublew, "hi-lo");
        
        sc_trace(tf, CPU0->MEM_WB->halt_out, "halt");

        if (nocache == 0) {
            sc_trace(tf, CPU0->I_CACHE->debug_state, "c_state");
            sc_trace(tf, CPU0->cache_rd_addr, "cache_rd_addr");
        }
    }


    file = fopen(filename, "rb");
    if (file != NULL) {
        // obtain file size:
        fseek(file, 0, SEEK_END);
        file_size = ftell(file);
        rewind(file);

        // cout << "file_size: " << file_size / 4 << endl;

        sc_assert((file_size / 4) <= IMAGE_SIZE);

        result = fread(buffer, 1, file_size, file);

        if (result != file_size) {
            fputs("Reading error", stderr);
            exit(3);
        }

        uint16_t bin_cache_blocks = buffer[0] & 0x0000FFFF;
        uint16_t bin_cache_block_size = (buffer[0] & 0xFFFF0000) >> 16;

        assert(bin_cache_blocks == CACHE_BLOCKS);
        assert(bin_cache_block_size == BLOCK_SIZE);

        //CPU memory initialization
        for (unsigned int i = 1; i < file_size / 4; i++) {
            CPU0->MEMORY->memory_data[i - 1] = (buffer[i]);

            if (single_cycle_fecth == 1) {
                CPU0->ROM->memory_data[i - 1] = (buffer[i]);

            }
        }
    } else {
        fputs("\n\n******************************\n", stderr);
        fputs("Binary program loading error!\n", stderr);
        fputs("*******************************\n\n", stderr);
       
        exit(-1);
    }
    //sc_start(sc_time(1000, SC_NS));
    sc_start();

    //total_simulation - reset_time + 1 cycle (simulation is stopped when reach <end address> or
    //halt instruction in WB pipe stage)
    sc_time cpu_time = sc_time_stamp() - sc_time(INIT_RESET_TIME, SC_NS) + 
            sc_time(CPU_CYCLE_TIME, SC_NS);

    if (dump) {
        CPU0->MEMORY->dump_contents_dec();
        CPU0->MEMORY->dump_contents_hword();
        CPU0->MEMORY->dump_contents();

        CPU0->SP_MEM->dump_contents();
        CPU0->SP_MEM->dump_contents_hword();
    }


    if (quiet == 0) {
        cout << endl;
        CPU0->RF->dump_contents();
        CPU0->HI_LO->dump_contents();
        CPU0->RF_PRE->dump_contents();

        cout << dec;
        cout << filename << ": " << cpu_time.value() / 20e3 << " (" << cpu_time << ")" << endl;

        if (nocache == 0) {
            cout << "I-cache misses: " << CPU0->I_CACHE->misses << endl;
            cout << "I-cache hits: " << CPU0->I_CACHE->hits << endl;
        }
    } else {
        if (nocache == 0) {
            cout << filename << "," << cpu_time.value() / 20000 << "," << cpu_time << ",";
            cout << CPU0->I_CACHE->misses << "," << CPU0->I_CACHE->hits << endl;
        } else {
            cout << filename << "," << cpu_time.value() / 20000 << "," << cpu_time << endl;

        }
    }

    return 0;
};

static int parse_command_line(int argc, char** argv, int* type) {

    int c;

    while (1) {
        /* getopt_long stores the option index here. */
        int option_index = 0;

        c = getopt_long(argc, argv, "abc:d:f:",
                long_options, &option_index);

        /* Detect the end of the options. */
        if (c == -1) {
            break;
        }

        switch (c) {
            case 0:
                break;
                //input_file = (char*) strdup(optarg);
            case 'f':
                filename = strdup(optarg);
                break;
            case 'q':
                quiet = 1;
                break;
            case 's':
                single_cycle_fecth = 1;
                break;
            case 'c':
                nocache = 1;
                break;
            case 'd':
                dump = 1;
                break;
            case 'i':
                ini_address = atoi(optarg);
                break;
            case 'e':
                end_address = atoi(optarg);
                break;
            case 'p':
                print_cpu_info();
                exit(0);
            case 'h':
                print_help();
                exit(0);
        }
    }

    if (filename == NULL) {
        printf("Invalid or missing --file parameter\n");
        return -1;
    }

    return 0;

}

static void print_help() {
    puts("Usage:");

    cout << "./cpu --file <binary program filename>  (--nocache --ini <first address> --end <end_address>)\n\n";
    cout << "if --ini and --end are set, WCET mode is activated, simulation begins in --ini address and terminates\n"
            "in --end address. Program semantics is lost." << endl;
}

static void print_cpu_info() {
    cpu_info info;

    cout << "CPU_CLOCK: " << CPU_CYCLE_TIME << "\t";
    cout << "MEM_CLOCK: " << MEM_CYCLE_TIME << endl;
    cout << "CACHE_LINES: " << CACHE_BLOCKS << "\t";
    cout << "CACHE_BLOCKS: " << BLOCK_SIZE << "\t";
    cout << "Cache Penalty: " << info.get_cache_penalty_cycles() << endl;

}