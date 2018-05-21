--------------------------------------------------------------------------------
--  VLIW-RT CPU - SRAM controller top entity
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

entity sram_controller is 
	port (
	  -- inputs:
	  address 		: IN STD_LOGIC_VECTOR (DATA_ADDR_SIZE-1 DOWNTO 0);
	  byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	  chipselect 	: IN STD_LOGIC;
	  clk 					: IN STD_LOGIC;
	  clken 				: IN STD_LOGIC;
	  reset 				: IN STD_LOGIC;
	  reset_req 	: IN STD_LOGIC;
	  write 				: IN STD_LOGIC;
	  read				: in std_logic;
	  writedata 		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	  -- outputs:
	  readdata 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	  waitrequest : out std_logic;
	  
	 ADSC_N :  out std_logic;
	 ADSP_N :  out std_logic;
	 ADV_N :  out std_logic;
	 BE :  out std_logic_vector( 3  downto 0  );
	
	GW_N :  out std_logic;
	OE_N :  out std_logic;
	WE_N :  out std_logic;
	CE_0_N :  out std_logic;
	CE_1_N :  out std_logic;
	FS_ADDR :  out std_logic_vector( 19  downto 0  );
	FS_DQ :  inout std_logic_vector( 31  downto 0  )
);
end entity sram_controller;

architecture rtl of sram_controller is

	component tristate
	PORT (
		mybidir 		: INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		myinput 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		myenable 	: IN STD_LOGIC
	);
	end component tristate;

	type mem_state_type is (IDLE, READ_M, WRITE_M, DONE);
	signal mem_state : mem_state_type;

	signal d_read : std_logic;
	signal d_write : std_logic;
	
	signal mem_data : word_t;
	
	signal byteenable_reg : STD_LOGIC_VECTOR (3 DOWNTO 0);
	
	signal in_reg_en : std_logic;
		
	signal  chip_en_reg : std_logic;	
	
begin

	FS_ADDR <= address(21 downto 2);
	
	do_clk_mem_acc_state: process (clk, reset, mem_state)
	begin
		if reset = '1'  then
			mem_state <= IDLE;			
		else
			if rising_edge (clk) then
				case mem_state is
					when IDLE =>
						
						if chipselect = '1' then
						
							if write = '1' then
								mem_state <= WRITE_M;
							else
								mem_state <= READ_M;
							end if;							
							
						end if;
					
					when WRITE_M =>
						mem_state <= DONE;
					
					when READ_M =>
						mem_state <= DONE;
						
					when DONE => 
						mem_state <= IDLE;
				
				end case;		
			end if;		
		end if;	
	end process;
	
	do_clk_mem_acc_state_output: process (mem_state, chipselect, write, read, byteenable, address, chip_en_reg, byteenable_reg)
	begin
		ADSP_N 	<= '1';						-- Address Status Processor
		ADSC_N 	<= '0';						-- Address Status Controller
		BE 				<= "0000";					-- Sync Byte Write Control
		GW_N 			<= '1';							-- Global Write Enable
		OE_N			<= '1';
		WE_N 			<= '1';
		CE_0_N		<= '1';							-- Chip selec SRAM 0
		CE_1_N		<= '1';							-- Chip selec SRAM 1
		
		in_reg_en    <= '0';
		waitrequest <= '0';
		d_read			 <= '0';
		d_write			<= '0';
		
		case mem_state is
						
			when IDLE =>
			
				in_reg_en <= '1';
			
				if chipselect = '1' then					
										
					if write = '1' then						
						WE_N <= '0';
						d_write <= '1';
									
						BE <=not byteenable;											
					else
						waitrequest 	<= '1';
						OE_N 					<= '0';
						ADSP_N				<= '0';
					end if;
					
					-- chipselect
					CE_0_N <= address(26);
					CE_1_N <= not address(26);			
				end if;
				
			
			when READ_M =>
				
				d_read <= '1';
				waitrequest 	<= '1';
				
				-- chipselect
				CE_0_N <= chip_en_reg;
				CE_1_N <= not chip_en_reg;
				
				OE_N 			<= '0';
				ADSP_N		<= '0';				
				
			when WRITE_M =>
				WE_N <= '0';
				d_write <= '1';
									
				BE <=byteenable_reg;	
				
				-- chipselect
				CE_0_N <= chip_en_reg;
				CE_1_N <= not chip_en_reg;			
							
				
			when DONE => 
				OE_N 			<= not read;
				
			
			
			end case;
	end process;	
	
	-- disable burst	    
    ADV_N 		<= '1';						-- Sync Burst Address Advance	 
	 
	 process (d_read, byteenable, FS_DQ)
	 begin
		
		readdata <= FS_DQ;
		
		if d_read = '1' then
						
			case byteenable is
				
				when "0000" =>				
			
				when "0001" => 
					readdata <= x"000000" & FS_DQ(7 downto 0);  
				
				when "0010" =>
					readdata <=  x"000000" & FS_DQ(15 downto 8);
				
				when "0100" => 
					readdata <= x"000000" & FS_DQ(23 downto 16);
				
				when "1000" => 
					readdata <= x"000000" & FS_DQ(31 downto 24); 
				
				when "1100" => 
					readdata <= x"0000" & FS_DQ(31 downto 16); 
				
				when "0011" =>
					readdata <= x"0000" & FS_DQ(15 downto 0); 
				
				when "1111" =>						
					readdata <= FS_DQ;
					
				when others =>
			end case;
				
		end if;	 
	 
	 end process;
	 
--	tristate_sram_data_rd	: tristate	port map (
--		mybidir 		=> mem_data,
--		myinput 		=> FS_DQ,
--		myenable 	=> d_read
--	);
	
	tristate_sram_data_wr	: tristate	port map (
		mybidir 		=> FS_DQ,
		myinput 		=> writedata,
		myenable 	=> d_write
	);

	 
	process (clk, reset, byteenable, in_reg_en)
	begin
		if reset = '1' then
			byteenable_reg <= "1111";
		else
			if rising_edge(clk) and in_reg_en = '1' then
				byteenable_reg <= not byteenable;	
				chip_en_reg <= address(26);
			end if;
		end if;
	end process;

end rtl;