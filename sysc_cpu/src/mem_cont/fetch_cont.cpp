/* 
 * File:   fetch_cont.cpp
 * Author: xtarke
 * 
 * Created on October 8, 2013, 5:01 PM
 */

#include "fetch_cont.h"

#include "rom.h"

//void fetch_cont::do_read()
//{
//	sc_logic local_enable;
//	sc_logic local_rd;
//	sc_uint<ADDR_SIZE> local_rd_addr;
//
//	local_enable = enable.read();
//	local_rd = rd.read();
//	local_rd_addr = rd_addr.read();
//
//	//latch on output
//	if ((local_enable == 1) && (local_rd == 1))
//	{
//			data_out.write(memory_data[local_rd_addr].to_int());
//	}
//
//}

void fetch_cont::do_clk_state() {
    sc_logic local_reset;
    sc_logic local_hit;
    sc_logic local_reading;

    mem_state_type local_mem_state;

    local_reset = reset.read();
    //    local_reading = reading_mem.read();

    if (local_reset == sc_logic('1')) {
        mem_state.write(M_IDLE);
    } else if (mem_clk.posedge() == true) {
        local_mem_state = mem_state.read();

        switch (local_mem_state) {
            case M_IDLE:
                mem_state.write(M_RD_BLOCK);
                break;
                //            case M_MEM_PREP:
                //                mem_state.write(M_RD_BLOCK);
                //                break;
            case M_RD_BLOCK:
                mem_state.write(M_IDLE);
                break;
            default:
                break;
        }
    }
}

void fetch_cont::do_state_ouput() {
    mem_state_type local_mem_state;

    local_mem_state = mem_state.read();

    mem_enable_out.write(sc_logic('0'));

    switch (local_mem_state) {
        case M_IDLE:

            done.write(sc_logic('0'));
            break;
        case M_RD_BLOCK:
            done.write(sc_logic('1'));
            mem_enable_out.write(sc_logic('1'));
            break;

        default:
            break;
    }
}

void fetch_cont::do_fetch() {

    sc_uint<WORD_SIZE> local_address;

    local_address = address.read();


    if (reset.read() == sc_logic('1'))
        ram_clk_en_out.write(sc_logic('0'));

    else {
        if (done.read() == sc_logic('0')) {
            stall_out.write(sc_logic('1'));
            ram_clk_en_out.write(sc_logic('1'));


            mem_addr_out.write(local_address);
            mem_enable_out.write(sc_logic('1'));
        }

        if (mem_clk.posedge() == true) {
            stall_out.write(sc_logic('0'));
            ram_clk_en_out.write(sc_logic('0'));
            mem_enable_out.write(sc_logic('0'));
            //done.write('1');            
        }
    }
}

void fetch_cont::addr_out() {
    sc_int<WORD_SIZE> local_mem_data_in;

    
    local_mem_data_in = mem_data_in.read();
    
    data_out.write(local_mem_data_in);


}

void fetch_cont::do_debug() {

    debug_state.write(mem_state);

}

