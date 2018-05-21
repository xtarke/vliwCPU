#include <systemc.h>
#include "../sizes.h"

#ifndef ALU_H
#define	ALU_H

enum ALU_MODE {
    ALU_NORMAL = 0,
    ALU_WCET
};

enum alu_ops {
    ALU_ADD = 1, //1
    ALU_SUB, //2   
    ALU_MULT, //3
    ALU_MULTU, //4
    ALU_DIV, //5
    ALU_AND, //6
    ALU_OR, //7
    ALU_NOR, //8
    ALU_XOR, //9
    ALU_SLT, //10
    ALU_SLTU, //11
    ALU_SLL, //12
    ALU_SLLV, //13
    ALU_SRL, //14
    ALU_SRLV, //15
    ALU_SRA, //16
    ALU_SRAV, //17
    ALU_SHIFTL, //18
    ALU_SHIFTR, //19
    ALU_SHIFTL_B, //20
    ALU_CMPEQ, //21
    ALU_CMPGE, //22
    ALU_CMPGEU, //23
    ALU_CMPGT, //24
    ALU_CMPGTU, //25
    ALU_CMPLE, //26
    ALU_CMPLEU, //27
    ALU_CMPLT, //28
    ALU_CMPLTU, //29
    ALU_CMPNE, //30
    ALU_NANDL, //31
    ALU_CMOV, //32
    ALU_MUL//33
};

SC_MODULE(alu) {
    sc_in<sc_int<WORD_SIZE> > a;
    sc_in<sc_int<WORD_SIZE> > b;
    sc_in<sc_uint<ALUOPS> > aluop;
    sc_in<sc_uint<SHAMT_SIZE> > shamt;

    sc_out<sc_int<WORD_SIZE> > result_out;
    sc_out<sc_int<WORD_SIZE> > lo_out;
    sc_out<sc_int<WORD_SIZE> > hi_out;


    sc_signal<sc_int<WORD_SIZE> > lo_result;
    sc_signal<sc_int<WORD_SIZE> > hi_result;
    sc_signal<sc_int<WORD_SIZE> > result;
    sc_signal<sc_int<WORD_SIZE> > result_usigned;

    //debug
    sc_signal<sc_uint<2 * WORD_SIZE> > result_doublew;

    void do_calc();
    void do_output();
    void do_hilo_ouput();

    SC_HAS_PROCESS(alu);

    alu(sc_module_name name_, ALU_MODE mode_ = ALU_NORMAL) :
            sc_module(name_), mode(mode_)
            //        SC_CTOR(alu)
    {
        SC_METHOD(do_calc);
        sensitive << a << b << aluop;

        SC_METHOD(do_output);
        sensitive << result;
        
        SC_METHOD(do_hilo_ouput);
        sensitive << lo_result << hi_result;

    }

    private:
    const ALU_MODE mode;
};

#endif
