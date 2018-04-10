/*
 * ELFsection.h
 *
 *  Created on: May 22, 2013
 *      Author: andreu
 */

#ifndef ELFSECTION_H_
#define ELFSECTION_H_

#include <elf.h>
#include <sys/types.h>


namespace linker {

    class ELF_object;

    class ELF_section {
    protected:
        uint8_t* section;
        uint32_t section_size;
        uint32_t section_fpos;
        Elf32_Section section_index;
        bool delete_section_data;
        bool section_found;
    public:

        ELF_section() {
            section = static_cast<uint8_t*> (0);
            section_size = 0;
            section_fpos = 0;
            section_index = 0;
            delete_section_data = true;
            section_found = false;
        }

        ~ELF_section() {
            // keep data buffer (will be deleted in another location)
            //if (delete_section_data) {
                delete[] section;
            //}
        }

        void dump(ELF_object* parent_obj);

        uint8_t* get_section() {
            return section;
        }

        void set_section(uint8_t* section_) {
            section = section_;
        }

        uint32_t get_section_size() {
            return section_size;
        }

        void set_section_size(uint32_t section_size_) {
            section_size = section_size_;
        }

        uint32_t get_section_fpos() {
            return section_fpos;
        }

        void set_section_fpos(uint32_t section_fpos_) {
            section_fpos = section_fpos_;
        }

        Elf32_Section get_section_index() {
            return section_index;
        }

        void set_section_index(Elf32_Section section_index_) {
            section_index = section_index_;
        }

        void disable_delete_section_data() {
            delete_section_data = false;
        }

        void set_as_found() {
            section_found = true;
        }

        bool was_found() {
            return section_found;
        }
        
        void append(ELF_section* sec);
        
        uint32_t get_word(unsigned int index);
        void expand(uint32_t amount);
    };

    class ELF_section_relocation : public ELF_section {
    public:

        ELF_section_relocation() : ELF_section() {};
        
        int get_n_relocs(){return get_section_size() / sizeof (Elf32_Rela);}
        Elf32_Rela* get_relocs(){return (Elf32_Rela*) get_section();}
        void fixup_after_append(uint32_t start_reloc, uint32_t sec_shift, uint32_t st_shift);
    };

} /* namespace linker */
#endif /* ELFSECTION_H_ */
