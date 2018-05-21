#include "wdemux.h"


void wdemux::do_wdemux()
{
	sc_logic local_out_ena;
	sc_uint<N_ADDR_REGISTER> local_addr;
	sc_lv<WORD_SIZE> local_demux_out;

	local_out_ena = out_ena.read();
	local_addr = addr.read();


	local_demux_out = "000000000000000000000000000000";

	//cout << "wdemux _ addr: " << local_addr << endl;


	if (local_out_ena == 1)
	{
		if (local_addr < N_REGISTERS)
			local_demux_out[local_addr] = "1";
		else
			local_demux_out = "000000000000000000000000000000";


//		switch (local_addr)
//		{
//			case 0:
//				local_demux_out[0] = "1";
//				break;
//			case 1:
//				local_demux_out[1] = "1";
//	 			break;
//			case 2:
//				local_demux_out[2] = "1";
//				break;
//			case 3:
//				local_demux_out[3] = "1";
//				break;
//			case 4:
//				local_demux_out[4] = "1";
//				break;
//			case 5:
//				local_demux_out[5] = "1";
//		 		break;
//			default:
//				//cout << "wdemux: " << local_addr << " addr out of bounds" << endl;
//				local_demux_out = "0000000000000000";
//				break;
//		}

	}

	//cout << "wdemux _ out: " << local_demux_out << endl;

	demux_out.write(local_demux_out);


}

//sc_in<sc_uint<3> > addr;
//sc_in<sc_logic> out_ena;

//architecture demux_logic of demux is
//begin
//	process (addr, out_ena)
//	begin
//		demux_out <= x"0000";
//
//		if out_ena = '1' then
//			case (addr) is
//				when x"0" => demux_out <= x"0001";
//				when x"1" => demux_out <= x"0002";
//				when x"2" => demux_out <= x"0004";
//				when x"3" => demux_out <= x"0008";
//				when x"4" => demux_out <= x"0010";
//				when x"5" => demux_out <= x"0020";
//				when x"6" => demux_out <= x"0040";
//				when x"7" => demux_out <= x"0080";
//				when x"8" => demux_out <= x"0100";
//				when x"9" => demux_out <= x"0200";
//				when x"a" => demux_out <= x"0400";
//				when x"b" => demux_out <= x"0800";
//				when x"c" => demux_out <= x"1000";
//				when x"d" => demux_out <= x"2000";
//				when x"e" => demux_out <= x"4000";
//				when x"f" => demux_out <= x"8000";
//				when others => demux_out <= x"0000";
//			end case;
//		end if;
//	end process;
//end demux_logic;

