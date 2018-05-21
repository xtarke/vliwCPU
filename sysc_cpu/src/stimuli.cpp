#include "stimuli.h"
#include "sizes.h"

void stimuli::generate() 
{

	while (true)
	{	
		reset.write(sc_logic('1'));
		wait(init_reset_time, SC_NS);

		reset.write(sc_logic('0'));

		wait();
	}
};                                                                                            
