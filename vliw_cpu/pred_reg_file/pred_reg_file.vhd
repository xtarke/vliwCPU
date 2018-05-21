--------------------------------------------------------------------------------
--  VLIW-RT CPU - Predicated register file entity
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

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

entity pred_reg_file IS
port (
	clk     : in std_logic;
	reset	  : in std_logic;
	
	port0_w_en 			: in std_logic;
	port1_w_en 			: in std_logic;
	port2_w_en 			: in std_logic;
	port3_w_en 			: in std_logic;
	-- full predication port
	port4_w_en 			: in std_logic;
	
	port0_w_data		: in std_logic;
	port1_w_data		: in std_logic;
	port2_w_data		: in std_logic;
	port3_w_data		: in std_logic;
	-- full predication port
	port4_w_data		: in std_logic;
		
	port0_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	port1_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	port2_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	port3_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	-- full predication port
	port4_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	
	
	port0_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	--port0_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	port1_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	--port1_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	port2_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	--port2_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	port3_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	--port3_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	-- full predication port
	port4_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		
	
	
	port0_a_rd			: out std_logic;
	--port0_b_rd			: out std_logic;
	port1_a_rd			: out std_logic;
	--port1_b_rd			: out std_logic;
	port2_a_rd			: out std_logic;
	--port2_b_rd			: out std_logic;
	port3_a_rd			: out std_logic;
	--port3_b_rd			: out std_logic;
	-- full predication port
	port4_a_rd			: out std_logic

	);
end entity pred_reg_file;


architecture rtl of pred_reg_file is
	component mux_mem
	port
	(
		data0		: IN STD_LOGIC ;
		data1		: IN STD_LOGIC ;
		data2		: IN STD_LOGIC ;
		data3		: IN STD_LOGIC ;
		data4		: IN STD_LOGIC ;
		data5		: IN STD_LOGIC ;
		sel		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		result		: OUT STD_LOGIC 
	);
	end component mux_mem;	
	
	type r_array is array (0 to 7) of std_logic;
	
	function array_init
		return r_array is
		variable result	: r_array;
	begin
		for i in 7 downto 0 loop
			result(i) := '0';
		end loop;
		return result;
	end array_init;
		
	signal registers	: r_array := array_init; 
	
	signal port0_mem	: std_logic;
	signal port1_mem	: std_logic;
	signal port2_mem	: std_logic;
	signal port3_mem	: std_logic;
	signal port4_mem	: std_logic;
	
	signal port0_w_data_reg : std_logic;
	signal port1_w_data_reg : std_logic;
	signal port2_w_data_reg : std_logic;
	signal port3_w_data_reg : std_logic;
	signal port4_w_data_reg : std_logic;
	
	signal port0_rd_addr_reg : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal port1_rd_addr_reg : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal port2_rd_addr_reg : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal port3_rd_addr_reg : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal port4_rd_addr_reg : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	
	
	signal mem_muxed_p0 : std_logic;
	signal p0_for_sel_mem : std_logic_vector(2 downto 0);
	
	signal mem_muxed_p1 : std_logic;
	signal p1_for_sel_mem : std_logic_vector(2 downto 0);
	
	signal mem_muxed_p2 : std_logic;
	signal p2_for_sel_mem : std_logic_vector(2 downto 0);
	
	signal mem_muxed_p3 : std_logic;
	signal p3_for_sel_mem : std_logic_vector(2 downto 0);
	
	signal mem_muxed_p4 : std_logic;
	signal p4_for_sel_mem : std_logic_vector(2 downto 0);
	
	signal p0_out_sel			: std_logic_vector(2 downto 0);
	signal p1_out_sel			: std_logic_vector(2 downto 0);
	signal p2_out_sel			: std_logic_vector(2 downto 0);
	signal p3_out_sel			: std_logic_vector(2 downto 0);
	signal p4_out_sel			: std_logic_vector(2 downto 0);
		
