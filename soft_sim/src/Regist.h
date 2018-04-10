/* 
 * File:   Regist.h
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 09:47
 */

#ifndef REGISTRADORES_H
#define	REGISTRADORES_H
#include <sys/types.h>
#include <stdint.h>
#include "Slot.h"
#include "Decoder.h"

using namespace std;

class Regist {
public:
    Regist(ofstream* file_);
    void set_value(int32_t data,int32_t posicao);
    int32_t get_value(int32_t posicao);
    bool get_pvalue(int32_t posicao);
    void set_pvalue(bool data, int32_t pos);
    
    void GetRegValue(Slot *slots);
    
    void dump();
    
    void write_back(Slot *slots);
    
    
    //int32_t get_hlvalue(int select);
    //void set_hlvalue(int32_t data ,int select);
    
private:
    
    int32_t reg0;
    int32_t reg[64];
    bool preg[8];
    ofstream* file;
    //int32_t hi;
    //int32_t lo;
};

#endif	/* REGISTRADORES_H */
