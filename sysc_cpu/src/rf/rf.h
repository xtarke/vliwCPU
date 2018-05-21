#ifndef RF_H
#define	RF_H

#include <systemc.h>
#include <sstream>
#include <string>
#include "../sizes.h"
#include "../register/register.h"
#include "../mux2-1/mux2-1.h"
#include "../wdemux/wdemux.h"

SC_MODULE( rf )
{
	sc_in_clk clk;
	sc_in<sc_logic> reset;

	//write port
	sc_in<sc_uint<N_ADDR_REGISTER> > w_addr;
	sc_in<sc_int <WORD_SIZE> > w_data;
	sc_in<sc_logic> w_wr;

	//ra read port
	sc_in<sc_uint<N_ADDR_REGISTER> > ra_addr;
	sc_out<sc_int <WORD_SIZE> > ra_data;
	sc_in<sc_logic> ra_rd;

	//rb read port
	sc_in<sc_uint<N_ADDR_REGISTER> > rb_addr;
	sc_out<sc_int <WORD_SIZE> > rb_data;
	sc_in<sc_logic> rb_rd;

	//internal signals
	//signals
	sc_signal<sc_lv<WORD_SIZE> > w_sel;
	sc_signal<sc_lv<WORD_SIZE> > ra_sel;
	sc_signal<sc_lv<WORD_SIZE> > rb_sel;

	sc_signal<sc_int<WORD_SIZE> > r0;
	sc_signal<sc_int<WORD_SIZE> > r1;

	sc_signal<sc_int <WORD_SIZE> > register_out[N_REGISTERS];

	sc_signal<sc_int<WORD_SIZE> > mux_out_ra;
	sc_signal<sc_int<WORD_SIZE> > mux_out_rb;

	sc_signal<sc_logic> w_select[N_REGISTERS];

	// low level components
	//registers

	reg *register_banc[N_REGISTERS];

	//write port decode logic
	wdemux *WDEMUX;
	//read port decoce logic
	mux2_1 *RA_MUX;
	mux2_1 *RB_MUX;

	//read control logic (port a)
	void do_rd_ctl_ra();
	//read control logic (port b)
	void do_rd_ctl_rb();

	//wsel
	void do_wsel_wsel_bit();

	//debug_ports
	void do_write_debug();
	void dump_contents();

    SC_HAS_PROCESS(rf);

    //parameterized module
    rf(sc_module_name name_, int n_registers_ = 32) :
		    sc_module(name_), n_registers(n_registers_)
	{
  		//port conections
  		RA_MUX = new mux2_1("RA_MUX", n_registers);
  		RA_MUX->addr(ra_addr);
  		RA_MUX->mux_out(mux_out_ra);

  		RB_MUX = new mux2_1("RB_MUX", n_registers);
  		RB_MUX->addr(rb_addr);
  		RB_MUX->mux_out(mux_out_rb);

  		WDEMUX = new wdemux("WDEMUX");
  		WDEMUX->addr(w_addr);
  		WDEMUX->out_ena(w_wr);
  		WDEMUX->demux_out(w_sel);

  		for (int i = 0; i < n_registers; i++)
  		{
  			std::stringstream out;
  			out << "register_" << i;
  			std::string reg_name = out.str();

//                        //stack pointer
//                        if (i == 29)
//                        {
//                            register_banc[i] = new reg(reg_name.c_str(), 0x033fc);
//                            SC_REPORT_INFO(1, "STACK_POINTER initialized: R29 =  0x33fc");
//                        }
//                        else    
                            register_banc[i] = new reg(reg_name.c_str());

  			register_banc[i]->clk(clk);
  			register_banc[i]->clear(reset);
  			register_banc[i]->w_flag(w_select[i]);
  			register_banc[i]->data_in(w_data);
  			register_banc[i]->reg_out(register_out[i]);

  			RA_MUX->in[i](register_out[i]);
  			RB_MUX->in[i](register_out[i]);
  		}

  		SC_METHOD(do_rd_ctl_ra);
  		sensitive << ra_rd << mux_out_ra << reset;

  		SC_METHOD(do_rd_ctl_rb);
  		sensitive << rb_rd << mux_out_rb << reset;

  		SC_METHOD(do_wsel_wsel_bit);
  		sensitive << w_sel;

  	}
	private:
		const int n_registers;

};

#endif
