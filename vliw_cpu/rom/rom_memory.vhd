--------------------------------------------------------------------------------
--  VLIW-RT CPU - Instruction memory top entity
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
-- This file uses Altera libraries subjected to Altera licenses
-- See altera-ip folder for more information

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

entity rom_memory is 
	port (
	  -- inputs:
	  address 		: IN STD_LOGIC_VECTOR (DATA_ADDR_SIZE-1 DOWNTO 0);
	  read				: in std_logic;
	  byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	  chipselect 	: IN STD_LOGIC;
	  clk 					: IN STD_LOGIC;
	  clken 				: IN STD_LOGIC;
	  reset 				: IN STD_LOGIC;
	  reset_req 	: IN STD_LOGIC;
	  
	
	  -- outputs:
	  readdata 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	  waitrequest : out std_logic
);
end entity rom_memory;

architecture rtl of rom_memory is

	component code_ram
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (INS_ADDR_SIZE-1 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			rden		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;

	type mem_state_type is (IDLE, READ_M, DONE);
	signal mem_state : mem_state_type;

	signal d_read : std_logic;
	signal d_mask: std_logic;
	
			
	signal  chip_en_reg : std_logic;	
	
	signal rom_data : word_t;
	
begin

	---FS_ADDR <= address(21 downto 2);
	
	do_clk_mem_acc_state: process (clk, reset, mem_state)
	begin
		if reset = '1'  then
			mem_state <= IDLE;			
		else
			if rising_edge (clk) then
				case mem_state is
					when IDLE =>
						
						if chipselect = '1' then
							mem_state <= READ_M;											
						end if;				
										
					when READ_M =>
						mem_state <= DONE;
						
					when DONE => 
						mem_state <= IDLE;
				
				end case;		
			end if;		
		end if;	
	end process;
	
	do_clk_mem_acc_state_output: process (mem_state, chipselect,  byteenable, address)
	begin	
		waitrequest <= '0';
		d_read			 <= '0';
				
		case mem_state is
						
			when IDLE =>			
			
				if chipselect = '1' then					
					waitrequest 	<= '1';
					d_read		  	 <= '1';
				end if;
				
			
			when READ_M =>
				
				d_mask			 <= '1';
				waitrequest 	<= '1';
							
				
			when DONE => 		
				
			
			
			end case;
	end process;	
	
 
	 
	 process (d_mask, byteenable, rom_data)
	 begin
		
		readdata <= rom_data;
		
		if d_mask = '1' then
						
			case byteenable is
				
				when "0000" =>				
			
				when "0001" => 
					readdata <= x"000000" & rom_data(7 downto 0);  
				
				when "0010" =>
					readdata <=  x"000000" & rom_data(15 downto 8);
				
				when "0100" => 
					readdata <= x"000000" & rom_data(23 downto 16);
				
				when "1000" => 
					readdata <= x"000000" & rom_data(31 downto 24); 
				
				when "1100" => 
					readdata <= x"0000" & rom_data(31 downto 16); 
				
				when "0011" =>
					readdata <= x"0000" & rom_data(15 downto 0); 
				
				when "1111" =>						
					readdata <= rom_data;
					
				when others =>
			end case;
				
		end if;	 
	 
	 end process;
	 
	rom_1:  code_ram port map	
	(
		address		=>  address(INS_ADDR_SIZE+1 DOWNTO 2),
		clock			=> clk,
		rden				=> d_read,
		q						=> rom_data
	);
	
end rtl;