begin

	-- register address and data
	process (clk, reset,
						port0_w_data, port1_w_data, port2_w_data, port3_w_data, port4_w_data,
						port0_a_rd_addr, port1_a_rd_addr, port2_a_rd_addr, port3_a_rd_addr, port4_a_rd_addr)
	begin
		if reset = '1' then
				port0_w_data_reg	<= '0';	
				port1_w_data_reg	<= '0';
				port2_w_data_reg	<= '0';
				port3_w_data_reg	<= '0';
				port4_w_data_reg	<= '0';
				
				port0_rd_addr_reg		<= "000";
				port1_rd_addr_reg		<= "000";
				port2_rd_addr_reg		<= "000";
				port3_rd_addr_reg		<= "000";				
		else
			if rising_edge(clk) then
				port0_w_data_reg	<= port0_w_data;	
				port1_w_data_reg	<= port1_w_data;
				port2_w_data_reg	<= port2_w_data;
				port3_w_data_reg	<= port3_w_data;
				port4_w_data_reg	<= port4_w_data;
				
				port0_rd_addr_reg		<= port0_a_rd_addr;
				port1_rd_addr_reg		<= port1_a_rd_addr;
				port2_rd_addr_reg		<= port2_a_rd_addr;
				port3_rd_addr_reg		<= port3_a_rd_addr;			
				port4_rd_addr_reg		<= port4_a_rd_addr;
			end if;
		end if;
	end process;


	-- read and write to registers
	process (clk, reset, port0_w_addr, port1_w_addr, port2_w_addr, port3_w_addr, port4_w_addr,
						port0_w_en, port1_w_en, port2_w_en, port3_w_en, port4_w_en, 
						port0_w_data, port1_w_data, port2_w_data, port3_w_data, port4_w_data)
	begin
		if reset = '1' then
			port0_mem	<=	'0';
			--port0_b_rd	<=	'0';
			port1_mem	<=	'0';
			--port1_b_rd	<=	'0';
			port2_mem	<=	'0';
			--port2_b_rd	<=	'0';
			port3_mem	<=	'0';
			--port3_b_rd	<=	'0';
			port4_mem	<=	'0';
		else			
			if rising_edge(clk) then			
				if port0_w_en = '1' then									
					registers(conv_integer(port0_w_addr)) <= port0_w_data;
				end if;
				
				if port1_w_en = '1' then
					registers(conv_integer(port1_w_addr)) <= port1_w_data;
					
				end if;
			
				if port2_w_en = '1' then
					registers(conv_integer(port2_w_addr)) <= port2_w_data;
				end if;
			
				if port3_w_en = '1' then
					registers(conv_integer(port3_w_addr)) <= port3_w_data;					
				end if;
				
				if port4_w_en = '1' then
					registers(conv_integer(port4_w_addr)) <= port4_w_data;					
				end if;
		
				port0_mem	<=	registers(conv_integer(port0_a_rd_addr));
				--port0_b_rd	<=	registers(conv_integer(port0_b_rd_addr));
				port1_mem	<=	registers(conv_integer(port1_a_rd_addr));
				--port1_b_rd	<=	registers(conv_integer(port1_b_rd_addr));
				port2_mem	<=	registers(conv_integer(port2_a_rd_addr));
				--port2_b_rd	<=	registers(conv_integer(port2_b_rd_addr));
				port3_mem	<=	registers(conv_integer(port3_a_rd_addr));
				--port3_b_rd	<=	registers(conv_integer(port3_b_rd_addr));
				port4_mem	<=	registers(conv_integer(port4_a_rd_addr));	
			end if;
		end if;
	end process;
	
	
	-- forward logic: if w addr and rd addr are equal, forward new value
	port0_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr,
											port0_a_rd_addr)
	begin
		if reset = '1' then	
			p0_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				
				p0_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port0_a_rd_addr then
					p0_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port0_a_rd_addr then
					p0_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port0_a_rd_addr then
					p0_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port0_a_rd_addr then
					p0_for_sel_mem	<= "100";
				end if;
				
				if port4_w_en = '1' and port4_w_addr = port0_a_rd_addr then
					p0_for_sel_mem	<= "101";
				end if;
			end if;
		end if;
	end process;
	
		-- forward logic: if w addr and rd addr are equal, forward new value
	port0_out_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
										port0_rd_addr_reg)
	begin
		p0_out_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port0_rd_addr_reg then
			p0_out_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port0_rd_addr_reg then
			p0_out_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port0_rd_addr_reg then
			p0_out_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port0_rd_addr_reg then
			p0_out_sel	<= "100";
		end if;

		if port4_w_en = '1' and port4_w_addr = port0_rd_addr_reg then
			p0_out_sel	<= "101";
		end if;
	end process;
	
	mux_mem_p0 : mux_mem port map
	(
		data0		=> port0_mem, 
		data1		=> port0_w_data_reg,
		data2		=> port1_w_data_reg,
		data3		=> port2_w_data_reg,
		data4		=> port3_w_data_reg,
		data5		=> port4_w_data_reg,
		sel				=> p0_for_sel_mem,
		result		=> mem_muxed_p0	
	);
	
	mux_out_p0 : mux_mem port map
	(
		data0		=> mem_muxed_p0, 
		data1		=> port0_w_data,
		data2		=> port1_w_data,
		data3		=> port2_w_data,
		data4		=> port3_w_data,
		data5		=> port4_w_data,
		sel				=> p0_out_sel,
		result		=> port0_a_rd	
	);
	
	
	----------------------------------------------------------------------
	
	-- forward logic: if w addr and rd addr are equal, forward new value
	port1_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
											port1_a_rd_addr)
	begin
		if reset = '1' then	
			p1_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				
				p1_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port1_a_rd_addr then
					p1_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port1_a_rd_addr then
					p1_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port1_a_rd_addr then
					p1_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port1_a_rd_addr then
					p1_for_sel_mem	<= "100";
				end if;
				
				if port4_w_en = '1' and port4_w_addr = port1_a_rd_addr then
					p1_for_sel_mem	<= "101";
				end if;
			end if;
		end if;
	end process;
	
		-- forward logic: if w addr and rd addr are equal, forward new value
	port1_out_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
										port1_rd_addr_reg)
	begin
		p1_out_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port1_rd_addr_reg then
			p1_out_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port1_rd_addr_reg then
			p1_out_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port1_rd_addr_reg then
			p1_out_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port1_rd_addr_reg then
			p1_out_sel	<= "100";
		end if;	
		
		if port4_w_en = '1' and port4_w_addr = port1_rd_addr_reg then
			p1_out_sel	<= "101";
		end if;		
	end process;
	
	mux_mem_p1 : mux_mem port map
	(
		data0		=> port1_mem, 
		data1		=> port0_w_data_reg,
		data2		=> port1_w_data_reg,
		data3		=> port2_w_data_reg,
		data4		=> port3_w_data_reg,
		data5		=> port4_w_data_reg,
		sel				=> p1_for_sel_mem,
		result		=> mem_muxed_p1
	);
	
	mux_out_p1 : mux_mem port map
	(
		data0		=> mem_muxed_p1, 
		data1		=> port0_w_data,
		data2		=> port1_w_data,
		data3		=> port2_w_data,
		data4		=> port3_w_data,
		data5		=> port4_w_data,
		sel				=> p1_out_sel,
		result		=> port1_a_rd	
	);
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- forward logic: if w addr and rd addr are equal, forward new value
	port2_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
											port2_a_rd_addr)
	begin
		if reset = '1' then	
			p2_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				
				p2_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port2_a_rd_addr then
					p2_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port2_a_rd_addr then
					p2_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port2_a_rd_addr then
					p2_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port2_a_rd_addr then
					p2_for_sel_mem	<= "100";
				end if;
				
				if port4_w_en = '1' and port4_w_addr = port2_a_rd_addr then
					p2_for_sel_mem	<= "101";
				end if;
			end if;
		end if;
	end process;
	
		-- forward logic: if w addr and rd addr are equal, forward new value
	port2_out_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
										port2_rd_addr_reg)
	begin
		p2_out_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port2_rd_addr_reg then
			p2_out_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port2_rd_addr_reg then
			p2_out_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port2_rd_addr_reg then
			p2_out_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port2_rd_addr_reg then
			p2_out_sel	<= "100";
		end if;

		if port4_w_en = '1' and port4_w_addr = port2_rd_addr_reg then
			p2_out_sel	<= "101";
		end if;		
	end process;
	
	mux_mem_p2 : mux_mem port map
	(
		data0		=> port2_mem, 
		data1		=> port0_w_data_reg,
		data2		=> port1_w_data_reg,
		data3		=> port2_w_data_reg,
		data4		=> port3_w_data_reg,
		data5		=> port4_w_data_reg,
		sel				=> p2_for_sel_mem,
		result		=> mem_muxed_p2
	);
	
	mux_out_p2 : mux_mem port map
	(
		data0		=> mem_muxed_p2, 
		data1		=> port0_w_data,
		data2		=> port1_w_data,
		data3		=> port2_w_data,
		data4		=> port3_w_data,
		data5		=> port4_w_data,
		sel				=> p2_out_sel,
		result		=> port2_a_rd	
	);
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- forward logic: if w addr and rd addr are equal, forward new value
	port3_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
											port3_a_rd_addr)
	begin
		if reset = '1' then	
			p3_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				
				p3_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port3_a_rd_addr then
					p3_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port3_a_rd_addr then
					p3_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port3_a_rd_addr then
					p3_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port3_a_rd_addr then
					p3_for_sel_mem	<= "100";
				end if;
				
				if port4_w_en = '1' and port4_w_addr = port3_a_rd_addr then
					p3_for_sel_mem	<= "101";
				end if;
				
			end if;
		end if;
	end process;
	
		-- forward logic: if w addr and rd addr are equal, forward new value
	port3_out_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
										port3_rd_addr_reg)
	begin
		p3_out_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port3_rd_addr_reg then
			p3_out_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port3_rd_addr_reg then
			p3_out_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port3_rd_addr_reg then
			p3_out_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port3_rd_addr_reg then
			p3_out_sel	<= "100";
		end if;

		if port4_w_en = '1' and port4_w_addr = port3_rd_addr_reg then
			p3_out_sel	<= "101";
		end if;		
	end process;
	
	mux_mem_p3 : mux_mem port map
	(
		data0		=> port3_mem, 
		data1		=> port0_w_data_reg,
		data2		=> port1_w_data_reg,
		data3		=> port2_w_data_reg,
		data4		=> port3_w_data_reg,
		data5		=> port4_w_data_reg,
		sel				=> p3_for_sel_mem,
		result		=> mem_muxed_p3
	);
	
	mux_out_p3 : mux_mem port map
	(
		data0		=> mem_muxed_p3,
		data1		=> port0_w_data,
		data2		=> port1_w_data,
		data3		=> port2_w_data,
		data4		=> port3_w_data,
		data5		=> port4_w_data,
		sel				=> p3_out_sel,
		result		=> port3_a_rd	
	);
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- forward logic: if w addr and rd addr are equal, forward new value
	port4_mem_forward: process (clk, reset, port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
											port4_a_rd_addr)
	begin
		if reset = '1' then	
			p4_for_sel_mem	<= "000";
		else
			if rising_edge(clk) then
				
				p4_for_sel_mem	<= "000";
				
				if port0_w_en = '1' and port0_w_addr = port4_a_rd_addr then
					p4_for_sel_mem	<= "001";
				end if;
				
				if port1_w_en = '1' and port1_w_addr = port4_a_rd_addr then
					p4_for_sel_mem	<= "010";
				end if;
				
				if port2_w_en = '1' and port2_w_addr = port4_a_rd_addr then
					p4_for_sel_mem	<= "011";
				end if;
				
				if port3_w_en = '1' and port3_w_addr = port4_a_rd_addr then
					p4_for_sel_mem	<= "100";
				end if;
				
				if port4_w_en = '1' and port4_w_addr = port4_a_rd_addr then
					p4_for_sel_mem	<= "101";
				end if;
				
			end if;
		end if;
	end process;
	
		-- forward logic: if w addr and rd addr are equal, forward new value
	port4_out_forward: process (port0_w_en, port0_w_addr, 
											port1_w_en, port1_w_addr, 
											port2_w_en, port2_w_addr, 
											port3_w_en, port3_w_addr, 
											port4_w_en, port4_w_addr, 
										port4_rd_addr_reg)
	begin
		p4_out_sel	<= "000";
		
		if port0_w_en = '1' and port0_w_addr = port4_rd_addr_reg then
			p4_out_sel	<= "001";
		end if;
		
		if port1_w_en = '1' and port1_w_addr = port4_rd_addr_reg then
			p4_out_sel	<= "010";
		end if;
		
		if port2_w_en = '1' and port2_w_addr = port4_rd_addr_reg then
			p4_out_sel	<= "011";
		end if;
		
		if port3_w_en = '1' and port3_w_addr = port4_rd_addr_reg then
			p4_out_sel	<= "100";
		end if;

		if port4_w_en = '1' and port4_w_addr = port4_rd_addr_reg then
			p4_out_sel	<= "101";
		end if;		
	end process;
	
	mux_mem_p4 : mux_mem port map
	(
		data0		=> port4_mem, 
		data1		=> port0_w_data_reg,
		data2		=> port1_w_data_reg,
		data3		=> port2_w_data_reg,
		data4		=> port3_w_data_reg,
		data5		=> port4_w_data_reg,
		sel		=> p4_for_sel_mem,
		result		=> mem_muxed_p4
	);
	
	mux_out_p4 : mux_mem port map
	(
		data0		=> mem_muxed_p4,
		data1		=> port0_w_data,
		data2		=> port1_w_data,
		data3		=> port2_w_data,
		data4		=> port3_w_data,
		data5		=> port4_w_data,
		sel			=> p4_out_sel,
		result		=> port4_a_rd	
	);
	

end architecture rtl;