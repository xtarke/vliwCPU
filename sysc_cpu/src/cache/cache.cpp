#include "cache.h"
#include "../sizes.h"

void cache::do_data_output() {
    cache_state_type local_cache_state;

    sc_logic local_hit;
    sc_logic local_enable;

    sc_uint<INDEX_SIZE> local_cb_index;
    sc_uint<BK_OFFSET_SIZE> local_bk_index;

    local_hit = hit.read();
    local_bk_index = b_offset.read();
    local_cache_state = cache_state.read();
    local_cb_index = index.read();
    local_enable = data_out_enable.read();

    sc_assert(local_cb_index < CACHE_BLOCKS);
    sc_assert(local_bk_index < BLOCK_SIZE);

    //if (clk.posedge()) {
    if (local_cache_state == C_COMP_TAG)// && local_enable == sc_logic('1'))// && local_hit == sc_logic('1'))
    {
        //	cout << sc_time_stamp() << " cache out" << endl;

        data_out.write(cb[local_cb_index].data[local_bk_index].to_int());
    }
    // }

}

void cache::do_cache_addr() {
    sc_uint<WORD_SIZE> local_addr;
    cache_state_type local_cache_state;

    local_addr = address.read();
    local_cache_state = cache_state.read();


    //teste
    //	static int print = 1;
    //
    //	sc_uint<WORD_SIZE> pc = 0;
    //
    //
    //	if (print == 1)
    //	{
    //		cout << "pc\ttag\tindex\tb_offset\tbase_mem" << endl;
    //		for (int i=0; i < 50; i++)
    //		{
    //			cout << pc << "\t";
    //			cout << pc.range(TAG_END, TAG_INI) << "\t";
    //			cout << pc.range(INDEX_END, INDEX_INI) << "\t";
    //			cout << pc.range(BK_OFFSET_END, BK_OFFSET_INI) << "\t";
    //			cout << (pc / BLOCK_SIZE)*BLOCK_SIZE << endl;
    //
    //			pc++;
    //		}
    //		print = 0;
    //	}


    if (local_cache_state == C_COMP_TAG) {
        tag.write(local_addr.range(TAG_END, TAG_INI));
        index.write(local_addr.range(INDEX_END, INDEX_INI));
        b_offset.write(local_addr.range(BK_OFFSET_END, BK_OFFSET_INI));

        //base memory: cache_line * BLOCK_SIZE + tag * CACHE_BLOCKS
        mem_addr.write(floor(local_addr / BLOCK_SIZE) * BLOCK_SIZE);
    }

}

void cache::do_check_hit() {
    sc_uint<TAG_SIZE> local_tag;
    cache_state_type local_cache_state;
    sc_uint<INDEX_SIZE> local_cb_index;

    local_cache_state = cache_state.read();
    local_cb_index = index.read();
    local_tag = tag.read();

    sc_assert(local_cb_index < CACHE_BLOCKS);

    if (local_cache_state == C_COMP_TAG) {
        if ((cb[local_cb_index].tag == local_tag) && (cb[local_cb_index].v_bit == sc_logic('1'))) {
            hit.write(sc_logic('1'));
            stall_out.write(sc_logic('0'));
            ram_clk_en_out.write(sc_logic('0'));
            hits++;
        } else {
            hit.write(sc_logic('0'));
            stall_out.write(sc_logic('1'));

            if (reset.read() == sc_logic('1')) {
                misses = 0;
                ram_clk_en_out.write(sc_logic('0'));
            } else {
                misses++;
                ram_clk_en_out.write(sc_logic('1'));
                //cout << "Miss @: " << address.read() << endl;
            }


        }
    }
}

void cache::do_clk_state() {
    sc_logic local_reset;
    sc_logic local_hit;
    sc_logic local_reading;

    sc_uint < BK_OFFSET_SIZE + 1 > local_word_index;

    cache_state_type local_cache_state;

    local_word_index = word_index.read();
    local_reset = reset.read();
    local_reading = reading_mem.read();

    if (local_reset == sc_logic('1')) {
        cache_state.write(C_COMP_TAG);
    } else if (mem_clk.posedge() == true) {
        local_hit = hit.read();
        local_cache_state = cache_state.read();

        switch (local_cache_state) {
            case C_COMP_TAG:
                if (local_hit == sc_logic('0'))
                    cache_state.write(C_MEM_PREP);
                break;
            case C_MEM_PREP:
                cache_state.write(C_RD_BLOCK);
                break;
            case C_RD_BLOCK:
                if (local_word_index >= BLOCK_SIZE)
                    cache_state.write(C_COMP_TAG);
                break;
            default:
                break;
        }
    }
}

