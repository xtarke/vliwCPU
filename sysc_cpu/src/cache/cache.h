#ifndef CPU_CACHE_H_
#define CPU_CACHE_H_


#include <systemc.h>
#include "../sizes.h"


//#define BY_OFFSET_SIZE 2			//bits to index a byte, always 2
//#define BY_OFFSET_INI 0			//bit 0
//#define BY_OFFSET_END 1			//to bit 1

static const int BY_OFFSET_END=-1;

static const int BK_OFFSET_SIZE=Log2Floor<BLOCK_SIZE>::VALUE;		// bits to index the block (WORDS in each block) log2 BLOCK_SIZE
static const int BK_OFFSET_INI=(BY_OFFSET_END + 1);
static const int BK_OFFSET_END=(BK_OFFSET_INI + BK_OFFSET_SIZE - 1);

static const int INDEX_SIZE=Log2Floor<CACHE_BLOCKS>::VALUE;			//bits to index CACHE_BLOCKS
static const int INDEX_INI=(BK_OFFSET_END + 1);
static const int INDEX_END=(INDEX_INI + INDEX_SIZE - 1);

//other bits are used in TAG
static const int TAG_INI=(INDEX_END + 1);
static const int TAG_END=(WORD_SIZE - 1);
static const int TAG_SIZE (TAG_END - TAG_INI + 1);


enum cache_state_type {
	C_COMP_TAG = 0,
	C_MEM_PREP,
	C_RD_BLOCK
 };


struct cache_line
{
	sc_logic v_bit;
	sc_uint<TAG_SIZE> tag;

	sc_uint<WORD_SIZE> data[BLOCK_SIZE];
};

SC_MODULE( cache )
{

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

	//cache data out
	sc_out<sc_int<WORD_SIZE> > data_out;
	sc_out<sc_logic> stall_out;

	//internal signals
	sc_signal<sc_uint<TAG_SIZE> > tag;
	sc_signal<sc_uint<INDEX_SIZE> > index;
	sc_signal<sc_uint<BK_OFFSET_SIZE> > b_offset;

	sc_signal<sc_uint<RAM_ADDR_SIZE> > mem_addr;
	sc_signal<sc_uint<BK_OFFSET_SIZE + 1> > word_index;

	sc_signal<sc_logic> hit;
	sc_signal<cache_state_type > cache_state;

	sc_signal<sc_logic> reading_mem;

	sc_signal <sc_uint<BK_OFFSET_SIZE + 1> > reading_word_index;

	sc_signal<int> debug_state;

	int misses;
	int hits;

	struct cache_line cb[CACHE_BLOCKS];

	void do_cache_addr ();
	void do_check_hit();

	void do_clk_state();
	void do_state_ouput();
	void do_mem_address_ouput();
	void do_read_memory();

	void do_data_output();

	void do_debug();

	void dump_contents();

  	SC_CTOR( cache )
	{
  		reading_word_index.write(0);

  		misses = 0;
  		hits   = 0;

  		//cache initialization
  		for (int i=0; i < CACHE_BLOCKS; i++)
  		{
  			cb[i].v_bit = sc_logic('0');
  			cb[i].tag   = 0;

  			for (int j=0; j < BLOCK_SIZE; j++)
  				cb[i].data[j] = 0;
  		}

  		word_index.write(0);

            SC_METHOD(do_clk_state);
  		sensitive << mem_clk <<  reset;

  		SC_METHOD(do_cache_addr);
  		sensitive << address;

  		SC_METHOD(do_state_ouput);
  		sensitive << cache_state;

  		SC_METHOD(do_mem_address_ouput);
  		sensitive << mem_clk;

  		SC_METHOD(do_read_memory);
  		sensitive << mem_clk << cache_state;

  		SC_METHOD(do_check_hit);
  		sensitive << index << tag << cache_state << reset;

  		SC_METHOD(do_data_output);
  		sensitive << clk << cache_state << hit << b_offset << index;

  		SC_METHOD(do_debug);
  		sensitive << cache_state;

  	}



};

#endif
