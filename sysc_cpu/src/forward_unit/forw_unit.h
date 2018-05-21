#include <systemc.h>
#include "../sizes.h"
#include "../controller/controller_types.h"


SC_MODULE( forw_unit )
{
	sc_in_clk clk;
	sc_in<sc_logic> reset;

	//detection signals
	sc_in<WbControl> id_ex_ctrl_wb_signals_in;
	sc_in<WbControl> ex_mem_ctrl_wb_signals_in;
	sc_in<sc_logic> id_ex_hilo_r_enable;
	sc_in<sc_uint<2> > id_ex_hilo_addr;
	sc_in<sc_logic> mem_wb_hilo_w_enable;
	sc_in<sc_logic> mem_wb_reg_w_enable;
        sc_in<sc_logic> mem_wb_cmov;
	sc_in<sc_logic> ex_mem_memory_read;
	sc_in<sc_logic> mem_wb_rpred_w_enable;
	sc_in<sc_uint<REG_ADDR_SIZE> > ex_mem_dest_reg;
	sc_in<sc_uint<REG_ADDR_SIZE> > mem_wb_dest_reg;
	sc_in<sc_uint<REG_ADDR_SIZE> > id_ex_rs;
	sc_in<sc_uint<REG_ADDR_SIZE> > id_ex_rt;
	sc_in<sc_uint<REG_ADDR_SIZE> > id_ex_dest_reg;
	sc_in<sc_uint<REG_ADDR_SIZE> > ex_mem_rt;
	sc_in<sc_uint<REG_ADDR_SIZE> > if_id_rs;
	sc_in<sc_logic> rpred_if_rs_value_in;

	//internal MUX
	sc_in<sc_int<WORD_SIZE> > hilo_data_in;
	sc_in<sc_int<WORD_SIZE> > ex_mem_lo;
	sc_in<sc_int<WORD_SIZE> > ex_mem_hi;
	sc_in<sc_int<WORD_SIZE> > mem_wb_hi;
	sc_in<sc_int<WORD_SIZE> > mem_wb_lo;
	sc_in<sc_int<WORD_SIZE> > rf_rs_value;
	sc_in<sc_int<WORD_SIZE> > rf_rt_value;
	sc_in<sc_int<WORD_SIZE> > id_ex_alu;
	sc_in<sc_int<WORD_SIZE> > ex_mem_alu;
	sc_in<sc_int<WORD_SIZE> > mem_wb_w_data;
	sc_in<sc_int<WORD_SIZE> > ex_mem_ram_datain;
	sc_in<sc_int<WORD_SIZE> > mem_wb_ram_datain;
	sc_in<sc_logic> mem_wb_pred_data_in;
	//predicates
	sc_in<sc_int<WORD_SIZE> > rpred_rs_value_in;
	sc_in<sc_int<WORD_SIZE> > rpred_rt_value_in;
	//ra to jr
	sc_in<sc_int<WORD_SIZE> > id_rs_value;
	//memory
	sc_in<sc_int<WORD_SIZE> > memory_data;

	//alu and hilo outputs (EX stage)
	sc_out<sc_int<WORD_SIZE> > rpred_rs_value_out;
	sc_out<sc_int<WORD_SIZE> > rpred_rt_value_out;
	sc_out<sc_int<WORD_SIZE> > alu_a_out;
	sc_out<sc_int<WORD_SIZE> > alu_b_out;
	sc_out<sc_int<WORD_SIZE> > ram_data_out;
	sc_out<sc_int<WORD_SIZE> > hilo_data_out;
	//
	//controller predicate read output (ID stage)
	sc_out<sc_logic> if_id_pred_s_out;
	//jump to register mux read output (ID STAGE)
	sc_out<sc_int<WORD_SIZE> > if_id_rs_out;



	void do_forward ();

  	SC_CTOR( forw_unit )
	{
		SC_METHOD(do_forward);
		sensitive << clk << reset << rf_rs_value << rf_rt_value << ex_mem_alu
				<< mem_wb_w_data << ex_mem_dest_reg << ex_mem_rt << ex_mem_memory_read <<
				rpred_rs_value_in << rpred_rt_value_in << id_ex_ctrl_wb_signals_in <<
				rpred_if_rs_value_in << id_ex_alu << id_ex_alu << id_rs_value << memory_data;

  	}

};

