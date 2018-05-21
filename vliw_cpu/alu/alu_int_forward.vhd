library IEEE;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;
use work.alu_functions.all;

entity alu_int_forward is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	
	-- cycle that need forward
	rd_ctrl		: in t_ctrl;
	
	-- destination registers
	wb_addr_reg		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en		: in std_logic;
		
	func   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
   
	carry_in		 : in std_logic;
	src1_in		 : in word_t;
	src2_in		 : in word_t;
				
	alu_out		: out t_alu_val
		
	);
end alu_int_forward;


architecture rtl of alu_int_forward is


	component add_carry port
	(
		cin			: IN STD_LOGIC ;
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
	
	signal alu_val : t_alu_val;	
begin
		
--	add_carry_1: add_carry port map 
--   (
--		cin => carry_in,
--		dataa => src1_in,
--		datab => src2_in, 
--		cout  => carry_out,
--		result => add_carry_val	
--	);	
--	
--	mul_1: mul port map
--	(
--		dataa	=> src1_in,
--		datab	=> src2_in,
--		result   => mul_result	
--	);
				
		
	calc: process (clk, reset, func, src1_in, src2_in, wb_reg_w_en, wb_addr_reg, rd_ctrl, alu_val)	
		variable s1 : word_t;
		variable s2 : word_t;
	
	begin
		if reset = '1' then			
			alu_val.alu_val 	<=  (alu_val.alu_val'range => '0');
			alu_val.carry_cmp <= '0';
		else			
			if rising_edge(clk) and func /= "000000" then				
				
				--alu_val.carry_cmp <= '0';
				
				if wb_addr_reg = rd_ctrl.src_1_reg and wb_reg_w_en = '1' then
					s1 := alu_val.alu_val;				
				else
					s1 := src1_in;				
				end if;
			
--				if ex_ctrl_0.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_0.reg_w_en = '1' then
--					s2 := alu_val.alu_val;
--				else
					s2 := src2_in;
--				end if;				
				
				
				case func is
					when ALU_ADD => 
						alu_val.alu_val <= s1 +s2;
					when ALU_SUB =>
						alu_val.alu_val <= s1 - s2;
					when ALU_SHL => 
						alu_val.alu_val <= SHL(s1, s2(4 downto 0));
					when ALU_SHR => 
						alu_val.alu_val <= SHR(s1, s2(4 downto 0));						
					when ALU_SHRU =>
						-- look in alu_functions
						alu_val.alu_val <= SHRU(s1, s2);
					when ALU_SH1ADD =>
--						alu_val.alu_val <= SHL(s1, "001") + s2;
--					when ALU_SH2ADD =>
--						alu_val.alu_val <= SHL(s1, "010") + s2;
--					when ALU_SH3ADD =>
--						alu_val.alu_val <= SHL(s1, "011") + s2;
--					when ALU_SH4ADD =>
--						alu_val.alu_val <= SHL(s1, "100") + s2;
					when ALU_AND =>
						alu_val.alu_val <= s1 and s2;
					when ALU_ANDC =>
						alu_val.alu_val <= (not s1) and s2;
					when ALU_OR =>
						alu_val.alu_val <= s1 or s2;
					when ALU_ORC =>
						alu_val.alu_val <= (not s1) or s2;
					when ALU_XOR =>
						alu_val.alu_val <= s1 xor s2;
						
					when ALU_MAX =>
						if s1 > s2 then
							alu_val.alu_val <= s1;
						else
							alu_val.alu_val <= s2;
						end if;
						
					when ALU_MAXU =>
						alu_val.alu_val <= MAXU(s1, s2);
					
					when ALU_MIN =>
						if s1 < s2 then
							alu_val.alu_val <= s1;
						else
							alu_val.alu_val <= s2;
						end if;
						
					when ALU_MINU =>
						alu_val.alu_val <= MINU(s1, s2);
					
					when ALU_SXTB =>
						if s1(7) = '1' then
							alu_val.alu_val <= x"FFFFFF" & s1(7 downto 0);
						else
							alu_val.alu_val <= s1;
						end if;
					
					when ALU_SXTH =>
						if s1(15) = '1' then
							alu_val.alu_val <= x"FFFF" & s1(15 downto 0);
						else
							alu_val.alu_val <= s1;
						end if;
					
					when ALU_ZXTB =>
						alu_val.alu_val <= x"000000" & s1(7 downto 0);
					
					when ALU_ZXTH =>
						alu_val.alu_val <= x"0000" & s1(15 downto 0);
											
					when ALU_ADDCG => 
						alu_val.alu_val <= add_carry_val;
						alu_val.carry_cmp <= carry_out;						
					
					when ALU_CMPEQ  => 
						
						if s1 = s2 then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;
						
					when ALU_CMPGE  => 
						
						if s1 >= s2 then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPGEU  => 
					
						if CMPGEU(s1,s2) then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;	
					
					
					when ALU_CMPGT  => 
					
						if s1 > s2 then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPGTU  => 
						if CMPGTU(s1,s2) then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;	
					
					when ALU_CMPLE  => 
					
						if s1 <= s2 then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPLEU  => 
						
						if CMPLEU(s1,s2) then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;	
					
					when ALU_CMPLT  => 
					
						if s1 < s2 then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;
					
					when ALU_CMPLTU  => 
					
						if CMPLTU(s1,s2) then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;	
					
					when ALU_CMPNE  => 
					
						if s1 /= s2 then
							alu_val.alu_val	 	<= x"00000001";
							alu_val.carry_cmp 	<= '1';
						else
							alu_val.alu_val 		<= x"00000000";
							alu_val.carry_cmp 	<= '0';
						end if;
					
					when ALU_ANDL  => 
						
						alu_val.alu_val 		<= "0000000000000000000000000000000" & (s1(0) and s2(0));
						alu_val.carry_cmp 	<= s1(0) and s2(0);
					
					when ALU_NANDL  => 
						
						alu_val.alu_val 		<= "0000000000000000000000000000000" & (s1(0) nand s2(0));
						alu_val.carry_cmp 	<= s1(0) nand s2(0);
										
					when ALU_NORL  => 	
						alu_val.alu_val 		<= "0000000000000000000000000000000" & (s1(0) nor s2(0));
						alu_val.carry_cmp 	<= s1(0) nor s2(0);
				
					when ALU_ORL  => 	
						alu_val.alu_val 		<= "0000000000000000000000000000000" & (s1(0) or s2(0));
						alu_val.carry_cmp 	<= s1(0) or s2(0);				
					
					
					when ALU_SLCT => 
						alu_val.carry_cmp 	<= '0';
						
						if carry_in = '1' then
							alu_val.alu_val 		<= s1;							
						else
							alu_val.alu_val 		<= s2;
						end if;
						
					when ALU_SLCTF => 
						alu_val.carry_cmp 	<= '0';
						
						if carry_in = '0' then
							alu_val.alu_val 		<= s1;							
						else
							alu_val.alu_val 		<= s2;
						end if;	
					
					when others =>
						
				end case;					
			end if;	
		end if;	
	end process;
	
	alu_out <= alu_val;

end rtl;
