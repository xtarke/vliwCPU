#include "mux3-1.h"


void mux3_1::do_mux()
{
	sc_int<WORD_SIZE> local_in0;
	sc_int<WORD_SIZE> local_in1;
	sc_int<WORD_SIZE> local_in2;
	sc_int<WORD_SIZE> local_in3;

	sc_uint<3> local_addr;

	local_in0 = in0.read();
	local_in1 = in1.read();
	local_in2 = in2.read();
	local_in3 = in3.read();
	local_addr = sel.read();

	//cout << "mux2_1: " << "in0: "  << local_in0 << " in1 " << local_in1 << " addr: " <<  local_addr << endl;

	switch (local_addr)
	{
		case 0:
			mux_out.write(local_in0);
			//cout << "@ " << sc_time_stamp() << "mux2_1: " << "in0: "  << local_in0 << endl;
			break;
	 	case 1:
	 		mux_out.write(local_in1);
	 		//cout << "@ " << sc_time_stamp() << "mux2_1: " << "in1: "  << local_in1 << endl;
	 		break;
	 	case 2:
	 		 mux_out.write(local_in2);
	 		// cout << "@ " << sc_time_stamp() << "mux2_1: " << "in2: "  << local_in2 << endl;
	 		 break;
	 	case 3:
			 mux_out.write(local_in3);
			 //cout << "@ " << sc_time_stamp() << "mux2_1: " << "in2: "  << local_in2 << endl;
			 break;
	 	 default:
	 		//cout << "mux3_1: " << local_addr << " addr out of bounds" << endl;
	 		break;
	}
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

