#include "clock_gen.h"
#include "../sizes.h"

void clock_gen::do_mult() {

    sc_logic local_enable;

    sc_int<WORD_SIZE> local_counter;

    local_enable = enable.read();
    local_counter = counter.read();

    if (local_enable == sc_logic('1')) {
        if (clk.event() == true) {// && local_counter > 0) {
            if (local_counter == 0)
                local_counter = (CPU_CYCLE_TIME * mul) / CPU_CYCLE_TIME;
            
            local_counter--;

            counter.write(local_counter);
        }
    }
    else
        local_counter = (CPU_CYCLE_TIME * mul) / CPU_CYCLE_TIME;
    
    
    counter.write(local_counter);
}

void clock_gen::do_output() {

    sc_logic local_enable;
    bool local_clk_int;
    sc_int<WORD_SIZE> local_counter;


    local_enable = enable.read();
    local_counter = counter.read();
    local_clk_int = clk_out.read();

    if (local_enable == sc_logic('1')) {
        if (local_counter == 0) {
            local_clk_int = !local_clk_int;
        }

        clk_out.write(local_clk_int);
    }
    else
        clk_out.write(true);


}