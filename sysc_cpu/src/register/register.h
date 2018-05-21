#include <systemc.h>
#include "../sizes.h"

#ifndef REG16_H
#define	REG16_H

SC_MODULE( reg )
{
	// clock
	sc_in_clk clk;

	//flags
	sc_in<sc_logic> clear;
	sc_in<sc_logic> w_flag;

	//data
	sc_in<sc_int<WORD_SIZE> > data_in;
	sc_out<sc_int<WORD_SIZE> > reg_out;

	void do_operation ();

	SC_HAS_PROCESS(reg);

	reg(sc_module_name name_, int initial_val_ = 0) :
			sc_module(name_), inital_val(initial_val_)
	{
  		SC_METHOD(do_operation);
  		sensitive << clk << clear << w_flag;
  	}
	private:
		sc_int<WORD_SIZE> inital_val;


};

//entity reg16 is
//port (
//	clk       : IN STD_LOGIC;
//	clear     : IN STD_LOGIC;
//	w_flag    : IN STD_LOGIC;
//	datain    : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
//	reg_out   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
//);
//end reg16;

#endif
