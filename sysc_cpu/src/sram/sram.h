#include <systemc.h>
#include "../sizes.h"

SC_MODULE(sram) {
    sc_uint<WORD_SIZE> sram_data[SCRATCHPAD_SIZE];

    sc_in_clk clk;

    sc_in<sc_logic> enable;
    // rd/wr
    sc_in<sc_logic> wr;
    sc_in<sc_logic> rd;

    // address
    sc_in<sc_uint<RAM_ADDR_SIZE> > w_addr;
    sc_in<sc_uint<RAM_ADDR_SIZE> > rd_addr;

    //data
    sc_in<sc_int<WORD_SIZE> > data_in;
    sc_out<sc_int<WORD_SIZE> > data_out;

    //sc_in<sc_int<WORD_SIZE >> io_in;
    //sc_out<sc_int<WORD_SIZE >> io_out

    void do_read();
    void do_write();

    void dump_contents();
    void dump_contents_hword();

    SC_CTOR(sram) {
        SC_METHOD(do_read);
        sensitive << clk;

        SC_METHOD(do_write);
        sensitive << clk;
    }

};

//generic(word_size: integer :=16;
//		 sram_size:	 integer :=256;
//		 addr_size:	 integer :=8);
//port (
//	clk     : in std_logic;
//	enable  : in std_logic;
//	-- rd/wr
//	wr     : in std_logic;
//	rd     : in std_logic;
//	-- address
//	w_addr  : std_logic_vector(addr_size-1 downto 0);
//	rd_addr : std_logic_vector(addr_size-1 downto 0);
//	-- data
//	data_in  : in std_logic_vector (word_size-1 downto 0);
//	data_out : out std_logic_vector (word_size-1 downto 0);
//
//	io_in  : in std_logic_vector (addr_size-1 downto 0);
//	io_out : out std_logic_vector (addr_size-1 downto 0)
//
//	);
//end sram;

