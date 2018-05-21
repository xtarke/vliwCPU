#ifndef CTRL_H
#define	CTRL_H

#include <systemc.h>
#include "../sizes.h"
#include "controller_types.h"
#include "../mux/mux.h"

//enum cpu_stage_type_old {STOP = 0,
//			HALT,
//			FETCH,
//			DECODE,
//			MEM_CALC,
//			ALU_EXE,
//			BRANCH_COMPL,
//			JUMP_COMPL,
//			MEM_RD,
//			MEM_WR,
//			LD_IMED,
//			WR_BK_MEM,
//			WR_BK_REG_1,
//			WR_BK_REG_2,
//			ERROR
// };

enum cpu_stage_type {
			STOP   = 0,
			RUN    = 1,
			HALT   = 7
 };


SC_MODULE( controller )
{
	//-----------------
	sc_in_clk clk;
	sc_in<sc_logic> reset;

	//-- instr type
	sc_in<sc_uint<OPCODE_SIZE> > insopcode;
	sc_in<sc_uint<SHAMT_SIZE> > shamt;
	sc_in<sc_uint<FUNCT_SIZE> > funct;

	//--bubble
	sc_in<sc_logic> hazd_in;
	sc_in<sc_logic>	i_cache_stall_in;
	sc_in<sc_logic> mem_stall;

	//--rom control
	sc_out<sc_logic> rom_rd;
	sc_out<sc_logic> rom_enable;
	//--pc control
	sc_out<sc_logic> pc_inc;
	sc_out<sc_logic> pc_load;
	//-- inst_register control
	sc_out<sc_logic> if_id_load;

	sc_out<sc_logic> pipeline_load;
	sc_out<sc_logic> pipe_flush;

	sc_out<sc_logic> pc_adder_enable;

	//-- register write
	sc_out<sc_uint<N_ADDR_REGISTER> > reg_w_addr;
	sc_out<sc_uint<N_ADDR_REGISTER> > reg_write_sel;
	sc_out<sc_logic> reg_w_enable;
	//-- register read
	sc_out<sc_logic> pred_rd_enable;
	sc_out<sc_logic> ra_rd_enable;
	sc_out<sc_logic> rb_rd_enable;
	sc_out<sc_uint<N_ADDR_REGISTER> > rega_rd_addr;
	sc_out<sc_uint<N_ADDR_REGISTER> > regb_rd_addr;

	//-- alu control
	sc_out<sc_uint<ALUOPS> > alu_op_out;
	sc_out<sc_uint<SHAMT_SIZE> > alu_shamt_out;
	sc_out<sc_uint<MAX_MUX_PORTS> > alu_pa_sel;
	sc_out<sc_uint<MAX_MUX_PORTS> > alu_pb_sel;

	sc_in<sc_int<WORD_SIZE> > immediate_in;
	sc_in<sc_logic> rpred_rs_value_in;

	sc_out<sc_uint<MAX_MUX_PORTS> > j_target_sel;

	sc_in<sc_uint<REG_ADDR_SIZE> > rd_in;
	sc_in<sc_uint<REG_ADDR_SIZE> > rt_in;
	sc_out<sc_uint<REG_ADDR_SIZE> >dest_reg_out;
	sc_out<WbControl> ctrl_wb_signals_out;
	//----
	//HI_LO control
	sc_out<sc_uint<2> > hi_lo_address_out;
	sc_out<sc_logic> hi_lo_enable;

	//MEM adder control
	sc_out<sc_logic> mem_adder_enable;
	//RAM enable
	sc_out<sc_logic> ram_enable;

	//internel signals
	sc_signal<cpu_stage_type > cpu_stage;
	sc_signal<cpu_stage_type > next_cpu_stage;

	//debug
	sc_out <int> int_cpu_stage;

	void do_clk_state();
	void do_state_logic();
	void do_output_logic();
	void enable_fetch();

	void do_debug();


  	SC_CTOR( controller )
	{
  		SC_METHOD(do_clk_state);
  		sensitive << clk << reset;

  		SC_METHOD(enable_fetch);
  		sensitive << cpu_stage;

  		SC_METHOD(do_output_logic);
  		sensitive << hazd_in << cpu_stage <<  insopcode << shamt <<  funct <<  rd_in <<
  				rt_in << rpred_rs_value_in << i_cache_stall_in << mem_stall;

  		SC_METHOD(do_debug);
  		sensitive << cpu_stage;

  	}

};

#endif
