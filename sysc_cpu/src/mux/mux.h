#ifndef MUX_H
#define	MUX_H

#include <systemc.h>
#include "../sizes.h"

#define MAX_MUX_PORTS 5

SC_MODULE( mux )
{
	sc_in<sc_int<WORD_SIZE> > *in; //[32];
	sc_in<sc_uint<MAX_MUX_PORTS> > addr;

	sc_out<sc_int<WORD_SIZE> > mux_out;

	void do_mux ();

	SC_HAS_PROCESS(mux);

	//parameterized module
	mux(sc_module_name name_, int n_inputs_ = 32) :
			    sc_module(name_), n_inputs(n_inputs_)
	{
  		SC_METHOD(do_mux);

  		in = new sc_in<sc_int<WORD_SIZE> > [n_inputs];

  		for (int i=0; i < n_inputs; i++)
  		  		sensitive << in[i];

  		sensitive << addr;
  	}

	private:
		const int n_inputs;

};

//in0 : in std_logic_vector(15 downto 0);
//in1 : in std_logic_vector(15 downto 0);

//addr    : in std_logic_vector(3 downto 0);
//mux_out : out STD_LOGIC_VECTOR (15 DOWNTO 0)

#endif
