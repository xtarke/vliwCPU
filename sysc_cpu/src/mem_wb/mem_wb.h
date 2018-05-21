#ifndef MEM_WB_H
#define	MEM_WB_H

#include <systemc.h>
#include "../sizes.h"
#include "../controller/controller_types.h"
#include "../rf/rf.h"

// conversion macros
#define __STR_EXPAND(x) #x
#define TO_BIN(x) __STR_EXPAND(x)

#define __NUMBER_EXPAND(x) v##x
#define TO_NUMBER(x) __NUMBER_EXPAND(x)

enum {
    v00 = 0,
    v01,
    v10,
    v11
};
// end

//exported
#define WB_MUX_ALU 00
#define WB_MUX_HILO_RF 01
#define WB_MUX_MEMORY 10
//#define WB_MUX_PC 11

SC_MODULE(mem_wb) {
    sc_in_clk clk;

    sc_in<sc_logic> reset;
    sc_in<sc_logic> load;
    sc_in<sc_logic> mem_stall;

    sc_in<sc_int<WORD_SIZE> > pc_in;
    sc_in<sc_int<WORD_SIZE> > alu_in;
    sc_in<sc_int<WORD_SIZE> > hi_in;
    sc_in<sc_int<WORD_SIZE> > lo_in;
    sc_in<sc_int<WORD_SIZE> > hilo_rf_data_in; //comes from HILO rf to write in WB in RF
    sc_in<sc_int<WORD_SIZE> > memory_data_in; //comes from memory to write on RF

    sc_in<sc_uint<REG_ADDR_SIZE> > dest_reg_in;
    sc_in<WbControl> ctrl_wb_signals_in;

    sc_out<sc_int<WORD_SIZE> > hi_out;
    sc_out<sc_int<WORD_SIZE> > lo_out;
    sc_out<sc_uint<REG_ADDR_SIZE> > dest_reg_out; //register address to write
    sc_out<sc_int<WORD_SIZE> > reg_w_data_out; //value to write
    sc_out<sc_logic> reg_w_enable_out; //register file enable bit
    sc_out<sc_logic> cmov_out; //cmov, fake register write
    sc_out<sc_logic> hilo_w_enable_out;
    sc_out<sc_logic> pred_wr_enable;

    sc_out<sc_logic> memory_w_enable_out;
    sc_in<sc_int<WORD_SIZE> > memory_w_data_in; //comes from Mem controller to write to RAM
    sc_out<sc_int<WORD_SIZE> > memory_w_data_out;

    sc_in<sc_uint<WORD_SIZE> > memory_addr_in;
    sc_out<sc_uint<WORD_SIZE> > memory_addr_out;

    sc_out<sc_logic> pred_data_out;

    sc_out<sc_logic> halt_out;

    //debug
    sc_in<sc_uint<WORD_SIZE> > instrunction_in;
    sc_out<sc_uint<WORD_SIZE> > instrunction_out;

    sc_signal<WbControl> Wb_control;
    sc_signal<sc_uint<REG_ADDR_SIZE> > dest_reg;
    sc_signal<sc_int<WORD_SIZE> > hi;
    sc_signal<sc_int<WORD_SIZE> > lo;
    sc_signal<sc_uint<WORD_SIZE> > memory_addr;
    sc_signal<sc_int<WORD_SIZE> > alu;
    sc_signal<sc_int<WORD_SIZE> > hilo_rf_data;
    sc_signal<sc_int<WORD_SIZE> > pc;

    sc_signal<sc_int<3> > reg_w_select_uint;
    sc_signal<sc_uint<WORD_SIZE> > ins;

    void mem_wb_write();
    void mem_wb_read();

    SC_HAS_PROCESS(mem_wb);

    mem_wb(sc_module_name name_, int final_address_ = ROM_INI + ROM_SIZE, int single_fetch_ = 0) :
            sc_module(name_), final_address(final_address_),  single_cycle_fetch(single_fetch_){
        //halt_out.write(sc_logic('0'));

        SC_METHOD(mem_wb_write);
        sensitive << clk << reset << load; // << memory_data_in << memory_w_data_in;

        SC_METHOD(mem_wb_read);
        sensitive << clk;

    }
    private:
    const sc_int<WORD_SIZE> final_address;
    const int single_cycle_fetch;

};

#endif
