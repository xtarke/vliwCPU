--------------------------------------------------------------------------------
--  VLIW-RT CPU - General-purpose register file entity
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
--
-- This modules uses Long Live Table for multi-ported memories, see:
-- LaForest, C., & Steffan, J. (2010). Efficient multi-ported memories for FPGAs. 
-- Proceedings of the ACM/SIGDA 18th International Symposium on Field Programmable Gate Arrays, 41. 
-- http://doi.org/10.1145/1723112.1723122


-- Insert library and use clauses
LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

entity reg_file_lvt IS
port (
	clk     : in std_logic;
	reset	  : in std_logic;
	
	port0_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port1_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port2_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port3_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);

	port0_w_data 		: in word_t;
	port1_w_data 		: in word_t;
	port2_w_data 		: in word_t;
	port3_w_data 		: in word_t;
	
	port0_w_en 			: in std_logic;
	port1_w_en 			: in std_logic;
	port2_w_en 			: in std_logic;
	port3_w_en 			: in std_logic;
	
	port0_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port0_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port1_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port1_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port2_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port2_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port3_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	port3_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	port0_a_rd 			: out word_t;
	port0_b_rd 			: out word_t;
	port1_a_rd			: out word_t;
	port1_b_rd 			: out word_t;
	port2_a_rd 			: out word_t;
	port2_b_rd 			: out word_t;
	port3_a_rd 			: out word_t;
	port3_b_rd 			: out word_t
	
	);
end entity reg_file_lvt;

