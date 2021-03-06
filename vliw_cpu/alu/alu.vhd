library IEEE;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;
use work.alu_functions.all;

entity alu is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	
	func   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
   
	carry_in		 : in std_logic;
	src1_in		 : in word_t;
	src2_in		 : in word_t;
				
	alu_out		: out t_alu_val
		
	);
end alu;


architecture rtl of alu is


	component add_carry port
	(
		add_sub	: IN STD_LOGIC ;
		cin					: IN STD_LOGIC ;
		dataa			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		cout			: OUT STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component add_carry;

	
	component mul port
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
	end component mul;

	signal enable : std_logic;
	signal opcode : std_logic_vector(OPCODE_SIZE-1 downto 0);
	
	signal add_carry_val	:	word_t;
	signal carry_out		:  std_logic;
	
	signal mul_result  :  std_logic_vector(2*WORD_SIZE-1 downto 0);
	
begin
		
	add_carry_0: add_carry port map 
   (
		add_sub => func(0),
		cin => carry_in,
		dataa => src1_in,	
		datab => src2_in,
		cout  => carry_out,
		result => add_carry_val	
	);
	
--	mul_1: mul port map
--	(
--		dataa	=> src1_in,
--		datab	=> src2_in,
--		result   => mul_result	
--	);
				
		
	process (clk, reset, func, src1_in, src2_in)		
	begin
		if reset = '1' then			
			alu_out.alu_val 	<=  (alu_out.alu_val'range => '0');
			alu_out.carry_cmp <= '0';
		else
			if rising_edge(clk) then				
				
				--alu_out.carry_cmp <= '0';
				
				case func is
					when ALU_ADD => 
						alu_out.alu_val <= add_carry_val;
					when ALU_SUB =>
						alu_out.alu_val <= add_carry_val;
					when ALU_SHL => 
						alu_out.alu_val <= SHL(src1_in, src2_in(4 downto 0));
					when ALU_SHR => 
						alu_out.alu_val <= SHR(src1_in, src2_in(4 downto 0));						
					when ALU_SHRU =>
						-- look in alu_functions
						alu_out.alu_val <= SHRU(src1_in, src2_in);
--					when ALU_SH1ADD =>
--						alu_out.alu_val <= SHL(src1_in, "001") + src2_in;
--					when ALU_SH2ADD =>
--						alu_out.alu_val <= SHL(src1_in, "010") + src2_in;
--					when ALU_SH3ADD =>
--						alu_out.alu_val <= SHL(src1_in, "011") + src2_in;
--					when ALU_SH4ADD =>
--						alu_out.alu_val <= SHL(src1_in, "100") + src2_in;
					when ALU_AND =>
						alu_out.alu_val <= src1_in and src2_in;
					when ALU_ANDC =>
						alu_out.alu_val <= (not src1_in) and src2_in;
					when ALU_OR =>
						alu_out.alu_val <= src1_in or src2_in;
					when ALU_ORC =>
						alu_out.alu_val <= (not src1_in) or src2_in;
					when ALU_XOR =>
						alu_out.alu_val <= src1_in xor src2_in;
						
					when ALU_MAX =>
						if src1_in > src2_in then
							alu_out.alu_val <= src1_in;
						else
							alu_out.alu_val <= src2_in;
						end if;
						
					when ALU_MAXU =>
						alu_out.alu_val <= MAXU(src1_in, src2_in);
					
					when ALU_MIN =>
						if src1_in < src2_in then
							alu_out.alu_val <= src1_in;
						else
							alu_out.alu_val <= src2_in;
						end if;
						
					when ALU_MINU =>
						alu_out.alu_val <= MINU(src1_in, src2_in);
					
					when ALU_SXTB =>
						if src1_in(7) = '1' then
							alu_out.alu_val <= x"FFFFFF" & src1_in(7 downto 0);
						else
							alu_out.alu_val <= src1_in;
						end if;
					
					when ALU_SXTH =>
						if src1_in(15) = '1' then
							alu_out.alu_val <= x"FFFF" & src1_in(15 downto 0);
						else
							alu_out.alu_val <= src1_in;
						end if;
					
					when ALU_ZXTB =>
						alu_out.alu_val <= x"000000" & src1_in(7 downto 0);
					
					when ALU_ZXTH =>
						alu_out.alu_val <= x"0000" & src1_in(15 downto 0);
											
					when ALU_ADDCG => 
						alu_out.alu_val <= add_carry_val;
						alu_out.carry_cmp <= carry_out;						
					
					when ALU_CMPEQ  => 
						
						if src1_in = src2_in then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;
						
					when ALU_CMPGE  => 
						
						if src1_in >= src2_in then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPGEU  => 
					
						if CMPGEU(src1_in,src2_in) then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;	
					
					
					when ALU_CMPGT  => 
					
						if src1_in > src2_in then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPGTU  => 
						if CMPGTU(src1_in,src2_in) then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;	
					
					when ALU_CMPLE  => 
					
						if src1_in <= src2_in then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPLEU  => 
						
						if CMPLEU(src1_in,src2_in) then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;	
					
					when ALU_CMPLT  => 
					
						if src1_in < src2_in then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPLTU  => 
					
						if CMPLTU(src1_in,src2_in) then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;	
					
					when ALU_CMPNE  => 
					
						if src1_in /= src2_in then
							alu_out.alu_val	 	<= x"00000001";
							alu_out.carry_cmp 	<= '1';
						else
							alu_out.alu_val 		<= x"00000000";
							alu_out.carry_cmp 	<= '0';
						end if;
					
					when ALU_ANDL  => 
						
						alu_out.alu_val 		<= "0000000000000000000000000000000" & (src1_in(0) and src2_in(0));
						alu_out.carry_cmp 	<= src1_in(0) and src2_in(0);
					
					when ALU_NANDL  => 
						
						alu_out.alu_val 		<= "0000000000000000000000000000000" & (src1_in(0) nand src2_in(0));
						alu_out.carry_cmp 	<= src1_in(0) nand src2_in(0);
										
					when ALU_NORL  => 	
						alu_out.alu_val 		<= "0000000000000000000000000000000" & (src1_in(0) nor src2_in(0));
						alu_out.carry_cmp 	<= src1_in(0) nor src2_in(0);
				
					when ALU_ORL  => 	
						alu_out.alu_val 		<= "0000000000000000000000000000000" & (src1_in(0) or src2_in(0));
						alu_out.carry_cmp 	<= src1_in(0) or src2_in(0);				
					
					
					when ALU_SLCT => 
						alu_out.carry_cmp 	<= '0';
						
						if carry_in = '1' then
							alu_out.alu_val 		<= src1_in;							
						else
							alu_out.alu_val 		<= src2_in;
						end if;
						
					when ALU_SLCTF => 
						alu_out.carry_cmp 	<= '0';
						
						if carry_in = '0' then
							alu_out.alu_val 		<= src1_in;							
						else
							alu_out.alu_val 		<= src2_in;
						end if;	
	
--					when ALU_MUL =>
--						alu_out.alu_val 	<= mul_result(WORD_SIZE-1 downto 0);
					
					
					when others =>
						
						
				end case;					
			end if;	
		end if;	
	end process;

end rtl;
