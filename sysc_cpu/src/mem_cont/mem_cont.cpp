#include "mem_cont.h"
#include "sizes.h"

#define SEL_RAM sc_logic('0')
#define SEL_SPRAM sc_logic('1')

void mem_control::mem_sync() {
    sc_logic local_acc_finish;
    sc_logic local_hzd_stall;
    sc_uint<RAM_ADDR_SIZE> local_addr;
    WbControl local_Wb_control;
    mem_ctr_state_type local_state;

    local_Wb_control = ctrl_wb_signals_in.read();

    local_acc_finish = acc_finish.read();
    local_state = mem_ctr_state.read();

    if (local_state == MC_STOP) {
        if ((local_Wb_control.memory_rd_enable == sc_logic('1') ||
                local_Wb_control.memory_w_enable == sc_logic('1')) &&
                local_acc_finish == sc_logic('0') && mem_type == SEL_RAM) {
            ram_clk_en_out.write(sc_logic('1'));
            stall_out.write(sc_logic('1'));
            mem_acc.write(sc_logic('1'));
        } else {
            ram_clk_en_out.write(sc_logic('0'));
            stall_out.write(sc_logic('0'));
            mem_acc.write(sc_logic('0'));
        }
    }
}

void mem_control::do_clk_state() {
    sc_logic local_reset;
    sc_logic local_mem_acc;
    sc_logic local_reading;

    mem_ctr_state_type local_state;
    local_mem_acc = mem_acc.read();

    if (local_reset == sc_logic('1')) {
        mem_ctr_state.write(MC_STOP);
    } else if (clk.posedge() == true) {
        local_state = mem_ctr_state.read();

        switch (local_state) {
            case MC_STOP:
                if (local_mem_acc == sc_logic('1'))
                    mem_ctr_state.write(MC_MEM_RD);
                break;
            case MC_MEM_RD:
                mem_ctr_state.write(MC_MEM_WR);
                break;
            case MC_MEM_WR:
                mem_ctr_state.write(MC_STOP);
                break;
            default:
                break;
        }
    }

}

void mem_control::do_output_logic() {
    mem_ctr_state_type local_state;
    sc_uint<RAM_ADDR_SIZE> local_ram_addr;
    WbControl local_Wb_control;

    local_state = mem_ctr_state.read();
    local_ram_addr = mem_addr.read();
    local_Wb_control = ctrl_wb_signals_in.read();

    switch (local_state) {
        case MC_STOP:
            ram_rd_enable.write(sc_logic('0'));
            ram_wr_enable.write(sc_logic('0'));

            acc_finish.write(sc_logic('0'));
            break;
        case MC_MEM_RD:
            //ram_clk_en_out.write(sc_logic('1'));
            ram_rd_enable.write(sc_logic('1'));
            ram_addr_out.write(local_ram_addr);
            break;
        case MC_MEM_WR:
            if (local_Wb_control.memory_w_enable == sc_logic('1')) {
                ram_wr_enable.write(sc_logic('1'));
                ram_data_out.write(data_to_write.read());
            }

            acc_finish.write(sc_logic('1'));
            break;
        default:
            break;
    }
}

void mem_control::do_read_memories() {
    sc_logic local_mem_type = mem_type.read();

    //cout << sc_time_stamp() << " do_read_memories" << endl;
    
    if (local_mem_type == SEL_RAM)
        data_read.write(ram_data_in.read());
    else if (local_mem_type == SEL_SPRAM)
        data_read.write(sp_data_in.read());
}

//read data from memory

void mem_control::do_calc_address() {
    sc_logic local_enable;
    sc_logic local_rd;

    sc_uint<RAM_ADDR_SIZE> local_addr;

    sc_uint<RAM_ADDR_SIZE> effective_addr;
    sc_uint<RAM_ADDR_SIZE> offset_addr;

    WbControl local_Wb_control;

    local_Wb_control = ctrl_wb_signals_in.read();
    local_addr = addr_in.read();

    //    cout << sc_time_stamp() << " " << dec << local_addr << endl;
    //    cout << dec;

    if (local_Wb_control.memory_rd_enable == sc_logic('1') ||
            local_Wb_control.memory_w_enable == sc_logic('1')) {
        effective_addr = local_addr / 4;
        offset_addr = local_addr % 4;

        // check alligment for WORD ACCESS
        if (local_Wb_control.access_width == WORD_ACC_SEL && offset_addr != 0) {
            //todo: exception
            cout << "Misaligned memory Access @ " << hex <<local_addr << endl;
            sc_assert(false);
        }

        if (local_Wb_control.access_width == HALF_WORD_ACC_SEL && (offset_addr % 2 != 0)) {
            //todo: exception
            cout << "Misaligned memory Access @ " << hex << local_addr << endl;
            sc_assert(false);
        }

        //		cout << "local_rd_addr: " << local_addr << " sram_addr: "
        //				<< effective_addr << " offset_addr: " << offset_addr << endl;

        mem_addr.write(effective_addr);
    } else {
        mem_addr.write(effective_addr);
    }
}

