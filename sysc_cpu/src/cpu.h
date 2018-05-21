#ifndef CPU_H
#define	CPU_H

#include "systemc.h"
#include "sizes.h"
#include "alu/alu.h"
#include "controller/debug.h"
#include "controller/controller.h"
#include "controller/controller_types.h"
#include "if_id/if_id.h"
#include "pc/pc.h"
#include "rf/rf.h"
#include "rf/rf_hilo.h"
#include "rf/rf_predic.h"
#include "rom/rom.h"
#include "sram/sram.h"
#include "mux3-1/mux3-1.h"
#include "id_ex/id_ex.h"
#include "ex_mem/ex_mem.h"
#include "mem_wb/mem_wb.h"
#include "adder/adder.h"
#include "mem_cont/mem_cont.h"
#include "mem_cont/fetch_cont.h"
#include "forward_unit/forw_unit.h"
#include "hazard_unit/haz_unit.h"
#include "mux/mux.h"
#include "umemory/umemory.h"
#include "cache/cache.h"
#include "clock/clock_gen.h"

enum MODE {
    SIM = 0,
    WCET
};

enum ALU_PA_MUX {
    RF_RS = 0,
    RFP_RS,
    RHILO,
    ZERO_PA,
    PC_OFFSET,
};

enum ALU_PB_MUX {
    RF_RT = 0,
    RFP_RT,
    INS_IMM_SIGEXT,
    INS_IMM_ZEROEXT,
    ZERO_PB,
    PC_PB
};

enum PC_LD_MUX {
    JUMP = 0,
    BRANCH,
    RS_VALUE
};

enum PC_ADDER_MUX {
    PC_ADDER_IMM = 0,
    PC_ADDER_JAL_OFFSET
};

