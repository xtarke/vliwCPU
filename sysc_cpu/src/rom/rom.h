#include <systemc.h>
#include "../sizes.h"



SC_MODULE( rom )
{
	sc_in_clk clk;
	sc_in<sc_logic> enable;
	// rd/wr
	sc_in<sc_logic> rd;
	// address
	sc_in<sc_uint<RAM_ADDR_SIZE> > rd_addr;
	//data
	sc_out<sc_int<WORD_SIZE> > data_out;

	sc_uint<WORD_SIZE> memory_data[IMAGE_SIZE];

	void do_read ();

  	SC_CTOR( rom )
	{
  		SC_METHOD(do_read);
  		sensitive << clk << rd_addr << enable << rd;
  	}

};

//port (
//	clk     : in std_logic;
//	enable  : in std_logic;
//
//	rd     : in std_logic;
//	-- address
//	rd_addr : std_logic_vector(addr_size-1 downto 0);
//	-- data
//	data_out : out std_logic_vector (word_size-1 downto 0) );
//end rom;
