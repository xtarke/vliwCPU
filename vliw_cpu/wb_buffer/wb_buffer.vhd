--------------------------------------------------------------------------------
--  VLIW-RT CPU - Pipeline inter-stage buffer
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

entity wb_buffer is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	stall :in std_logic;
	
	ctrl_in      : in t_ctrl;
	
	mul_div_w_addr_in	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	mul_div_w_en_in		: in std_logic;
  	
	pred_reg_w_addr	:	out std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	pred_reg_w_en		:	out std_logic;	
		
	reg_w_addr	: out std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	reg_w_en		: out std_logic;

	halt					: out std_logic;
		
	wb_mux_sel : out std_logic_vector(1 downto 0)
	
		
	);
end wb_buffer;


architecture rtl of wb_buffer is
begin

		
	process (clk, reset, ctrl_in, stall)
	begin
		if reset = '1' then
			reg_w_addr <= (reg_w_addr'range => '0');
			reg_w_en	  <= '0';
			
			pred_reg_w_addr 	<= (pred_reg_w_addr'range => '0');
			pred_reg_w_en		<= '0';
			halt								<= '0';
			wb_mux_sel				<= "00";
		else
			if rising_edge(clk) and stall = '0' then
												
				reg_w_addr <= ctrl_in.dest_reg;
				reg_w_en	  <= ctrl_in.reg_w_en;-- and (not (ctrl_in.mul_div or ctrl_in.mem_rd));
				
				pred_reg_w_addr <= ctrl_in.b_dest;
				pred_reg_w_en	 <= ctrl_in.pred_reg_w_en;
				
				halt	<= ctrl_in.halt;
				
				if ctrl_in.reg_w_en = '1' then
					wb_mux_sel	<= "00";
				end if;
				
				if ctrl_in.mem_rd = '1' then
					wb_mux_sel	<= "01";
				end if;
	
				if ctrl_in.mul_div = '1' then
					wb_mux_sel <= "10";
				end if;
			
				
			end if;	
		end if;	
	end process;

end rtl;
