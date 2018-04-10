#include "HexRead.h"
#include <string>

HexRead::HexRead(const char* filename)
{
  file.open(filename);
}

HexRead::~HexRead()
{

}


/* Hex file is:
 * [BC][ADDR][RT][b1][b2][b3][b4][b5][b6][b...16][ck]
 * 
 * where:
 * 
 * BC: byte count
 * ADDR: address;
 * RT:
 * b1: byte 1
 * b2: byte 2
 * b...16: b ... 16
 * ck: checksum */

bool HexRead::parse(uint32_t *memory_array, int size_words)
{
  int words = 0;
  
  std::string line; 
  std::string BC;
  std::string ADDR;
  std::string RT;
  std::string Data;
  std::string ck;

  
  while (std::getline(file, line))
  {    
    // check is each line is a valid hex file
    if (line[0] != ':')
      return false;
   
    if (words < size_words)
    {
      
      BC = line.substr(1,2);
      ADDR = line.substr(3,4);
      RT = line.substr(7,2);
      Data = line.substr(9,8);
      ck = line.substr(17,2);
     
      if (std::stoi(BC, nullptr, 0) != 4)
      {
	cout << "Invalid byte count in hex file" << endl;
	return false;
      }
      
      
      memory_array[words] = std::stol(Data,nullptr,16);
    
      //cout <<  hex << memory_array[words] << endl;
    
      words++;
    }    
  }  
  return true;
}