SC_MODULE(cpu) {
    //input signals
    sc_in_clk clk;
    sc_in_clk mem_clk;

    sc_in<sc_logic> reset;
    sc_out<sc_logic> halted;

    //memory clocks
    clock_gen *MEM_CLK_pA;
    clock_gen *MEM_CLK_pB;
    
    //debugger
    debug *INS_DEBUGGER;

    //cpu controller
    controller *CPU_CTLR;
    //memory controller
    mem_control *MEM_CTRL;

    //pipeline registers
    if_id *IF_ID;
    id_ex *ID_EX;
    ex_mem *EX_MEM;
    mem_wb *MEM_WB;

    //forward and hazard units
    forw_unit *FORWD_UNIT;
    hazard_unit * HAZD_UNIT;

    //register
    pc *PC; //program counter
    rf *RF; //register file
    rf_hilo *HI_LO; //high and low (64-bits mult/div)
    rf_predic *RF_PRE; //predicates

    alu *ALU; //general propose ULA
    adder *MEM_ADDER; //memory calculation
    adder *PC_ADDER; //pc calculation

    //memories
    umemory *MEMORY; //Unified slow memory
    cache *I_CACHE; //Instruction cache
    sram *SP_MEM; //Scratchpad memory
    rom *ROM; //When simulated without cache
    
    fetch_cont *SLOW_FETCH; //When simulated without cache, read from main memory

    //muxes
    mux *ALU_PA_MUX; //ALU port a selection
    mux *ALU_PB_MUX; //ALU port b selection
    mux *PC_LD_MUX; //pc write selection

    sc_signal<bool> mem_clk_pa;
    sc_signal<bool> mem_clk_pb;
    
    //signals
    //-- branches control
    sc_signal<sc_logic> branch_ctl;
    sc_signal<sc_logic> hazd_stall;
    sc_signal<sc_logic> i_cache_stall;
    sc_signal<sc_logic> mem_stall;
    sc_signal<sc_logic> pipeline_load;

    sc_signal<bool> neg_clk;

    //--rom control
    sc_signal<sc_logic> rom_rd;
    sc_signal<sc_logic> rom_enable;
    sc_signal<sc_int<WORD_SIZE> > rom_data_out;
    
    sc_signal<sc_int<WORD_SIZE> > slow_fetch_data_out;
    sc_signal<sc_logic> ctrl_rom_rd_;

    //--pc control
    sc_signal<sc_logic> pc_inc;
    sc_signal<sc_logic> pc_load;
    sc_signal <sc_int<WORD_SIZE> > pc_addr_in;
    sc_signal <sc_uint<WORD_SIZE> > pc_register;
    sc_signal <sc_int<WORD_SIZE> > pc_register_signed;

    //pipeline if_id port connection
    sc_signal<sc_logic> if_id_load;
    sc_signal<sc_int<WORD_SIZE> > if_id_pc;
    sc_signal<sc_uint<WORD_SIZE> > if_id_instrunction;
    sc_signal<sc_int<WORD_SIZE> > if_id_immed_sigext;
    sc_signal<sc_int<WORD_SIZE> > if_id_immed_zeroext;
    sc_signal<sc_uint<REG_ADDR_SIZE> > if_id_rs;
    sc_signal<sc_uint<REG_ADDR_SIZE> > if_id_rt;
    sc_signal<sc_uint<REG_ADDR_SIZE> > if_id_rd;
    sc_signal<sc_int<WORD_SIZE> > if_id_j_target;
    sc_signal<sc_uint<OPCODE_SIZE> > if_id_opcode;
    sc_signal<sc_uint<SHAMT_SIZE> > if_id_shamt;
    sc_signal<sc_uint<FUNCT_SIZE> > if_id_funct;
    sc_signal<sc_logic> if_id_bubble;

    //pipeline id_ex port connection
    sc_signal<sc_logic> id_ex_load;
    sc_signal<sc_int<WORD_SIZE> > id_ex_pc;
    sc_signal<sc_int<WORD_SIZE> > id_ex_rs_value;
    sc_signal<sc_int<WORD_SIZE> > id_ex_rt_value;
    sc_signal<sc_int<WORD_SIZE> > id_ex_rp_rs_value;
    sc_signal<sc_int<WORD_SIZE> > id_ex_rp_rt_value;
    sc_signal<sc_int<WORD_SIZE> > id_ex_immed_sigext;
    sc_signal<sc_int<WORD_SIZE> > id_ex_immed_zeroext;
    sc_signal<sc_uint<REG_ADDR_SIZE> > id_ex_rs;
    sc_signal<sc_uint<REG_ADDR_SIZE> > id_ex_rt;
    sc_signal<sc_uint<REG_ADDR_SIZE> > id_ex_rd;
    sc_signal<sc_uint<SHAMT_SIZE> > id_ex_shamt;
    sc_signal<sc_uint<ALUOPS> > id_ex_alu_op;
    sc_signal<sc_uint<WORD_SIZE> > id_ex_instrunction;
    sc_signal<sc_logic> id_ex_bubble;
    sc_signal<sc_logic> id_ex_if_id_reset;
    sc_signal<sc_int<WORD_SIZE> > id_ex_hilo_rf_data;
    sc_signal<sc_logic> id_ex_hilo_rd_enable;
    sc_signal<sc_uint<2> > id_ex_hilo_addr;
    sc_signal<sc_logic> id_ex_mem_adder_enable;
    sc_signal<sc_uint<MAX_MUX_PORTS> > id_ex_alu_pa_sel;
    sc_signal<sc_uint<MAX_MUX_PORTS> > id_ex_alu_pb_sel;
    sc_signal<sc_uint<N_ADDR_REGISTER> > id_ex_dest_reg;
    sc_signal<WbControl> id_ex_wb_signals;

    //pipeline ex_mem port connection
    sc_signal<sc_logic> ex_mem_load;
    sc_signal<sc_int<WORD_SIZE> > ex_mem_alu;
    sc_signal<sc_int<WORD_SIZE> > ex_mem_hi; //hi register data to write
    sc_signal<sc_int<WORD_SIZE> > ex_mem_lo; //lo registger data to write
    sc_signal<sc_uint<WORD_SIZE> > ex_mem_mem_address;
    sc_signal<sc_uint<REG_ADDR_SIZE> > ex_mem_rt;
    sc_signal<sc_int<WORD_SIZE> > ex_mem_pc;
    sc_signal<WbControl> ex_mem_ctrl_wb_signals; //comes from ex_mem
    sc_signal<sc_uint<N_ADDR_REGISTER> > ex_mem_dest_reg; // comes from ex_mem
    sc_signal<sc_int<WORD_SIZE> > ex_mem_ram_datain;
    sc_signal<sc_int<WORD_SIZE> > ex_mem_rf_data;
    sc_signal<sc_uint<WORD_SIZE> > ex_mem_instrunction;


    //pipeline mem_wb port connection
    sc_signal<sc_logic> mem_wb_load;
    sc_signal<sc_int<WORD_SIZE> > mem_wb_reg_w_data;
    sc_signal<sc_logic> mem_wb_reg_w_enable;
    sc_signal<sc_logic> mem_wb_cmov;
    sc_signal<sc_int<WORD_SIZE> > mem_wb_lo;
    sc_signal<sc_int<WORD_SIZE> > mem_wb_hi;
    sc_signal<sc_logic> mem_wb_hilo_w_enable;
    sc_signal<sc_uint<N_ADDR_REGISTER> > mem_wb_dest_reg; //comes from mem_wb
    sc_signal<sc_int<WORD_SIZE> > mem_wb_alu;
    sc_signal<sc_logic> mem_wb_memory_enable; // --write control
    sc_signal<sc_int<WORD_SIZE> > mem_wb_spram_w_data; //data to write to memory
    sc_signal<sc_uint<RAM_ADDR_SIZE> > mem_wb_mem_addr; //addr to write to memory
    sc_signal<sc_logic> mem_wb_pred_data;
    sc_signal<sc_logic> mem_wb_pred_wr_enable;
    sc_signal<sc_uint<WORD_SIZE> > mem_wb_instrunction;

    //forward unit signals
    sc_signal<sc_int<WORD_SIZE> > forward_hilo_data;
    sc_signal<sc_int<WORD_SIZE> > forward_alu_ra_value;
    sc_signal<sc_int<WORD_SIZE> > forward_alu_rb_value;
    sc_signal<sc_int<WORD_SIZE> > forward_rp_rs_value;
    sc_signal<sc_int<WORD_SIZE> > forward_rp_rt_value;
    sc_signal<sc_int<WORD_SIZE> > forward_ram_datain;
    sc_signal<sc_int<WORD_SIZE> > forward_id_rs;
    sc_signal<sc_logic> forward_id_prs;

    //controller signals
    sc_signal<sc_logic> ctrl_rom_rd;
    sc_signal<sc_logic> ctrl_if_id_load;
    sc_signal<WbControl> ctrl_wb_signals; //comes from controller
    sc_signal<sc_uint<2> > ctrl_hilo_addr; //select hi or lo to read
    sc_signal<sc_logic> ctrl_hilo_rd_enable; //read enable
    sc_signal<sc_logic> ctrl_pipeline_flush; //flush entire pipeline
    sc_signal<sc_logic> ctrl_if_id_reset; //stall pipeline
    sc_signal<sc_uint<N_ADDR_REGISTER> > ctrl_dest_reg; // comes from controller mux
    sc_signal<sc_logic> ctrl_pc_inc;
    sc_signal<sc_logic> ctrl_ram_enable;
    sc_signal<sc_logic> ctrl_pc_adder_enable;
    sc_signal<sc_uint<MAX_MUX_PORTS> > ctrl_jtarget_sel;
    sc_signal<sc_logic> ctrl_mem_adder_enable;
    sc_signal<sc_uint<MAX_MUX_PORTS> > ctrl_alu_pa_sel;
    sc_signal<sc_uint<MAX_MUX_PORTS> > ctrl_alu_pb_sel;
    sc_signal<sc_uint<ALUOPS> > ctrl_alu_op;
    sc_signal<sc_uint<SHAMT_SIZE> > ctrl_shamt;
    sc_signal<sc_logic> ctrl_pc_load;

    sc_signal<sc_int<WORD_SIZE> > pc_adder_mux;

    //-- register file signals write
    sc_signal<sc_uint<N_ADDR_REGISTER> > reg_w_addr;
    sc_signal<sc_uint<N_ADDR_REGISTER> > reg_write_sel;
    sc_signal<sc_logic> reg_w_enable;
    sc_signal<sc_logic> ra_rd_enable; //-- register read PA
    sc_signal<sc_logic> rb_rd_enable; //-- register read PB
    sc_signal<sc_uint<N_ADDR_REGISTER> > rega_rd_addr;
    sc_signal<sc_uint<N_ADDR_REGISTER> > regb_rd_addr;
    sc_signal<sc_int<WORD_SIZE> > reg_w_data;
    sc_signal<sc_int<WORD_SIZE> > rs_data;
    sc_signal<sc_int<WORD_SIZE> > rt_data;

    //-- alu control
    sc_signal<sc_int<WORD_SIZE> > alu_out;
    sc_signal<sc_int<WORD_SIZE> > alu_lo;
    sc_signal<sc_int<WORD_SIZE> > alu_hi;
    sc_signal<sc_int<WORD_SIZE> > alu_pa_value;
    sc_signal<sc_int<WORD_SIZE> > alu_pb_value;

    //-- mem controller (byte addressing generator)
    sc_signal<sc_int<WORD_SIZE> > mem_ctrl_ram_r_data;
    sc_signal<sc_int<WORD_SIZE> > mem_ctrl_spram_w_data;
    sc_signal<sc_uint<RAM_ADDR_SIZE> >mem_ctrl_spram_addr;
    sc_signal<sc_uint<RAM_ADDR_SIZE> >mem_ctrl_ram_addr;

    sc_signal<sc_logic> mem_ctrl_ram_wr;
    sc_signal<sc_logic> mem_ctrl_ram_rd; // --read control
    sc_signal<sc_logic> mem_ctrl_ram_clk_en; //-- clk control
    sc_signal<sc_int<WORD_SIZE> > mem_ctrl_spram_data;
    sc_signal<sc_int<WORD_SIZE> > mem_ctrl_ram_data;
    sc_signal<sc_logic> mem_ctrl_spram_rd; // --read control

    //-- ram signals
    sc_signal<sc_int<WORD_SIZE> > spram_dataout;
    sc_signal<sc_int<WORD_SIZE> > ram_dataout;
    sc_signal<sc_uint<ADDR_SIZE> > sram_w_addr;
    sc_signal<sc_uint<ADDR_SIZE> > sram_rd_addr;

    //hi lo register signals
    sc_signal<sc_int<WORD_SIZE> > hilo_rf_data;

    //mem adder signals
    sc_signal<sc_uint<WORD_SIZE> > mem_adder_result;
    sc_signal<sc_uint<WORD_SIZE> > pc_adder_result;
    sc_signal<sc_int<WORD_SIZE> > pc_adder_result_int;

    //predicate control
    sc_signal<sc_logic> pred_rd_enable;
    sc_signal<sc_logic> pred_rs_data;
    sc_signal<sc_logic> pred_rt_data;

    //Jump and branch mux signals
    sc_signal<sc_uint<WORD_SIZE> > j_target;
    sc_signal<sc_int<WORD_SIZE> > j_target_int;

    //always zero
    sc_signal<sc_int<WORD_SIZE> > zero;
    sc_signal<sc_uint<WORD_SIZE> > u_zero;
    sc_signal<sc_int<WORD_SIZE> > jal_offset;

    //cache signals
    sc_signal<sc_logic> cache_rd_enable;
    sc_signal<sc_logic> cache_ram_clk_en;
    sc_signal<sc_uint<RAM_ADDR_SIZE> > cache_rd_addr;
    sc_signal<sc_int<WORD_SIZE> > inst_mem_data_out;

    sc_signal<sc_int<WORD_SIZE> > cache_data_out;
    
    ////////////////////////////////////////

    sc_signal<sc_logic> stop;

    //debug
    sc_signal<int> int_cpu_stage;
    uint64_t cycles;

    void do_neg_clock();
    void do_stall_halt();
    void do_pc_signed();
    void do_jump_target_mux();
    void do_zero();
    void calc_halt_time();
    
    //debug
    int get_ini_address();
    int get_end_address();
    
    SC_HAS_PROCESS(cpu);

    cpu(sc_module_name name_, int nocache_ = 0, int ini_address_ = 0,
            int end_address_ = ROM_INI + ROM_SIZE, int mode_ = SIM, int quiet_ = 0, 
            int single_cycle_fetch_ = 0) :
            sc_module(name_), nocache(nocache_),
            ini_address(ini_address_), end_address(end_address_),
            mode(mode_), quiet(quiet_), single_cycle_fetch(single_cycle_fetch_)
            //SC_CTOR( cpu )
    {
        cycles = 0;

        CPU_CTLR = new controller("cpu_controller");
        CPU_CTLR->clk(clk);
        CPU_CTLR->reset(reset);
        CPU_CTLR->insopcode(if_id_opcode);
        CPU_CTLR->funct(if_id_funct);
        CPU_CTLR->shamt(if_id_shamt);
        //---alu control
        CPU_CTLR->alu_shamt_out(ctrl_shamt);
        CPU_CTLR->alu_op_out(ctrl_alu_op);
        CPU_CTLR->alu_pa_sel(ctrl_alu_pa_sel);
        CPU_CTLR->alu_pb_sel(ctrl_alu_pb_sel);
        //--jump/branch control
        CPU_CTLR->j_target_sel(ctrl_jtarget_sel);
        CPU_CTLR->pc_adder_enable(ctrl_pc_adder_enable);
        //todo: NOP detection?
        CPU_CTLR->immediate_in(if_id_immed_sigext);
        //branch and cmove predicate read port
        CPU_CTLR->rpred_rs_value_in(forward_id_prs);
        //register write selection
        CPU_CTLR->rd_in(if_id_rd);
        CPU_CTLR->rt_in(if_id_rt);
        CPU_CTLR->dest_reg_out(ctrl_dest_reg);
        CPU_CTLR->ctrl_wb_signals_out(ctrl_wb_signals);
        //hi_lo read control
        CPU_CTLR->hi_lo_address_out(ctrl_hilo_addr);
        CPU_CTLR->hi_lo_enable(ctrl_hilo_rd_enable);
        //mem_adder
        CPU_CTLR->mem_adder_enable(ctrl_mem_adder_enable);
        //mem_enable
        CPU_CTLR->ram_enable(ctrl_ram_enable);
        //flush
        CPU_CTLR->pipe_flush(ctrl_pipeline_flush);
        //bubble
        CPU_CTLR->hazd_in(hazd_stall);
        CPU_CTLR->i_cache_stall_in(i_cache_stall);
        //CPU_CTLR->i_cache_stall_in(id_ex_bubble); ???
        CPU_CTLR->mem_stall(mem_stall);
        //jump data mux
        CPU_CTLR->rom_rd(ctrl_rom_rd);
        CPU_CTLR->rom_enable(rom_enable);
        CPU_CTLR->pc_inc(ctrl_pc_inc);
        CPU_CTLR->pc_load(ctrl_pc_load);
        CPU_CTLR->pipeline_load(pipeline_load);
        CPU_CTLR->if_id_load(ctrl_if_id_load);
        CPU_CTLR->reg_w_addr(reg_w_addr);
        CPU_CTLR->reg_write_sel(reg_write_sel);
        CPU_CTLR->reg_w_enable(reg_w_enable);
        CPU_CTLR->ra_rd_enable(ra_rd_enable);
        CPU_CTLR->rb_rd_enable(rb_rd_enable);
        CPU_CTLR->rega_rd_addr(rega_rd_addr);
        CPU_CTLR->regb_rd_addr(regb_rd_addr);
        CPU_CTLR->int_cpu_stage(int_cpu_stage);
        //predicates
        CPU_CTLR->pred_rd_enable(pred_rd_enable);

        FORWD_UNIT = new forw_unit("forward_unit");
        FORWD_UNIT->clk(clk);
        FORWD_UNIT->reset(reset);
        //read and write signals
        FORWD_UNIT->id_ex_ctrl_wb_signals_in(id_ex_wb_signals);
        FORWD_UNIT->ex_mem_ctrl_wb_signals_in(ex_mem_ctrl_wb_signals);
        FORWD_UNIT->mem_wb_reg_w_enable(mem_wb_reg_w_enable);
        FORWD_UNIT->mem_wb_cmov(mem_wb_cmov);
        FORWD_UNIT->ex_mem_memory_read(mem_ctrl_ram_rd);
        FORWD_UNIT->id_ex_hilo_r_enable(id_ex_hilo_rd_enable);
        FORWD_UNIT->id_ex_hilo_addr(id_ex_hilo_addr);
        FORWD_UNIT->mem_wb_rpred_w_enable(mem_wb_pred_wr_enable);
        FORWD_UNIT->mem_wb_hilo_w_enable(mem_wb_hilo_w_enable);
        //register write addresses for all stages
        FORWD_UNIT->id_ex_dest_reg(id_ex_dest_reg);
        FORWD_UNIT->ex_mem_dest_reg(ex_mem_dest_reg);
        FORWD_UNIT->mem_wb_dest_reg(mem_wb_dest_reg);
        //register read addresses for all stages
        FORWD_UNIT->if_id_rs(if_id_rs);
        FORWD_UNIT->id_ex_rs(id_ex_rs);
        FORWD_UNIT->id_ex_rt(id_ex_rt);
        FORWD_UNIT->ex_mem_rt(ex_mem_rt);
        FORWD_UNIT->ex_mem_hi(ex_mem_hi);
        FORWD_UNIT->ex_mem_lo(ex_mem_lo);
        //mux signals
        FORWD_UNIT->id_rs_value(rs_data); //value read directly from register file
        FORWD_UNIT->rf_rs_value(id_ex_rs_value);
        FORWD_UNIT->rf_rt_value(id_ex_rt_value);
        FORWD_UNIT->hilo_data_in(id_ex_hilo_rf_data);
        FORWD_UNIT->hilo_data_out(forward_hilo_data);
        FORWD_UNIT->mem_wb_hi(mem_wb_hi);
        FORWD_UNIT->mem_wb_lo(mem_wb_lo);
        //predicates
        FORWD_UNIT->rpred_if_rs_value_in(pred_rs_data);
        FORWD_UNIT->rpred_rs_value_in(id_ex_rp_rs_value);
        FORWD_UNIT->rpred_rt_value_in(id_ex_rp_rt_value);
        FORWD_UNIT->rpred_rs_value_out(forward_rp_rs_value);
        FORWD_UNIT->rpred_rt_value_out(forward_rp_rt_value);
        FORWD_UNIT->mem_wb_pred_data_in(mem_wb_pred_data);
        //normal data
        FORWD_UNIT->id_ex_alu(alu_out);
        FORWD_UNIT->ex_mem_alu(ex_mem_alu);
        FORWD_UNIT->mem_wb_w_data(mem_wb_reg_w_data);
        FORWD_UNIT->alu_a_out(forward_alu_ra_value);
        FORWD_UNIT->alu_b_out(forward_alu_rb_value);
        FORWD_UNIT->ex_mem_ram_datain(ex_mem_ram_datain);
        FORWD_UNIT->mem_wb_ram_datain(mem_wb_reg_w_data);
        FORWD_UNIT->ram_data_out(forward_ram_datain);
        //predicate and rs_value in ID stage
        FORWD_UNIT->if_id_pred_s_out(forward_id_prs);
        FORWD_UNIT->if_id_rs_out(forward_id_rs);
        //forward memory data when it read
        FORWD_UNIT->memory_data(mem_ctrl_ram_r_data);


        HAZD_UNIT = new hazard_unit("hazard_unit");
        HAZD_UNIT->clk(clk);
        HAZD_UNIT->reset(reset);
        HAZD_UNIT->ins_in(if_id_instrunction);
        HAZD_UNIT->if_ex_ctrl_wb_signals_in(id_ex_wb_signals);
        HAZD_UNIT->if_id_rs(if_id_rs);
        HAZD_UNIT->if_id_rt(if_id_rt);
        HAZD_UNIT->id_ex_rt(id_ex_rt);
        HAZD_UNIT->stall_out(hazd_stall);

        //Register file is read in IF stage
        //Register file is written in WB stage
        RF = new rf("general_purpose_register_file", N_REGISTERS);
        RF->clk(neg_clk);
        RF->reset(reset);
        RF->w_addr(mem_wb_dest_reg);
        RF->w_data(mem_wb_reg_w_data);
        RF->w_wr(mem_wb_reg_w_enable);
        //register addresses comes from ir (if-id)
        RF->ra_addr(if_id_rs);
        RF->rb_addr(if_id_rt);
        RF->ra_data(rs_data);
        RF->rb_data(rt_data);
        RF->ra_rd(ra_rd_enable);
        RF->rb_rd(rb_rd_enable);

        IF_ID = new if_id("pipeline_if_id");
        IF_ID->clk(clk);
        //IF_ID->reset(id_ex_if_id_reset);
        IF_ID->reset(ctrl_pipeline_flush);
        IF_ID->load(if_id_load);
        IF_ID->data_in(rom_data_out);
        IF_ID->pc_in(pc_register);
        IF_ID->immed_sigext(if_id_immed_sigext);
        IF_ID->immed_zeroext(if_id_immed_zeroext);
        IF_ID->rd_out(if_id_rd);
        IF_ID->rs_out(if_id_rs);
        IF_ID->rt_out(if_id_rt);
        IF_ID->ins_out(if_id_instrunction);
        IF_ID->pc_out(if_id_pc);
        IF_ID->bubble_in(i_cache_stall);
        IF_ID->bubble_out(if_id_bubble);
        IF_ID->opcode_out(if_id_opcode);
        IF_ID->shamt_out(if_id_shamt);
        IF_ID->funct_out(if_id_funct);
        IF_ID->j_target_out(if_id_j_target);

        ID_EX = new id_ex("pipeline_id_ex");
        ID_EX->clk(clk);
        ID_EX->reset(ctrl_pipeline_flush);
        ID_EX->load(id_ex_load);
        ID_EX->pc_in(if_id_pc);
        ID_EX->instrunction_in(if_id_instrunction);
        ID_EX->rs_out(id_ex_rs);
        ID_EX->rt_out(id_ex_rt);
        ID_EX->rd_out(id_ex_rd);
        ID_EX->rs_value_in(rs_data);
        ID_EX->rt_value_in(rt_data);
        ID_EX->pc_out(id_ex_pc);
        ID_EX->immed_sigext_in(if_id_immed_sigext);
        ID_EX->immed_sigext_out(id_ex_immed_sigext);
        ID_EX->immed_zeroext_in(if_id_immed_zeroext);
        ID_EX->immed_zeroext_out(id_ex_immed_zeroext);
        ID_EX->mem_adder_enable_in(ctrl_mem_adder_enable);
        ID_EX->mem_adder_enable_out(id_ex_mem_adder_enable);
        ID_EX->rs_value_out(id_ex_rs_value);
        ID_EX->rt_value_out(id_ex_rt_value);
        ID_EX->rpred_rs_value_in(pred_rs_data);
        ID_EX->rpred_rt_value_in(pred_rt_data);
        ID_EX->rpred_rs_value_out(id_ex_rp_rs_value);
        ID_EX->rpred_rt_value_out(id_ex_rp_rt_value);
        //STALL
        ID_EX->if_id_reset_in(ctrl_if_id_reset);
        ID_EX->if_id_reset_out(id_ex_if_id_reset);
        ID_EX->bubble_in(if_id_bubble);
        ID_EX->bubble_out(id_ex_bubble);
        //debug
        ID_EX->instrunction_out(id_ex_instrunction);
        //ALU
        ID_EX->alu_pa_sel_in(ctrl_alu_pa_sel);
        ID_EX->alu_pa_sel_out(id_ex_alu_pa_sel);
        ID_EX->alu_pb_sel_in(ctrl_alu_pb_sel);
        ID_EX->alu_pb_sel_out(id_ex_alu_pb_sel);
        ID_EX->alu_shamt_in(ctrl_shamt);
        ID_EX->alu_op_in(ctrl_alu_op);
        ID_EX->alu_shamt_out(id_ex_shamt);
        ID_EX->alu_op_out(id_ex_alu_op);
        //register write
        ID_EX->ctrl_wb_signals_in(ctrl_wb_signals);
        ID_EX->ctrl_wb_signals_out(id_ex_wb_signals);
        ID_EX->dest_reg_in(ctrl_dest_reg);
        ID_EX->dest_reg_out(id_ex_dest_reg);
        ID_EX->hilo_rf_data_in(hilo_rf_data);
        ID_EX->hilo_rf_data_out(id_ex_hilo_rf_data);
        ID_EX->hilo_addr_in(ctrl_hilo_addr);
        ID_EX->hilo_addr_out(id_ex_hilo_addr);
        ID_EX->hilo_rd_enable_in(ctrl_hilo_rd_enable);
        ID_EX->hilo_rd_enable_out(id_ex_hilo_rd_enable);

        EX_MEM = new ex_mem("pipeline_ex_mem");
        EX_MEM->clk(clk);
        EX_MEM->reset(ctrl_pipeline_flush);
        EX_MEM->load(ex_mem_load);
        EX_MEM->instrunction_in(id_ex_instrunction);
        EX_MEM->instrunction_out(ex_mem_instrunction);
        //alu output
        EX_MEM->alu_in(alu_out);
        EX_MEM->alu_out(ex_mem_alu);
        EX_MEM->hi_in(alu_hi);
        EX_MEM->lo_in(alu_lo);
        EX_MEM->pc_in(id_ex_pc);
        EX_MEM->pc_out(ex_mem_pc);
        EX_MEM->rt_in(id_ex_rt);
        EX_MEM->rt_out(ex_mem_rt);
        EX_MEM->hi_out(ex_mem_hi);
        EX_MEM->lo_out(ex_mem_lo);
        EX_MEM->dest_reg_in(id_ex_dest_reg);
        EX_MEM->dest_reg_out(ex_mem_dest_reg);
        EX_MEM->ctrl_wb_signals_in(id_ex_wb_signals);
        EX_MEM->ctrl_wb_signals_out(ex_mem_ctrl_wb_signals);
        EX_MEM->hilo_rf_data_in(forward_hilo_data);
        EX_MEM->hilo_rf_data_out(ex_mem_rf_data);
        EX_MEM->mem_address_in(mem_adder_result);
        EX_MEM->mem_address_out(ex_mem_mem_address);
        EX_MEM->mem_data_in(forward_alu_rb_value);
        EX_MEM->mem_data_out(ex_mem_ram_datain);


        MEM_WB = new mem_wb("pipeline_mem_wb", end_address, single_cycle_fetch);
        MEM_WB->clk(clk);
        MEM_WB->reset(ctrl_pipeline_flush);
        MEM_WB->mem_stall(mem_stall);
        MEM_WB->load(mem_wb_load);
        MEM_WB->pc_in(ex_mem_pc);

        MEM_WB->alu_in(ex_mem_alu);
        MEM_WB->hilo_rf_data_in(ex_mem_rf_data);
        MEM_WB->lo_in(ex_mem_lo);
        MEM_WB->hi_in(ex_mem_hi);
        MEM_WB->dest_reg_in(ex_mem_dest_reg);
        MEM_WB->ctrl_wb_signals_in(ex_mem_ctrl_wb_signals);
        MEM_WB->dest_reg_out(mem_wb_dest_reg);
        MEM_WB->cmov_out(mem_wb_cmov);
        MEM_WB->reg_w_enable_out(mem_wb_reg_w_enable);
        MEM_WB->reg_w_data_out(mem_wb_reg_w_data);
        MEM_WB->hi_out(mem_wb_hi);
        MEM_WB->lo_out(mem_wb_lo);
        MEM_WB->hilo_w_enable_out(mem_wb_hilo_w_enable);
        MEM_WB->memory_data_in(mem_ctrl_ram_r_data); //data from memory to write in RF
        MEM_WB->memory_w_data_in(mem_ctrl_spram_w_data); //data to write to memory
        MEM_WB->memory_w_data_out(mem_wb_spram_w_data); //data to write to memory
        MEM_WB->memory_addr_in(mem_ctrl_spram_addr);
        MEM_WB->memory_addr_out(mem_wb_mem_addr);
        MEM_WB->memory_w_enable_out(mem_wb_memory_enable);
        //predicates
        MEM_WB->pred_data_out(mem_wb_pred_data);
        MEM_WB->pred_wr_enable(mem_wb_pred_wr_enable);
        //debugger mode
        MEM_WB->instrunction_in(ex_mem_instrunction);
        MEM_WB->instrunction_out(mem_wb_instrunction);
        MEM_WB->halt_out(stop);

        PC = new pc("pc_counter", ini_address);
        PC->clk(clk);
        PC->reset(reset);
        PC->up(pc_inc);
        PC->load(ctrl_pc_load);
        PC->data_in(j_target);
        PC->data(pc_register);

        //HI_LO values are written in WB stage
        //HI_LO value is read in MEM stage
        HI_LO = new rf_hilo("hi_lo_register_file");
        HI_LO->clk(neg_clk);
        HI_LO->reset(reset);
        HI_LO->lo_data_in(mem_wb_lo);
        HI_LO->hi_data_in(mem_wb_hi);
        HI_LO->wr_enable(mem_wb_hilo_w_enable);
        HI_LO->rd_addr_in(ctrl_hilo_addr); //select hi or lo to read
        HI_LO->rd_enable(ctrl_hilo_rd_enable); //enable reading
        HI_LO->rd_data_out(hilo_rf_data);

        RF_PRE = new rf_predic("predicate_register_file");
        RF_PRE->clk(neg_clk);
        RF_PRE->wr_enable(mem_wb_pred_wr_enable);
        RF_PRE->rd_enable(pred_rd_enable);
        RF_PRE->wr_addr_in(mem_wb_dest_reg);
        RF_PRE->rda_addr_in(if_id_rs);
        RF_PRE->rdb_addr_in(if_id_rt);
        RF_PRE->data_in(mem_wb_pred_data);
        RF_PRE->pa_data_out(pred_rs_data);
        RF_PRE->pb_data_out(pred_rt_data);

        MEMORY = new umemory("CPU_MEMORY");
        //MEMORY->clk_pa(mem_clk);
        MEMORY->clk_pa(mem_clk_pa);
        MEMORY->clk_pb(mem_clk_pb);
        MEMORY->clk_pw(mem_clk_pb);
        MEMORY->enable(rom_enable);
        MEMORY->rd_a(cache_rd_enable);
        MEMORY->rd_a_addr(cache_rd_addr);
        MEMORY->data_a_out(inst_mem_data_out);
        MEMORY->wr(mem_ctrl_ram_wr);
        MEMORY->w_addr(mem_ctrl_ram_addr);
        MEMORY->data_in(mem_ctrl_ram_data);
        MEMORY->rd_b(mem_ctrl_ram_rd);
        MEMORY->rd_b_addr(mem_ctrl_ram_addr);
        MEMORY->data_b_out(ram_dataout);


        if (nocache == 0) {
            I_CACHE = new cache("INS_CACHE");
            I_CACHE->clk(clk);
            //I_CACHE->mem_clk(mem_clk); 
            I_CACHE->mem_clk(mem_clk_pa);
            I_CACHE->ram_clk_en_out(cache_ram_clk_en);
            I_CACHE->reset(reset);
            I_CACHE->stall_out(i_cache_stall);
            I_CACHE->address(pc_register);
            I_CACHE->data_out(rom_data_out);
            I_CACHE->data_out_enable(ctrl_rom_rd);
            I_CACHE->mem_addr_out(cache_rd_addr);
            I_CACHE->mem_enable_out(cache_rd_enable);
            I_CACHE->mem_data_in(inst_mem_data_out);
        } else if (single_cycle_fetch == 1){
            ROM = new rom("INS_ROM");
            ROM->clk(clk);
            ROM->enable(rom_enable);
            ROM->rd(ctrl_rom_rd);
            ROM->rd_addr(pc_register);
            ROM->data_out(rom_data_out);
        }
        else
        {      
            SLOW_FETCH = new fetch_cont("SLOW_FETCH");
            SLOW_FETCH->clk(clk);
            //I_CACHE->mem_clk(mem_clk); 
            SLOW_FETCH->mem_clk(mem_clk_pa);
            SLOW_FETCH->ram_clk_en_out(cache_ram_clk_en);
            SLOW_FETCH->reset(reset);
            SLOW_FETCH->stall_out(i_cache_stall);
            SLOW_FETCH->address(pc_register);
            SLOW_FETCH->data_out(rom_data_out);
            SLOW_FETCH->data_out_enable(ctrl_rom_rd);
            SLOW_FETCH->mem_addr_out(cache_rd_addr);
            SLOW_FETCH->mem_enable_out(cache_rd_enable);
            SLOW_FETCH->mem_data_in(inst_mem_data_out);            
        }

        if (mode == WCET)
            MEM_CTRL = new mem_control("memory_controller", SP_0_ONLY);
        else
            MEM_CTRL = new mem_control("memory_controller");
        MEM_CTRL->clk(mem_clk_pb);
        MEM_CTRL->cpu_clk(clk);
        MEM_CTRL->reset(reset);
        MEM_CTRL->ctrl_wb_signals_in(ex_mem_ctrl_wb_signals);
        MEM_CTRL->addr_in(ex_mem_mem_address);          //address to read/write from instruction
        MEM_CTRL->pipe_data_in(forward_ram_datain);     //data to write in RAM
        MEM_CTRL->spram_rd_enable(mem_ctrl_spram_rd);
        MEM_CTRL->sp_addr_out(mem_ctrl_spram_addr);     //effective RAM address
        MEM_CTRL->sp_data_in(spram_dataout);            //data read from RAM
        MEM_CTRL->sp_data_w_out(mem_ctrl_spram_w_data); //data to write in SP_RAM
        MEM_CTRL->data_r_out(mem_ctrl_ram_r_data);      //data read from RAM to write on MEM_WB (SP and RAM)
        MEM_CTRL->ram_data_in(ram_dataout);
        MEM_CTRL->ram_data_out(mem_ctrl_ram_data);
        MEM_CTRL->ram_wr_enable(mem_ctrl_ram_wr);
        MEM_CTRL->ram_addr_out(mem_ctrl_ram_addr);
        MEM_CTRL->ram_rd_enable(mem_ctrl_ram_rd);
        MEM_CTRL->ram_clk_en_out(mem_ctrl_ram_clk_en);
        MEM_CTRL->stall_out(mem_stall);

        SP_MEM = new sram("scrach_pad_memory");
        SP_MEM->clk(neg_clk);
        SP_MEM->enable(ctrl_ram_enable);
        SP_MEM->wr(mem_wb_memory_enable);
        SP_MEM->rd(mem_ctrl_spram_rd);
        SP_MEM->w_addr(mem_wb_mem_addr);
        SP_MEM->rd_addr(mem_ctrl_spram_addr);
        SP_MEM->data_in(mem_wb_spram_w_data);
        SP_MEM->data_out(spram_dataout);

        if (mode == WCET)
            ALU = new alu("ALU", ALU_WCET);
        else
            ALU = new alu("ALU");
        ALU->a(alu_pa_value); // <-- comes from forward unit
        ALU->b(alu_pb_value); // <-- comes from forward unit
        ALU->shamt(id_ex_shamt);
        ALU->aluop(id_ex_alu_op);
        ALU->result_out(alu_out);
        ALU->lo_out(alu_lo);
        ALU->hi_out(alu_hi);

        MEM_ADDER = new adder("mem_adder");
        MEM_ADDER->enable(id_ex_mem_adder_enable);
        //MEM_ADDER->a(alu_pa_value); // <-- comes from Forward unit
        MEM_ADDER->a(forward_alu_ra_value); // <-- comes from Forward unit
        MEM_ADDER->b(id_ex_immed_sigext); // <-- comes from id_ex register
        MEM_ADDER->result(mem_adder_result);

        PC_ADDER = new adder("pc_adder");
        PC_ADDER->enable(ctrl_pc_adder_enable);
        PC_ADDER->a(pc_register_signed);
        PC_ADDER->b(if_id_immed_sigext);
        PC_ADDER->result(pc_adder_result);

        ALU_PA_MUX = new mux("ALU_PA_MUX", 5);
        ALU_PA_MUX->in[RF_RS](forward_alu_ra_value);
        ALU_PA_MUX->in[RFP_RS](forward_rp_rs_value); //rp_rs_extended
        ALU_PA_MUX->in[RHILO](forward_hilo_data);
        ALU_PA_MUX->in[ZERO_PA](zero);
        ALU_PA_MUX->in[PC_OFFSET](jal_offset);
        ALU_PA_MUX->addr(id_ex_alu_pa_sel);
        ALU_PA_MUX->mux_out(alu_pa_value);

        ALU_PB_MUX = new mux("ALU_PB_MUX", 6);
        ALU_PB_MUX->in[RF_RT](forward_alu_rb_value);
        ALU_PB_MUX->in[RFP_RT](forward_rp_rt_value); //rp_rs_extended
        ALU_PB_MUX->in[INS_IMM_SIGEXT](id_ex_immed_sigext);
        ALU_PB_MUX->in[INS_IMM_ZEROEXT](id_ex_immed_zeroext);
        ALU_PB_MUX->in[ZERO_PB](zero);
        ALU_PB_MUX->in[PC_PB](if_id_pc);
        ALU_PB_MUX->addr(id_ex_alu_pb_sel);
        ALU_PB_MUX->mux_out(alu_pb_value);

        PC_LD_MUX = new mux("PC_LD_MUX", 3);
        PC_LD_MUX->in[JUMP](if_id_j_target);
        PC_LD_MUX->in[BRANCH](pc_adder_result_int);
        PC_LD_MUX->in[RS_VALUE](forward_id_rs);
        PC_LD_MUX->addr(ctrl_jtarget_sel);
        PC_LD_MUX->mux_out(j_target_int);

        MEM_CLK_pB = new clock_gen("MEM_CLK_pB", MEM_CYCLE_TIME/CPU_CYCLE_TIME);
        MEM_CLK_pB->clk(clk);
        MEM_CLK_pB->enable(mem_ctrl_ram_clk_en);
        MEM_CLK_pB->clk_out(mem_clk_pb);
//        
        MEM_CLK_pA = new clock_gen("MEM_CLK_pA", MEM_CYCLE_TIME/CPU_CYCLE_TIME);
        MEM_CLK_pA->clk(clk);
        MEM_CLK_pA->enable(cache_ram_clk_en);
        MEM_CLK_pA->clk_out(mem_clk_pa);
        
        if (quiet == 0) {
            INS_DEBUGGER = new debug("CPU_DEBUGGER");
            INS_DEBUGGER->reset(reset);
            INS_DEBUGGER->instrunction_in(id_ex_instrunction);
            INS_DEBUGGER->pc_in(id_ex_pc);
        }

        SC_METHOD(do_neg_clock)
        sensitive << clk;

        SC_METHOD(do_stall_halt)
        sensitive << i_cache_stall << hazd_stall <<
                ctrl_rom_rd << ctrl_pc_inc << ctrl_if_id_load << ctrl_pc_load <<
                mem_stall << stop << reset;

        SC_METHOD(calc_halt_time)
        sensitive << stop;        
        
        SC_METHOD(do_pc_signed)
        sensitive << pc_register << j_target_int << pc_adder_result;

        SC_METHOD(do_zero)
        sensitive << reset;

    }

    private:
    const int nocache;
    const int single_cycle_fetch;
    const int ini_address;
    const int end_address;
    const int mode;
    const int quiet;

};

SC_MODULE(cpu_hmonitor) {
    sc_in<sc_logic> in;

    void do_monitor();

    SC_CTOR(cpu_hmonitor) {
        SC_METHOD(do_monitor);
        sensitive << in;        
    }

};

#endif