void mem_control::sel_mem_type() {
    const sc_uint<WORD_SIZE> sp_ini = SCRATCHPAD_INI;
    const sc_uint<WORD_SIZE> sp_end = SCRATCHPAD_END;

    sc_uint<RAM_ADDR_SIZE> local_addr;

    local_addr = mem_addr.read();

    if (mode == SP_0_ONLY) {
        mem_type.write(SEL_SPRAM); //select SP_MEM
    } else {
        if (local_addr > MEMORY_SIZE_WORDS) {
            cout << sc_time_stamp() << " Error @:" << hex << local_addr << endl;
        }

        //sc_assert(local_addr < MEMORY_SIZE_WORDS);

        if (local_addr >= sp_ini && local_addr < sp_end)
            mem_type.write(SEL_SPRAM); //select SP_MEM
        else
            mem_type.write(SEL_RAM); //select RAM or ROM
    }

}

void mem_control::update_read_output() {
    sc_int<WORD_SIZE> local_ram_data;
    sc_int<WORD_SIZE> local_ram_data_unsigned;

    sc_uint<RAM_ADDR_SIZE> local_rd_addr;

    sc_uint<RAM_ADDR_SIZE> offset_addr;

    WbControl local_Wb_control;

    local_Wb_control = ctrl_wb_signals_in.read();
    local_rd_addr = addr_in.read();

    local_ram_data = data_read.read();
    //local_ram_data_unsigned = data_r_in.read().to_uint();

    //cout << "local_ram_data_unsigned: " << local_ram_data_unsigned << hex << endl;;

    //output is latched because MEM_WD pipeline register read data
    //on the clock positive edge
    if (local_Wb_control.memory_rd_enable == sc_logic('1')) {
        offset_addr = local_rd_addr % 4;

        //cout << sc_time_stamp() << " : " << local_ram_data << " / " << offset_addr << endl;
        
        switch (local_Wb_control.access_width) {
            case WORD_ACC_SEL:
                break;

            case HALF_WORD_ACC_SEL:
                
                //cout << sc_time_stamp() << " : " << local_ram_data << " / " << offset_addr << endl;
                
                
//                cout << sc_time_stamp() << endl;
//                cout << "local_ram_data_unsigned: " << hex << local_ram_data_unsigned << endl;
//                cout << "local_rd_addr: " << local_rd_addr << " offset_addr: " << dec << offset_addr << endl;
//
//                cout << "offset_addr: " << offset_addr << endl;

//                local_ram_data_unsigned = local_ram_data_unsigned.range(offset_addr * 8 + 15, offset_addr * 8);
//                local_ram_data = local_ram_data_unsigned.to_int();
                
                               
                local_ram_data = local_ram_data.range(offset_addr * 8 + 15, offset_addr * 8);

                //cout << sc_time_stamp() << " : " << local_ram_data << endl;
                
                //signal extension
                if (local_Wb_control.unsigned_load == sc_logic('0')) {
                    if (local_ram_data.bit(16 - 1) == 1) {
                        local_ram_data = local_ram_data | 0xFFFF0000;
                    }
                }
                
                 

                break;

            case BYTE_ACC_SEL:

                //				cout << "BYTE_ACC_SEL" << endl;
                //				cout << "local_ram_data_unsigned: " << hex << local_ram_data_unsigned << endl;

                //				local_ram_data_unsigned = local_ram_data_unsigned.range(offset_addr*8 + 7, offset_addr*8);
                //				local_ram_data = local_ram_data_unsigned.to_int();

                local_ram_data = local_ram_data.range(offset_addr * 8 + 7, offset_addr * 8);

                if (local_Wb_control.unsigned_load == sc_logic('0')) {

                    //signal extension
                    if (local_ram_data.bit(8 - 1) == 1) {
                        local_ram_data = local_ram_data | 0xFFFFFF00;
                    }

                }
                break;

            default:
                break;
        }

        data_r_out.write(local_ram_data);
    }
}


//Synchronous read in negedge. Pipeline buffer value is not hold when forward logic is active:
//mem store after mem ld

void mem_control::do_read_pipe_data() {
    WbControl local_Wb_control;

    //cout << sc_time_stamp() << "read: " << read << endl;

    local_Wb_control = ctrl_wb_signals_in.read();

    if (cpu_clk.negedge() == true &&
            pipe_read.read() == sc_logic('0') &&
            local_Wb_control.memory_w_enable == sc_logic('1')) {
        //read data when it is stable
        pipe_data.write(pipe_data_in.read());
        //self suspend if there is a pipeline stall
        pipe_read.write(sc_logic('1'));

        //cout << sc_time_stamp() << "data: " << pipe_data_in.read() << endl;
    }
    //self reset
    if (cpu_clk.posedge() == true && stall_out.read() == sc_logic('0'))
        pipe_read.write(sc_logic('0'));

}



