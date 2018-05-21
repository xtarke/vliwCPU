#include "ex_mem.h"
#include "controller_types.h"

void ex_mem::ex_mem_write()
{
	sc_logic local_reset;
	sc_logic local_load;

	sc_uint<WORD_SIZE> local_pc;
	sc_uint<WORD_SIZE> local_data;
	sc_int<WORD_SIZE> local_alu;
	sc_int<WORD_SIZE> local_hi;
	sc_int<WORD_SIZE> local_lo;
	sc_uint<REG_ADDR_SIZE> local_rt;
	sc_uint<REG_ADDR_SIZE> local_dest_reg;
	sc_int<WORD_SIZE> local_hilo_rf_data;
	sc_uint<WORD_SIZE> local_mem_address;
	sc_int<WORD_SIZE> local_mem_data;
	sc_uint<WORD_SIZE> local_ins;

	WbControl local_Wb_control;

	//assync read
	local_reset = reset.read();
	local_load = load.read();
	local_hilo_rf_data = hilo_rf_data_in.read();

	//sync read
	local_pc = pc.read();
	local_alu = alu.read();
	local_dest_reg = dest_reg.read();
	local_Wb_control = Wb_control.read();
	local_hi = hi.read();
	local_lo = lo.read();
	local_alu = alu.read();
	local_mem_data = mem_data.read();
	local_mem_address = mem_address.read();
	local_rt = rt.read();
	local_ins = ins.read();

	if (local_reset == sc_logic('1'))
	{
		//reset all signals
		local_Wb_control.reset();

		ctrl_wb_signals_out.write(local_Wb_control);
		hilo_rf_data_out.write(0);
		mem_address_out.write(0);
		dest_reg_out.write(0);
		hi_out.write(0);
		lo_out.write(0);
		mem_data_out.write(0);
		pc_out.write(0);
		alu_out.write(0);
		rt_out.write(0);
		instrunction_out.write(0);
	}
	else if (local_load == 1 && clk.posedge())
	{
		//alu data is read in here because RAM output
		//is in negedgde, so data is ready only here
		//only works if ALU outputs are latched

//		local_hi = hi_in.read();
//		local_lo = lo_in.read();

		rt_out.write(local_rt);

		alu_out.write(local_alu);
		ctrl_wb_signals_out.write(local_Wb_control);
		dest_reg_out.write(local_dest_reg);

		hi_out.write(local_hi);
		lo_out.write(local_lo);

		hilo_rf_data_out.write(local_hilo_rf_data);
		mem_address_out.write(local_mem_address);

		mem_data_out.write(local_mem_data);
		pc_out.write(local_pc.to_int());

		instrunction_out.write(local_ins);

	}
};


void ex_mem::ex_mem_read()
{
	sc_uint<WORD_SIZE> local_pc;
	sc_uint<WORD_SIZE> local_data;
	sc_int<WORD_SIZE> local_alu;
	sc_int<WORD_SIZE> local_hi;
	sc_int<WORD_SIZE> local_lo;
	sc_uint<REG_ADDR_SIZE> local_rt;
	sc_uint<REG_ADDR_SIZE> local_dest_reg;
	sc_uint<WORD_SIZE> local_mem_address;
	sc_int<WORD_SIZE> local_mem_data;
	sc_uint<WORD_SIZE> local_ins;

	WbControl local_Wb_control;

	local_pc = pc_in.read();
	local_alu = alu_in.read();
	local_dest_reg = dest_reg_in.read();
	local_Wb_control = ctrl_wb_signals_in.read();
	local_hi = hi_in.read();
	local_lo = lo_in.read();
	local_alu = alu_in.read();
	local_mem_data = mem_data_in.read();
	local_mem_address = mem_address_in.read();
	local_rt = rt_in.read();
	local_ins = instrunction_in.read();


	if (clk.negedge())
	{
		pc.write(local_pc);
		alu.write(local_alu);
		dest_reg.write(local_dest_reg);
		Wb_control.write(local_Wb_control);
		hi.write(local_hi);
		lo.write(local_lo);
		alu.write(local_alu);
		mem_data.write(local_mem_data);
		mem_address.write(local_mem_address);

		rt.write(local_rt);
		ins.write(local_ins);
	}
}
