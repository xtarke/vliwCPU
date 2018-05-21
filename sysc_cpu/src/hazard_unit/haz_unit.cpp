#include "haz_unit.h"
#include "instrunctions.h"

void hazard_unit::do_hazard() {
    sc_logic local_reset;
    sc_logic local_stall;

    sc_uint<WORD_SIZE> local_instrunction;
    sc_uint<OPCODE_SIZE> local_if_id_opcode;
    sc_uint<FUNCT_SIZE> local_if_id_funct;
    sc_uint<REG_ADDR_SIZE> local_id_ex_rt;
    sc_uint<REG_ADDR_SIZE> local_if_id_rs;
    sc_uint<REG_ADDR_SIZE> local_if_id_rt;

    WbControl local_id_ex_Wb_control;

    //read all signals
    //id_ex memory read
    local_id_ex_Wb_control = if_ex_ctrl_wb_signals_in.read();

    local_id_ex_rt = id_ex_rt.read();

    local_if_id_rs = if_id_rs.read();
    local_if_id_rt = if_id_rt.read();
    local_instrunction = ins_in.read();
    local_if_id_opcode = local_instrunction.range(OPCODE_INI, OPCODE_END);
    local_if_id_funct = local_instrunction.range(FUNCT_INI, FUNCT_END);

    local_reset = reset.read();
    local_stall = sc_logic('0');

    if (local_reset == 1) {
        stall_out.write(sc_logic('0'));
    } else {
        //Pipeline Hazard:
        //IF EX stage has a load, stall everything if:
        if (local_id_ex_Wb_control.memory_rd_enable == sc_logic('1'))            
        {
            //if ID has any STORE
            if ((local_if_id_opcode == SW) || (local_if_id_opcode == SB) || (local_if_id_opcode == SH))
            {
                // LOAD   ->   Rt            = MEM[ Rs + Im]    
                // STORE  ->   MEM [RS + Im] = Rt
                //--------------------- 
                // LW  14, x, x    <- load @ EX stage
                // SW  1 , 14 , x  -< store @ ID stage                  
                if (local_if_id_rs == local_id_ex_rt)
                    local_stall = sc_logic('1');                
            }
            //EX Hazard
            else if ((local_id_ex_rt == local_if_id_rs) || (local_id_ex_rt == local_if_id_rt)) {
                //cout << "@" <<  sc_time_stamp() << " Memory Load Hazard" << endl;
                local_stall = sc_logic('1');
            }
        }
        stall_out.write(local_stall);
    }
};
