/* 
 * File:   Execute.h
 * Author: bpibic
 *
 * Created on 13 de Janeiro de 2015, 15:52
 */

#ifndef EXECUTE_H
#define	EXECUTE_H

#include "Slot.h"
#include "ULA.h"
#include "MemOperation.h"

class Execute {
public:
    Execute();
    unsigned int execute(Slot *slots);
    
    ULA ula;
    
    
private:

};

#endif	/* EXECUTE_H */

