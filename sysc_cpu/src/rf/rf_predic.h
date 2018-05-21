#include <systemc.h>
#include "../sizes.h"

#define N_PREDICATES 10

SC_MODULE( rf_predic )
{
	sc_in_clk clk;

	sc_in<sc_logic> wr_enable;	//write enable control
	sc_in<sc_logic> rd_enable;  //read enable control

	sc_in<sc_uint<REG_ADDR_SIZE> > wr_addr_in;
	sc_in<sc_uint<REG_ADDR_SIZE> > rda_addr_in;
	sc_in<sc_uint<REG_ADDR_SIZE> > rdb_addr_in;

	sc_in<sc_logic> data_in;

	sc_out<sc_logic> pa_data_out;
	sc_out<sc_logic> pb_data_out;

	sc_logic data[N_PREDICATES];

	void do_read_a();
	void do_read_b();
	void do_write();

	void dump_contents();

  	SC_CTOR( rf_predic )
	{
  		//initialization, all predicates are false
  		for (int i=0; i < N_PREDICATES; i++)
  			data[i] = sc_logic('0');

		SC_METHOD(do_read_a);
		sensitive << clk << rd_enable << rda_addr_in;

		SC_METHOD(do_read_b);
		sensitive << clk << rd_enable << rdb_addr_in;

		SC_METHOD(do_write);
		sensitive << clk << wr_enable << data_in;
	}

};

