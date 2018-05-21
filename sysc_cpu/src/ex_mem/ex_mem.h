#include <systemc.h>
#include "../sizes.h"
#include "../controller/controller_types.h"


SC_MODULE( ex_mem )
{
	sc_in_clk clk;

	sc_in<sc_logic> reset;
	sc_in<sc_logic> load;

	sc_in<sc_int<WORD_SIZE > > pc_in;

	sc_in<sc_uint<WORD_SIZE> > instrunction_in;

	sc_in<sc_uint<WORD_SIZE> > mem_address_in;
	sc_in<sc_int<WORD_SIZE> > mem_data_in;
	sc_in<sc_int<WORD_SIZE> > alu_in;			//comes from ALU to write in WB in RF
	sc_in<sc_int<WORD_SIZE> > hi_in;			//comes from ALU to write in WB in HILO rf
	sc_in<sc_int<WORD_SIZE> > lo_in;			//comes from ALU to write in WB in HILO rf
	sc_in<sc_int<WORD_SIZE> > hilo_rf_data_in; //comes from HILO rf to write in WB in RF
	sc_in<sc_uint<REG_ADDR_SIZE> > dest_reg_in;
	sc_in<sc_uint<REG_ADDR_SIZE> > rt_in;
	sc_out<sc_uint<REG_ADDR_SIZE> > rt_out;
	sc_in<WbControl> ctrl_wb_signals_in;

	sc_out<sc_int<WORD_SIZE> > mem_data_out;
	sc_out<sc_uint<WORD_SIZE> > mem_address_out;
	sc_out<sc_int<WORD_SIZE> > alu_out;
	sc_out<sc_int<WORD_SIZE> > hi_out;
	sc_out<sc_int<WORD_SIZE> > lo_out;
	sc_out<sc_int<WORD_SIZE> > hilo_rf_data_out;
	sc_out<sc_uint<REG_ADDR_SIZE> > dest_reg_out;
	sc_out<WbControl> ctrl_wb_signals_out;

	sc_out<sc_int<WORD_SIZE > > pc_out;
	sc_out<sc_uint<WORD_SIZE> > instrunction_out;

	sc_signal<sc_uint<WORD_SIZE> > pc;
	sc_signal<sc_uint<WORD_SIZE> > data;
	sc_signal<sc_int<WORD_SIZE> > alu;
	sc_signal<sc_int<WORD_SIZE> > hi;
	sc_signal<sc_int<WORD_SIZE> > lo;
	sc_signal<sc_uint<REG_ADDR_SIZE> > rt;
	sc_signal<sc_uint<REG_ADDR_SIZE> > dest_reg;
	sc_signal<sc_uint<WORD_SIZE> > mem_address;
	sc_signal<sc_int<WORD_SIZE> > mem_data;
	sc_signal<sc_uint<WORD_SIZE> > ins;

	sc_signal<WbControl> Wb_control;


	void ex_mem_write ();
	void ex_mem_read ();

  	SC_CTOR( ex_mem )
	{
		SC_METHOD(ex_mem_write);
		sensitive << clk << reset << load << hilo_rf_data_in;

		SC_METHOD(ex_mem_read);
		sensitive << clk;


  	}

};


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
