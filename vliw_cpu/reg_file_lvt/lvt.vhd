--------------------------------------------------------------------------------
--  VLIW-RT CPU - Long Live Table entity
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


LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

entity lvt IS
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
end entity lvt;


architecture rtl of lvt is
	type r_array is array (0 to 63) of std_logic_vector(1 downto 0);
	
	signal registers	: r_array;
	
begin

--	port0_a_rd	<=	registers(conv_integer(port0_a_rd_addr));
--	port0_b_rd	<=	registers(conv_integer(port0_b_rd_addr));
--	port1_a_rd	<=	registers(conv_integer(port1_a_rd_addr));
--	port1_b_rd	<=	registers(conv_integer(port1_b_rd_addr));
--	port2_a_rd	<=	registers(conv_integer(port2_a_rd_addr));
--	port2_b_rd	<=	registers(conv_integer(port2_b_rd_addr));
--	port3_a_rd	<=	registers(conv_integer(port3_a_rd_addr));
--	port3_b_rd	<=	registers(conv_integer(port3_b_rd_addr));
	

	process (clk, reset, port0_w_addr, port1_w_addr, port2_w_addr, port3_w_addr,
						port0_w_en, port1_w_en, port2_w_en, port3_w_en)
	begin
		if reset = '1' then
			port0_a_rd	<=	"00";
			port0_b_rd	<=	"00";
			port1_a_rd	<=	"00";
			port1_b_rd	<=	"00";
			port2_a_rd	<=	"00";
			port2_b_rd	<=	"00";
			port3_a_rd	<=	"00";
			port3_b_rd	<=	"00";
		else			
			if rising_edge(clk) then			
				if port0_w_en = '1' then
					case port0_w_addr is
						when "000000" => registers(0) <="00";
						when "000001" => registers(1) <="00";
						when "000010" => registers(2) <="00";
						when "000011" => registers(3) <="00";
						when "000100" => registers(4) <="00";
						when "000101" => registers(5) <="00";
						when "000110" => registers(6) <="00";
						when "000111" => registers(7) <="00";
						when "001000" => registers(8) <="00";
						when "001001" => registers(9) <="00";
						when "001010" => registers(10) <="00";
						when "001011" => registers(11) <="00";
						when "001100" => registers(12) <="00";
						when "001101" => registers(13) <="00";
						when "001110" => registers(14) <="00";
						when "001111" => registers(15) <="00";
						when "010000" => registers(16) <="00";
						when "010001" => registers(17) <="00";
						when "010010" => registers(18) <="00";
						when "010011" => registers(19) <="00";
						when "010100" => registers(20) <="00";
						when "010101" => registers(21) <="00";
						when "010110" => registers(22) <="00";
						when "010111" => registers(23) <="00";
						when "011000" => registers(24) <="00";
						when "011001" => registers(25) <="00";
						when "011010" => registers(26) <="00";
						when "011011" => registers(27) <="00";
						when "011100" => registers(28) <="00";
						when "011101" => registers(29) <="00";
						when "011110" => registers(30) <="00";
						when "011111" => registers(31) <="00";
						when "100000" => registers(32) <="00";
						when "100001" => registers(33) <="00";
						when "100010" => registers(34) <="00";
						when "100011" => registers(35) <="00";
						when "100100" => registers(36) <="00";
						when "100101" => registers(37) <="00";
						when "100110" => registers(38) <="00";
						when "100111" => registers(39) <="00";
						when "101000" => registers(40) <="00";
						when "101001" => registers(41) <="00";
						when "101010" => registers(42) <="00";
						when "101011" => registers(43) <="00";
						when "101100" => registers(44) <="00";
						when "101101" => registers(45) <="00";
						when "101110" => registers(46) <="00";
						when "101111" => registers(47) <="00";
						when "110000" => registers(48) <="00";
						when "110001" => registers(49) <="00";
						when "110010" => registers(50) <="00";
						when "110011" => registers(51) <="00";
						when "110100" => registers(52) <="00";
						when "110101" => registers(53) <="00";
						when "110110" => registers(54) <="00";
						when "110111" => registers(55) <="00";
						when "111000" => registers(56) <="00";
						when "111001" => registers(57) <="00";
						when "111010" => registers(58) <="00";
						when "111011" => registers(59) <="00";
						when "111100" => registers(60) <="00";
						when "111101" => registers(61) <="00";
						when "111110" => registers(62) <="00";
						when "111111" => registers(63) <="00";

						when others => 
					end case;
				end if;
				
				if port1_w_en = '1' then
					case port1_w_addr is
						when "000000" => registers(0) <="01";
						when "000001" => registers(1) <="01";
						when "000010" => registers(2) <="01";
						when "000011" => registers(3) <="01";
						when "000100" => registers(4) <="01";
						when "000101" => registers(5) <="01";
						when "000110" => registers(6) <="01";
						when "000111" => registers(7) <="01";
						when "001000" => registers(8) <="01";
						when "001001" => registers(9) <="01";
						when "001010" => registers(10) <="01";
						when "001011" => registers(11) <="01";
						when "001100" => registers(12) <="01";
						when "001101" => registers(13) <="01";
						when "001110" => registers(14) <="01";
						when "001111" => registers(15) <="01";
						when "010000" => registers(16) <="01";
						when "010001" => registers(17) <="01";
						when "010010" => registers(18) <="01";
						when "010011" => registers(19) <="01";
						when "010100" => registers(20) <="01";
						when "010101" => registers(21) <="01";
						when "010110" => registers(22) <="01";
						when "010111" => registers(23) <="01";
						when "011000" => registers(24) <="01";
						when "011001" => registers(25) <="01";
						when "011010" => registers(26) <="01";
						when "011011" => registers(27) <="01";
						when "011100" => registers(28) <="01";
						when "011101" => registers(29) <="01";
						when "011110" => registers(30) <="01";
						when "011111" => registers(31) <="01";
						when "100000" => registers(32) <="01";
						when "100001" => registers(33) <="01";
						when "100010" => registers(34) <="01";
						when "100011" => registers(35) <="01";
						when "100100" => registers(36) <="01";
						when "100101" => registers(37) <="01";
						when "100110" => registers(38) <="01";
						when "100111" => registers(39) <="01";
						when "101000" => registers(40) <="01";
						when "101001" => registers(41) <="01";
						when "101010" => registers(42) <="01";
						when "101011" => registers(43) <="01";
						when "101100" => registers(44) <="01";
						when "101101" => registers(45) <="01";
						when "101110" => registers(46) <="01";
						when "101111" => registers(47) <="01";
						when "110000" => registers(48) <="01";
						when "110001" => registers(49) <="01";
						when "110010" => registers(50) <="01";
						when "110011" => registers(51) <="01";
						when "110100" => registers(52) <="01";
						when "110101" => registers(53) <="01";
						when "110110" => registers(54) <="01";
						when "110111" => registers(55) <="01";
						when "111000" => registers(56) <="01";
						when "111001" => registers(57) <="01";
						when "111010" => registers(58) <="01";
						when "111011" => registers(59) <="01";
						when "111100" => registers(60) <="01";
						when "111101" => registers(61) <="01";
						when "111110" => registers(62) <="01";
						when "111111" => registers(63) <="01";
						when others => 
					end case;				
				end if;
			
				if port2_w_en = '1' then
					case port2_w_addr is
						when "000000" => registers(0) <="10";
						when "000001" => registers(1) <="10";
						when "000010" => registers(2) <="10";
						when "000011" => registers(3) <="10";
						when "000100" => registers(4) <="10";
						when "000101" => registers(5) <="10";
						when "000110" => registers(6) <="10";
						when "000111" => registers(7) <="10";
						when "001000" => registers(8) <="10";
						when "001001" => registers(9) <="10";
						when "001010" => registers(10) <="10";
						when "001011" => registers(11) <="10";
						when "001100" => registers(12) <="10";
						when "001101" => registers(13) <="10";
						when "001110" => registers(14) <="10";
						when "001111" => registers(15) <="10";
						when "010000" => registers(16) <="10";
						when "010001" => registers(17) <="10";
						when "010010" => registers(18) <="10";
						when "010011" => registers(19) <="10";
						when "010100" => registers(20) <="10";
						when "010101" => registers(21) <="10";
						when "010110" => registers(22) <="10";
						when "010111" => registers(23) <="10";
						when "011000" => registers(24) <="10";
						when "011001" => registers(25) <="10";
						when "011010" => registers(26) <="10";
						when "011011" => registers(27) <="10";
						when "011100" => registers(28) <="10";
						when "011101" => registers(29) <="10";
						when "011110" => registers(30) <="10";
						when "011111" => registers(31) <="10";
						when "100000" => registers(32) <="10";
						when "100001" => registers(33) <="10";
						when "100010" => registers(34) <="10";
						when "100011" => registers(35) <="10";
						when "100100" => registers(36) <="10";
						when "100101" => registers(37) <="10";
						when "100110" => registers(38) <="10";
						when "100111" => registers(39) <="10";
						when "101000" => registers(40) <="10";
						when "101001" => registers(41) <="10";
						when "101010" => registers(42) <="10";
						when "101011" => registers(43) <="10";
						when "101100" => registers(44) <="10";
						when "101101" => registers(45) <="10";
						when "101110" => registers(46) <="10";
						when "101111" => registers(47) <="10";
						when "110000" => registers(48) <="10";
						when "110001" => registers(49) <="10";
						when "110010" => registers(50) <="10";
						when "110011" => registers(51) <="10";
						when "110100" => registers(52) <="10";
						when "110101" => registers(53) <="10";
						when "110110" => registers(54) <="10";
						when "110111" => registers(55) <="10";
						when "111000" => registers(56) <="10";
						when "111001" => registers(57) <="10";
						when "111010" => registers(58) <="10";
						when "111011" => registers(59) <="10";
						when "111100" => registers(60) <="10";
						when "111101" => registers(61) <="10";
						when "111110" => registers(62) <="10";
						when "111111" => registers(63) <="10";					
						when others =>					
					end case;
				end if;
			
				if port3_w_en = '1' then
					case port3_w_addr is
						when "000000" => registers(0) <="11";
						when "000001" => registers(1) <="11";
						when "000010" => registers(2) <="11";
						when "000011" => registers(3) <="11";
						when "000100" => registers(4) <="11";
						when "000101" => registers(5) <="11";
						when "000110" => registers(6) <="11";
						when "000111" => registers(7) <="11";
						when "001000" => registers(8) <="11";
						when "001001" => registers(9) <="11";
						when "001010" => registers(10) <="11";
						when "001011" => registers(11) <="11";
						when "001100" => registers(12) <="11";
						when "001101" => registers(13) <="11";
						when "001110" => registers(14) <="11";
						when "001111" => registers(15) <="11";
						when "010000" => registers(16) <="11";
						when "010001" => registers(17) <="11";
						when "010010" => registers(18) <="11";
						when "010011" => registers(19) <="11";
						when "010100" => registers(20) <="11";
						when "010101" => registers(21) <="11";
						when "010110" => registers(22) <="11";
						when "010111" => registers(23) <="11";
						when "011000" => registers(24) <="11";
						when "011001" => registers(25) <="11";
						when "011010" => registers(26) <="11";
						when "011011" => registers(27) <="11";
						when "011100" => registers(28) <="11";
						when "011101" => registers(29) <="11";
						when "011110" => registers(30) <="11";
						when "011111" => registers(31) <="11";
						when "100000" => registers(32) <="11";
						when "100001" => registers(33) <="11";
						when "100010" => registers(34) <="11";
						when "100011" => registers(35) <="11";
						when "100100" => registers(36) <="11";
						when "100101" => registers(37) <="11";
						when "100110" => registers(38) <="11";
						when "100111" => registers(39) <="11";
						when "101000" => registers(40) <="11";
						when "101001" => registers(41) <="11";
						when "101010" => registers(42) <="11";
						when "101011" => registers(43) <="11";
						when "101100" => registers(44) <="11";
						when "101101" => registers(45) <="11";
						when "101110" => registers(46) <="11";
						when "101111" => registers(47) <="11";
						when "110000" => registers(48) <="11";
						when "110001" => registers(49) <="11";
						when "110010" => registers(50) <="11";
						when "110011" => registers(51) <="11";
						when "110100" => registers(52) <="11";
						when "110101" => registers(53) <="11";
						when "110110" => registers(54) <="11";
						when "110111" => registers(55) <="11";
						when "111000" => registers(56) <="11";
						when "111001" => registers(57) <="11";
						when "111010" => registers(58) <="11";
						when "111011" => registers(59) <="11";
						when "111100" => registers(60) <="11";
						when "111101" => registers(61) <="11";
						when "111110" => registers(62) <="11";
						when "111111" => registers(63) <="11";	
					 	when others =>
					end case;			
				end if;
		
				port0_a_rd	<=	registers(conv_integer(port0_a_rd_addr));
				port0_b_rd	<=	registers(conv_integer(port0_b_rd_addr));
				port1_a_rd	<=	registers(conv_integer(port1_a_rd_addr));
				port1_b_rd	<=	registers(conv_integer(port1_b_rd_addr));
				port2_a_rd	<=	registers(conv_integer(port2_a_rd_addr));
				port2_b_rd	<=	registers(conv_integer(port2_b_rd_addr));
				port3_a_rd	<=	registers(conv_integer(port3_a_rd_addr));
				port3_b_rd	<=	registers(conv_integer(port3_b_rd_addr));

		
			end if;
		end if;
	end process;
	
--	process (clk, reset, port0_a_rd_addr, port0_b_rd_addr, 
--						port1_a_rd_addr, port1_b_rd_addr,
--						port2_a_rd_addr, port2_b_rd_addr,
--						port3_a_rd_addr, port3_b_rd_addr,
--						registers)
--	begin
--		if reset = '1' then
--			port0_a_rd	<= (port0_a_rd'range => '0');
--		
--		else
--			if rising_edge(clk) then
--				port0_a_rd	<=	registers(conv_integer(port0_a_rd_addr));
--				port0_b_rd	<=	registers(conv_integer(port0_b_rd_addr));
--				port1_a_rd	<=	registers(conv_integer(port1_a_rd_addr));
--				port1_b_rd	<=	registers(conv_integer(port1_b_rd_addr));
--				port2_a_rd	<=	registers(conv_integer(port2_a_rd_addr));
--				port2_b_rd	<=	registers(conv_integer(port2_b_rd_addr));
--				port3_a_rd	<=	registers(conv_integer(port3_a_rd_addr));
--				port3_b_rd	<=	registers(conv_integer(port3_b_rd_addr));
--			
--			end if;
--		end if;
--	
--	
--	end process;
	
	

end architecture rtl;