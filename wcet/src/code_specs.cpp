#include "code_specs.h"
#include "logger.h"

code_specs::code_specs()
{

}

void code_specs::add_inst(int addr, uint32_t new_word)
{
  ins_specs *ins = new ins_specs;
  
  ins->addr = addr;
  ins->word = new_word;
  
  
  ins_to_modify.push_back(ins);
}

void code_specs::modify(linker::ELF_object* object)
{
  uint32_t *inst_buffer = (uint32_t*) object->get_text_section()->get_section();
  
//  cout << "Size:" << object->calculate_size() / sizeof (uint32_t)  << endl;

  
  for (int i = 0; i < ins_to_modify.size(); i++)  {
    ins_specs *new_ins = ins_to_modify[i];
    
    LOG << "Modifing mif @ " << new_ins->addr << endl;
    
    assert(new_ins->addr < object->calculate_size() / sizeof (uint32_t));
    inst_buffer[new_ins->addr] = new_ins->word;
    
    
    
  }  
}
