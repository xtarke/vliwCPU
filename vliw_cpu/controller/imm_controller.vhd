--------------------------------------------------------------------------------
--  VLIW-RT CPU - Immediate generator entity
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

entity imm_controller is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
		
   slot_0_in : in word_t;
	slot_1_in : in word_t;
	slot_2_in : in word_t;
	slot_3_in : in word_t;
			
	imm_0_out		 : out word_t;
	imm_1_out		 : out word_t;
	imm_2_out		 : out word_t;
	imm_3_out		 : out word_t
		
	);
end imm_controller;


architecture rtl of imm_controller is

--	signal nop_reset	  : std_logic;
--	signal ins_format_0 : std_logic_vector(INS_FORMAT_SIZE-1 downto 0);
--	signal ins_format_1 : std_logic_vector(INS_FORMAT_SIZE-1 downto 0);
--	signal ins_format_2 : std_logic_vector(INS_FORMAT_SIZE-1 downto 0);
--	signal ins_format_3 : std_logic_vector(INS_FORMAT_SIZE-1 downto 0);
	
begin	
	
--	ins_format_0	<= slot_0_in(INS_FORMAT_END downto INS_FORMAT_INI);
--	ins_format_1	<= slot_1_in(INS_FORMAT_END downto INS_FORMAT_INI);
--	ins_format_2	<= slot_2_in(INS_FORMAT_END downto INS_FORMAT_INI);
--	ins_format_3	<= slot_3_in(INS_FORMAT_END downto INS_FORMAT_INI);
		
	
	process (clk, reset, slot_0_in, slot_1_in, slot_2_in ,slot_3_in)
	begin
		if reset = '1' then
			imm_0_out	<= (imm_0_out'range => '0');
			imm_1_out	<= (imm_1_out'range => '0');
			imm_2_out	<= (imm_2_out'range => '0');
			imm_3_out	<= (imm_3_out'range => '0');
		else
			if rising_edge(clk) then 				
				imm_0_out	<= (imm_0_out'range => '0');
				imm_1_out	<= (imm_1_out'range => '0');
				imm_2_out	<= (imm_2_out'range => '0');
				imm_3_out	<= (imm_3_out'range => '0');
		
				if  slot_0_in(IMMEDIATE_END) = '1'  then
					imm_0_out <= "11111111111111111111111" & slot_0_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				else
					imm_0_out <= "00000000000000000000000" & slot_0_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				end if;
						
				-- verify if there is a long immediate instrunction in slot 1 (IMML)
				if slot_1_in(29 downto 23) = "0101010" then
					imm_0_out	<= slot_1_in(L_IMM_END downto L_IMM_INI) & slot_0_in(IMMEDIATE_END downto IMMEDIATE_INI);
				end if;				
					
				-------------------------------------------------------------------
						
				if  slot_1_in(IMMEDIATE_END) = '1'  then
					imm_1_out <= "11111111111111111111111" & slot_1_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				else
					imm_1_out <= "00000000000000000000000" & slot_1_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				end if;
										
				-- verify if there is a long immediate instrunction in slot 0 (IMMR)
				if slot_0_in(29 downto 23) = "0101011" then
					imm_1_out	<= slot_0_in(L_IMM_END downto L_IMM_INI) & slot_1_in(IMMEDIATE_END downto IMMEDIATE_INI);
				end if;			
				
				-- verify if there is a long immediate instrunction in slot 1 (IMML)
				if slot_2_in(29 downto 23) = "0101010" then
					imm_1_out	<= slot_2_in(L_IMM_END downto L_IMM_INI) & slot_1_in(IMMEDIATE_END downto IMMEDIATE_INI);
				end if;						
							
				-------------------------------------------------------------------
							
				if  slot_2_in(IMMEDIATE_END) = '1'  then
					imm_2_out <= "11111111111111111111111" & slot_2_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				else
					imm_2_out <= "00000000000000000000000" & slot_2_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				end if;
				
				-- verify if there is a long immediate instrunction in slot 1 (IMMR)
				if slot_1_in(29 downto 23) = "0101011" then
					imm_2_out	<= slot_1_in(L_IMM_END downto L_IMM_INI) & slot_2_in(IMMEDIATE_END downto IMMEDIATE_INI);
				end if;			
				
				-- verify if there is a long immediate instrunction in slot 3 (IMML)
				if slot_3_in(29 downto 23) = "0101010" then
					imm_2_out	<= slot_3_in(L_IMM_END downto L_IMM_INI) & slot_2_in(IMMEDIATE_END downto IMMEDIATE_INI);
				end if;				
						
				-------------------------------------------------------------------	
				
				if  slot_3_in(IMMEDIATE_END) = '1'  then
					imm_3_out <= "11111111111111111111111" & slot_3_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				else
					imm_3_out <= "00000000000000000000000" & slot_3_in(IMMEDIATE_END downto IMMEDIATE_INI);	
				end if;
				
				-- verify if there is a long immediate instrunction in slot 1 (IMMR)
				if slot_2_in(29 downto 23) = "0101011" then
					imm_3_out	<= slot_2_in(L_IMM_END downto L_IMM_INI) & slot_3_in(IMMEDIATE_END downto IMMEDIATE_INI);
				end if;			
	
			end if;	
		end if;	
	end process;

end rtl;
