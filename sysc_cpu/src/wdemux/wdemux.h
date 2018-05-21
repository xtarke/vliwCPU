#include <systemc.h>
#include "../sizes.h"


SC_MODULE( wdemux )
{
	sc_in<sc_uint<N_ADDR_REGISTER> > addr;
	sc_in<sc_logic> out_ena;

	sc_out<sc_lv<WORD_SIZE> > demux_out;

	void do_wdemux ();

  	SC_CTOR( wdemux  )
	{
  		SC_METHOD(do_wdemux);
  		sensitive << addr << out_ena;
  	}

};

//entity demux is
//port (
//	addr   	  : in STD_LOGIC_VECTOR (3 DOWNTO 0);
//	out_ena    : in std_logic;
//	demux_out  : out STD_LOGIC_VECTOR (15 DOWNTO 0)
//);
//end demux;
