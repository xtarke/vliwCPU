#include <systemc.h>
#include "../sizes.h"

#ifndef MUX3_1_H
#define	MUX3_1_H

SC_MODULE( mux3_1 )
{
	sc_in<sc_int<WORD_SIZE> > in0;
	sc_in<sc_int<WORD_SIZE> > in1;
	sc_in<sc_int<WORD_SIZE> > in2;
	sc_in<sc_int<WORD_SIZE> > in3;

	sc_in<sc_uint<N_ADDR_REGISTER> > sel;

	sc_out<sc_int<WORD_SIZE> > mux_out;

	void do_mux ();

  	SC_CTOR( mux3_1  )
	{
  		SC_METHOD(do_mux);
  		sensitive << in0 << in1 << in2 << in3 << sel;
  	}

};

//in0 : in std_logic_vector(15 downto 0);
//in1 : in std_logic_vector(15 downto 0);

//addr    : in std_logic_vector(3 downto 0);
//mux_out : out STD_LOGIC_VECTOR (15 DOWNTO 0)

#endif
