-------------------------------------------------------
-- Design Name : User Pakage
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.cpu_typedef_package.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
    
package alu_functions is
	constant ALU_IDLE		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000000";
	constant ALU_ADD		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000001";
	constant ALU_SUB		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000010";	
	constant ALU_SHL		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000011";	
	constant ALU_SHR		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000100";	
	constant ALU_SHRU			: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000101";	
	constant ALU_SH1ADD	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000110";
	constant ALU_SH2ADD	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "000111";
	constant ALU_SH3ADD	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001000";
	constant ALU_SH4ADD	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001001";
	
	constant ALU_AND		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001010";
	constant ALU_ANDC	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001011";
	
	constant ALU_OR		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001100";
	constant ALU_ORC		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001101";
	
	constant ALU_XOR		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001110";
	
	constant ALU_MAX		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "001111";
	constant ALU_MAXU	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010000";
	constant ALU_MIN		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010001";
	constant ALU_MINU	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010010";
	
	constant	ALU_SXTB	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010011";
	constant	ALU_SXTH	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010100";
	constant	ALU_ZXTB	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010101";
	constant	ALU_ZXTH	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010110";
	
	constant	ALU_ADDCG	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "010111";	-- LSB must be 1
	constant	ALU_SUBCG	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "111110";	-- LSB must be 0
	
	
	-- compare functions
	constant ALU_CMPEQ 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011000";
	constant ALU_CMPGE 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011001";
	constant ALU_CMPGEU	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011010";
	constant ALU_CMPGT 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011011";
	constant ALU_CMPGTU 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011100";
	constant ALU_CMPLE 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011101";
	constant ALU_CMPLEU 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011110";
	constant ALU_CMPLT 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "011111";
	constant ALU_CMPLTU 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "100000";
	constant ALU_CMPNE 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "100001";
	constant ALU_NANDL 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "100010";
	constant ALU_NORL 	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "100011";
	constant ALU_ORL 		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "100100";
	constant ALU_ANDL		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "100101";
	
	-- selects
	constant ALU_SLCT		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "100111";
	constant ALU_SLCTF	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) 	  := "101000";
	
	-- mul
	constant ALU_MULL				: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "101001";
	constant ALU_MULL64H		: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "101010";
	constant ALU_MULL64HU	: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "101011";
	constant ALU_DIVQ				: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "101111";
	constant ALU_DIVR				: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "110000";
	constant ALU_DIVQU			: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "110001";
	constant ALU_DIVRU				: std_logic_vector (ALU_FUN_SIZE-1 downto 0) := "110010";
	
		
	-- wrappers of unsigned operations
	-- use ieee.std_logic_unsigned.all only
	-- signed operations are done in base alu component
	function SHRU(a : word_t; b : word_t) return word_t;
	function MAXU(a : word_t; b : word_t) return word_t;
	function MINU(a : word_t; b : word_t) return word_t;
	function CMPGEU(a: word_t; b: word_t) return boolean;
	function CMPGTU(a: word_t; b: word_t) return boolean;
	function CMPLEU(a: word_t; b: word_t) return boolean;
	function CMPLTU(a: word_t; b: word_t) return boolean; 

	
end;

package body alu_functions is

	function SHRU(a : word_t; b : word_t) return word_t is					
	begin
		return SHR(a, b(4 downto 0));	
	end SHRU;
	
	function MAXU(a : word_t; b : word_t) return word_t is					
	begin
		if a > b then
			return a;
		else
			return b;
		end if;	
	end MAXU;
	
	function MINU(a : word_t; b : word_t) return word_t is					
	begin
		if a < b then
			return a;
		else
			return b;
		end if;	
	end MINU;
	
	function CMPGEU(a : word_t; b : word_t) return boolean is					
	begin
		return a >= b;
	end CMPGEU;
	
	function CMPGTU(a : word_t; b : word_t) return boolean is					
	begin
		return a > b;
	end CMPGTU;

	function CMPLEU(a : word_t; b : word_t) return boolean is					
	begin
		return a <= b;
	end CMPLEU;
	
	function CMPLTU(a : word_t; b : word_t) return boolean is					
	begin
		return a < b;
	end CMPLTU;
	 
end package body;


		
