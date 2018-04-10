/* 
 * File:   stack_analyzer.h
 * Author: andreu
 *
 * Created on July 30, 2013, 11:48 AM
 */

#ifndef STACK_ANALYZER_H
#define	STACK_ANALYZER_H

#include <sys/types.h>
#include <stdint.h>

using namespace std;

class stack_analyzer {
public:
    stack_analyzer(uint8_t* raw_image, uint32_t limit);
    void analyze();
    virtual ~stack_analyzer();
private:
    int32_t stack_base;
    int32_t stack_max;
    int32_t stack_limit;
    int32_t actual_stack;
    
    uint32_t* image;
    
    void recursive_analyzer(uint32_t inst);
    void update_stack_info(int32_t val);
    int32_t back_track_offset(uint32_t inst);
};

#endif	/* STACK_ANALYZER_H */

