/* 
 * File:   fetch_cont.h
 * Author: xtarke
 *
 * Created on October 8, 2013, 5:01 PM
 */

#ifndef FETCH_CONT_H
#define	FETCH_CONT_H

#include <systemc.h>
#include "../sizes.h"

enum mem_state_type {
	M_IDLE = 0,
        M_MEM_PREP,	
	M_RD_BLOCK
 };

SC_MODULE(fetch_cont) {

    sc_in_clk clk;
    sc_in_clk mem_clk;
    sc_in<sc_logic> reset;
    sc_in<sc_logic> data_out_enable;
    sc_out<sc_logic> ram_clk_en_out;

    //sc_in<sc_logic> enable;

    sc_in<sc_uint<WORD_SIZE> > address;

    //RAM memory read control
    sc_out<sc_uint<RAM_ADDR_SIZE> > mem_addr_out;
    sc_out<sc_logic> mem_enable_out;
    sc_in<sc_int<WORD_SIZE> > mem_data_in;

    //mem data out
    sc_out<sc_int<WORD_SIZE> > data_out;
    sc_out<sc_logic> stall_out;
        
    sc_signal<mem_state_type > mem_state;
    
    
    sc_signal<sc_logic> done;
    
    sc_signal<int> debug_state;
    
    void do_fetch();
    void addr_out();
    
    void do_debug();
    
    
    void do_clk_state();
    void do_state_ouput();
    

    SC_CTOR(fetch_cont) {
        
        done.write(sc_logic('0'));

        SC_METHOD(do_fetch);
        sensitive << address << reset << done << mem_clk;
        
//        SC_METHOD(do_clk_state);
//        sensitive << mem_clk << reset;
//        
//        SC_METHOD(do_state_ouput);
//        sensitive << mem_state;
        
        SC_METHOD(addr_out);
        sensitive << mem_data_in;
        
        SC_METHOD(do_debug);
  	sensitive << mem_state;
    }

};

#endif	/* FETCH_CONT_H */

