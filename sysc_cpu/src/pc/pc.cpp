#include "pc.h"

void pc::do_write()
{
	sc_logic local_enable;
	sc_logic local_reset;
	sc_logic local_up;
	sc_logic local_load;
	sc_int<WORD_SIZE> local_data_in;

	//port read
	//local_enable = enable.read();
	local_reset = reset.read();
	local_up 	= up.read();
	local_load = load.read();
	local_data_in = data_in.read().to_int();

	w_flag.write(local_up | local_load);

	if (local_reset == 1)
	{
		w_data.write(initial_pc);
		//cout << "@ " << sc_time_stamp() << " pc: reset" << endl;
	}
	else
	{
		if (local_up == 1)
		{
			w_data.write(pc_value.read() + 1);
			//cout << "@ " << sc_time_stamp() << " pc: up : " << w_data << endl;
		}

		else if (local_load == 1)
		{
			//cout << "@ " << sc_time_stamp() << " pc: load: " << local_data_in << endl;
			w_data.write(local_data_in);
		}
	}

	//data->write(pc_value);
}

void pc::do_read()
{
	//cout << "@ " << sc_time_stamp() << " pc: pc_value" << endl;
	data->write(pc_value.read().to_uint());
}


//data <= pc;
//w_flag <= load or up;
//
//process (up, load, reset)
//begin
//	if reset = '1' then
//		w_data <= x"0000";
//	else
//		if up = '1' then
//			w_data <= pc + 1;
//		elsif load = '1' then
//			w_data <= datain;
//		end if;
//	end if;
//end process;
//
//


