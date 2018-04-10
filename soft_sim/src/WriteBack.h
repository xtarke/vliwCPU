#ifndef WRITEBACK_H
#define WRITEBACK_H

#include "Regist.h"

using namespace std;

class WriteBack
{
  WriteBack(Regist reg_bank);
  
  void write(Slot *slots);
  
};

#endif // WRITEBACK_H
