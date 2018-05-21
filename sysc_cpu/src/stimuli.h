#ifndef CPU_STIMU_H
#define	CPU_STIMU_H

#include <systemc.h>
#include "sizes.h"

SC_MODULE(stimuli) {
    sc_out<sc_logic> reset;

    void generate();

    SC_HAS_PROCESS(stimuli);

    stimuli(sc_module_name name_, int reset_ = INIT_RESET_TIME) : sc_module(name_),
            init_reset_time(reset_)
            //SC_CTOR( stimuli )
    {
        SC_THREAD(generate);
    }

    private:
    const int init_reset_time;

};

#endif

