--------------------------------------------------------------------------------
--  VLIW-RT CPU - Operation decoder entity
--------------------------------------------------------------------------------
--
-- Copyright (c) 2016, Renan Augusto Starke <xtarke@gmail.com>
-- 
-- Departamento de Automação e Sistemas - DAS (Automation and Systems Department)
-- Universidade Federal de Santa Catarina - UFSC (Federal University of Santa Catarina)
-- Florianópolis, Brasil (Brazil)
--
-- This file is part of VLIW-RT CPU.

-- VLIW-RT CPU is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- VLIW-RT CPU is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with VLIW-RT CPU.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;
use work.opcodes.all;
use work.alu_functions.all;

entity controller is
port (
	clk    				  : in std_logic;	
	reset				  : in std_logic;
	
	dep_stall		  : in std_logic;	-- current interlock dependecy detection	
	delay_dep	  : in std_logic;	-- true when ex stall happens with a dep_stall
	ex_stall			  : in std_logic;	-- execution stage dependecy
	
	-- performance monitoring
	alu_ops 				: out word_t;		-- format = "00"
	special_ops		: out word_t;		-- format = "01"	
	mem_ops			: out word_t;		-- format = "10"
	branche_ops : out word_t;		-- format = "11"
	
   slot_in  : in word_t;	
		
	ctrl   : out t_ctrl		
	);
end controller;


architecture rtl of controller is

	signal nop_reset : std_logic;
	signal enable : std_logic;
	signal opcode : std_logic_vector(OPCODE_SIZE-1 downto 0);
	signal cmp_opcode : std_logic_vector(CMP_OPCODE_SIZE-1 downto 0);
	signal ins_format : std_logic_vector(INS_FORMAT_SIZE-1 downto 0);
	
	-- operations accouting
	signal alus 			: word_t;		-- format = "00"
	signal special		: word_t;		-- format = "01"	
	signal mems		: word_t;		-- format = "10"
	signal branches : word_t;		-- format = "11"
	
