#ifndef ID_EX_H
#define	ID_EX_H

#include <systemc.h>
#include "../sizes.h"
#include "../mux/mux.h"
#include "../controller/controller_types.h"

SC_MODULE( id_ex )
{
	sc_in_clk clk;

	sc_in<sc_logic> reset;
	sc_in<sc_logic> load;

	//alu control signals in
	sc_in<sc_uint<ALUOPS> > alu_op_in;
	sc_in<sc_uint<SHAMT_SIZE> > alu_shamt_in;
	sc_in<sc_uint<MAX_MUX_PORTS> > alu_pa_sel_in;
	sc_in<sc_uint<MAX_MUX_PORTS> > alu_pb_sel_in;
	//alu control signals out
	sc_out<sc_uint<ALUOPS> > alu_op_out;
	sc_out<sc_uint<SHAMT_SIZE> > alu_shamt_out;
	sc_out<sc_uint<MAX_MUX_PORTS> > alu_pa_sel_out;
	sc_out<sc_uint<MAX_MUX_PORTS> > alu_pb_sel_out;

	//register write signals in
	sc_in<WbControl> ctrl_wb_signals_in;
	sc_in<sc_uint<REG_ADDR_SIZE> >dest_reg_in;
	//register write signals out
	sc_out<WbControl> ctrl_wb_signals_out;
	sc_out<sc_uint<REG_ADDR_SIZE> >dest_reg_out;

	sc_in<sc_logic> hilo_rd_enable_in;
	sc_out<sc_logic> hilo_rd_enable_out;

	sc_in<sc_logic> mem_adder_enable_in;
	sc_out<sc_logic> mem_adder_enable_out;


	sc_in<sc_uint<2> > hilo_addr_in;
	sc_out<sc_uint<2> > hilo_addr_out;

	sc_in<sc_int<WORD_SIZE> > hilo_rf_data_in;
	sc_out<sc_int<WORD_SIZE> > hilo_rf_data_out;

	sc_in<sc_int<WORD_SIZE > > pc_in;
	sc_in<sc_uint<WORD_SIZE> > instrunction_in;	//read instrunction

	sc_in<sc_int<WORD_SIZE> > immed_sigext_in;
        sc_in<sc_int<WORD_SIZE> > immed_zeroext_in;

	sc_in<sc_int<WORD_SIZE> > rs_value_in;
	sc_in<sc_int<WORD_SIZE> > rt_value_in;
	sc_in<sc_logic> rpred_rs_value_in;
	sc_in<sc_logic> rpred_rt_value_in;

	sc_out<sc_int<WORD_SIZE> > pc_out;
	sc_out<sc_int<WORD_SIZE> > immed_sigext_out;
        sc_out<sc_int<WORD_SIZE> > immed_zeroext_out;

	sc_out<sc_uint<REG_ADDR_SIZE> > rs_out;
	sc_out<sc_uint<REG_ADDR_SIZE> > rd_out;
	sc_out<sc_uint<REG_ADDR_SIZE> > rt_out;

	sc_in<sc_logic> bubble_in;
	sc_out<sc_logic> bubble_out;

	sc_in<sc_logic> if_id_reset_in;
	sc_out<sc_logic> if_id_reset_out;

	sc_out<sc_int<WORD_SIZE> > rs_value_out;
	sc_out<sc_int<WORD_SIZE> > rt_value_out;
	sc_out<sc_int<WORD_SIZE> > rpred_rs_value_out;
	sc_out<sc_int<WORD_SIZE> > rpred_rt_value_out;

	sc_out<sc_uint<WORD_SIZE> > instrunction_out;

	sc_signal<sc_logic> mem_adder;
	sc_signal<sc_logic> if_id_reset;
	sc_signal<sc_logic> hilo_rd_enable;
	sc_signal<sc_uint<2> > hilo_addr;
	//sc_signal<sc_int<WORD_SIZE> > hilo_rf_data;
	sc_signal<WbControl> Wb_control;
	sc_signal<sc_uint<REG_ADDR_SIZE> > dest_reg;
	sc_signal<sc_uint<WORD_SIZE> > pc;
	sc_signal<sc_uint<WORD_SIZE> > instrunction;

	sc_signal<sc_int<WORD_SIZE> > immediate_sigext;
        sc_signal<sc_int<WORD_SIZE> > immediate_zeroext;
	sc_signal<sc_uint<MAX_MUX_PORTS> > alu_pa_sel;
	sc_signal<sc_uint<MAX_MUX_PORTS> > alu_pb_sel;
	sc_signal<sc_uint<ALUOPS> > alu_op;
	sc_signal<sc_uint<SHAMT_SIZE> > alu_shamt;


	void id_ex_write ();
	void id_ex_read ();

  	SC_CTOR( id_ex )
	{
		SC_METHOD(id_ex_write);
		sensitive << clk << reset << load << rs_value_in << rs_value_in <<
				rpred_rs_value_in << rpred_rt_value_in << hilo_rf_data_in;

		SC_METHOD(id_ex_read);
		sensitive << clk;
  	}

};

#endif

//clk:    in std_logic;
//	reset:  in std_logic;
//	load:	  in std_logic;
//	data:   in std_logic_vector(n-1 downto 0);
//
//	opcode:  out std_logic_vector(n/2 - 1 downto 0);
//	mem_addr: out std_logic_vector(n/2 - 1 downto 0);
//	imediate: out std_logic_vector(n/2 - 1 downto 0);
//
//	reg_a:   out std_logic_vector(n/4 - 1 downto 0);
//	reg_b:   out std_logic_vector(n/4 - 1 downto 0)