void cache::do_state_ouput() {
    cache_state_type local_cache_stage;

    local_cache_stage = cache_state.read();

    mem_enable_out.write(sc_logic('0'));

    switch (local_cache_stage) {
        case C_COMP_TAG:
            break;

        case C_MEM_PREP:
        case C_RD_BLOCK:
            mem_enable_out.write(sc_logic('1'));
            break;

        default:
            break;
    }
}

void cache::do_mem_address_ouput() {
    cache_state_type local_cache_state;
    sc_uint<RAM_ADDR_SIZE> local_mem_addr;
    sc_uint < BK_OFFSET_SIZE + 1 > local_word_index;

    local_word_index = word_index.read();
    local_cache_state = cache_state.read();
    local_mem_addr = mem_addr.read();

    if (mem_clk.posedge() == true && ((local_cache_state == C_RD_BLOCK) ||
            (local_cache_state == C_MEM_PREP))) {
        local_word_index++;

        if (local_word_index > BLOCK_SIZE)
            local_word_index = 0;

        mem_addr_out.write(local_mem_addr + local_word_index);
        word_index.write(local_word_index);
    } else if (mem_clk.posedge() == true && ((local_cache_state == C_MEM_PREP) ||
            (local_cache_state == C_COMP_TAG))) {
        //word_index.write(0);
        mem_addr_out.write(local_mem_addr);
    }

}

void cache::do_read_memory() {
    cache_state_type local_cache_state;
    sc_uint<TAG_SIZE> local_tag;
    sc_int<WORD_SIZE> local_mem_data;
    sc_uint<INDEX_SIZE> local_cb_index;
    sc_uint < BK_OFFSET_SIZE + 1 > local_word_index;

    local_cache_state = cache_state.read();
    local_cb_index = index.read();
    local_mem_data = mem_data_in.read();
    local_tag = tag.read();

    local_word_index = reading_word_index.read();

    if (mem_clk.negedge() == true && local_cache_state == C_RD_BLOCK) {
        //		cout << sc_time_stamp() << " local_word_inde: " << local_word_index << endl;
        //		cout << "data: " <<  hex << local_mem_data <<  dec << endl;

        sc_assert(local_cb_index < CACHE_BLOCKS);
        sc_assert(local_word_index < BLOCK_SIZE);

        cb[local_cb_index].data[local_word_index] = local_mem_data.to_uint();
        cb[local_cb_index].v_bit = sc_logic('1');
        cb[local_cb_index].tag = local_tag;

        local_word_index++;
        reading_word_index.write(local_word_index);

        if (local_word_index >= BLOCK_SIZE)
            reading_word_index.write(0);
    }
}

//void cache::do_read_memory()
//{
//	cache_state_type local_cache_state;
//	sc_uint<TAG_SIZE> local_tag;
//	sc_int<WORD_SIZE> local_mem_data;
//	sc_uint<INDEX_SIZE> local_cb_index;
//	static sc_uint<BK_OFFSET_SIZE + 1>  local_word_index = 0;
//
//	local_cache_state = cache_state.read();
//	local_cb_index = index.read();
//	local_mem_data = mem_data_in.read();
//	local_tag      = tag.read();
//
//	if (mem_clk.negedge() == true && local_cache_state == C_RD_BLOCK)
//	{
////		cout << sc_time_stamp() << " local_word_inde: " << local_word_index << endl;
////		cout << "data: " <<  hex << local_mem_data <<  dec << endl;
//
//		sc_assert(local_cb_index < CACHE_BLOCKS);
//		sc_assert(local_word_index < BLOCK_SIZE);
//
//		cb[local_cb_index].data[local_word_index]  = local_mem_data.to_uint();
//		cb[local_cb_index].v_bit = sc_logic('1');
//		cb[local_cb_index].tag = local_tag;
//
//		local_word_index++;
//
//		if (local_word_index >= BLOCK_SIZE)
//			local_word_index = 0;
//	}
//}

void cache::do_debug() {

    debug_state.write(cache_state);

}

void cache::dump_contents() {
    sc_logic v_bit;
    sc_uint<TAG_SIZE> tag;
    sc_uint<WORD_SIZE> data;


    cout << "I-Cache contents: " << endl;
    for (int i = 0; i < CACHE_BLOCKS; i++) {
        tag = cb[i].tag;
        v_bit = cb[i].v_bit;

        cout << dec;
        cout << i << " " << hex << tag << "[" << v_bit << "]" << ": ";

        for (int j = 0; j < BLOCK_SIZE; j++) {
            data = cb[i].data[j];

            cout << data << " ";
        }

        cout << endl;

    }

    //	cout << "BK_OFFSET_SIZE: " <<  dec <<BK_OFFSET_SIZE << endl;
    //	cout << "INDEX_SIZE: " << INDEX_SIZE << endl;
    //	cout << "INDEX_INI: " << INDEX_INI << endl;
    //	cout << "INDEX_END: " << INDEX_END << endl;
    //
    //	cout << "TAG_SIZE: " << TAG_SIZE << endl;


}
