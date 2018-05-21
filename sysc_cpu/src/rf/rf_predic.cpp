#include "rf_predic.h"

//asynchronous read
void rf_predic::do_read_a()
{
	sc_logic local_rd;
	sc_uint<N_PREDICATES> local_addr;

	local_rd = rd_enable.read();
	local_addr = rda_addr_in.read();

	if ((local_rd == sc_logic('1')) && (local_addr < N_PREDICATES) )
	{
		pa_data_out.write(data[local_addr]);
	}
};

//asynchronous read
void rf_predic::do_read_b()
{
	sc_logic local_rd;
	sc_uint<N_PREDICATES> local_addr;

	local_rd = rd_enable.read();
	local_addr = rdb_addr_in.read();

	if ((local_rd == sc_logic('1')) && (local_addr < N_PREDICATES) )
	{
		pb_data_out.write(data[local_addr]);
	}
};


void rf_predic::do_write()
{
	sc_logic local_wr;
	sc_logic local_data;
	sc_uint<N_PREDICATES> local_addr;

	local_addr = wr_addr_in.read();
	local_wr = wr_enable.read();
	local_data = data_in.read();

	if (local_wr == sc_logic('1'))
	{
		if ((clk.posedge() == true) && (local_addr < N_PREDICATES))
		{
			data[local_addr] = local_data;
		}
	}
};

void rf_predic::dump_contents()
{
	cout << "Predicate Register contents:" << endl;
	for (int i = 0; i < N_PREDICATES; i++)
		cout << "P[" << i << "] = " << hex << data[i] << endl;

}
