#include <systemc.h>
#include "../sizes.h"

#ifndef ADDER_H
#define	ADDER_H

SC_MODULE( adder )
{
	sc_in<sc_logic> enable;
	sc_in<sc_int<WORD_SIZE> > a;
	sc_in<sc_int<WORD_SIZE> > b;

	sc_out<sc_uint<WORD_SIZE> > result;

	void do_calc ();

  	SC_CTOR( adder )
	{
		SC_METHOD(do_calc);
		sensitive << a << b << enable;
  	}

};

#endif
