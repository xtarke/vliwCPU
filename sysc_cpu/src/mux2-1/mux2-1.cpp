#include "mux2-1.h"


void mux2_1::do_mux()
{
	sc_int<WORD_SIZE> local_in[n_inputs];

	sc_uint<N_ADDR_REGISTER> local_addr;

	for (int i = 0; i < n_inputs; i++)
		local_in[i] = in[i].read();

	local_addr = addr.read();

	//cout << "mux2_1: " << "in0: "  << local_in0 << " in1 " << local_in1 << " addr: " <<  local_addr << endl;

	mux_out.write(local_in[local_addr]);


//	switch (local_addr)
//	{
//		case 0:
//			mux_out.write(local_in0);
//			//cout << "@ " << sc_time_stamp() << "mux2_1: " << "in0: "  << local_in0 << endl;
//			break;
//	 	case 1:
//	 		mux_out.write(local_in1);
//	 		//cout << "@ " << sc_time_stamp() << "mux2_1: " << "in1: "  << local_in1 << endl;
//	 		break;
//	 	 default:
//	 		//cout << "mux2_1: " << local_addr << " addr out of bounds" << endl;
//	 		break;
//	}
}

//begin
//		case (addr) is
//			when x"0" => mux_out <= in0;
//			when x"1" => mux_out <= in1;
//--			when x"2" => mux_out <= in2;
//--			when x"3" => mux_out <= in3;
//--			when x"4" => mux_out <= in4;
//--			when x"5" => mux_out <= in5;
//--			when x"6" => mux_out <= in6;
//--			when x"7" => mux_out <= in7;
//--			when x"8" => mux_out <= in8;
//--			when x"9" => mux_out <= in9;
//--			when x"a" => mux_out <= ina;
//--			when x"b" => mux_out <= inb;
//--			when x"c" => mux_out <= inc;
//--			when x"d" => mux_out <= ind;
//--			when x"e" => mux_out <= ine;
//--			when x"f" => mux_out <= inf;
//			when others => mux_out <= "XXXXXXXXXXXXXXXX";
//		end case;
//	end process;
//end mux16x1_logic;

