/*
 * debug.h
 *
 *  Created on: Apr 17, 2013
 *      Author: xtarke
 */

#ifndef DEBUG_H
#define	DEBUG_H

#include <systemc.h>
#include "../sizes.h"
#include "../rf/rf.h"



SC_MODULE( debug )
{
	//-----------------
	sc_in<sc_logic> reset;

	sc_signal<bool> stop;

	sc_in<sc_uint<WORD_SIZE> > instrunction_in;
	sc_in<sc_int<WORD_SIZE> > pc_in;

	void do_run_history();


//	void read_key();

  	SC_CTOR( debug )
	{

  		SC_METHOD(do_run_history);
  		sensitive << instrunction_in;

  	}

};

#endif



