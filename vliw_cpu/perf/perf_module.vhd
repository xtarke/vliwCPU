--------------------------------------------------------------------------------
--  VLIW-RT CPU - Performance monitoring entity
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

entity perf_module is
port (
	clk    				  : in std_logic;	
	reset				  : in std_logic;
	
	dep_stall		  : in std_logic;	-- current interlock dependecy detection	
	delay_dep	  : in std_logic;	-- true when ex stall happens with a dep_stall
	ex_stall			  : in std_logic;	-- execution stage dependecy
	
	instructions   : out word_t;
			
	slot_0_in  : in word_t	
	
	);
end perf_module;


architecture rtl of perf_module is
	signal nop_reset_0 : std_logic;	
	
	signal ins_counter : word_t;
begin

	instructions <= ins_counter;

	--auto disable/enable
	process (slot_0_in)
	begin
		if (slot_0_in = x"0000000") then
			nop_reset_0 <= '1';
		else
			nop_reset_0 <= '0';
		end if;	
	end process;	
	
	read_slot: process (clk, nop_reset_0, reset)
	begin
		if reset = '1' then
			ins_counter <= (others => '0');
		else
			if rising_edge(clk) then
				
				if nop_reset_0 = '0' and dep_stall	= '0'  and ex_stall = '0' and delay_dep = '0' then
					ins_counter <= ins_counter + 1;				
				end if;
				
			end if;
		end if;
	end process;
end architecture;
