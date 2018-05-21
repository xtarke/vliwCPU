#include <systemc.h>
#include "../sizes.h"


SC_MODULE( umemory )
{
	sc_in_clk clk_pa;
        sc_in_clk clk_pb;
        sc_in_clk clk_pw;

	sc_in<sc_logic> enable;
	// rd/wr
	sc_in<sc_logic> wr;
	sc_in<sc_logic> rd_a;
	sc_in<sc_logic> rd_b;

	// address
	sc_in<sc_uint<RAM_ADDR_SIZE> > w_addr;

	sc_in<sc_uint<RAM_ADDR_SIZE> > rd_a_addr;
	sc_in<sc_uint<RAM_ADDR_SIZE> > rd_b_addr;

	//data
	sc_in<sc_int<WORD_SIZE> > data_in;
	sc_out<sc_int<WORD_SIZE> > data_a_out;
	sc_out<sc_int<WORD_SIZE> > data_b_out;

	sc_uint<WORD_SIZE> memory_data[MEMORY_SIZE_WORDS];


	void do_a_read ();
	void do_b_read ();
	void do_write ();

	void dump_contents();
        void dump_contents_hword();
        void dump_contents_dec();


  	SC_CTOR( umemory )
	{

  		SC_METHOD(do_a_read);
  		sensitive << clk_pa << rd_a_addr;

  		SC_METHOD(do_b_read);
  		sensitive << clk_pb << rd_b_addr;

  		SC_METHOD(do_write);
		sensitive << clk_pw;
  	}

};

