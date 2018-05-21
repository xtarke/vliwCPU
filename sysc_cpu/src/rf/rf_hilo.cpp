#include "rf_hilo.h"

void rf_hilo::do_rd_mux()
{
	sc_logic local_rd;
	sc_logic local_reset;
	sc_uint<2> local_rd_addr;

	sc_int<WORD_SIZE> local_value;

	local_reset = reset.read();
	local_rd = rd_enable.read();
	local_rd_addr = rd_addr_in.read();


	//cout << "local_mux_out_ra : " << local_mux_out_ra << endl;

	if ((local_rd == 1) && (local_reset == 0))
	{
		if (local_rd_addr < 2)
		{
			local_value = register_out[local_rd_addr].read();
			rd_data_out.write(local_value);
		}
		//cout << "local_mux_out_ra : " << local_mux_out_ra << endl;
	}
}

//--read control logic (port a)
//process (ra_rd, mux_out_ra, reset)
//begin
//	if ra_rd = '1' and reset = '0'  then
//		ra_data <= mux_out_ra;
//	--else
//	--	ra_data <= "ZZZZZZZZZZZZZZZZ";
//	end if;
//end process;

void rf_hilo::dump_contents()
{
	cout << "Hi Lo register contents:" << endl;

	cout << "Lo = " << register_out[0].read() << endl;
	cout << "Hi = " << register_out[1].read() << endl;

}
