/* 
 * File:   ULA.h
 * Author: bpibic
 *
 * Created on 13 de Janeiro de 2015, 15:50
 */

#ifndef ULA_H
#define	ULA_H

#include "Slot.h"
#include <stdint.h>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <iomanip>

#include <fstream>

using namespace std;

class ULA {
public:
    ULA();
    ~ULA();
    
    ula_ouput Exec(uint32_t ula_func, int32_t src1, int32_t src2, int32_t imm, unsigned char src_sel, uint32_t scond);
    
private:
  
   ofstream file;

};

#endif	/* ULA_H */

