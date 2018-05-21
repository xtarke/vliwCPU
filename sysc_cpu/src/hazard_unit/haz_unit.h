#include <systemc.h>
#include "../sizes.h"
#include "../controller/controller_types.h"


SC_MODULE( hazard_unit )
{
	sc_in_clk clk;
	sc_in<sc_logic> reset;

	//detection signals
	sc_in<WbControl> if_ex_ctrl_wb_signals_in;
	sc_in<sc_uint<WORD_SIZE> > ins_in;
	sc_in<sc_uint<REG_ADDR_SIZE> > if_id_rs;
	sc_in<sc_uint<REG_ADDR_SIZE> > if_id_rt;
	sc_in<sc_uint<REG_ADDR_SIZE> > id_ex_rt;

	//Hazard detection signal
	sc_out<sc_logic> stall_out;

	void do_hazard ();

  	SC_CTOR( hazard_unit )
	{
		SC_METHOD(do_hazard);
		sensitive << reset << if_id_rs << if_id_rt << id_ex_rt << if_ex_ctrl_wb_signals_in;
  	}

};
