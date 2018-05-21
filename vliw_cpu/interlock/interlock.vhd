--------------------------------------------------------------------------------
--  VLIW-RT CPU - Interlock entity
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
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;
use work.alu_functions.all;
use work.opcodes.all;

entity interlock is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	
	-- cycle that need forward
	rd_ctrl_src_0_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_1_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_2_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_3_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	rd_ctrl_src_0_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_1_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_2_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_3_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	rd_ctrl_opc_0			: in std_logic_vector(DECOD_SIZE-1 downto 0);		
	rd_ctrl_opc_1			: in std_logic_vector(DECOD_SIZE-1 downto 0);
	rd_ctrl_opc_2			: in std_logic_vector(DECOD_SIZE-1 downto 0);
	rd_ctrl_opc_3			: in std_logic_vector(DECOD_SIZE-1 downto 0);
	
	-- destination registers
	wb_addr_reg_0		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_0	: in std_logic;
	wb_mul_div_0		: in std_logic;	
	wb_mem_rd_0		: in std_logic;	
	-- predicates
	wb_b_dest_0	  				: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_0		: in std_logic;
	
	wb_addr_reg_1		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_1	: in std_logic;
	wb_mul_div_1		: in std_logic;	
	wb_mem_rd_1		: in std_logic;	
	-- predicates
	wb_b_dest_1	  			: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_1	: in std_logic;
	
	
	wb_addr_reg_2		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_2	: in std_logic;
	wb_mul_div_2		: in std_logic;	
	wb_mem_rd_2		: in std_logic;	
	-- predicates
	wb_b_dest_2	  			: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_2	: in std_logic;
	
	
	wb_addr_reg_3		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_3	: in std_logic;
	wb_mul_div_3		: in std_logic;	
	wb_mem_rd_3		: in std_logic;	
	-- predicates
	wb_b_dest_3	  			: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	wb_pred_w_en_3	: in std_logic;
	
	dep_stall			: out std_logic
	
	);
end interlock;



architecture rtl of interlock is

	signal ex_stall  : std_logic;
	signal ctrl_flow : std_logic;
	
	
	signal bcond : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);

begin

	dep_stall <= ex_stall or ctrl_flow;
	
	-- predicate read register address
	bcond <= rd_ctrl_opc_0(4 downto 2);
	
	-- include a delay slot when a BR instruction is detected, there is no forward to this slot, compiler should sched diferently to
	-- stop this delay
	br_delay_slot : process	(clk, reset, rd_ctrl_opc_0, bcond,
																					wb_b_dest_0, wb_pred_w_en_0,
																					wb_b_dest_1, wb_pred_w_en_1,
																					wb_b_dest_2, wb_pred_w_en_2,
																					wb_b_dest_3, wb_pred_w_en_3)
	begin
		if reset = '1' then
			ctrl_flow <= '0';
		else
				ctrl_flow <= '0';
				
				-- if slot_0 has a branch contol flow instruction
				if rd_ctrl_opc_0(DECOD_SIZE-1 downto DECOD_SIZE-3) = "111" then
					
					-- slot 0 bcond  = bdest
					if bcond = wb_b_dest_0 and wb_pred_w_en_0 = '1' then
						ctrl_flow <= '1';
					end if;
					
					-- slot 1 bcond  = bdest
					if bcond = wb_b_dest_1 and wb_pred_w_en_1 = '1' then
						ctrl_flow <= '1';
					end if;
					
					-- slot 2 bcond  = bdest
					if bcond = wb_b_dest_2 and wb_pred_w_en_2 = '1' then
						ctrl_flow <= '1';
					end if;
					
					-- slot 3 bcond  = bdest
					if bcond = wb_b_dest_3 and wb_pred_w_en_3 = '1' then
						ctrl_flow <= '1';
					end if;					
				end if;
				
				-- if slot_0 has a goto to link register 
				if rd_ctrl_opc_0(DECOD_SIZE-1 downto DECOD_SIZE-3) = "110" and rd_ctrl_opc_0(2) = '1' then
				
--					if wb_addr_reg_0 = "111111" and wb_mem_rd_0 = '1' then
--						ctrl_flow <= '1';
--					end if;
--					
--					if wb_addr_reg_1 = "111111" and wb_mem_rd_1 = '1' then
--						ctrl_flow <= '1';
--					end if;
			
				if wb_addr_reg_0 = rd_ctrl_src_0_a and wb_mem_rd_0 = '1'  then
					ctrl_flow <= '1';
				end if;
			
				if wb_addr_reg_0 =rd_ctrl_src_0_b and wb_mem_rd_1 = '1'  then
					ctrl_flow <= '1';
				end if;
																	
				end if;			
		end if;
