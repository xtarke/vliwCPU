#ifndef WBCONTROL_TYPE_H
#define WBCONTROL_TYPE_H
#include "systemc.h"
#include <string>
#include <iomanip>

class WbControl {
  private:

  public:
	sc_logic reg_w_enable;
	sc_lv<2> reg_w_select;

	sc_logic hilo_w_enable;

	sc_uint<2> access_width;
	sc_logic memory_rd_enable;
	sc_logic memory_w_enable;
	sc_logic unsigned_load;
	sc_logic rf_predic_w_enable;

	sc_logic halt;
        sc_logic hazard;
        
        sc_logic cmov;

    // constructor
    WbControl (sc_logic _reg_w_enable = sc_logic('0'), sc_lv<2> _reg_w_select = "XX",
    		sc_logic _hilo_w_enable = sc_logic('0'),
    		sc_uint<2> _access_width =  0, sc_logic _memory_rd_enable = sc_logic('0'),
    		sc_logic _memory_w_enable = sc_logic('0'), sc_logic _unsigned_load = sc_logic('0'),
    		sc_logic _rf_predic_w_enable = sc_logic('0'),
    		sc_logic _halt = sc_logic('0'),
                sc_logic _hazard = sc_logic('0'),
                sc_logic _pmov = sc_logic('0')) {
    	reg_w_enable  = _reg_w_enable;
    	reg_w_select  = _reg_w_select;
    	hilo_w_enable = _hilo_w_enable;
    	unsigned_load = _unsigned_load;
    	access_width  = _access_width;
    	memory_rd_enable = _memory_rd_enable;
    	memory_w_enable = _memory_w_enable;
    	rf_predic_w_enable = _rf_predic_w_enable;
    	halt = _halt;
        hazard = _hazard;
        cmov = _pmov;
    }

    inline bool operator == (const WbControl & rhs) const {
      return (rhs.reg_w_enable == reg_w_enable && rhs.reg_w_select == reg_w_select &&
    		  rhs.hilo_w_enable == hilo_w_enable && rhs.access_width == access_width &&
    		  rhs.memory_rd_enable == memory_rd_enable && rhs.memory_w_enable == memory_w_enable &&
    		  rhs.unsigned_load == unsigned_load && rhs.rf_predic_w_enable == rf_predic_w_enable &&
    		  rhs.halt == halt && rhs.hazard == hazard && rhs.cmov == cmov);
    }

    inline WbControl& operator = (const WbControl& rhs) {
    	reg_w_enable = rhs.reg_w_enable;
    	reg_w_select = rhs.reg_w_select;
    	hilo_w_enable = rhs.hilo_w_enable;
    	access_width = rhs.access_width;
    	memory_rd_enable = rhs.memory_rd_enable;
    	memory_w_enable = rhs.memory_w_enable;
    	unsigned_load = rhs.unsigned_load;
    	rf_predic_w_enable = rhs.rf_predic_w_enable;
    	halt = rhs.halt;
        hazard = rhs.hazard;
        cmov = rhs.cmov;

    	return *this;
    }

    inline void set_values (sc_logic _reg_w_enable, sc_lv<2> _reg_w_select, sc_logic _hilo_w_enable,
    		sc_uint<2> _access_width, sc_logic _memory_rd_enable, sc_logic _memory_w_enable,
    		sc_logic _unsigned_load, sc_logic _rf_predic_w_enable)
    {
    	reg_w_enable = _reg_w_enable;
    	reg_w_select = _reg_w_select;
    	hilo_w_enable = _hilo_w_enable;
    	access_width = _access_width;
    	memory_rd_enable = _memory_rd_enable;
    	memory_w_enable = _memory_w_enable;
    	unsigned_load = _unsigned_load;
    	rf_predic_w_enable = _rf_predic_w_enable;
    }

    inline void get_values (sc_logic *_reg_w_enable, sc_lv<2> *_reg_w_select, sc_logic *_hilo_w_enable,
    		sc_uint<2> *_access_width, sc_logic *_memory_rd_enable, sc_logic *_memory_w_enable,
    		sc_logic *_unsigned_load, sc_logic *_rf_predic_w_enable)
    {
    	*_reg_w_enable = reg_w_enable;
    	*_reg_w_select = reg_w_select;
    	*_hilo_w_enable = hilo_w_enable;
    	*_access_width = access_width;
    	*_memory_rd_enable = memory_rd_enable;
    	*_memory_w_enable = memory_w_enable;
    	*_unsigned_load = unsigned_load;
    	*_rf_predic_w_enable = rf_predic_w_enable;
    }

    inline void reset (void)
    {
    	reg_w_enable = sc_logic('0');
    	reg_w_select = "XX";
    	hilo_w_enable = sc_logic('0');
    	access_width = 0;
    	memory_rd_enable = sc_logic('0');
    	memory_w_enable = sc_logic('0');
    	unsigned_load = sc_logic('0');
    	rf_predic_w_enable = sc_logic('0');
    	halt = sc_logic('0');
        hazard = sc_logic('0');
        cmov = sc_logic('0');
    }

    inline friend void sc_trace(sc_trace_file *tf, const WbControl & v,
    const std::string& NAME ) {
      sc_trace(tf,v.reg_w_enable, NAME + ".reg_w_enable");
      sc_trace(tf,v.reg_w_select, NAME + ".reg_w_select");
      sc_trace(tf,v.hilo_w_enable, NAME + ".hilo_w_enable");
      sc_trace(tf,v.access_width, NAME + ".access_width");
      sc_trace(tf,v.memory_rd_enable, NAME + ".memory_rd_enable");
      sc_trace(tf,v.memory_w_enable, NAME + ".memory_w_enable");
      sc_trace(tf,v.unsigned_load, NAME + ".unsigned_load");
      sc_trace(tf,v.rf_predic_w_enable, NAME + ".rf_predic_w_enable");
      sc_trace(tf,v.halt, NAME + ".halt");
      sc_trace(tf,v.hazard, NAME + ".hazard");
      sc_trace(tf,v.cmov, NAME + ".pmov");
    }

    inline friend ostream& operator << ( ostream& os,  WbControl const & v ) {
      os << "(" << v.reg_w_enable << "," << v.reg_w_select << "," << v.hilo_w_enable << ","
    		  << v.access_width << "," << v.memory_rd_enable << "," << v.memory_w_enable << "," <<
    		  v.unsigned_load << v.rf_predic_w_enable << v.halt << v.hazard << v.cmov << ")";
      return os;
    }

};
#endif
