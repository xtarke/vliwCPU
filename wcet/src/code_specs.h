#ifndef CODE_SPECS_H
#define CODE_SPECS_H

#include <stdint.h>
#include <vector>
#include "ELFobject.h"

using namespace std;

class ins_specs
{
  public:
    int addr;
    uint32_t word;   
};


class code_specs
{
public:
  code_specs();
  void add_inst (int addr, uint32_t new_word);
  void modify (linker::ELF_object* object);
  
  
private:  
  vector<ins_specs*> ins_to_modify;
  
};

#endif // CODE_SPECS_H
