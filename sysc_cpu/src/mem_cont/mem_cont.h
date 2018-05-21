#ifndef MEM_CTRL_H
#define	MEM_CTRL_H

#include <systemc.h>
#include "../sizes.h"
#include "../controller/controller_types.h"

//Data and access width controller
enum access_width{
	WORD_ACC_SEL = 0,
	HALF_WORD_ACC_SEL,
	BYTE_ACC_SEL
};

enum mem_ctr_state_type {
	MC_STOP = 0,
	MC_MEM_RD,
	MC_MEM_WR
 };

enum MEM_CONTROL_MODE
{
	NORMAL = 0,
	SP_0_ONLY
};

SC_MODULE( mem_control )
{
	sc_in_clk clk;
	sc_in_clk cpu_clk;

	sc_in<sc_logic> reset;

	sc_in<WbControl> ctrl_wb_signals_in;

	// address
	sc_in<sc_uint<RAM_ADDR_SIZE> > addr_in;
	sc_out<sc_uint<RAM_ADDR_SIZE> > sp_addr_out;

	//data
	sc_in<sc_int<WORD_SIZE> > pipe_data_in;

	sc_in<sc_int<WORD_SIZE> > sp_data_in;

	sc_out<sc_int<WORD_SIZE> > sp_data_w_out;
	sc_out<sc_int<WORD_SIZE> > data_r_out;

	sc_out<sc_logic> spram_rd_enable;

	sc_in<sc_int<WORD_SIZE> > ram_data_in;

	sc_out<sc_logic> ram_rd_enable;
	sc_out<sc_logic> ram_wr_enable;
	sc_out<sc_uint<RAM_ADDR_SIZE> > ram_addr_out;
	sc_out<sc_int<WORD_SIZE> > ram_data_out;
        sc_out<sc_logic> ram_clk_en_out;
        
	sc_out<sc_logic> stall_out;


	sc_signal<sc_logic> mem_type;		// 0 selects RAM or ROM (same address space), 1 selects SP_RAM
	sc_signal<sc_int<WORD_SIZE> > pipe_data;	//pipe data internally lachted
	sc_signal<sc_int<WORD_SIZE> > data_to_write;
	sc_signal<sc_int<WORD_SIZE> > data_read;

	sc_signal<sc_logic> acc_finish;
	sc_signal<sc_logic> mem_acc;
	sc_signal<sc_uint<RAM_ADDR_SIZE> > mem_addr;
	sc_signal<mem_ctr_state_type > mem_ctr_state;

	sc_signal<sc_logic> pipe_read;

	sc_signal<int> debug_state;

	void do_read_memories();

	void do_sp_read ();
	void do_sp_write ();

	void do_memory_enable();
	void do_calc_address ();

	void update_read_output();
	void update_write_output();

	void mem_sync();

	void do_clk_state();
	void do_output_logic();
	void do_read_pipe_data();

	void sel_mem_type();

	void do_debug();


	SC_HAS_PROCESS(mem_control);
//
	mem_control(sc_module_name name_, int mode_ = NORMAL) :
			 sc_module(name_), mode(mode_)
  	//SC_CTOR( mem_control )
	{
  		acc_finish.write(sc_logic('0'));
  		mem_acc.write(sc_logic('0'));
  		pipe_read.write(sc_logic('0'));

  		SC_METHOD(do_clk_state);
  		sensitive << clk << reset;

  		SC_METHOD(do_output_logic);
  		sensitive << mem_ctr_state;

  		SC_METHOD(mem_sync);
  		sensitive << clk << ctrl_wb_signals_in 
                        << mem_ctr_state << mem_type << mem_addr
                        << pipe_data_in;

  		SC_METHOD(do_calc_address);
  		sensitive << ctrl_wb_signals_in << addr_in;

  		SC_METHOD(update_read_output);
  		sensitive << ctrl_wb_signals_in << data_read << addr_in;

  		SC_METHOD(update_write_output);
  		sensitive << ctrl_wb_signals_in << pipe_data << data_read << addr_in;

  		SC_METHOD(do_read_memories)
  		sensitive << ram_data_in << sp_data_in << mem_type;

  		SC_METHOD(do_read_pipe_data)
  		sensitive << cpu_clk;

  		SC_METHOD(do_sp_read);
  		sensitive << ctrl_wb_signals_in << mem_addr <<mem_type;

  		SC_METHOD(do_sp_write);
  		sensitive << mem_type << data_to_write;

  		SC_METHOD(sel_mem_type);
  		sensitive << mem_addr;

  		SC_METHOD(do_debug);
		sensitive << mem_ctr_state;
  	}
	private:
		const int mode;


};

#endif
