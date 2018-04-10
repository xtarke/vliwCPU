/*
 * cache.cpp
 *
 *  Created on: May 15, 2013
 *      Author: xtarke
 */

#include "cache.h"
#include <assert.h>
#include "logger.h"

void cache_state::clear() {
    for (unsigned int i = 0; i < cache_blocks; i++)
        cb[i].clear();
}

void cache_state::add_reference(uint32_t address) {
    uint32_t tag;
    unsigned int index;

    index = get_line(address);
    tag = get_tag(address);

    assert(index < cache_blocks);

    cb[index].insert(tag);
}

void cache_state::add_input_reference(uint32_t address) {
    uint32_t tag;
    unsigned int index;

    index = get_line(address);
    tag = get_tag(address);

    assert(index < cache_blocks);

    if (cb[index].size() == 0)
        cb[index].insert(tag);
}

void cache_state::add_output_reference(uint32_t address) {
    uint32_t tag;
    unsigned int index;

    index = get_line(address);
    tag = get_tag(address);

    assert(index < cache_blocks);

    cb[index].clear();
    cb[index].insert(tag);
}

bool cache_state::search_tag(uint32_t tag, unsigned int index) {
    assert(index < cache_blocks);

    if (cb[index].find(tag) == cb[index].end())
        return false;
    else
        return true;
}

void cache_state::print() {
    set<uint32_t>::iterator it;

    for (unsigned int i = 0; i < cache_blocks; i++) {
        LOG_NL << "Line: " << "[" << i << "]: ";

        for (it = cb[i].begin(); it != cb[i].end(); it++)
            LOG_NL << *it << " ";

        LOG_NL << endl;
    }

}

bool cache_state::add_tag(uint32_t tag, unsigned int index) {
    assert(index < cache_blocks);

    if (!search_tag(tag, index)) {
        cb[index].insert(tag);
        return true;
    }

    return false;
}

int cache_state::get_references_size(unsigned int index) {
    assert(index < cache_blocks);

    return cb[index].size();
}

bool cache_state::is_empty(unsigned int index) {
    assert(index < cache_blocks);

    return cb[index].empty();
}

void cache_state::clear_index(unsigned int index) {
    assert(index < cache_blocks);

    cb[index].clear();
}

uint32_t cache_state::get_tag(uint32_t address) {
    uint32_t mask = 0xFFFFFFFF;
    uint32_t tag;

    //create tag mask and compute
    mask = mask << tag_ini;
    tag = (address & mask) >> tag_ini;

    return tag;

}

uint32_t cache_state::get_line(uint32_t address) {
    uint32_t mask_1 = 0xFFFFFFFF;
    uint32_t mask_2 = 0xFFFFFFFF;
    uint32_t mask_f = 0xFFFFFFFF;
    uint32_t index;

    //create index mask and compute
    mask_1 = mask_1 << index_ini;
    mask_2 = ~(mask_2 << (index_ini + index_size));
    mask_f = mask_1 & mask_2;
    index = (address & mask_f) >> index_ini;

    return index;
}

uint32_t cache_state::get_blk_offset(uint32_t address) {
    uint32_t mask_1 = 0xFFFFFFFF;
    uint32_t mask_2 = 0xFFFFFFFF;
    uint32_t mask_f = 0xFFFFFFFF;
    uint32_t block_offset;

    //create index mask and compute
    mask_1 = mask_1 << bk_offset_ini;
    mask_2 = ~(mask_2 << (bk_offset_ini + bk_offset_size));
    mask_f = mask_1 & mask_2;
    block_offset = (address & mask_f) >> bk_offset_ini;

    return block_offset;
}

uint32_t cache_state::get_cache_blocks() {
    return cache_blocks;
}

set<uint32_t> *cache_state::get_line_set(int index) {
    //cout << index << endl;
    assert(index < cache_blocks);

    return &cb[index];
}

bool cache_state::compare_sets(set<uint32_t> *cb_1, set<uint32_t> *cb_2) {

    set<uint32_t>::iterator it;

    bool in = true;

    for (it = cb_1->begin(); it != cb_1->end(); it++) {
        uint32_t tag = *it;

        if (cb_2->find(tag) == cb_2->end()) {
            in = false;
            break;
        }
    }

    return in;
}

void cache_state::set_intersec(set<uint32_t> *new_set, set<uint32_t> *cb_1, set<uint32_t> *cb_2) {
    assert(new_set != 0);
    assert(cb_1 != 0);
    assert(cb_1 != 0);

    set<uint32_t>::iterator it;

    for (it = cb_1->begin(); it != cb_1->end(); it++) {
        uint32_t tag = *it;

        if (cb_2->find(tag) != cb_2->end())
            new_set->insert(tag);

    }
}

void cache_state::create_state(std::vector<VLIW_bundle*> &bundles)
{
    vector<VLIW_bundle*>::iterator ITb;

    for (ITb = bundles.begin(); ITb != bundles.end(); ITb++) {
        VLIW_bundle* bundle = *ITb;

        add_reference(bundle->address);
    }
}

void cache_state::set_bundle_cache_info(std::vector<VLIW_bundle*> &bundles)
{
    vector<VLIW_bundle*>::iterator ITb;

    for (ITb = bundles.begin(); ITb != bundles.end(); ITb++) {
        VLIW_bundle* bundle = *ITb;

        bundle->blk_off = get_blk_offset(bundle->address);
        bundle->tag = get_tag(bundle->address);
        bundle->line = get_line(bundle->address);
        bundle->prediction = UNKNOWN;
	
// 	cout << "-----------------------" << endl;	
// 	cout << "adr:" <<  bundle->address << "\n";
// 	cout << "tag:" << bundle->tag << "\n";
// 	cout << "line:" << bundle->line << "\n";
// 	cout << "-----------------------" << endl;	
	

    }
}





