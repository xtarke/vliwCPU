// -*- C++ -*-
/* 
 * File:   clock_gen.
 * Author: xtarke
 *
 * Created on July 15, 2013, 1:47 PM
 */

#ifndef CLOCK_GEN_
#define	CLOCK_GEN_

#include <systemc.h>
#include "../sizes.h"

SC_MODULE(clock_gen) {
    sc_in_clk clk;

    sc_in<sc_logic> enable;

    sc_out<bool> clk_out;

    sc_signal<sc_int<WORD_SIZE> > counter;
    sc_signal<bool> clk_int;

    SC_HAS_PROCESS(clock_gen);

    void do_mult();
    void do_output();

    clock_gen(sc_module_name name_, int mul_ = 1) :
            sc_module(name_), mul(mul_) {

        //counter.write((CPU_CYCLE_TIME * mul)/CPU_CYCLE_TIME);

        SC_METHOD(do_mult);
        sensitive << clk << enable;
        
        SC_METHOD(do_output);
        sensitive << counter << enable;

    }
    private:
        const int mul;

};


#endif	/* CLOCK_GEN_ */