architecture rtl of reg_file_lvt is
	
	-- altera dual port BRAM
	component sram_register
	port
	(
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		wraddress		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
	
	component lvt IS
	port (
		clk     : in std_logic;
		reset	  : in std_logic;
		
		port0_w_en 			: in std_logic;
		port1_w_en 			: in std_logic;
		port2_w_en 			: in std_logic;
		port3_w_en 			: in std_logic;
		
		port0_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port1_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port2_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port3_w_addr 		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		
		port0_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port0_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port1_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port1_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port2_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port2_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port3_a_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		port3_b_rd_addr 	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
			
		
		port0_a_rd			: out std_logic_vector(1 downto 0);
		port0_b_rd			: out std_logic_vector(1 downto 0);
		port1_a_rd			: out std_logic_vector(1 downto 0);
		port1_b_rd			: out std_logic_vector(1 downto 0);
		port2_a_rd			: out std_logic_vector(1 downto 0);
		port2_b_rd			: out std_logic_vector(1 downto 0);
		port3_a_rd			: out std_logic_vector(1 downto 0);
		port3_b_rd			: out std_logic_vector(1 downto 0)
	);
	end component;
	
	component rd_mux
	port
	(
		--clock		: IN STD_LOGIC ;
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data3x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
	
	component rd_for_mux
	port
	(
		--clock		: IN STD_LOGIC ;
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data3x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data4x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
	
	-------------------------------------
	-- ram outputs: 
	-- each write port has 8 replicated 
	-- blocks (for earch RF read port)
	
	-- ram <w_port> < rd port> < a / b >
	-- w_port : 0, 1, 2, 3
	-- rd_port: 0, ... 3
	-- rd index: a, b	
	------------------------------------
	
	-- write bank	0 --
	signal ram_0_0_a	: word_t;
	signal ram_0_0_b	: word_t;
	signal ram_0_1_a	: word_t;
	signal ram_0_1_b	: word_t;
	signal ram_0_2_a	: word_t;
	signal ram_0_2_b	: word_t;
	signal ram_0_3_a	: word_t;
	signal ram_0_3_b	: word_t;
	-- write bank	1 --
	signal ram_1_0_a	: word_t;
	signal ram_1_0_b	: word_t;
	signal ram_1_1_a	: word_t;
	signal ram_1_1_b	: word_t;
	signal ram_1_2_a	: word_t;
	signal ram_1_2_b	: word_t;
	signal ram_1_3_a	: word_t;
	signal ram_1_3_b	: word_t;
	-- write bank	2 --
	signal ram_2_0_a	: word_t;
	signal ram_2_0_b	: word_t;
	signal ram_2_1_a	: word_t;
	signal ram_2_1_b	: word_t;
	signal ram_2_2_a	: word_t;
	signal ram_2_2_b	: word_t;
	signal ram_2_3_a	: word_t;
	signal ram_2_3_b	: word_t;
	-- write bank	3 --
	signal ram_3_0_a	: word_t;
	signal ram_3_0_b	: word_t;
	signal ram_3_1_a	: word_t;
	signal ram_3_1_b	: word_t;
	signal ram_3_2_a	: word_t;
	signal ram_3_2_b	: word_t;
	signal ram_3_3_a	: word_t;
	signal ram_3_3_b	: word_t;	
	
	-- lvt output, rd ouputs muxes
	signal lvt_out_0_a : std_logic_vector(1 downto 0);
	signal lvt_out_0_b : std_logic_vector(1 downto 0);
	signal lvt_out_1_a : std_logic_vector(1 downto 0);
	signal lvt_out_1_b : std_logic_vector(1 downto 0);
	signal lvt_out_2_a : std_logic_vector(1 downto 0);
	signal lvt_out_2_b : std_logic_vector(1 downto 0);
	signal lvt_out_3_a : std_logic_vector(1 downto 0);
	signal lvt_out_3_b : std_logic_vector(1 downto 0);
	
	-- forward control
	signal port0_a_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port0_b_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal port1_a_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port1_b_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal port2_a_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port2_b_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal port3_a_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port3_b_rd_addr_reg	: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal p0_a_for_sel_mem	 : std_logic_vector(2 downto 0);
	signal p0_b_for_sel_mem	 : std_logic_vector(2 downto 0);

	signal p1_a_for_sel_mem	 : std_logic_vector(2 downto 0);
	signal p1_b_for_sel_mem	 : std_logic_vector(2 downto 0);
	
	signal p2_a_for_sel_mem	 : std_logic_vector(2 downto 0);
	signal p2_b_for_sel_mem	 : std_logic_vector(2 downto 0);
		
	signal p3_a_for_sel_mem	 : std_logic_vector(2 downto 0);
	signal p3_b_for_sel_mem	 : std_logic_vector(2 downto 0);
	
	signal p0_a_for_sel 		: std_logic_vector(2 downto 0);
	signal p0_b_for_sel 		: std_logic_vector(2 downto 0);
	
	signal p1_a_for_sel 		: std_logic_vector(2 downto 0);
	signal p1_b_for_sel 		: std_logic_vector(2 downto 0);
	
	signal p2_a_for_sel 		: std_logic_vector(2 downto 0);
	signal p2_b_for_sel 		: std_logic_vector(2 downto 0);
	
	signal p3_a_for_sel 		: std_logic_vector(2 downto 0);
	signal p3_b_for_sel 		: std_logic_vector(2 downto 0);
	
	
	signal port0_a_rd_mem : word_t;
	signal port0_b_rd_mem : word_t;
	
	signal port1_a_rd_mem : word_t;
	signal port1_b_rd_mem : word_t;
	
	signal port2_a_rd_mem : word_t;
	signal port2_b_rd_mem : word_t;
	
	signal port3_a_rd_mem : word_t;
	signal port3_b_rd_mem : word_t;
		
	signal port0_w_data_reg	: word_t;
	signal port1_w_data_reg	: word_t;
	signal port2_w_data_reg	: word_t;
	signal port3_w_data_reg	: word_t;
	
	signal port0_a_rd_mem_for : word_t;
	signal port0_b_rd_mem_for : word_t;
	
	signal port1_a_rd_mem_for : word_t;
	signal port1_b_rd_mem_for : word_t;
	
	signal port2_a_rd_mem_for : word_t;
	signal port2_b_rd_mem_for : word_t;
	
	signal port3_a_rd_mem_for : word_t;
	signal port3_b_rd_mem_for : word_t;
	
	
begin
		
	lvt_1: lvt port map (
		clk => clk,
		reset => reset,
		port0_w_en	=> port0_w_en,
		port1_w_en	=> port1_w_en,
		port2_w_en	=> port2_w_en,
		port3_w_en	=> port3_w_en,
				
		port0_w_addr	=> port0_w_addr,
		port1_w_addr	=> port1_w_addr,
		port2_w_addr	=> port2_w_addr,
		port3_w_addr	=> port3_w_addr,
				
		port0_a_rd_addr => port0_a_rd_addr,
		port0_b_rd_addr => port0_b_rd_addr,
		port1_a_rd_addr => port1_a_rd_addr,
		port1_b_rd_addr => port1_b_rd_addr,
		port2_a_rd_addr => port2_a_rd_addr,
		port2_b_rd_addr => port2_b_rd_addr,
		port3_a_rd_addr => port3_a_rd_addr,
		port3_b_rd_addr => port3_b_rd_addr,
							
		port0_a_rd		=> lvt_out_0_a,
		port0_b_rd		=> lvt_out_0_b,
		port1_a_rd		=> lvt_out_1_a,
		port1_b_rd		=> lvt_out_1_b,
		port2_a_rd		=> lvt_out_2_a,
		port2_b_rd		=> lvt_out_2_b,
		port3_a_rd		=> lvt_out_3_a,
		port3_b_rd		=> lvt_out_3_b		
	);
	
	--register addresses and write data  to forward logic
	process (clk, reset, port0_a_rd_addr, port0_b_rd_addr,
						port1_a_rd_addr, port1_b_rd_addr,
						port2_a_rd_addr, port2_b_rd_addr,
						port3_a_rd_addr, port3_b_rd_addr,
						port0_w_data, 
						port1_w_data, 
						port2_w_data, 
						port3_w_data)
	begin
		if reset = '1' then
			port0_a_rd_addr_reg	<= (port0_a_rd_addr_reg'range => '0');
			port0_b_rd_addr_reg	<= (port0_b_rd_addr_reg'range => '0');
			port1_a_rd_addr_reg	<= (port0_a_rd_addr_reg'range => '0');
			port1_b_rd_addr_reg	<= (port0_b_rd_addr_reg'range => '0');
			port2_a_rd_addr_reg	<= (port0_a_rd_addr_reg'range => '0');
			port2_b_rd_addr_reg	<= (port0_b_rd_addr_reg'range => '0');
			port3_a_rd_addr_reg	<= (port0_a_rd_addr_reg'range => '0');
			port3_b_rd_addr_reg	<= (port0_b_rd_addr_reg'range => '0');
			
			
			port0_w_data_reg		<= (port0_w_data_reg'range => '0');
			port1_w_data_reg		<= (port1_w_data_reg'range => '0');
			port2_w_data_reg		<= (port2_w_data_reg'range => '0');
			port3_w_data_reg		<= (port3_w_data_reg'range => '0');
		
		
		else
			if rising_edge(clk) then
				port0_a_rd_addr_reg	<= port0_a_rd_addr;
				port0_b_rd_addr_reg	<= port0_b_rd_addr;
				port1_a_rd_addr_reg	<= port1_a_rd_addr;
				port1_b_rd_addr_reg	<= port1_b_rd_addr;
				port2_a_rd_addr_reg	<= port2_a_rd_addr;
				port2_b_rd_addr_reg	<= port2_b_rd_addr;
				port3_a_rd_addr_reg	<= port3_a_rd_addr;
				port3_b_rd_addr_reg	<= port3_b_rd_addr;
				
				port0_w_data_reg		<= port0_w_data;
				port1_w_data_reg		<= port1_w_data;
				port2_w_data_reg		<= port2_w_data;
				port3_w_data_reg		<= port3_w_data;				
			end if;		
		end if;	
	end process;
	
	
	
	---------WRITE/READ SAME CYCLE FORWARD----------------------
	--
	-- RAM block forward logic: if a read ocurrs in same write
	-- cycle, MK4 blocks outputs old or don't care
	-- 
	-----------------------------------------------------------
		
	--	forward logic: if w addr and rd addr are equal, forward new value
	port0_a_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port0_a_rd_addr)
	begin
		
		if reset = '1' then	
			p0_a_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
		
				p0_a_for_sel_mem	<= "000";
		
				if port0_w_en = '1' and port0_w_addr = port0_a_rd_addr then
					p0_a_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port0_a_rd_addr then
					p0_a_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port0_a_rd_addr then
					p0_a_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port0_a_rd_addr then
					p0_a_for_sel_mem	<= "100";
				end if;
			
			end if;			
		end if;
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port0_b_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port0_b_rd_addr)
	begin
		if reset = '1' then	
			p0_b_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
		
				p0_b_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port0_b_rd_addr then
					p0_b_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port0_b_rd_addr then
					p0_b_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port0_b_rd_addr then
					p0_b_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port0_b_rd_addr then
					p0_b_for_sel_mem	<= "100";
				end if;
			end if;
		end if;
		
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port1_a_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port1_a_rd_addr)
	begin
		if reset = '1' then	
			p1_a_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
		
				p1_a_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port1_a_rd_addr then
					p1_a_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port1_a_rd_addr then
					p1_a_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port1_a_rd_addr then
					p1_a_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port1_a_rd_addr then
					p1_a_for_sel_mem	<= "100";
				end if;
			end if;
		end if;
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port1_b_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port1_b_rd_addr)
	begin
		if reset = '1' then	
			p1_b_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				
				p1_b_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port1_b_rd_addr then
					p1_b_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port1_b_rd_addr then
					p1_b_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port1_b_rd_addr then
					p1_b_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port1_b_rd_addr then
					p1_b_for_sel_mem	<= "100";
				end if;	
			end if;
		end if;
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port2_a_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port2_a_rd_addr)
	begin
		if reset = '1' then	
			p2_a_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				p2_a_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port2_a_rd_addr then
					p2_a_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port2_a_rd_addr then
					p2_a_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port2_a_rd_addr then
					p2_a_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port2_a_rd_addr then
					p2_a_for_sel_mem	<= "100";
				end if;
			end if;
		end if;
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port2_b_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port2_b_rd_addr)
	begin
		if reset = '1' then	
			p2_b_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
		
				p2_b_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port2_b_rd_addr then
					p2_b_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port2_b_rd_addr then
					p2_b_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port2_b_rd_addr then
					p2_b_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port2_b_rd_addr then
					p2_b_for_sel_mem	<= "100";
				end if;	
			end if;
		end if;
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port3_a_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port3_a_rd_addr)
	begin
		if reset = '1' then	
			p3_a_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				p3_a_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port3_a_rd_addr then
					p3_a_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port3_a_rd_addr then
					p3_a_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port3_a_rd_addr then
					p3_a_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port3_a_rd_addr then
					p3_a_for_sel_mem	<= "100";
				end if;
			end if;
		end if;
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port3_b_rd_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port3_b_rd_addr)
	begin
		if reset = '1' then	
			p3_b_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				
				p3_b_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port3_b_rd_addr then
					p3_b_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port3_b_rd_addr then
					p3_b_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port3_b_rd_addr then
					p3_b_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port3_b_rd_addr then
					p3_b_for_sel_mem	<= "100";
				end if;
			end if;
		end if;
	end process;
	
	
	---------------ASYNC FORWARD LOGIC---------------------------
	-- Happens when a read ocurrs one cycle earlier of a write --
	-- address position 					         					  --
	-------------------------------------------------------------
	
	
	--	forward logic: if w addr and rd addr are equal, forward new value
	port0_a_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port0_a_rd_addr_reg)
	begin
		p0_a_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port0_a_rd_addr_reg then
			p0_a_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port0_a_rd_addr_reg then
			p0_a_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port0_a_rd_addr_reg then
			p0_a_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port0_a_rd_addr_reg then
			p0_a_for_sel	<= "100";
		end if;		
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port0_b_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port0_b_rd_addr_reg)
	begin
		p0_b_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port0_b_rd_addr_reg then
			p0_b_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port0_b_rd_addr_reg then
			p0_b_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port0_b_rd_addr_reg then
			p0_b_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port0_b_rd_addr_reg then
			p0_b_for_sel	<= "100";
		end if;		
	end process;
	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port1_a_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port1_a_rd_addr_reg)
	begin
		p1_a_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port1_a_rd_addr_reg then
			p1_a_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port1_a_rd_addr_reg then
			p1_a_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port1_a_rd_addr_reg then
			p1_a_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port1_a_rd_addr_reg then
			p1_a_for_sel	<= "100";
		end if;		
	end process;
--	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port1_b_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port1_b_rd_addr_reg)
	begin
		p1_b_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port1_b_rd_addr_reg then
			p1_b_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port1_b_rd_addr_reg then
			p1_b_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port1_b_rd_addr_reg then
			p1_b_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port1_b_rd_addr_reg then
			p1_b_for_sel	<= "100";
		end if;		
	end process;
--	
	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port2_a_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port2_a_rd_addr_reg)
	begin
		p2_a_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port2_a_rd_addr_reg then
			p2_a_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port2_a_rd_addr_reg then
			p2_a_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port2_a_rd_addr_reg then
			p2_a_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port2_a_rd_addr_reg then
			p2_a_for_sel	<= "100";
		end if;		
	end process;
--	
--	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port2_b_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port2_b_rd_addr_reg)
	begin
		p2_b_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port2_b_rd_addr_reg then
			p2_b_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port2_b_rd_addr_reg then
			p2_b_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port2_b_rd_addr_reg then
			p2_b_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port2_b_rd_addr_reg then
			p2_b_for_sel	<= "100";
		end if;		
	end process;
--	
--	--	-- forward logic: if w addr and rd addr are equal, forward new value
	port3_a_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port3_a_rd_addr_reg)
	begin
		p3_a_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port3_a_rd_addr_reg then
			p3_a_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port3_a_rd_addr_reg then
			p3_a_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port3_a_rd_addr_reg then
			p3_a_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port3_a_rd_addr_reg then
			p3_a_for_sel	<= "100";
		end if;		
	end process;
	
	-- forward logic: if w addr and rd addr are equal, forward new value
	port3_b_rd_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
										port3_b_rd_addr_reg)
	begin
		p3_b_for_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port3_b_rd_addr_reg then
			p3_b_for_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port3_b_rd_addr_reg then
			p3_b_for_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port3_b_rd_addr_reg then
			p3_b_for_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port3_b_rd_addr_reg then
			p3_b_for_sel	<= "100";
		end if;		
	end process;
	
	-----------------
	-- OUPUT MUXES --
	-----------------
		
	mux_for_p0_a: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port0_a_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data_reg,
		sel		=> p0_a_for_sel_mem,
		result	=> port0_a_rd_mem_for
	);	
	
	mux_for_p0_a_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port0_a_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p0_a_for_sel,
		result	=> port0_a_rd
	);	
	
	-----
	
	mux_for_p0_b: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port0_b_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data_reg,
		sel		=> p0_b_for_sel_mem,
		result	=> port0_b_rd_mem_for
	);
	
	mux_for_p0_b_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port0_b_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p0_b_for_sel,
		result	=> port0_b_rd
	);
	
	
	mux_p0_a: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_0_a,
		data1x	=> ram_1_0_a,
		data2x	=> ram_2_0_a,
		data3x	=> ram_3_0_a,
		sel		=> lvt_out_0_a,
		result	=> port0_a_rd_mem
	);
	
	mux_p0_b: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_0_b,
		data1x	=> ram_1_0_b,
		data2x	=> ram_2_0_b,
		data3x	=> ram_3_0_b,
		sel		=> lvt_out_0_b,
		result	=> port0_b_rd_mem
	);
	
	---------------------------------------------------
	
	mux_for_p1_a: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port1_a_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data_reg,
		sel		=> p1_a_for_sel_mem,
		result	=> port1_a_rd_mem_for
	);
	
	mux_for_p1_a_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port1_a_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p1_a_for_sel,
		result	=> port1_a_rd
	);
	
	
	mux_for_p1_b: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port1_b_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data_reg,
		sel		=> p1_b_for_sel_mem,
		result	=> port1_b_rd_mem_for
	);
	
	mux_for_p1_b_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port1_b_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p1_b_for_sel,
		result	=> port1_b_rd
	);
	
	mux_p1_a: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_1_a,
		data1x	=> ram_1_1_a,
		data2x	=> ram_2_1_a,
		data3x	=> ram_3_1_a,
		sel		=> lvt_out_1_a,
		result	=> port1_a_rd_mem
	);	
	
	mux_p1_b: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_1_b,
		data1x	=> ram_1_1_b,
		data2x	=> ram_2_1_b,
		data3x	=> ram_3_1_b,
		sel		=> lvt_out_1_b,
		result	=> port1_b_rd_mem
	);
	
	---------------------------------------------------
	
	mux_for_p2_a: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port2_a_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data_reg,
		sel		=> p2_a_for_sel_mem,
		result	=> port2_a_rd_mem_for
	);
	
	mux_for_p2_a_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port2_a_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p2_a_for_sel,
		result	=> port2_a_rd
	);
	
	mux_for_p2_b: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port2_b_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data_reg,
		sel		=> p2_b_for_sel_mem,
		result	=> port2_b_rd_mem_for
	);
	
	mux_for_p2_b_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port2_b_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p2_b_for_sel,
		result	=> port2_b_rd
	);
	
	
	mux_p2_a: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_2_a,
		data1x	=> ram_1_2_a,
		data2x	=> ram_2_2_a,
		data3x	=> ram_3_2_a,
		sel		=> lvt_out_2_a,
		result	=> port2_a_rd_mem
	);	
	
	mux_p2_b: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_2_b,
		data1x	=> ram_1_2_b,
		data2x	=> ram_2_2_b,
		data3x	=> ram_3_2_b,
		sel		=> lvt_out_2_b,
		result	=> port2_b_rd_mem
	);
	
	
	
	---------------------------------------------------
	mux_for_p3_a: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port3_a_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data_reg,
		sel		=> p3_a_for_sel_mem,
		result	=> port3_a_rd_mem_for
	);
	
	mux_for_p3_a_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port3_a_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p3_a_for_sel,
		result	=> port3_a_rd
	);
	
	mux_for_p3_b: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port3_b_rd_mem,
		data1x	=> port0_w_data_reg,
		data2x	=> port1_w_data_reg,
		data3x	=> port2_w_data_reg,
		data4x	=> port3_w_data,
		sel		=> p3_b_for_sel_mem,
		result	=> port3_b_rd_mem_for
	);
	
	mux_for_p3_b_async: rd_for_mux port map (
		--clock		=> clk,
		data0x	=> port3_b_rd_mem_for,
		data1x	=> port0_w_data,
		data2x	=> port1_w_data,
		data3x	=> port2_w_data,
		data4x	=> port3_w_data,
		sel		=> p3_b_for_sel,
		result	=> port3_b_rd
	);
	
	mux_p3_a: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_3_a,
		data1x	=> ram_1_3_a,
		data2x	=> ram_2_3_a,
		data3x	=> ram_3_3_a,
		sel		=> lvt_out_3_a,
		result	=> port3_a_rd_mem
	);
	
	mux_p3_b: rd_mux port map (
		--clock		=> clk,
		data0x	=> ram_0_3_b,
		data1x	=> ram_1_3_b,
		data2x	=> ram_2_3_b,
		data3x	=> ram_3_3_b,
		sel		=> lvt_out_3_b,
		result	=> port3_b_rd_mem
	);
	
	
	-------------------------------
	--		-- write bank	0 		 --
	-------------------------------
	
	-- port rd 0 a
	ramblk_0_0_a	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port0_a_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_0_a
	);
	-- port rd 0 b
	ramblk_0_0_b	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port0_b_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_0_b
	);
	
	-- port rd 1 a
	ramblk_0_1_a	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port1_a_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_1_a
	);
	-- port rd 1 b
	ramblk_0_1_b	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port1_b_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_1_b
	);
	
		-- port rd 2 a
	ramblk_0_2_a	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port2_a_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_2_a
	);
	-- port rd 2 b
	ramblk_0_2_b	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port2_b_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_2_b
	);
	
		-- port rd 3 a
	ramblk_0_3_a	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port3_a_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_3_a
	);
	-- port rd 3 b
	ramblk_0_3_b	:	sram_register port map(
		
		clock => clk,
		data	=> port0_w_data,
		
		rdaddress => port3_b_rd_addr,
		wraddress => port0_w_addr,
		
		
		wren		 => port0_w_en,
		q			 => ram_0_3_b
	);
	
	-------------------------------
	--		-- write bank	1 		 --
	-------------------------------
	
	-- port rd 0 a
	ramblk_1_0_a	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port0_a_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_0_a
	);
	-- port rd 0 b
	ramblk_1_0_b	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port0_b_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_0_b
	);
	
	-- port rd 1 a
	ramblk_1_1_a	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port1_a_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_1_a
	);
	-- port rd 1 b
	ramblk_1_1_b	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port1_b_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_1_b
	);
	
		-- port rd 2 a
	ramblk_1_2_a	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port2_a_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_2_a
	);
	-- port rd 2 b
	ramblk_1_2_b	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port2_b_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_2_b
	);
	
		-- port rd 3 a
	ramblk_1_3_a	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port3_a_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_3_a
	);
	-- port rd 3 b
	ramblk_1_3_b	:	sram_register port map(
		
		clock => clk,
		data	=> port1_w_data,
		
		rdaddress => port3_b_rd_addr,
		wraddress => port1_w_addr,
		
		
		wren		 => port1_w_en,
		q			 => ram_1_3_b
	);
	
	-------------------------------
	--		-- write bank	2 		 --
	-------------------------------
	
	-- port rd 0 a
	ramblk_2_0_a	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port0_a_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_0_a
	);
	-- port rd 0 b
	ramblk_2_0_b	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port0_b_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_0_b
	);
	
	-- port rd 1 a
	ramblk_2_1_a	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port1_a_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_1_a
	);
	-- port rd 1 b
	ramblk_2_1_b	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port1_b_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_1_b
	);
	
		-- port rd 2 a
	ramblk_2_2_a	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port2_a_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_2_a
	);
	-- port rd 2 b
	ramblk_2_2_b	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port2_b_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_2_b
	);
	
		-- port rd 3 a
	ramblk_2_3_a	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port3_a_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_3_a
	);
	-- port rd 3 b
	ramblk_2_3_b	:	sram_register port map(
		
		clock => clk,
		data	=> port2_w_data,
		
		rdaddress => port3_b_rd_addr,
		wraddress => port2_w_addr,
		
		
		wren		 => port2_w_en,
		q			 => ram_2_3_b
	);
	
	-------------------------------
	--		-- write bank	2 		 --
	-------------------------------
	
	-- port rd 0 a
	ramblk_3_0_a	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port0_a_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_0_a
	);
	-- port rd 0 b
	ramblk_3_0_b	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port0_b_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_0_b
	);
	
	-- port rd 1 a
	ramblk_3_1_a	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port1_a_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_1_a
	);
	-- port rd 1 b
	ramblk_3_1_b	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port1_b_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_1_b
	);
	
		-- port rd 2 a
	ramblk_3_2_a	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port2_a_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_2_a
	);
	-- port rd 2 b
	ramblk_3_2_b	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port2_b_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_2_b
	);
	
		-- port rd 3 a
	ramblk_3_3_a	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port3_a_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_3_a
	);
	-- port rd 3 b
	ramblk_3_3_b	:	sram_register port map(
		
		clock => clk,
		data	=> port3_w_data,
		
		rdaddress => port3_b_rd_addr,
		wraddress => port3_w_addr,
		
		
		wren		 => port3_w_en,
		q			 => ram_3_3_b
	);
	
		

end architecture rtl;