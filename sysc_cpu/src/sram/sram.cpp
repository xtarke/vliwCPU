#include "sram.h"

void sram::dump_contents() {
    int i;
    ofstream file;

    file.open("sp-w.txt");

    file << "CPU SP_RAM contents: " << endl;

    for (i = 0; i < SCRATCHPAD_SIZE; i++) {
        if (i % 4 == 0 && i != 0)
            file << endl;
        file << "[" << dec << i * 4 << "]" << " : " << dec << sram_data[i] << " \t";
    }
    file << endl;
    
    file.close();

}

void sram::dump_contents_hword() {
    int i;
    ofstream file;

    file.open("sp-hw.txt");


    file << "CPU SPRAM contents: " << endl;
    file << "[addr(bytes)] : content" << endl;

    for (i = 0; i < SCRATCHPAD_SIZE; i++) {
        if (i % 4 == 0 && i != 0)
            file << endl;

        sc_int < WORD_SIZE / 2 > hi = sram_data[i].range(WORD_SIZE - 1, WORD_SIZE / 2).to_int();
        sc_int < WORD_SIZE / 2 > lo = sram_data[i].range(WORD_SIZE / 2 - 1, 0).to_int();

        file << "[" << dec << i * 4 << "]" << " : " << hex << hi
                << "\t" << lo << " \t";

        //        cout << hex << lo << endl;
        //        cout << hex << hi << endl;
    }

    file << dec << endl;
    file.close();

}

void sram::do_read() {
    sc_logic local_enable;
    sc_logic local_rd;
    sc_uint<RAM_ADDR_SIZE> local_rd_addr;

    local_enable = enable.read();
    local_rd = rd.read();
    local_rd_addr = rd_addr.read();

    sc_assert(local_rd_addr < SCRATCHPAD_SIZE);

    if ((local_enable == 1) && (local_rd == 1)) {
        if (clk.posedge() == true) {
            data_out.write(sram_data[local_rd_addr].to_int());
            //cout << "@ " << sc_time_stamp() << " sram read addr: "
            //			<< local_rd_addr << " data: " << sram_data[local_rd_addr] << endl;
        }
    }
}

//-- read process
//process (clk, rd, enable)
//begin
//	--data_out <= "ZZZZZZZZZZZZZZZZ";
//	if enable = '1' and rd = '1' then
//		if rising_edge (clk) then
//			data_out <= ram_block(conv_integer(rd_addr));
//		end if;
//	end if;
//end process;

void sram::do_write() {
    //sc_logic local_clock;

    sc_logic local_enable;
    sc_logic local_wr;
    sc_uint<RAM_ADDR_SIZE> local_wr_addr;
    sc_int<WORD_SIZE> local_data;


    //local_clock = clk;
    local_enable = enable.read();
    local_wr = wr.read();
    local_wr_addr = w_addr.read();
    local_data = data_in.read();

    sc_assert(local_wr_addr < SCRATCHPAD_SIZE);

    if ((local_enable == 1) && (local_wr == 1)) {
        if (clk.posedge() == true) {
            sram_data[local_wr_addr] = local_data;
            //cout << "@ " << sc_time_stamp() << " sram write addr: "
            //	<< local_wr_addr << " data: " << local_data << hex << endl;
        }
    }
}

//process (clk, wr, enable, io_in)
//	begin
//		--data_out <= "ZZZZZZZZZZZZZZZZ";
//		if enable = '1' and wr = '1' then
//			if rising_edge (clk) then
//				ram_block(conv_integer(w_addr)) <= data_in;
//			end if;
//		end if;
