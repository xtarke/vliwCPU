/* 
 * File:   MIF_converter.h
 * Author: andreu
 *
 * Created on 15 de Julho de 2014, 15:54
 */

#ifndef MIF_CONVERTER_H
#define	MIF_CONVERTER_H

namespace linker {
    class ELF_object;
};


class MIF_converter {
public:
    MIF_converter(linker::ELF_object* obj);
    MIF_converter(const MIF_converter& orig);
    virtual ~MIF_converter();
    void dump_to_file(const char* filename);
    void dump_data_to_file(const char* filename);
    
private:
    linker::ELF_object* object;
};

#endif	/* MIF_CONVERTER_H */

