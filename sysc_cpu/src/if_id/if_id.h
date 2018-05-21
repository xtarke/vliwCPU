#include <systemc.h>
#include "../sizes.h"


SC_MODULE( if_id )
{
	sc_in_clk clk;

	sc_in<sc_logic> reset;
	sc_in<sc_logic> load;
	sc_in<sc_int<WORD_SIZE> > data_in;
	sc_in<sc_uint<WORD_SIZE> > pc_in;

	sc_out<sc_int<WORD_SIZE> > pc_out; 		//pc_incremented
	sc_out<sc_uint<WORD_SIZE> > ins_out;		//read instruction

	sc_in<sc_logic> bubble_in;
	sc_out<sc_logic> bubble_out;

	sc_out<sc_uint<OPCODE_SIZE> > opcode_out;
	sc_out<sc_uint<SHAMT_SIZE> > shamt_out;
	sc_out<sc_uint<FUNCT_SIZE> > funct_out;

	sc_out<sc_int<WORD_SIZE> > j_target_out;
	sc_out<sc_int<WORD_SIZE> > immed_sigext;
        sc_out<sc_int<WORD_SIZE> > immed_zeroext;
	sc_out<sc_uint<REG_ADDR_SIZE> > rd_out;
	sc_out<sc_uint<REG_ADDR_SIZE> > rs_out;
	sc_out<sc_uint<REG_ADDR_SIZE> > rt_out;

	sc_signal<sc_uint<WORD_SIZE> > data;
	sc_signal<sc_uint<IMEDIATE_SIZE> > immediate;
	sc_signal<sc_int<WORD_SIZE> > pc;

	void if_id_write ();
	void if_id_read ();

  	SC_CTOR( if_id )
	{
		SC_METHOD(if_id_write);
		sensitive << clk << reset << load << bubble_in;

		SC_METHOD(if_id_read);
		sensitive << clk << reset << load << bubble_in;
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