end process;	
		

	
ex_stall <= '0';

	
--	-- Load/Store and Mul_div units dont have forward logic to ALU	
--	-- only slot 0 and 1 support memory and mul_div instructions
--	ld_st_dep_detection : process	(clk, reset, 
--											wb_addr_reg_0 , rd_ctrl_src_0_a, rd_ctrl_src_0_b, wb_reg_w_en_0, wb_mem_rd_0, wb_mul_div_0,
--											wb_addr_reg_1 , rd_ctrl_src_1_a, rd_ctrl_src_1_b, wb_reg_w_en_1, wb_mem_rd_1, wb_mul_div_1,
--											wb_addr_reg_2 , rd_ctrl_src_2_a, rd_ctrl_src_2_b, wb_reg_w_en_2, 
--											wb_addr_reg_3 , rd_ctrl_src_3_a, rd_ctrl_src_3_b, wb_reg_w_en_3)
--	begin
--		if reset = '1' then
--			ex_stall <= '0';
--		else
--				ex_stall <= '0';		
--	
--				-- slot_0 to ALU 0
--				if wb_addr_reg_0 = rd_ctrl_src_0_a and wb_mul_div_0 = '1'  then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_0 =rd_ctrl_src_0_b and wb_mul_div_0 = '1'  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 0
--				if wb_addr_reg_1 = rd_ctrl_src_0_a and wb_mul_div_1 = '1'  then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_0_b and  wb_mul_div_1 = '1'  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_0 to ALU 1
--				if wb_addr_reg_0 = rd_ctrl_src_1_a and wb_mul_div_0 = '1'  then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_0 =rd_ctrl_src_1_b and wb_mul_div_0 = '1'  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 1
--				if wb_addr_reg_1 = rd_ctrl_src_1_a and wb_mul_div_1 = '1' then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_1_b and  wb_mul_div_1 = '1'  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_0 to ALU 2
--				if wb_addr_reg_0 = rd_ctrl_src_2_a and wb_mul_div_0 = '1'  then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_0 =rd_ctrl_src_2_b and wb_mul_div_0 = '1'  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 2
--				if wb_addr_reg_1 = rd_ctrl_src_2_a and  wb_mul_div_1 = '1'  then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_2_b and  wb_mul_div_1 = '1'  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_0 to ALU 3
--				if wb_addr_reg_0 = rd_ctrl_src_3_a and wb_mul_div_0 = '1'   then
--					ex_stall <= '1';
--				end if;
--		
--				if wb_addr_reg_0 =rd_ctrl_src_3_b and wb_mul_div_0 = '1'  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 3
--				if wb_addr_reg_1 = rd_ctrl_src_3_a and  wb_mul_div_1 = '1'   then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_3_b and wb_mul_div_1 = '1'   then
--					ex_stall <= '1';
--				end if;					
--				
--				--ex_stall <= '0';
--				
--		end if;
--end process;
	

end rtl;





---- Load/Store and Mul_div units dont have forward logic to ALU	
--	-- only slot 0 and 1 support memory and mul_div instructions
--	ld_st_dep_detection : process	(clk, reset, 
--											wb_addr_reg_0 , rd_ctrl_src_0_a, rd_ctrl_src_0_b, wb_reg_w_en_0, wb_mem_rd_0, wb_mul_div_0,
--											wb_addr_reg_1 , rd_ctrl_src_1_a, rd_ctrl_src_1_b, wb_reg_w_en_1, wb_mem_rd_1, wb_mul_div_1,
--											wb_addr_reg_2 , rd_ctrl_src_2_a, rd_ctrl_src_2_b, wb_reg_w_en_2, 
--											wb_addr_reg_3 , rd_ctrl_src_3_a, rd_ctrl_src_3_b, wb_reg_w_en_3)
--	begin
--		if reset = '1' then
--			ex_stall <= '0';
--		else
--				ex_stall <= '0';		
--	
--				-- slot_0 to ALU 0
--				if wb_addr_reg_0 = rd_ctrl_src_0_a and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' ) then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_0 =rd_ctrl_src_0_b and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' ) then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 0
--				if wb_addr_reg_1 = rd_ctrl_src_0_a and (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' ) then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_0_b and (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' )  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_0 to ALU 1
--				if wb_addr_reg_0 = rd_ctrl_src_1_a and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' ) then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_0 =rd_ctrl_src_1_b and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' )then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 1
--				if wb_addr_reg_1 = rd_ctrl_src_1_a and  (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' ) then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_1_b and  (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' ) then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_0 to ALU 2
--				if wb_addr_reg_0 = rd_ctrl_src_2_a and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' ) then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_0 =rd_ctrl_src_2_b and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' ) then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 2
--				if wb_addr_reg_1 = rd_ctrl_src_2_a and (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' ) then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_2_b and (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' ) then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_0 to ALU 3
--				if wb_addr_reg_0 = rd_ctrl_src_3_a and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' )  then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_0 =rd_ctrl_src_3_b and (wb_mem_rd_0 = '1' or wb_mul_div_0 = '1' )  then
--					ex_stall <= '1';
--				end if;
--				
--				-- slot_1 to ALU 3
--				if wb_addr_reg_1 = rd_ctrl_src_3_a and (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' )  then
--					ex_stall <= '1';
--				end if;
--			
--				if wb_addr_reg_1 =rd_ctrl_src_3_b and (wb_mem_rd_1 = '1' or wb_mul_div_1 = '1' )  then
--					ex_stall <= '1';
--				end if;					
--				
--				ex_stall <= '0';
--				
--		end if;
--end process;
	