/*
 * sim_library.h
 *
 *  Created on: May 27, 2013
 *      Author: xtarke
 */

#ifndef SIM_LIBRARY_H_
#define SIM_LIBRARY_H_

#include <vector>
#include "../cpu.h"
#include "../stimuli.h"
#include "../cache/cache.h"
#include "../instrunctions.h"

//#define DEBUG

using namespace std;

//Pipe modeling:
//SINGLE_CYC_FETCH doesn't model piple stalls due slow memory access, use with 
//    cache analysis
//SLOW_FETCH models a memory stall when an instruction is fetched 
enum lib_pipeline_type {
    SINGLE_CYC_FETCH = 0,
    SLOW_FETCH
};

class sim_data {
private:
    int id;
    uint32_t ini_addr;
    uint32_t end_addr;
    uint64 cycles;

public:
    cpu *CPU_CORE;

    sim_data(int id_, uint32_t ini_addr_, uint32_t end_addr_, lib_pipeline_type sim_pipe_mode) :
    id(id_), ini_addr(ini_addr_), end_addr(end_addr_) {
        std::stringstream out;
        out << "cpu_" << id;
        std::string msg = out.str();

        if (sim_pipe_mode == SINGLE_CYC_FETCH)
            CPU_CORE = new cpu(msg.c_str(), 1, ini_addr, end_addr, WCET, 1, 1);
        if (sim_pipe_mode == SLOW_FETCH)
            CPU_CORE = new cpu(msg.c_str(), 1, ini_addr, end_addr, WCET, 1, 0);

#ifdef DEBUG
        out << " : " << ini_addr << " " << end_addr << " WCET mode";
        msg = out.str();

        SC_REPORT_INFO(1, msg.c_str());
#endif
        cycles = 0;
    }

    ~sim_data() {
        delete(CPU_CORE);
    }
};

class cpu_info {
private:
    uint32_t cache_index_size;
    uint32_t cache_index_ini;
    uint32_t cache_index_end;

    uint32_t cache_tag_ini;

    uint32_t cache_bk_offset_size;
    uint32_t cache_bk_offset_ini;
    uint32_t cache_bk_offset_end;

    uint32_t cache_blocks;
    uint32_t cache_block_size;

    uint32_t ram_size;
    uint32_t scratchpad_size;

    uint32_t rom_size;

    unsigned int mem_cycle_time;
    unsigned int cpu_cycle_time;

    unsigned int cache_penalty_cycles;
    unsigned int umem_access_cycles;

public:

    cpu_info() {
        cache_index_size = INDEX_SIZE;
        cache_index_ini = INDEX_INI;
        cache_index_end = INDEX_END;

        cache_tag_ini = TAG_INI;

        cache_bk_offset_size = BK_OFFSET_SIZE;
        cache_bk_offset_ini = BK_OFFSET_INI;
        cache_bk_offset_end = BK_OFFSET_END;

        cache_blocks = CACHE_BLOCKS;
        cache_block_size = BLOCK_SIZE;

        ram_size = RAM_SIZE;
        scratchpad_size = SCRATCHPAD_SIZE;

        rom_size = ROM_SIZE;

        mem_cycle_time = MEM_CYCLE_TIME;
        cpu_cycle_time = CPU_CYCLE_TIME;

        //number of cpu cycles in each cache miss
        //= (number of cache blocks to load + alignment frequency cycles) * mem_time
        //  -------------------------------------------------------------------------
        //                              cpu_time
        cache_penalty_cycles = (BLOCK_SIZE + 2) * MEM_CYCLE_TIME / CPU_CYCLE_TIME;
        umem_access_cycles = (3 * MEM_CYCLE_TIME) / CPU_CYCLE_TIME;
    }

    uint32_t get_cache_bk_offset_end() const {
        return cache_bk_offset_end;
    }

    uint32_t get_cache_bk_offset_ini() const {
        return cache_bk_offset_ini;
    }

    uint32_t get_cache_bk_offset_size() const {
        return cache_bk_offset_size;
    }

    uint32_t get_cache_block_size() const {
        return cache_block_size;
    }

    uint32_t get_cache_blocks() const {
        return cache_blocks;
    }

    uint32_t get_cache_index_end() const {
        return cache_index_end;
    }

    uint32_t get_cache_index_ini() const {
        return cache_index_ini;
    }

    uint32_t get_cache_index_size() const {
        return cache_index_size;
    }

    unsigned int get_cache_penalty_cycles() const {
        return cache_penalty_cycles;
    }

    unsigned int get_umem_access_cycles() const {
        return umem_access_cycles;
    }

    uint32_t get_cache_tag_ini() const {
        return cache_tag_ini;
    }

    unsigned int get_cpu_cycle_time() const {
        return cpu_cycle_time;
    }

    unsigned int get_mem_cycle_time() const {
        return mem_cycle_time;
    }

    uint32_t get_ram_size() const {
        return ram_size;
    }

    uint32_t get_rom_size() const {
        return rom_size;
    }

    uint32_t get_scratchpad_size() const {
        return scratchpad_size;
    }

};

class cpu_sim {
private:
    uint32_t buffer[MEMORY_SIZE_WORDS];
    unsigned long file_size;
    lib_pipeline_type sim_pipe_mode;

public:
    vector<sim_data*> sim_datalist;

    uint32_t cache_index_size;
    uint32_t cache_index_ini;
    uint32_t cache_index_end;

    uint32_t cache_tag_ini;

    uint32_t cache_bk_offset_size;
    uint32_t cache_bk_offset_ini;
    uint32_t cache_bk_offset_end;

    uint32_t cache_blocks;
    uint32_t cache_block_size;

    uint32_t ram_size;
    uint32_t scratchpad_size;

    uint32_t rom_size;

    unsigned int cache_size;

    unsigned int mem_cycle_time;
    unsigned int cpu_cycle_time;

    //number of cpu cycles in each cache miss
    //= (number of cache blocks to load + alignment frequency cycles) * mem_time
    //  -------------------------------------------------------------------------
    //                              cpu_time
    unsigned int cache_penalty_cycles;
    unsigned int umem_access_cycles;

    void hello();

    cpu_sim(const char* file_name, lib_pipeline_type pipe_mode);

    void sim();

    void add_block(int id, uint32_t ini_addr, uint32_t end_addr);
};

SC_MODULE(siml_hmonitor) {
    sc_in<sc_logic> *in; //[32];

    sc_logic *status;

    void do_monitor();

    SC_HAS_PROCESS(siml_hmonitor);

    //parameterized module

    siml_hmonitor(sc_module_name name_, int n_inputs_ = 32) :
            sc_module(name_), n_inputs(n_inputs_) {
        SC_METHOD(do_monitor);

        status = new sc_logic [n_inputs];

        in = new sc_in<sc_logic> [n_inputs];

        for (int i = 0; i < n_inputs; i++) {
            status[i] = sc_logic('0');
            sensitive << in[i];
        }

    }

    private:
    const int n_inputs;

};

#endif /* SIM_LIBRARY_H_ */
