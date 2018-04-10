/* 
 * File:   Control.h
 * Author: bpibic
 *
 * Created on 8 de Janeiro de 2015, 10:54
 */

#ifndef CONTROL_H
#define	CONTROL_H

#include <stdint.h>

#include "Fetch.h"
#include "Regist.h"
#include "Slot.h"

class Control {
public:
    Control();
    void GetData(Slot *slots);   
    
    
private:

};

#endif	/* CONTROL_H */

