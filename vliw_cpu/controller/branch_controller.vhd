--------------------------------------------------------------------------------
--  VLIW-RT CPU - Branch controller entity (singal and address generation)           
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
--
--
-- This file uses Altera libraries subjected to Altera licenses
-- See altera-ip folder for more information

library IEEE;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;
use work.opcodes.all;

entity branch_controller is
port (
	clk    	: in std_logic;	
	reset  : in std_logic;
		
   -- normal control flow instructions
	slot_0_in		 : in word_t;
	reg_addr 		 : in word_t;
	
	-- branch prediction instuctions
	slot_1_in		 : in word_t;
	slot_2_in		 : in word_t;
	slot_3_in		 : in word_t;
	
	dep_stall		 : in std_logic;
	ex_stall			 : in std_logic;
	delay_dep		 : in std_logic;	-- true when ex stall happens with a dep_stall
	
	pc					: in pc_t;
	pred_value 		: in std_logic;
	
	branch_en		: out std_logic;	
	branch_addr		: out pc_t;

	goto_en			: out std_logic;
	goto_addr		: out pc_t;
	
	preld_en			: out std_logic;
	preload_addr	: out pc_t;
	
	jump_reg_en 	: out std_logic
	
	);
end branch_controller;


architecture rtl of branch_controller is

	component pc_adder
	PORT
	(
		clken		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (22 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (22 DOWNTO 0);
		result	: OUT STD_LOGIC_VECTOR (22 DOWNTO 0)
	);
	end component;

	-- internal register signals
	signal branch_ins	: std_logic;	
	signal br_true		: std_logic;
	signal br_false	: std_logic;
	
	signal addr_sel : std_logic;
	signal imm_branch_addr : word_t;
	
	signal reg_add_rst	: std_logic;
	
	signal counter : word_t;
	
	signal branch_en_s : std_logic;

	signal pc_adder_br_clk_en : std_logic;
	signal pc_adder_goto_clk_en : std_logic;
	
	signal pc_offset_br: pc_t;
	signal pc_offset_goto: pc_t;
	
	signal pc_adder_pred_clk_en : std_logic;
	signal pc_offset_pred_0 : pc_t;
	signal pc_offset_pred_1 : pc_t;
	signal pc_offset_pred_2 : pc_t;
	signal pc_offset_pred_3 : pc_t;
	
	signal preload_addr_sel : std_logic_vector(1 downto 0);
	
begin	

	-- two registed adders are neccessary when br is folowed by a goto
	adder_br : pc_adder port map(
		clken	=> pc_adder_br_clk_en,
		clock => clk,
		dataa => slot_0_in(BTARG_END downto BTARG_INI),
		datab => pc,
		result => pc_offset_br
	);
	
	adder_goto: pc_adder port map(
		clken	=> pc_adder_goto_clk_en,
		clock => clk,
		dataa => slot_0_in(BTARG_END downto BTARG_INI),
		datab => pc,
		result => pc_offset_goto
	);
	
	goto_addr <= pc_offset_goto;	
	branch_addr <= pc_offset_br;
	
	--- prediction addresses
	adder_pred_0 : pc_adder port map(
		clken	=> pc_adder_pred_clk_en,
		clock => clk,
		dataa => slot_0_in(BTARG_END downto BTARG_INI),
		datab => pc,
		result => pc_offset_pred_0
	);
	
	adder_pred_1 : pc_adder port map(
		clken	=> pc_adder_pred_clk_en,
		clock => clk,
		dataa => slot_1_in(BTARG_END downto BTARG_INI),
		datab => pc,
		result => pc_offset_pred_1
	);
	
	adder_pred_2 : pc_adder port map(
		clken	=> pc_adder_pred_clk_en,
		clock => clk,
		dataa => slot_2_in(BTARG_END downto BTARG_INI),
		datab => pc,
		result => pc_offset_pred_2
	);
	
	adder_pred_3 : pc_adder port map(
		clken	=> pc_adder_pred_clk_en,
		clock => clk,
		dataa => slot_3_in(BTARG_END downto BTARG_INI),
		datab => pc,
		result => pc_offset_pred_3
	);
	
		
	process (clk, reset, dep_stall, ex_stall, delay_dep, slot_0_in, reg_addr, pred_value)
	begin
		if reset = '1' then
			imm_branch_addr	<= (imm_branch_addr'range => '0');
			addr_sel <= '0';	
			goto_en <= '0';
			pc_adder_goto_clk_en <= '1';
			pc_adder_br_clk_en <= '1';
			jump_reg_en <= '0';
			branch_ins <= '0';	
			--branch_en <= '0';
	
		else
			if rising_edge(clk) and dep_stall = '0'  and ex_stall = '0' and delay_dep = '0' then
			
				branch_ins <= '0';	
				br_true		<= '0';
				br_false		<= '0';
				goto_en  <= '0';
				pc_adder_goto_clk_en <= '1';
				pc_adder_br_clk_en <= '1';
				jump_reg_en <= '0';
				--branch_en <= '0';
					
				if slot_0_in(INS_FORMAT_END downto INS_FORMAT_INI) = "11" then
				
				-- if control flow is a br/brf
					if slot_0_in(CTRFL_SELC) = '1' then							
							--branch_en <= '0';
							
							branch_ins <= '1';
							
							-- br if true
							if slot_0_in(CTRFL_BR_SELC) = '0' then
								--branch_en	<= '1';
								pc_adder_br_clk_en	<= '0';								
								br_true <= '1';
							
							end if;
							
							-- br if false
							if slot_0_in(CTRFL_BR_SELC) = '1' then
								--branch_en	<= '1';
								pc_adder_br_clk_en	<= '0';								
								br_false <= '1';
															
							end if;
										
					-- else it is a call/goto instruction
					else							
							-- prevent execution of branch prediction instructions as call/goto
							if slot_0_in(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_CALL or
								slot_0_in(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_GOTO then
														
								-- call or goto absolute address
								if slot_0_in(CTRFL_REG_IMM_SELL) = '0' then	
									pc_adder_goto_clk_en	<= '0';
									goto_en					<= '1';																						
							
								-- call or goto $lr address							
								else									
										jump_reg_en <= '1';
										
								end if;
							end if;
					end if;
				end if;
			end if;
		end if;	
	end process;
	
	
	process (clk, reset, pred_value, delay_dep, br_false, br_true, branch_ins)
	begin
		if reset = '1' then
			branch_en_s <= '0';	
		else
			--if falling_edge(clk)  then
			--if rising_edge(clk)  then
					branch_en_s <= branch_ins and ((not(br_true) and br_false and not(pred_value)) or (br_true and not(br_false) and pred_value));			
			--end if;
		end if;	
	end process;
	
	branch_en <= branch_en_s;	
	
	
	--- branch prediction instruction decoding: preload
	process (clk, reset, dep_stall, ex_stall, delay_dep, slot_0_in, slot_1_in, slot_2_in, slot_3_in)
	begin
		if reset = '1' then
			pc_adder_pred_clk_en <= '0';
			preload_addr_sel <= "00";
			preld_en <= '0';
		else
			if rising_edge(clk) and dep_stall = '0'  and ex_stall = '0' and delay_dep = '0' then
				
				pc_adder_pred_clk_en <= '1';
				preload_addr_sel		<= "00";
				preld_en	<= '0';
			
				if slot_0_in(INS_FORMAT_END downto INS_FORMAT_INI) = "11" then									
					if slot_0_in(CTRFL_SELC) = '0' then							
							-- prevent execution of branch prediction instructions as call/goto
							if slot_0_in(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_PRED then								
								pc_adder_pred_clk_en <= '0';
								preload_addr_sel		<= "00";
								preld_en <= '1';
							end if;							
					end if;
				end if;
					
				if slot_1_in(INS_FORMAT_END downto INS_FORMAT_INI) = "11" then									
					if slot_1_in(CTRFL_SELC) = '0' then							
							-- prevent execution of branch prediction instructions as call/goto
							if slot_1_in(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_PRED then
								pc_adder_pred_clk_en <= '0';
								preload_addr_sel		<= "01";
								preld_en <= '1';																
							end if;							
					end if;
				end if;
				
				if slot_2_in(INS_FORMAT_END downto INS_FORMAT_INI) = "11" then									
					if slot_2_in(CTRFL_SELC) = '0' then							
							-- prevent execution of branch prediction instructions as call/goto
							if slot_2_in(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_PRED then
								pc_adder_pred_clk_en <= '0';
								preload_addr_sel		<= "10";
								preld_en <= '1';
							end if;
					end if;							
				end if;
				
				if slot_3_in(INS_FORMAT_END downto INS_FORMAT_INI) = "11" then									
					if slot_3_in(CTRFL_SELC) = '0' then							
							-- prevent execution of branch prediction instructions as call/goto
							if slot_3_in(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_PRED then
								pc_adder_pred_clk_en <= '0';
								preload_addr_sel		<= "11";
								preld_en <= '1';
							end if;
					end if;							
				end if;
			end if;
		end if;	
	end process;
	
	-- preload select
	process (preload_addr_sel, pc_offset_pred_0, pc_offset_pred_1, pc_offset_pred_2, pc_offset_pred_3)
	begin
		
		case preload_addr_sel is
			when "00" => preload_addr <= pc_offset_pred_0;
			when "01" => preload_addr <= pc_offset_pred_1;
			when "10" => preload_addr <= pc_offset_pred_2;
			when "11" => preload_addr <= pc_offset_pred_3;
			when others =>			
		end case;
		
	end process;
	
	
end rtl;



