#include "rom.h"


void rom::do_read()
{
	sc_logic local_enable;
	sc_logic local_rd;
	sc_uint<ADDR_SIZE> local_rd_addr;

	local_enable = enable.read();
	local_rd = rd.read();
	local_rd_addr = rd_addr.read();

	//latch on output
	if ((local_enable == 1) && (local_rd == 1))
	{
			data_out.write(memory_data[local_rd_addr].to_int());
	}

}

