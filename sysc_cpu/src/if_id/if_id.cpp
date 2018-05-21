#include "if_id.h"

void if_id::if_id_write()
{
	sc_logic local_reset;
	sc_logic local_load;
	sc_logic local_bubble;
	sc_uint<WORD_SIZE> local_data;
	sc_uint<IMEDIATE_SIZE> local_imediate;
	sc_int<WORD_SIZE> local_pc;
	sc_uint<WORD_SIZE> local_jump_target;
	sc_uint<WORD_SIZE> local_imediate_double;

	local_reset = reset.read();
	local_load = load.read();
	local_bubble = bubble_in.read();

	local_data = data.read();
	local_imediate = immediate.read();
	local_pc = pc.read();

	if (local_bubble == sc_logic('1'))
		bubble_out.write(sc_logic('1'));
	else
		bubble_out.write(sc_logic('0'));


	if (local_reset == sc_logic('1'))
	{
		pc_out.write(0);
		ins_out.write(0);
		immed_sigext.write(0);
                immed_zeroext.write(0);
		rd_out.write(0);
		rs_out.write(0);
		rt_out.write(0);

		opcode_out.write(0);
		funct_out.write(0);
		shamt_out.write(0);
		j_target_out.write(0);

	}
	else if (local_load == 1 && clk.posedge())
	{
		//signal extension
		if (local_imediate.bit(IMEDIATE_SIZE - 1) == 1)
		{
			local_imediate_double = local_imediate.to_int();
			local_imediate_double = local_imediate_double | 0xFFFF0000;

			immed_sigext.write(local_imediate_double.to_int());
		}
		else
			immed_sigext.write(local_imediate.to_int());
                
                immed_zeroext.write(local_imediate.to_int());

		rd_out.write(local_data.range(RD_INI, RD_END));
		rs_out.write(local_data.range(RS_INI, RS_END));
		rt_out.write(local_data.range(RT_INI, RT_END));

		opcode_out.write(local_data.range(OPCODE_INI, OPCODE_END));
		funct_out.write(local_data.range(FUNCT_INI, FUNCT_END));
		shamt_out.write(local_data.range(SHAMT_INI, SHAMT_END));

		local_jump_target = local_data.range(JTARGET_INI, JTARGET_END);

		j_target_out.write(local_jump_target.to_int());

		ins_out.write(local_data);
		pc_out.write(local_pc);
	}
}


void if_id::if_id_read()
{
	sc_uint<WORD_SIZE> local_data;
	sc_uint<IMEDIATE_SIZE> local_immediate;
	sc_int<WORD_SIZE> local_pc;

	local_data = data_in.read().range(WORD_SIZE-1,0).to_uint();
	local_immediate = data_in.read().range(IMEDIATE_INI, IMEDIATE_END).to_uint();
	local_pc = pc_in.read().to_int();

	if (clk.negedge())
	{
		data.write(local_data);
		pc.write(local_pc);
		immediate.write(local_immediate);
	}
}