//There is no write in this cycle, write is postponed to WB stage
//If there is byte or halfword byte, Mem_controller has to read the
//entire memory word, makes an OR an enable the write on next pipe stage

void mem_control::update_write_output() {
    sc_int<WORD_SIZE> local_ram_data_to_write;

    sc_uint<WORD_SIZE> local_ram_data_unsigned;
    sc_uint<WORD_SIZE> local_ram_data_to_w_unsigned;

    sc_uint<RAM_ADDR_SIZE> local_w_addr;

    sc_uint<RAM_ADDR_SIZE> offset_addr;

    WbControl local_Wb_control;

    local_Wb_control = ctrl_wb_signals_in.read();
    local_w_addr = addr_in.read();

    //Mem controller has to read
    local_ram_data_unsigned = data_read.read().to_uint();
    local_ram_data_to_w_unsigned = pipe_data.read().to_uint();

    //cout << sc_time_stamp() << " " << "to_write: " << local_ram_data_to_w_unsigned << endl;
    //cout << "local_data_to_write_unsigned: " << local_ram_data_unsigned << endl;

    if (local_Wb_control.memory_w_enable == sc_logic('1')) {
        offset_addr = local_w_addr % 4;

        switch (local_Wb_control.access_width) {
            case WORD_ACC_SEL:
                local_ram_data_to_write = local_ram_data_to_w_unsigned.to_int();
                break;

            case HALF_WORD_ACC_SEL:
                local_ram_data_to_w_unsigned = local_ram_data_to_w_unsigned.range(15, 0);
                local_ram_data_to_w_unsigned = local_ram_data_to_w_unsigned << offset_addr * 8;

                //				cout << "local_ram_data_unsigned: " << hex << local_ram_data_unsigned << endl;
                //				cout << "local_ram_data_to_w_unsigned: " << hex << local_ram_data_to_w_unsigned << endl;

                // mask the value corresponding to the memory address
                local_ram_data_unsigned = (~(0xFFFF << offset_addr * 8) & (0xffffffff)) & local_ram_data_unsigned;
                local_ram_data_to_w_unsigned = local_ram_data_to_w_unsigned | local_ram_data_unsigned;

                //				cout << "local_ram_data_unsigned: " << hex << local_ram_data_unsigned << endl;
                //				cout << "local_ram_data_to_w_unsigned: " << hex << local_ram_data_to_w_unsigned << endl;

                local_ram_data_to_write = local_ram_data_to_w_unsigned.to_int();
                break;

            case BYTE_ACC_SEL:
                //cout << "BYTE_ACC_SEL" << endl;

                //read and shift to memory position
                local_ram_data_to_w_unsigned = local_ram_data_to_w_unsigned.range(7, 0);
                local_ram_data_to_w_unsigned = local_ram_data_to_w_unsigned << offset_addr * 8;

                //				cout << "local_ram_data_unsigned: " << hex << local_ram_data_unsigned << endl;
                //				cout << "local_ram_data_to_w_unsigned: " << hex << local_ram_data_to_w_unsigned << endl;

                // mask the value corresponding to the memory address
                local_ram_data_unsigned = (~(0xFF << offset_addr * 8) & (0xffffffff)) & local_ram_data_unsigned;
                local_ram_data_to_w_unsigned = local_ram_data_to_w_unsigned | local_ram_data_unsigned;

                //				cout << "local_ram_data_unsigned: " << hex << local_ram_data_unsigned << endl;
                //				cout << "local_ram_data_to_w_unsigned: " << hex << local_ram_data_to_w_unsigned << endl;

                local_ram_data_to_write = local_ram_data_to_w_unsigned.to_int();
                break;

            default:
                break;
        }

        data_to_write.write(local_ram_data_to_write);

    } else
        data_to_write.write(0);
}


//always read

void mem_control::do_sp_read() {
    WbControl local_Wb_control;
    const sc_uint<WORD_SIZE> sp_offset = SCRATCHPAD_INI;

    local_Wb_control = ctrl_wb_signals_in.read();

    if ((local_Wb_control.memory_rd_enable == sc_logic('1') ||
            local_Wb_control.memory_w_enable == sc_logic('1')) &&
            mem_type.read() == SEL_SPRAM) {
        spram_rd_enable.write(sc_logic('1'));

        if (mode == SP_0_ONLY)
            sp_addr_out.write(0);
        else
            sp_addr_out.write(mem_addr.read() - sp_offset);
    } else {
        spram_rd_enable.write(sc_logic('0'));
        sp_addr_out.write(0);
    }
}

//always read

void mem_control::do_sp_write() {
    if (mem_type.read() == SEL_SPRAM)
        sp_data_w_out.write(data_to_write.read());
    else
        sp_data_w_out.write(0);
}

void mem_control::do_debug() {
    debug_state.write(mem_ctr_state);
}

