#include <systemc.h>
#include <sstream>
#include <string>
#include "../sizes.h"
#include "../register/register.h"

#ifndef RF_HILO_H
#define	RF_HILO_H

#define LO_RF_ADDR 0
#define HI_RF_ADDR 1

SC_MODULE( rf_hilo )
{
	sc_in_clk clk;
	sc_in<sc_logic> reset;

	//write port
	sc_in<sc_int <WORD_SIZE> > lo_data_in;
	sc_in<sc_int <WORD_SIZE> > hi_data_in;

	sc_in<sc_logic> wr_enable;	//write enable control
	sc_in<sc_logic> rd_enable;  //read enable control

	//ra read port
	sc_in<sc_uint<2> > rd_addr_in;
	sc_out<sc_int <WORD_SIZE> > rd_data_out;

	sc_signal<sc_int <WORD_SIZE> > register_out[2];

	// low level components
	//registers

	reg *register_banc[2];

	//read control logic (port a)
	void do_rd_mux();

	//debug_ports
	void do_write_debug();
	void dump_contents();

	SC_CTOR( rf_hilo )
	{

		//lo register
		register_banc[0] = new reg("lo_register");
		register_banc[0]->clk(clk);
		register_banc[0]->clear(reset);
		register_banc[0]->w_flag(wr_enable);
		register_banc[0]->data_in(lo_data_in);
		register_banc[0]->reg_out(register_out[0]);

		//hi register
		register_banc[1] = new reg("hi_register");
		register_banc[1]->clk(clk);
		register_banc[1]->clear(reset);
		register_banc[1]->w_flag(wr_enable);
		register_banc[1]->data_in(hi_data_in);
		register_banc[1]->reg_out(register_out[1]);

  		SC_METHOD(do_rd_mux);
  		sensitive << rd_enable << rd_addr_in << register_out[0] 
                        << register_out[1] << reset;

  	}
};

#endif
