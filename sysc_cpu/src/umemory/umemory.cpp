#include "umemory.h"
#include "../sizes.h"

void umemory::dump_contents() {
    ofstream file;
    int i;

    file.open("umemory-w.txt");

    file << "CPU RAM contents: " << endl;
    file << "[addr(bytes)] : content" << endl;

    for (i = 0; i < MEMORY_SIZE_WORDS; i++) {
        if (i % 4 == 0 && i != 0)
            file << endl;
        file << "[" << dec << i * 4 << "]" << " : " << hex << memory_data[i] << " \t";
    }
    file << endl;

    file.close();
}

void umemory::dump_contents_dec() {
    ofstream file;
    int i;

    file.open("umemory-dec.txt");

    file << "CPU RAM contents: " << endl;
    file << "[addr(bytes)] : content" << endl;

    for (i = 0; i < MEMORY_SIZE_WORDS; i++) {
        if (i % 4 == 0 && i != 0)
            file << endl;
        file << "[" << dec << i * 4 << "]" << " : " << dec << memory_data[i] << " \t";
    }
    file << endl;

    file.close();
}

void umemory::dump_contents_hword() {
    int i;
    ofstream file;

    file.open("umemory-hw.txt");


    file << "CPU RAM contents: " << endl;
    file << "[addr(bytes)] : content" << endl;

    for (i = 0; i < MEMORY_SIZE_WORDS; i++) {
        if (i % 4 == 0 && i != 0)
            file << endl;

        sc_int < WORD_SIZE / 2 > hi = memory_data[i].range(WORD_SIZE - 1, WORD_SIZE / 2).to_int();
        sc_int < WORD_SIZE / 2 > lo = memory_data[i].range(WORD_SIZE / 2 - 1, 0).to_int();

        file << "[" << dec << i * 4 << "]" << " : " << hex << hi
                << "\t" << lo << " \t";

        //        cout << hex << lo << endl;
        //        cout << hex << hi << endl;
    }

    file << dec << endl;
    file.close();

}

void umemory::do_a_read() {
    sc_logic local_enable;
    sc_logic local_rd;

    sc_uint<RAM_ADDR_SIZE> local_rd_addr;

    local_rd_addr = rd_a_addr.read();
    local_enable = enable.read();
    local_rd = rd_a.read();

    sc_assert(local_rd_addr < MEMORY_SIZE_WORDS);

    if ((local_enable == sc_logic('1')) && (local_rd == sc_logic('1'))) {
        if (clk_pa.posedge() == true) {
            data_a_out.write(memory_data[local_rd_addr].to_int());
            //            cout << "@ " << sc_time_stamp() << " port_a read addr: "
            //                    << local_rd_addr << " data: " << memory_data[local_rd_addr] << endl;
        }
    }
}

void umemory::do_b_read() {
    sc_logic local_enable;
    sc_logic local_rd;
    sc_uint<RAM_ADDR_SIZE> local_rd_addr;

    local_enable = enable.read();
    local_rd = rd_b.read();
    local_rd_addr = rd_b_addr.read();

    sc_assert(local_rd_addr < MEMORY_SIZE_WORDS);

    if ((local_enable == 1) && (local_rd == 1)) {
        if (clk_pb.negedge() == true) {
            data_b_out.write(memory_data[local_rd_addr].to_int());
            //            cout << "@ " << sc_time_stamp() << " sram read addr: "
            //                    << local_rd_addr << " data: " << memory_data[local_rd_addr] << endl;
        }
    }
}

void umemory::do_write() {
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

    sc_assert(local_wr_addr < MEMORY_SIZE_WORDS);

    if ((local_enable == 1) && (local_wr == 1)) {
        if (clk_pw.negedge() == true) {
            memory_data[local_wr_addr] = local_data.to_uint();
            //			cout << "@ " << sc_time_stamp() << " sram write addr: "
            //				<< local_wr_addr << " data: " << local_data << hex << endl;
        }
    }
}