begin

	alu_ops <= alus;
	special_ops	<= special;
	mem_ops	<= mems;
	branche_ops	<= branches;	

	opcode 				<= slot_in(OPCODE_END downto OPCODE_INI);
	cmp_opcode		<= slot_in(CMP_OPCODE_END downto CMP_OPCODE_INI);
	ins_format			<= slot_in(INS_FORMAT_END	downto INS_FORMAT_INI);

	--auto disable/enable
	process (slot_in)
	begin
		if (slot_in = x"0000000") then
			nop_reset <= '1';
		else
			nop_reset <= '0';
		end if;	
	end process;	
	
	
	read_slot: process (clk, nop_reset, reset, enable, slot_in, opcode)
	begin
		if reset = '1' then
			ctrl.alu_func  <= (ctrl.alu_func'range => '0');
			ctrl.alu_mux	<= '0';
			ctrl.branch_en <= '0';
			ctrl.reg_w_en 	<= '0';
			ctrl.dest_reg  <= (ctrl.dest_reg'range => '0');
			ctrl.src_1_reg	<= (ctrl.src_1_reg'range => '0');
			ctrl.src_2_reg <= (ctrl.src_2_reg'range => '0');
			
			ctrl.pred_reg_w_en	<= '0';
			ctrl.b_dest				<= (ctrl.b_dest'range => '0');
			ctrl.scond           <= (ctrl.scond'range => '0');			
			
			ctrl.mem_wr	<= '0';
			ctrl.mem_rd		<= '0'; 
			ctrl.mem_byteen  <= "00";
			ctrl.mem_sig_ex  <= '0';
			
			ctrl.mul_div     <= '0';
			ctrl.mul_div_sel <= '0';
			
			ctrl.halt	<= '0';
			ctrl.f_pred <= '0';
			
			ctrl.par_on  <= '0';
			ctrl.par_off <= '0';
			
			-- performance operations accouting
			alus 			 <= (others => '0');
			special	 <= (others => '0');
			mems		 <= (others => '0');
			branches  <= (others => '0');
			
		else
			if rising_edge(clk) then --and enable = '1' then				
							
				ctrl.alu_func  <= (ctrl.alu_func'range => '0');
				ctrl.alu_mux	<= '0';
				ctrl.branch_en <= '0';
				ctrl.reg_w_en 	<= '0';
				ctrl.dest_reg  <= (ctrl.dest_reg'range => '0');
								
				ctrl.src_1_reg	<= (ctrl.src_1_reg'range => '0');
				ctrl.src_2_reg <= (ctrl.src_2_reg'range => '0');
				
				ctrl.pred_reg_w_en	<= '0';
				ctrl.b_dest				<= (ctrl.b_dest'range => '0');
				ctrl.scond           <= (ctrl.scond'range => '0');
				ctrl.mul_div    		 <= '0';
				ctrl.mul_div_sel  <= '0';
				
				ctrl.mem_wr	<= '0';
				ctrl.mem_rd		<= '0';
				ctrl.mem_byteen <= "00";
				ctrl.mem_sig_ex  <= '0';
				
				ctrl.par_on  <= '0';
				ctrl.par_off <= '0';
				
					
				if nop_reset = '0' and dep_stall	= '0'  and ex_stall = '0' and delay_dep = '0' then
				
					ctrl.src_1_reg		<= slot_in(REG_SRC1_END downto REG_SRC1_INI);
					ctrl.src_2_reg		<= slot_in(REG_SRC2_END downto REG_SRC2_INI);
					ctrl.scond        <= slot_in(SCOND_END downto SCOND_INI);
					
					ctrl.f_pred <= slot_in(30);
				
					case ins_format is
					
						-- ALU type
						when "00"	=> 
							
							-- disable counter on nop operations 
							if slot_in /= x"88000000" and slot_in /= x"8000000" then
								alus <= alus + 1;
							end if;
							
							-- INT3R, INT3l na Monadic instructions							
							if (slot_in(M0) = '0') then	
												
								ctrl.dest_reg  <= slot_in(REG_DEST_END downto REG_DEST_INI);
								
								if (slot_in(REG_DEST_END downto REG_DEST_INI) /= "000000") then 
									ctrl.reg_w_en 	<= '1';
								else
									ctrl.reg_w_en 	<= '0';
								end if;
									
								-- read from immediate
								if slot_in(M1) = '1' then							
									ctrl.dest_reg  <= slot_in(IDEST_END downto IDEST_INI);
									ctrl.alu_mux	<= '1';
									
									if (slot_in(IDEST_END downto IDEST_INI) /= "000000") then 
										ctrl.reg_w_en 	<= '1';
									else
										ctrl.reg_w_en 	<= '0';
									end if;								
									
								end if;								
			
								-- 25 downto 21
								case opcode is
									when ADD_OP =>	ctrl.alu_func <= ALU_ADD;			
																
									when SUB_OP =>	ctrl.alu_func <= ALU_SUB;									
																												
									when SHL_OP => ctrl.alu_func <= ALU_SHL;	
									
									when SHR_OP => ctrl.alu_func <= ALU_SHR;	
									
									when SHRU_OP => ctrl.alu_func <= ALU_SHRU;
									
									when SH1ADD_OP => ctrl.alu_func <= ALU_SH1ADD;
									
									when SH2ADD_OP => ctrl.alu_func <= ALU_SH2ADD;
									
									when SH3ADD_OP => ctrl.alu_func <= ALU_SH3ADD;
									
									when SH4ADD_OP => ctrl.alu_func <= ALU_SH4ADD;
									
									when AND_OP => ctrl.alu_func <= ALU_AND;
									
									when ANDC_OP => ctrl.alu_func <= ALU_ANDC;
									
									when OR_OP => ctrl.alu_func <= ALU_OR;
									
									when ORC_OP => ctrl.alu_func <= ALU_ORC;
									
									when XOR_OP => ctrl.alu_func <= ALU_XOR;
									
									when MAX_OP => ctrl.alu_func <= ALU_MAX;
									
									-- implementar imediato sem sinal, alu OK com wrappers
									when MAXU_OP => ctrl.alu_func <= ALU_MAXU;
									
									when MIN_OP => ctrl.alu_func <= ALU_MIN;
									
									-- implementar imediato sem sinal, alu OK  com wrappers
									when MINU_OP => ctrl.alu_func <= ALU_MINU;
									
									when MULL_OP => 
										ctrl.alu_func 	<= ALU_MULL;
										ctrl.mul_div     <= '1';
																		
									when DIVR_OP	=>
										ctrl.alu_func	<= ALU_DIVR;
										ctrl.mul_div		<= '1';
										ctrl.mul_div_sel  <= '1';																
							
									when DIVQ_OP	=>
										ctrl.alu_func	<= ALU_DIVQ;
										ctrl.mul_div		<= '1';
										ctrl.mul_div_sel  <= '1';
									
									when DIVRU_OP	=>
										ctrl.alu_func	<= ALU_DIVRU;
										ctrl.mul_div		<= '1';
										ctrl.mul_div_sel  <= '1';
							
									when DIVQU_OP	=>
										ctrl.alu_func	<= ALU_DIVQU;
										ctrl.mul_div		<= '1';
										ctrl.mul_div_sel  <= '1';
																			
									-- monadic instructions, sign exten byte, half word, ...
									when MONADIC_OP =>
										
										case slot_in(IMMEDIATE_END downto IMMEDIATE_INI) is
											when SXTB_OP => ctrl.alu_func <= ALU_SXTB;
									
											when SXTH_OP => ctrl.alu_func <= ALU_SXTH;
											
											when ZXTB_OP => ctrl.alu_func <= ALU_ZXTB;
									
											when ZXTH_OP => ctrl.alu_func <= ALU_ZXTH;											
											
											when others =>
										
											
										end case;									
																
							
									when others =>									
							end case;
											
						-- Compare instructions: slot_in(M0) = '1'
						else 
							-- read from immediate
							if slot_in(M1) = '1' then							
								
								-- selects immediate as ALU source
								ctrl.alu_mux	<= '1';
									
								-- select destination: predicated register or normal register
								if slot_in(CMP_DEST_SEL) = '1' then
									ctrl.b_dest				<= slot_in(IBDEST_END downto IBDEST_INI);
									ctrl.pred_reg_w_en	<= '1';
								else
									ctrl.dest_reg  <= slot_in(IDEST_END downto IDEST_INI);
									
									if (slot_in(IDEST_END downto IDEST_INI) /= "000000") then 
										ctrl.reg_w_en 	<= '1';
									else
										ctrl.reg_w_en 	<= '0';
									end if;	
									
								end if;								
							
							--  read from register file
							else								
								-- select destination: predicated register or normal register
								if slot_in(CMP_DEST_SEL) = '1' then
									ctrl.b_dest				<= slot_in(BDEST_END downto BDEST_INI);
									ctrl.pred_reg_w_en	<= '1';
								else
									ctrl.dest_reg  <= slot_in(REG_DEST_END downto REG_DEST_INI);
									
									if (slot_in(REG_DEST_END downto REG_DEST_INI) /= "000000") then 
										ctrl.reg_w_en 	<= '1';
									else
										ctrl.reg_w_en 	<= '0';
									end if;	
									
								end if;
							end if;		
							
							-- program ALU	
							case cmp_opcode is
								
								when CMPEQ_OP => ctrl.alu_func <= ALU_CMPEQ;
								
								when CMPNE_OP => ctrl.alu_func <= ALU_CMPNE;
								
								when CMPGE_OP => ctrl.alu_func <= ALU_CMPGE;
								
								when CMPGEU_OP => ctrl.alu_func <= ALU_CMPGEU;
								
								when CMPGT_OP => ctrl.alu_func <= ALU_CMPGT;
								
								when CMPGTU_OP => ctrl.alu_func <= ALU_CMPGTU;
								
								when CMPLE_OP => ctrl.alu_func <= ALU_CMPLE;
								
								when CMPLEU_OP => ctrl.alu_func <= ALU_CMPLEU;
								
								when CMPLT_OP => ctrl.alu_func <= ALU_CMPLT;
								
								when CMPLTU_OP => ctrl.alu_func <= ALU_CMPLTU;											
								
								when ANDL_OP => ctrl.alu_func <= ALU_ANDL;
								
								when NANDL_OP => ctrl.alu_func <= ALU_NANDL;
								
								when NORL_OP => ctrl.alu_func <= ALU_NORL;
								
								when ORL_OP => ctrl.alu_func <= ALU_ORL;	
		
							   when MUL64H_OP => 								
										ctrl.alu_func 	<= ALU_MULL64H;
										ctrl.mul_div     <= '1';
										
								when MUL64HU_OP =>
										ctrl.alu_func 					<= ALU_MULL64HU;
										ctrl.pred_reg_w_en	<= '0';
										ctrl.dest_reg  				<= slot_in(REG_DEST_END downto REG_DEST_INI);
																				
										if (slot_in(REG_DEST_END downto REG_DEST_INI) /= "000000") then 
											ctrl.mul_div     				<= '1';
											ctrl.reg_w_en 	<= '1';
										else
											ctrl.mul_div     	<= '0';										
											ctrl.reg_w_en 	<= '0';
										end if;	
																
								when others => 								
							end case;						
						end if;						
						
						
						-- Long immediate, select, add carry
						when "01"	=>
						
								special	 <= 	special	 + 1;
																			
							if slot_in(M1) = '0' then
																												
								case slot_in(26 downto 24) is
									
									when SLCT_OP => 										
										ctrl.dest_reg  	<= slot_in(REG_DEST_END downto REG_DEST_INI);
										ctrl.alu_func 		<= ALU_SLCT;
										ctrl.reg_w_en 		<= '1';				
									
									when SLCTF_OP => 
										ctrl.dest_reg  		<= slot_in(REG_DEST_END downto REG_DEST_INI);
										ctrl.alu_func 			<= ALU_SLCTF;
										ctrl.reg_w_en 		<= '1';				
									
									when ADDCG_OP => 
										ctrl.pred_reg_w_en	<= '1';
										ctrl.b_dest				<= slot_in(BDEST_END downto BDEST_INI);
										ctrl.dest_reg  		<= slot_in(REG_DEST_END downto REG_DEST_INI);
										ctrl.alu_func 			<= ALU_ADDCG;
										ctrl.reg_w_en 		<= '1';				
									
									when SUBCG_OP => 
										ctrl.pred_reg_w_en	<= '1';
										ctrl.b_dest				<= slot_in(BDEST_END downto BDEST_INI);
										ctrl.dest_reg  		<= slot_in(REG_DEST_END downto REG_DEST_INI);
										ctrl.alu_func 			<= ALU_SUBCG;
										ctrl.reg_w_en 			<= '1';	
								
									when PAR_ON =>
										ctrl.par_on  <= '1';									
									
									when PAR_OFF => 
										ctrl.par_off <= '1';
									
									when DIVS_OP  =>
										ctrl.reg_w_en 		<= '0';				
									
									when IMM_OP =>
										ctrl.reg_w_en 		<= '0';				
									
									when others =>	
										ctrl.reg_w_en 		<= '0';				
					
								end case;
								
								if (slot_in(REG_DEST_END downto REG_DEST_INI) = "000000") then 							
									ctrl.reg_w_en 	<= '0';
								end if;
	
							else
								-- select with immediates
								
								if (slot_in(27 downto 21) = BREAK_OP ) then 
									ctrl.halt	<= '1';																		
								else
									-- selects immediate as ALU source
									ctrl.alu_mux	<= '1';
								
									case slot_in(26 downto 24) is									
										when SLCT_OP => 										
											ctrl.dest_reg  		<= slot_in(IDEST_END downto IDEST_INI);
											ctrl.alu_func 			<= ALU_SLCT;
											ctrl.reg_w_en 		<= '1';								
										when SLCTF_OP => 
											ctrl.dest_reg  		<= slot_in(IDEST_END downto IDEST_INI);
											ctrl.alu_func 			<= ALU_SLCTF;
											ctrl.reg_w_en 		<= '1';
										when others =>
											ctrl.reg_w_en 		<= '0';
								
										end case;
									
									if (slot_in(IDEST_END downto IDEST_INI) = "000000") then 								
										ctrl.reg_w_en 	<= '0';
									end if;									
									
								end if;							
							end if;				
						
						-- MEM type
						when "10"	=>
							
							mems <= mems + 1;
							
							case slot_in(MEMI_END downto MEMI_INI) is
								when LDW_OP	=>
									ctrl.reg_w_en 	<= '1';
									ctrl.mem_rd			<= '1';
									ctrl.dest_reg  	<= slot_in(IDEST_END downto IDEST_INI);
									ctrl.mem_byteen <= "00";
									
								when LDH_OP => 
									ctrl.reg_w_en 	<= '1';
									ctrl.mem_rd			<= '1';
									ctrl.dest_reg  	<= slot_in(IDEST_END downto IDEST_INI);
									ctrl.mem_byteen <= "01";
									ctrl.mem_sig_ex  <= '1';
								
								when LDHU_OP => 
									ctrl.reg_w_en 	<= '1';
									ctrl.mem_rd			<= '1';
									ctrl.dest_reg  	<= slot_in(IDEST_END downto IDEST_INI);
									ctrl.mem_byteen <= "01";									
									
								when LDB_OP => 
									ctrl.reg_w_en 	<= '1';
									ctrl.mem_rd			<= '1';
									ctrl.dest_reg  	<= slot_in(IDEST_END downto IDEST_INI);
									ctrl.mem_byteen <= "10";
									ctrl.mem_sig_ex  <= '1';		
								
								when LDBU_OP => 
									ctrl.reg_w_en 	<= '1';
									ctrl.mem_rd			<= '1';
									ctrl.dest_reg  	<= slot_in(IDEST_END downto IDEST_INI);
									ctrl.mem_byteen <= "10";
															
								when STW_OP => 
									ctrl.mem_wr			<= '1';
									ctrl.mem_byteen <= "00";							
									
								when STH_OP => 
									ctrl.mem_wr			<= '1';
									ctrl.mem_byteen <= "01";
								
								when STB_OP =>
									ctrl.mem_wr			<= '1';
									ctrl.mem_byteen <= "10";
								
								when others =>			
						end case;
						
						
						-- control flow type
						when "11"	=>
						
							branches <= branches + 1;
							
							ctrl.branch_en <= '1';
							
							-- goto / call instruction
							if slot_in(CTRFL_SELC) = '0' then
							
								-- call must store pc
								if slot_in(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_CALL then
									
									-- ALU sources are controlled by ex_buffer when dest_reg = "111111" (63) (Link register)
									-- this technic uses same datapath to write LR to the register bank
									-- register bank R0 MUST be zero									
									ctrl.alu_mux	<= '0';
									ctrl.alu_func  <= ALU_ADD;
									ctrl.dest_reg  <= "111111";	
									ctrl.reg_w_en 	<= '1';
									-- call doest not read
									ctrl.src_1_reg	<= (ctrl.src_1_reg'range => '0');
									ctrl.src_2_reg <= (ctrl.src_2_reg'range => '0');
	
								end if;
								
								-- goto only jumps
								-- addresses are controlled by branch unit							
							
--							-- predicated branch instruction
--							else
--								--BR
--								if slot_in(CTRFL_BR_SELC) = '0' then
--									br_true	<= '1';								
--								-- BRF
--								else
--									br_false	<= '1';								
--								end if;
								
							end if;							
						when others =>
						
					end case;
						
				end if;					
			end if;	
		end if;	
	end process;

end rtl;
