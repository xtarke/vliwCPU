/* 
 * File:   main.cpp
 * Author: bpibic
 *
 * Created o
 * n 8 de Janeiro de 2015, 09:28
 */

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <stdint.h>
#include  <iomanip>
#include <getopt.h>
#include <string.h>

#include "CPU.h"
#include "HexRead.h"
#include "MifRead.h"
#include "Rom.h"
#include "SPram.h"

using namespace std;


static char* input_file = NULL;
bool mif_hex = false; //true for mif/false for hex

static const struct option long_options[] = {   
    { "mif", required_argument, NULL, 'm'},
    { "hex", required_argument, NULL, 'x'},
    { "help", no_argument, NULL, 'h'},    
    { NULL, no_argument, NULL, 0}
};


/*usage params*/
static void usage(void) {
    cout << "Integrated Linker & Wcet Analyzer" << endl;
    cout << "Usage:" << endl << endl;
    cout << "\t\t-m (--mif) <mif memory file>" << endl;
    cout << "\t\t-x (--hex) <mif memory file>" << endl;  
    cout << "--------------------------------" << endl;

    exit(EXIT_FAILURE);
}

static int parse_command_line(int argc, char** argv) {
    int c;
    const char* solver_name = NULL;

    while (1) {
        /* getopt_long stores the option index here. */
        int option_index = 0;

        c = getopt_long(argc, argv, "m:x:h",
                        long_options, &option_index);

        /* Detect the end of the options. */
        if (c == -1) {
            break;
        }

        switch (c) {
        case 0:
            usage();
            break;
            //input_file = (char*) strdup(optarg);      
        case 'm':
            if (input_file == NULL){
	      input_file = (char*)strdup(optarg);
	      mif_hex = true;
	    }
	    else{
	      cout << "ABORT: Input file defined twice" << endl;
	      exit(EXIT_FAILURE);	      
	    } 
	      
            break;
	case 'x':
            if (input_file == NULL){
	      input_file = (char*)strdup(optarg);
	      mif_hex = false;
	    }
	    else{
	      cout << "ABORT: Input file defined twice" << endl;
	      exit(EXIT_FAILURE);	      
	    } 
	      
            break;
        case 'h':
            usage();
            exit(0);
        }
    }

    if (!input_file) {
        printf("ABORT: Undefined input file\n");
        exit(EXIT_FAILURE);
    }     
    

    return 0;
}

bool check_file (const std::string& name) {
    ifstream f(name.c_str());
    if (f.good()) {
        f.close();
        return true;
    } else {
        f.close();
        return false;
    }   
}

/*
 * 
 */
int main(int argc, char** argv) {
  
  uint32_t rom[ROM_SIZE_WORDS];
  uint32_t spram[SPRAM_SIZE_WORDS];
  
  string program;
  string file_name;
  string sp_file_name;
  
  CPU cpu;
   
  parse_command_line(argc, argv);
  
  program = input_file;
  
  //true for mif/false for hex
  if (mif_hex == true)
  {
    file_name = input_file;
    sp_file_name = input_file;
    
    file_name.append(".mif");
    sp_file_name.append("-dp_sp.mif");    
      
    MifRead mifread_code(file_name.c_str());
    if (mifread_code.parse(rom, ROM_SIZE_WORDS, 0xFFFFFFFF) != true)
    {
      cout << "ABORT: Error parsing code mif file, check log" << endl;
      exit(EXIT_FAILURE);	      
    }      
    
    MifRead miffile_spram(sp_file_name.c_str());
    
    if (miffile_spram.parse(spram, SPRAM_SIZE_WORDS, 0) != true)
    {
      cout << "ABORT: Error parsing spram mif file, check log" << endl;
      exit(EXIT_FAILURE);	      
    }    
  }
  else
  {
    file_name = input_file;
    sp_file_name = input_file;
    
    file_name.append(".hex");
    sp_file_name.append("-dp_sp.hex");
    
    if (!check_file(file_name))
    {
      cout << "ABORT: Undefined input file" << endl;
      exit(EXIT_FAILURE);	      
    }
    
    HexRead hexfile_code(file_name.c_str());  
    hexfile_code.parse(rom, ROM_SIZE_WORDS);
  
    HexRead hexfile_spram(sp_file_name.c_str());
    hexfile_spram.parse(spram, SPRAM_SIZE_WORDS);
  }
     
  //load memories   
  cpu.load_rom(rom,ROM_SIZE_WORDS);
  //cpu.rom.dump();
  
  cpu.load_spram(spram, SPRAM_SIZE_WORDS);
  //cpu.spram.dump();
    
  //run 
  cpu.CPU_run();
  
  //dump spram after simulation
  cpu.spram.file_dump(); 

  
  cout << program << " : " << cpu.get_cycles() << " : " << ((float)cpu.get_ops() / cpu.get_cycles()) << endl;
    
  return 0;
}

