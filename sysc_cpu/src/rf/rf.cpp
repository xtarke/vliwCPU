#include "rf.h"

#include <iostream>
#include <iomanip>


void rf::do_rd_ctl_ra()
{
	sc_logic local_ra_rd;
	sc_logic local_reset;
	sc_int<WORD_SIZE> local_mux_out_ra;

	local_reset = reset.read();
	local_ra_rd = ra_rd.read();
	local_mux_out_ra = mux_out_ra.read();

	//cout << "local_mux_out_ra : " << local_mux_out_ra << endl;

	if ((local_ra_rd == 1) && (local_reset == 0))
	{
		ra_data.write(local_mux_out_ra);
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

void rf::do_rd_ctl_rb()
{
	sc_logic local_rb_rd;
	sc_logic local_reset;
	sc_int<WORD_SIZE> local_mux_out_rb;

	local_reset = reset.read();
	local_rb_rd = rb_rd.read();
	local_mux_out_rb = mux_out_rb.read();

	if ((local_rb_rd == 1) && (local_reset == 0))
	{
		rb_data.write(local_mux_out_rb);
		//cout << "local_mux_out_rb : " << local_mux_out_rb << endl;
	}
}

void rf::do_wsel_wsel_bit()
{
	sc_lv<WORD_SIZE> local_w_sel;

	local_w_sel = w_sel.read();

	//if (local_w_sel < N_ADDR_REGISTER)
	for (int i=0; i < N_REGISTERS; i++)
		w_select[i].write(local_w_sel[i]);

	//w_sel0.write(local_w_sel[0]);
	//w_sel1.write(local_w_sel[1]);

}

void rf::dump_contents()
{
	cout << "Register contents:" << endl;
        cout << dec;
        
	for (int i = 0; i < N_REGISTERS; i++)
	{
		if (i % 4 == 0 && i != 0)
					cout << endl;

		cout << "R[" << i << "] = " << register_banc[i]->reg_out << " \t";


	}

	cout << endl;
}
