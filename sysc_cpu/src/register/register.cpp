#include "register.h"

//static sc_int<WORD_SIZE> data;

void reg::do_operation()
{
	sc_logic local_clear;
	sc_logic local_w_flag;
	sc_int<WORD_SIZE> local_data_in;

	local_clear = clear.read();
	local_w_flag = w_flag.read();
	local_data_in = data_in.read();


	if (local_clear == 1)
	{
		//data = 0;
		reg_out.write(inital_val);
	}
	else if (clk.posedge() == true)
	{
		if (local_w_flag == 1)
		{
			reg_out.write(local_data_in);
//			cout << "@ " << sc_time_stamp() << " write on reg_16:  "
//					<< local_data_in << endl;
		}

	}
}

//architecture reg16_beh of reg16 is
//begin
//	process(clk, clear, w_flag)
//	begin
//		if clear = '1' then
//			reg_out <= x"0000";
//		elsif rising_edge (clk) then
//			if w_flag = '1' then
//				reg_out <= datain;
//			end if;
//		end if;
//	end process;
//end reg16_beh;

