#include "mux.h"


void mux::do_mux()
{
	sc_int<WORD_SIZE> local_in[n_inputs];

	sc_uint<MAX_MUX_PORTS> local_addr;

	for (int i = 0; i < n_inputs; i++)
			local_in[i] = in[i].read();

	local_addr = addr.read();

	//cout << "mux2_1: " << "in0: "  << local_in0 << " in1 " << local_in1 << " addr: " <<  local_addr << endl;

	mux_out.write(local_in[local_addr]);


	//cout << sc_time_stamp() << " local_addr: " << local_addr << " : " << local_in[local_addr]  << endl;

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
