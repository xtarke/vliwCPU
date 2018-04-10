/*
 * File:   ULA.cpp
 * Author: bpibic
 *
 * Created on 13 de Janeiro de 2015, 15:50
 */

#include "ULA.h"

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <stdint.h>
#include "ULACodeName.h"
#include "Slot.h"


#include <assert.h>
#include <iostream>
#include <fstream>
#include <iomanip>


using namespace std;

ULA::ULA() {
  
  file.open("ula-log.txt");
  
}

ULA::~ULA() {  
  file.close();  
}

ula_ouput ULA::Exec(uint32_t ula_func, int32_t src1, int32_t src2, int32_t imm, unsigned char src_sel, uint32_t scond) {

  int32_t s1 = src1;
  int32_t s2 = 0;
  
  int64_t data64 = 0;
  uint64_t data64_u = 0;
  
  ula_ouput out_data;
  out_data.ula_result  = 0;
  out_data.pred_result = 0;
  
  int32_t res = 0;
  
  //ula source multiplexer
  (src_sel == 0) ? (s2 = src2) : (s2 = imm);
      
    switch (ula_func) {
      
      case ALU_IDLE:
	return out_data;
	
      case ALU_ADD:
	out_data.ula_result = s1 + s2; 	
	return out_data;
	
      case ALU_SUB:	
	out_data.ula_result = s2 - s1; 	
	
	file << "SUB: " << s2 << " - " << s1 << " : " << out_data.ula_result << endl;
	return out_data;
		  
      case ALU_SHL:
	out_data.ula_result = s1 << s2;
	return out_data;
	
      case ALU_SHR:
	out_data.ula_result = s1 >> s2; 	
	return out_data;
	  
      case ALU_SHRU:
	out_data.ula_result = (uint32_t)s1 >> s2;	
	return out_data;
	
      case ALU_SH1ADD:
      case ALU_SH2ADD:
      case ALU_SH3ADD:
      case ALU_SH4ADD:

      case ALU_AND:
	out_data.ula_result = s1 & s2;	
	return out_data;
	  
      case ALU_ANDC:
	  break;

      case ALU_OR:
	out_data.ula_result = s1 | s2;	
	return out_data;
	
      case ALU_ORC:
	  break;

      case ALU_XOR:
	out_data.ula_result = s1 ^ s2;	
	return out_data;
	

      case ALU_MAX:
	  break;
      case ALU_MAXU:
	  break;
      case ALU_MIN:
	  break;
      case ALU_MINU:
	  break;

      case ALU_SXTB:
	  break;
      case ALU_SXTH:
	  break;
      case ALU_ZXTB:
	  break;
      case ALU_ZXTH:
	  break;

      case ALU_ADDCG:
	 
// 	cout << "src1: " << src1 << endl;
// 	cout << "src2: " << src2 << endl;
// 	cout << "scond " << scond << endl;
// 	
	res = (int32_t) src1 + src2 + scond;
// 	cout << "res: " << res << endl;
	
	
	data64   = src1 + src2 + scond;
	out_data.ula_result = (uint32_t)data64;
	
	//overflow as VHDL
	//a >= 0 and b >= 0 and sum < 0 ? 1 : 0
	//or a < 0 and b < 0 and sum >= 0 ? 1 : 0
	// output is: a + b + cin
	
	if ((src1 >= 0 && src2 >= 0 && res < 0) || (src1 < 0 && src2 < 0 && res >= 0))
	  out_data.pred_result = 1;
	else
	  out_data.pred_result = 0;	
	
// 	cout << "pred: " <<  out_data.pred_result << endl;
	
	return out_data;
		
      case ALU_SUBCG:
	
//  	cout << "src1: " << src1 << endl;
//  	cout << "src2: " << src2 << endl;
//  	cout << "scond " << scond << endl;
		
	//overflow as VHDL
	//a >= 0 and b < 0 and sum < 0 ? 1 : 0
	//or a < 0 and b >= 0 and sum >= 0 ? 1 : 0
	// output is: a - b + cin - 1
	//res = (int32_t) src2 + src1 + scond - 1;
	res = (int32_t) src1 + src2 + scond - 1;
	
	//data64   = src2 - src1 + scond - 1;  //as in VHDL lpm_add_sub megafunction
	data64   = src1 - src2 + scond - 1;  //as in VHDL lpm_add_sub megafunction
	out_data.ula_result = (uint32_t)data64;
	
	if ((src1 >= 0 && src2 < 0 && res < 0) || (src1 < 0 && src2 >= 0 && res >= 0))
	  out_data.pred_result = 1;
	else
	  out_data.pred_result = 0;	
	
	return out_data;

    //-- compare functions
      case ALU_CMPEQ:

	out_data.ula_result = s1 == s2;	
	out_data.pred_result = s1 == s2;
	return out_data;
	
      case ALU_CMPGE:
	out_data.ula_result = s1 >= s2;	
	out_data.pred_result = s1 >= s2;;
	return out_data;
	
      case ALU_CMPGEU:
	out_data.ula_result = (uint32_t)s1 >= (uint32_t)s2;	
	out_data.pred_result = (uint32_t)s1 >= (uint32_t)s2;
	return out_data;
		
	  
      case ALU_CMPGT:
	
	out_data.ula_result = s1 > s2;	
	out_data.pred_result = s1 > s2;
	return out_data;
	
		
      case ALU_CMPGTU:
	out_data.ula_result = (uint32_t)s1 > (uint32_t)s2;	
	out_data.pred_result = (uint32_t)s1 > (uint32_t)s2;
	return out_data;
		
      case ALU_CMPLE:
	out_data.ula_result = s1 <= s2;
	out_data.pred_result = s1 <= s2;
	return out_data;
	    
      case ALU_CMPLEU:
	out_data.ula_result = (uint32_t)s1 <= (uint32_t)s2;	
	out_data.pred_result = (uint32_t)s1 <= (uint32_t)s2;
	return out_data;
	  
      
      case ALU_CMPLT:	
	out_data.ula_result = s1 < s2;
	out_data.pred_result = s1 < s2;
	return out_data;
	
      case ALU_CMPLTU:
	  break;
      
      case ALU_CMPNE:
	out_data.ula_result = s1 != s2;
	out_data.pred_result = s1 != s2;
	return out_data;
	
      case ALU_NANDL:
	  break;
      case ALU_NORL:
	  break;
     
      case ALU_ORL:
	out_data.ula_result = s1 | s2;
	out_data.pred_result = s1 | s2;
	return out_data;
      
      case ALU_ANDL:
	  break;

	  //-- selects
      case ALU_SLCT:
	
// 	cout << "src1: " << src1 << endl;
// 	cout << "src2: " << src2 << endl;
// 	cout << "scond " << scond << endl;
// 	
	
	if (scond == 1)
	  out_data.ula_result = s1;
	else
	  out_data.ula_result = s2;
	
	return out_data;
	  
      case ALU_SLCTF:
	if (scond == 0)
	  out_data.ula_result = s1;
	else
	  out_data.ula_result = s2;
	
	return out_data;
	
      case ALU_MULL:
	data64 = ((int64_t)s1 * s2);// & 0x00000000FFFFFFFF;
	
	out_data.ula_result = (int32_t)data64;
	
	//file << "ALU_MULL: s1: " << hex << s1 << " s2: " << s2 << " diff: " << hex << data64 << endl;
	
	
	return out_data;

      case ALU_MULL64H:
	data64 = (int64_t)s1 * s2;	
	out_data.ula_result = (data64 >> 32);	
	return out_data;  
	
      case ALU_MULL64HU:
	data64 = s1 * s2;
	
	out_data.ula_result = data64 >> 32;	
	return out_data;  
	
	  break;
      case ALU_DIVQ:
	out_data.ula_result = s1 / s2;
	
// 	file << "ALU_DIVQ: s1: " <<  hex << s1 << " s2: " << s2 << " diff: " << hex << out_data.ula_result << endl;
// 	file << "ALU_DIVR: s1: " <<  dec << s1 << " s2: " << s2 << " diff: " << dec <<  s1 % s2 << endl;
	
	
	return out_data;  	  
      case ALU_DIVR:
	  break;
      case ALU_DIVQU:
	  break;
      case ALU_DIVRU:
	out_data.ula_result = (uint32_t)s1 % (uint32_t)s2;
	return out_data;  
	
      default:
	  break;

    }


}

