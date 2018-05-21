#include <systemc.h>
#include "../sizes.h"
#include "../register/register.h"


SC_MODULE( pc )
{
	sc_in_clk clk;
	sc_in<sc_logic> reset;
	sc_in<sc_logic> up;
	sc_in<sc_logic> load;

	// write port
	sc_in<sc_uint<WORD_SIZE> > data_in;
	//data
	sc_out<sc_uint<WORD_SIZE> > data;

	//internal signals
	//signals
	sc_signal<sc_int<WORD_SIZE> > pc_value;
	sc_signal<sc_int<WORD_SIZE> > w_data;
	sc_signal<sc_logic> w_flag;
	sc_signal<sc_uint<WORD_SIZE> > next_pc;

	reg *REG;

	void do_write();
	void do_read();

	SC_HAS_PROCESS(pc);

	pc(sc_module_name name_, int initial_pc_ = 0) :
		sc_module(name_), initial_pc(initial_pc_)
	{
  		REG = new reg("pc_register", initial_pc);
  		REG->clk(clk);
  		REG->clear(reset);
  		REG->w_flag(w_flag);
  		REG->data_in(w_data);
  		REG->reg_out(pc_value);

  		SC_METHOD(do_write);
  		sensitive << clk.pos() << up << load << reset << pc_value << data_in;
  		SC_METHOD(do_read);
  		sensitive << pc_value;

  		//initial
  	}
	private:
		sc_int<WORD_SIZE> initial_pc;


};

//signal pc:     std_logic_vector (word_size-1 downto 0);
//signal next_pc :     std_logic_vector (word_size-1 downto 0);
//signal w_data: std_logic_vector (word_size-1 downto 0);
//signal w_flag: std_LOGIC;

//port (
//	clk    : in std_logic;
//	reset  : in std_logic;
//	up	    : in std_logic;
//	load	 : in std_logic;
//	-- write port
//	datain : in std_logic_vector (word_size-1 downto 0);
//
//	-- pc value
//	data   : out std_logic_vector (word_size-1 downto 0)
//	);
//end pc;

//-- registers
//pc_reg: reg16 PORT MAP (clk => clk,
//							clear => reset,
//							w_flag => w_flag,
//							datain => w_data,
//							reg_out => pc);
