/* 
 * File:   stack_analyzer.cpp
 * Author: andreu
 * 
 * Created on July 30, 2013, 11:48 AM
 */

#include "stack_analyzer.h"
#include "instruction.h"
#include "logger.h"
#include <cerrno>
#include <string>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <cmath>


stack_analyzer::stack_analyzer(uint8_t* raw_image, uint32_t limit) {
    image = (uint32_t*) raw_image;
    stack_limit = (int32_t) limit;
    stack_base = 0;
    stack_max = 0;
    actual_stack = stack_base;
}

stack_analyzer::~stack_analyzer() {
}

void stack_analyzer::analyze(){
 
    recursive_analyzer(0);
    
    LOG << "max stack: " << stack_max << "\n";
    LOG << "stack limit: " << stack_limit << "\n";
    
    
    if(stack_max > stack_limit){
        std::cout << "program stack exceeds the available stack\n";
        std::cout << "-->max stack: " << stack_max << "\n";
        std::cout << "-->stack limit: " << stack_limit << "\n";
        exit(EXIT_FAILURE);
    }
}

void stack_analyzer::recursive_analyzer(uint32_t inst_index){
//     instrunction inst;
    bool not_end_call = true;
    uint32_t start_stack, end_stack;
    
    start_stack = actual_stack;
  /*  
    while(not_end_call){
        inst.instr_data = image[inst_index];
        
        switch(inst.get_opcode()){
            case JAL:{
                uint32_t target = inst.get_addr26();
                //std::cout << "call: " << target << "\n"; 
                
                recursive_analyzer(target);;
                break;
            } 
            case NORM_ARIT:{
                if(inst.get_func() == JR && 
                        inst.get_rs() == RA_REGISTER){
                    //std::cout << "return" << "\n";
                    not_end_call = false;
                    
                } else if(inst.get_func() == ADDU && 
                    inst.get_rs() == SP_REGISTER && 
                    inst.get_rd() == SP_REGISTER){
                    
                    int32_t val = back_track_offset(inst_index);
                    update_stack_info(val);
                    //std::cout << "esse é o caso: " << inst_index << "\n";
                    
                } else if(inst.get_rs() == SP_REGISTER && 
                        inst.get_rd() == SP_REGISTER){
                    std::cout << "Unhandled stack case at instr: " << inst_index << "\n";
                    exit(EXIT_FAILURE);
                }
                
                break;
            }
            case ADDIU: {
                if(inst.get_rt() == SP_REGISTER && 
                        inst.get_rs() == SP_REGISTER){                  
                    int32_t val = inst.get_imm();
                    //std::cout << "adjusting stack: " << val << "\n";
                    update_stack_info(val);
                }
                break;
            }
            case HLT: {
                  not_end_call = false;
            }
            default:
                if(inst.get_rs() == SP_REGISTER && 
                        inst.get_rd() == SP_REGISTER){
                    std::cout << "Unhandled stack case at instr: " << inst_index << "\n";
                    exit(EXIT_FAILURE);
                }
                
                break;
        }
        inst_index++;
    }
    
    end_stack = actual_stack;
    */
    assert(start_stack == end_stack && "Stack mismatch inside a procedure");
}

void stack_analyzer::update_stack_info(int32_t val){
    int32_t max;
    
    max = labs(stack_base - actual_stack);
    
    actual_stack = actual_stack += val;
    if(max > stack_max){
        stack_max = max;
    }
}

int32_t stack_analyzer::back_track_offset(uint32_t inst_index){
    
//     instrunction inst;
    
    uint32_t from_register;
    int32_t upper_value, lower_value;
    uint32_t index;
    int32_t offset;
    
//     inst.instr_data = image[inst_index];
//     from_register = inst.get_rt();
    
    index = inst_index;
  /*  
    do{
        inst.instr_data = image[index];
        index--;
    } while(!(inst.get_opcode() == ADDIU && 
            inst.get_rt() == from_register &&
            inst.get_rs() == from_register));
    
    lower_value = inst.get_imm();
    
    index = inst_index;
    do{
        inst.instr_data = image[index];
        index--;
    } while(!(inst.get_opcode() == LUI && 
            inst.get_rt() == from_register));
    
    upper_value = inst.get_imm();
    
    offset = upper_value;
    offset = offset << 16;
    offset += lower_value;
    */
    return offset;
}