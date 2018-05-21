--------------------------------------------------------------------------------
--  VLIW-RT CPU - Instruction decoder and buffer
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

entity ins_buffer is
port (
	clk      		: in std_logic;	
	reset    		: in std_logic;
	enable			: in std_logic;	
	addr_ld			: in std_logic;
	preld				: in std_logic;
	addr_in			: in pc_t;	
	bundle_in  	: in std_logic_vector(CACHE_LINE_SIZE-1 downto 0);	
			
	slot_0			   : out word_t; 
	slot_1			   : out word_t;
	slot_2			   : out word_t;
	slot_3			   : out word_t;

	error					: out std_logic;
	
	recover				: out pc_t;
	next_address 		: out pc_t	
	);
end ins_buffer;


architecture rtl of ins_buffer is
	signal nxt_slot : std_logic_vector(2 downto 0);
	signal address  : pc_t;
			
begin	
	
	next_address <= address;
	
	detect_stop_bit: process (clk, reset, addr_ld, enable, addr_in)
	begin
		if reset = '1' then		
			slot_0 <= (slot_0'range => '0');
			slot_1 <= (slot_1'range => '0');
			slot_2 <= (slot_2'range => '0');
			slot_3 <= (slot_3'range => '0');
			
			address <= (address'range => '0');
			recover <= (recover'range => '0');
			nxt_slot <= "000";	
			error <= '0';
		
		else	
			if rising_edge (clk) and enable = '1' then

			if addr_ld = '1' then
				address <= addr_in;		
				nxt_slot <= addr_in(2 downto 0);
				error <= '0';
				
				-- sync reset slots
				if preld = '0' then					
					slot_0 <= (slot_0'range => '0');
					slot_1 <= (slot_1'range => '0');
					slot_2 <= (slot_2'range => '0');
					slot_3 <= (slot_3'range => '0');				
				end if;
				
			else
				slot_0 <= (slot_0'range => '0');
				slot_1 <= (slot_1'range => '0');
				slot_2 <= (slot_2'range => '0');
				slot_3 <= (slot_3'range => '0');
				error <= '0';
																		
				case nxt_slot is
					
						-- Bundle LSB:	words 0 to 3 of cache line
						when "000" => 
							if bundle_in(31) = '1' then
								nxt_slot <= "001";
								
								slot_0 <= bundle_in(WORD_SIZE-1 downto 0);

								address <= address + 1;
								recover <= address + 1;
												
							elsif bundle_in(63) = '1' then 
								nxt_slot  <= "010";
						
								slot_0 <= bundle_in(WORD_SIZE-1 downto 0);
								slot_1 <= bundle_in(2*WORD_SIZE-1 downto WORD_SIZE);
--								issue_ins <= "010";
								
								address <= address + 2;
								recover <= address + 2;
										
							elsif bundle_in(95) = '1' then  
								nxt_slot <=  "011";
							
								slot_0 <= bundle_in(WORD_SIZE-1 downto 0);
								slot_1 <= bundle_in(2*WORD_SIZE-1 downto WORD_SIZE);
								slot_2 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
							
								--issue_ins <= "011";
								
								address <= address + 3;
								recover <= address + 3;
															
							elsif bundle_in(127) = '1' then 
							
								nxt_slot <= "100";
			
								slot_0 <= bundle_in(WORD_SIZE-1 downto 0);
								slot_1 <= bundle_in(2*WORD_SIZE-1 downto WORD_SIZE);
								slot_2 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								slot_3 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								
								address <= address + 4;
								recover <= address + 4;
								
							else
								error <= '1';																
							end if;
			
						-- nxt_slot = 1
						when "001" =>					
							if bundle_in(63) = '1' then 
								nxt_slot  <= "010";
							
								slot_0 <= bundle_in(2*WORD_SIZE-1 downto WORD_SIZE);
								--issue_ins <= "001";
								
								address <= address + 1;
								recover <= address + 1;
																
							elsif bundle_in(95) = '1' then  
								nxt_slot <= "011";
						
								slot_0 <= bundle_in(2*WORD_SIZE-1 downto WORD_SIZE);
								slot_1 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								--issue_ins <= "010";
								
								address <= address + 2;
								recover <= address + 2;
												
							elsif bundle_in(127) = '1' then 						
								nxt_slot <= "100";
			
								slot_0 <= bundle_in(2*WORD_SIZE-1 downto WORD_SIZE);
								slot_1 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								slot_2 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								--issue_ins <= "011";	
						
								address <= address + 3;
								recover <= address + 3;
							
							elsif bundle_in(159) = '1' then 
							
								nxt_slot <= "101";
			
								slot_0 <= bundle_in(2*WORD_SIZE-1 downto WORD_SIZE);
								slot_1 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								slot_2 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								slot_3 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								
								address <= address + 4;
								recover <= address + 4;
							else
								error <= '1';																
			
							end if;
						
						-- nxt_slot = 2
						when "010" => 
							if bundle_in(95) = '1' then  
								nxt_slot <=  "011";
						
								slot_0 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								--issue_ins <= "001";	
								
								address <= address + 1;
								recover <= address + 1;
					
							elsif bundle_in(127) = '1' then 
								nxt_slot <= "100";
									
								slot_0 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								slot_1 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								--issue_ins <= "010";
								
								address <= address +2;
								recover <= address +2;								
							
							elsif bundle_in(159) = '1' then 
								nxt_slot <= "101";
									
								slot_0 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								slot_1 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								slot_2 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								--issue_ins <= "010";
								
								address <= address +3;
								recover <= address +3;
							
							elsif bundle_in(191) = '1' then 
								nxt_slot <= "110";
									
								slot_0 <= bundle_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
								slot_1 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								slot_2 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								slot_3 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
								--issue_ins <= "010";
								
								address <= address +4;
								recover <= address +4;
							else
								error <= '1';
							end if;
							
						when "011" => 
							if bundle_in(127) = '1'  then 
								nxt_slot <= "100";	
					
								slot_0 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
											
								address <= address+ 1;
								recover <= address+ 1;
							
							elsif bundle_in(159) = '1' then 
								nxt_slot <= "101";
									
								slot_0 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								slot_1 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
															
								address <= address +2;
								recover <= address +2;								
							
							elsif bundle_in(191) = '1' then 
								nxt_slot <= "110";
									
								slot_0 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								slot_1 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								slot_2 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
																
								address <= address +3;
								recover <= address +3;
							
							elsif bundle_in(223) = '1' then 
								nxt_slot <= "111";
									
								slot_0 <= bundle_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);
								slot_1 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								slot_2 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
								slot_3 <= bundle_in(7*WORD_SIZE-1 downto 6*WORD_SIZE);								
								
								address <= address +4;
								recover <= address +4;
							else
								error <= '1';
							end if;
															
						
						-- Bundle MSB:	words 4 to 7 of cache line
						
						when "100" => 
						
							if bundle_in(159) = '1' then
								nxt_slot <= "101";
								
								slot_0 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);

								address <= address + 1;
								recover <= address + 1;
												
							elsif bundle_in(191) = '1' then 
								nxt_slot  <= "110";
						
								slot_0 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								slot_1 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
								
								address <= address + 2;
								recover <= address + 2;
										
							elsif bundle_in(223) = '1' then  
								nxt_slot <=  "111";
							
								slot_0 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								slot_1 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
								slot_2 <= bundle_in(7*WORD_SIZE-1 downto 6*WORD_SIZE);							
														
								address <= address + 3;
								recover <= address + 3;
															
							elsif bundle_in(255) = '1' then 
							
								nxt_slot <= "000";
			
								slot_0 <= bundle_in(5*WORD_SIZE-1 downto 4*WORD_SIZE);
								slot_1 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
								slot_2 <= bundle_in(7*WORD_SIZE-1 downto 6*WORD_SIZE);
								slot_3 <= bundle_in(8*WORD_SIZE-1 downto 7*WORD_SIZE);
								
								address <= address + 4;
								recover <= address + 4;
							else
								error <= '1';
																
							end if;
							
						when "101" =>
							if bundle_in(191) = '1' then 
								nxt_slot  <= "110";
							
								slot_0 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
																
								address <= address + 1;
								recover <= address + 1;
																
							elsif bundle_in(223) = '1' then  
								nxt_slot <= "111";
						
								slot_0 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
								slot_1 <= bundle_in(7*WORD_SIZE-1 downto 6*WORD_SIZE);
															
								address <= address + 2;
								recover <= address + 2;
												
							elsif bundle_in(255) = '1' then 						
								nxt_slot <= "000";
			
								slot_0 <= bundle_in(6*WORD_SIZE-1 downto 5*WORD_SIZE);
								slot_1 <= bundle_in(7*WORD_SIZE-1 downto 6*WORD_SIZE);
								slot_2 <= bundle_in(8*WORD_SIZE-1 downto 7*WORD_SIZE);
														
								address <= address + 3;
								recover <= address + 3;
							else
								error <= '1';			
							end if;		
						
						when "110" =>
							if bundle_in(223) = '1' then  
								nxt_slot <=  "111";
						
								slot_0 <= bundle_in(7*WORD_SIZE-1 downto 6*WORD_SIZE);
																
								address <= address + 1;
								recover <= address + 1;
					
							elsif bundle_in(255) = '1' then 
								nxt_slot <= "000";
									
								slot_0 <= bundle_in(7*WORD_SIZE-1 downto 6*WORD_SIZE);
								slot_1 <= bundle_in(8*WORD_SIZE-1 downto 7*WORD_SIZE);
								
								address <= address +2;
								recover <= address +2;
							else
								error <= '1';								 
							end if;		
							
						when "111" => 
							if bundle_in(255) = '1'  then 
								nxt_slot <= "000";	
					
								slot_0 <= bundle_in(8*WORD_SIZE-1 downto 7*WORD_SIZE);
								--issue_ins <= "001";
				
								address <= address+ 1;
								recover <= address+ 1;
							else
								error <= '1';
							end if;		
							
						when others =>
							nxt_slot <= "000";
						
					end case;
			
				-- if preload exists (for branch prediction)
				-- continue instruction decoding, but load the preload address
--				if preld = '1' then
--					address <= addr_in;		
--					nxt_slot <= addr_in(2 downto 0);				
--				end if;
			
	
				end if;
			end if;
		end if;
	end process;
end rtl;