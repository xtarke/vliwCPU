#include "adder.h"

void adder::do_calc()
{
	sc_logic local_enable;
	sc_int<WORD_SIZE> local_a;
	sc_int<WORD_SIZE> local_b;

	sc_int<WORD_SIZE> local_result = 0;

	local_a = a.read();
	local_b = b.read();
	local_enable = enable.read();

	if (local_enable == sc_logic('1'))
	{
		local_result = (local_a + local_b);
		result.write(local_result.to_uint());
	}

}
