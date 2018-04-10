#ifndef INTERLOCK_H
#define INTERLOCK_H

#include "Slot.h"
#include "Decoder.h"

class Interlock
{
public:
  unsigned int check(Slot *exec_slot, Slot *old_slot);
  
  
  
  
};

#endif // INTERLOCK_H
