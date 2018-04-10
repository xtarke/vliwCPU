#include "MifRead.h"
#include <string>

MifRead::MifRead(const char* filename)
{
    file.open(filename);
    
    if (!file.good()) {
      cout << "ABORT<MifRead>: Undefined input file" << endl;
      LOG << "ABORT: Invalid mif file" << endl;
      exit(EXIT_FAILURE);      
    }   
}

MifRead::~MifRead()
{

}


/* Mif file is:
WIDTH = 32;
DEPTH = 16384;

ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;

CONTENT BEGIN
0	:	08084200;
(..)
25	:	xxxxxxxx;
[26..16383]	:	FFFFFFFF;
END;
 */

bool MifRead::parse(uint32_t *memory_array, int size_words, uint32_t fill)
{
    int words = 0;
    int i = 0;
    int addr = 0;
    int ret = 0;

    uint32_t data;

    int pos = 0;

    bool hex_radix = false;
    bool content_begin = false;


    LOG << "Parsing mif file" << endl;

    std::string line;
    std::string radix;
    std::string width;
    std::string depth;

    while (std::getline(file, line))
    {
        //check WIDTH parameter
        if (i == 0)
        {
            pos = line.find("WIDTH =");            
	    
	    if (pos == string::npos)
	    {
	      LOG << "ABORT: Invalid mif file" << endl;
	      LOG << "WIDTH not found at line 0" << endl;
	      return false;  
	    }

            width = line.substr(8,3);            
	    
	    if (std::stoi(width, nullptr, 0) != 32)
	    {
	      LOG << "ABORT: Invalid mif file" << endl;
	      LOG << "WIDTH is not 32" << endl;
	      return false;  
	    }
	    

            LOG << "\t" << "WIDTH is " << width << endl;
        }

        //check DEPTH parameter
        if (i == 1)
        {
            pos = line.find("DEPTH =");            
	    
	    if (pos == string::npos)
	    {
	      LOG << "ABORT: Invalid mif file" << endl;
	      LOG << "DEPTH not found at line 1" << endl;
	      return false;  
	    }
	    
            depth = line.substr(8,5);            
	    
	    if (std::stoi(depth, nullptr, 0) != size_words)
	    {
	      LOG << "ABORT: Invalid mif file" << endl;
	      LOG << "WIDTH is not " <<  size_words << endl;
	      return false;  
	    }

            LOG << "\t" << "DEPTH is " << depth << endl;
        }

        // ignore empty lines
        if (line.empty()) {
            i++;
            continue;
        }

        //check Data_radix
        pos = line.find("DATA_RADIX=");

        if (pos == string::npos && hex_radix == false)
        {
            i++;
            continue;
        }
        else
        {
            if (hex_radix == false)
            {
                radix = line.substr(11,3);

                if (radix.find("HEX") == string::npos)
                {
                    LOG << "ABORT: Invalid mif file" << endl;
                    return false;
                }
                LOG << "\t" << "DATA_RADIX found at line " << i << endl;

                hex_radix = true;
                i++;
                continue;
            }
        }

        //check Content begin
        pos = line.find("CONTENT BEGIN");

        if (pos == string::npos && content_begin == false)
        {
            i++;
            continue;
        }
        else
        {
            if (content_begin == false)
            {
                content_begin = true;

                LOG << "\t" << "CONTENT BEGIN at line " << i << endl;

                i++;
                continue;
            }
        }

        if (content_begin == false)
        {
            i++;
            continue;
        }


        pos = line.find("[");
        if (pos != string::npos)
        {
            LOG << "\t" << "CONTENT END at line " << i << endl;
            break;
        }

        ret = sscanf(line.c_str(), "%d\t:\t%x;\n", &addr, &data);

        if (ret != 2 || addr > size_words)
	{
	    cout << "ABORT: Invalid mif file" << endl;
	    cout << "Error at line i" << endl;
            return false;	  
	}	
	
	memory_array[addr] = data;
	words++;

        //cout << line << "   " << addr << "   "<< hex << data  << " : " << ret << endl;

        i++;
    }
    
    LOG << "\t" << "Read "<< dec << words << " data words" << endl;
    LOG << "\t" << "Filling remaining memory lines with " <<  hex << fill << dec << endl;
    
    for (i = words; i < size_words;i++)
	memory_array[i] = fill;    
    
    return true;
}
