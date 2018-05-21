--------------------------------------------------------------------------------
--  VLIW-RT CPU - Multiplication and division top entity
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
-- 
-- This file uses Altera libraries subjected to Altera licenses
-- See altera-ip folder for more information

library IEEE;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;
use work.alu_functions.all;
use work.opcodes.all;

entity mul_div_unit is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	ex_stall : in std_logic;
	
	-- control
	ctrl_0   : in t_ctrl;
	ctrl_1   : in t_ctrl;
	ctrl_2   : in t_ctrl;
	ctrl_3   : in t_ctrl;
	
	-- forward logic
	rd_ctrl_src_0_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_1_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_2_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_3_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_0_mul_div		: in std_logic;

	rd_ctrl_src_0_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_1_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_2_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_src_3_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	rd_ctrl_1_mul_div		: in std_logic;
	
	wb_addr_reg_0		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_0		: in std_logic;
		
	wb_addr_reg_1		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_1		: in std_logic;
	
	wb_addr_reg_2		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_2		: in std_logic;
	
	wb_addr_reg_3		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_reg_w_en_3		: in std_logic;
	
	alu_val_0					: in word_t;
	alu_val_1					: in word_t;
	alu_val_2					: in word_t;
	alu_val_3					: in word_t;	

	memory_data					: in word_t;
	memory_data_1				: in word_t;
	
	
	-- pipeline data  
	src1_in_0		 : in word_t;
	src2_in_0		 : in word_t;
	
	src1_in_1		 : in word_t;
	src2_in_1		 : in word_t;
	
	src1_in_2		 : in word_t;
	src2_in_2		 : in word_t;
	
	src1_in_3		 : in word_t;
	src2_in_3		 : in word_t;				
	
	stall			: out std_logic;	
--	dep_stall			: out std_logic;

	
	wb_wait			: out std_logic;

	val_rd_0			: out std_logic;
	val_rd_1			: out std_logic;
	
	wb_dest_reg_0	: out std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	wb_dest_reg_1	: out std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	val_0				: out word_t;
	val_1				: out word_t;
	val_2				: out word_t;
	val_3				: out word_t
		
	);
end mul_div_unit;


architecture rtl of mul_div_unit is

	component forward_mux  port
	(
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data3x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data4x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data5x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data6x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data7x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data8x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel				: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component forward_mux;

	component mul_64_signed
		PORT
		(
			clken		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
		);
	end component;
	
	component mul_64_unsigned
	PORT
	(
		clken		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
	end component;
	
	component div_signed
	PORT
	(
		clken		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
	
	component div_unsigned
	PORT
	(
		clken		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
	
	type mul_div_state_type is (IDLE, REG, WAITING, RESULT, DONE);
	signal mul_div_state : mul_div_state_type;
	
	signal stall_cycles : std_logic_vector(3 downto 0);
	
	-- forward
	signal src_1_sel_0	: std_logic_vector(3 downto 0);
	signal src_1_sel_1	: std_logic_vector(3 downto 0);
	signal src_2_sel_0	: std_logic_vector(3 downto 0);
	signal src_2_sel_1	: std_logic_vector(3 downto 0);		
	signal src1_0_val		: word_t;
	signal src1_1_val		: word_t;
	signal src2_0_val		: word_t;
	signal src2_1_val		: word_t;
	

	signal mul_0_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);
	signal mul_1_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);
--	signal mul_2_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);
--	signal mul_3_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);
	
	signal mulu_0_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);
	signal mulu_1_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);
--	signal mulu_2_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);
--	signal mulu_3_val	: std_logic_vector(2*WORD_SIZE-1 downto 0);

	signal quo_0		: std_logic_vector(WORD_SIZE-1 downto 0);
	signal rem_0		: std_logic_vector(WORD_SIZE-1 downto 0);
	
	signal quou_0		: std_logic_vector(WORD_SIZE-1 downto 0);
	signal remu_0		: std_logic_vector(WORD_SIZE-1 downto 0);
	
	signal mull_0_clk_en : std_logic;
	signal mull_1_clk_en : std_logic;
	
	signal mullu_0_clk_en : std_logic;
	signal mullu_1_clk_en : std_logic;
	
	signal div_0_clk_en : std_logic;
	signal divu_0_clk_en : std_logic;
	
	signal out_enable : std_logic;
	signal reg_enable : std_logic;
	
	signal src1_in_0_reg : word_t;
	signal src2_in_0_reg : word_t;
	
	signal src1_in_1_reg : word_t;
	signal src2_in_1_reg : word_t;
	
	signal func_0_reg			: std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
	signal dest_reg_0_reg : std_logic_vector(REG_ADDR_SIZE-1 downto 0);	
	signal mul_div_0_reg		: std_logic;
	signal mul_div_0_sel_reg		: std_logic;
	
	signal func_1_reg			: std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
	signal dest_reg_1_reg : std_logic_vector(REG_ADDR_SIZE-1 downto 0);	
	signal mul_div_1_reg		: std_logic;
	signal mul_div_1_sel_reg		: std_logic;
		
	signal val_0_int				: word_t;
	signal val_1_int				: word_t;
	
	signal src_1_mul_0_to_0 : std_logic;
	signal src_2_mul_0_to_0 : std_logic;
	signal src_1_mul_1_to_0 : std_logic;
	signal src_2_mul_1_to_0 : std_logic;
	
	signal src_1_mul_0_to_1 : std_logic;
	signal src_2_mul_0_to_1 : std_logic;
	signal src_1_mul_1_to_1 : std_logic;
	signal src_2_mul_1_to_1 : std_logic;
	
	signal mul_to_mul_rst_0 : std_logic;
	signal mul_to_mul_rst_1 : std_logic;
	
	
begin

	----------------------
	-- Forward logic muxes		
	mux_forward_0_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src1_in_0,	-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> val_0_int,	
		data6x		=> val_1_int,	
		data7x		=> memory_data,	
		data8x		=> memory_data_1,	
		sel					=> src_1_sel_0,
		result			=> src1_0_val
	);
	
	mux_forward_1_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src1_in_1,	-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> val_0_int,	
		data6x		=> val_1_int,	
		data7x		=> memory_data,	
		data8x		=> memory_data_1,	
		sel			=> src_1_sel_1,
		result		=> src1_1_val
	);	
	
	mux_forward_0_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src2_in_0,			-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> val_0_int,	
		data6x		=> val_1_int,
		data7x		=> memory_data,	
		data8x		=> memory_data_1,		
		sel					=> src_2_sel_0,
		result			=> src2_0_val
	);
	
	mux_forward_1_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> src2_in_1,			-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> val_0_int,	
		data6x		=> val_1_int,
		data7x		=> memory_data,	
		data8x		=> memory_data_1,	
		sel			=> src_2_sel_1,
		result		=> src2_1_val
	);
	
	-- Forward logic for data on Load from memory operations
	process	(clk, reset, wb_addr_reg_0 , rd_ctrl_src_0_a, rd_ctrl_src_0_b, wb_reg_w_en_0, 
											wb_addr_reg_1 , rd_ctrl_src_1_a, rd_ctrl_src_1_b, wb_reg_w_en_1, 
											wb_addr_reg_2 , rd_ctrl_src_2_a, rd_ctrl_src_2_b, wb_reg_w_en_2, 
											wb_addr_reg_3 , rd_ctrl_src_3_a, rd_ctrl_src_3_b, wb_reg_w_en_3,
											ex_stall)
	begin
		if reset = '1' then
			src_1_sel_0	<=	"0000";
			src_2_sel_0	<=	"0000";
			
			src_1_sel_1	<=	"0000";
			src_2_sel_1	<=	"0000";			
			
		else
			if rising_edge(clk) then
					
				if ex_stall = '0' then
				
					src_1_sel_0	<=	"0000";
					src_2_sel_0	<=	"0000";
					
					src_1_sel_1	<=	"0000";
					src_2_sel_1	<=	"0000";
							
					-- ALU	0 to mul-div-0
					if wb_addr_reg_0 = rd_ctrl_src_0_a and wb_reg_w_en_0 = '1' then
						src_1_sel_0	<=	"0001";
					end if;
				
					if wb_addr_reg_0 =rd_ctrl_src_0_b and wb_reg_w_en_0 = '1' then
						src_2_sel_0	<=	"0001";
					end if;
					
					-- ALU	1  to mul-div-0
					if wb_addr_reg_1 = rd_ctrl_src_0_a and wb_reg_w_en_1 = '1' then
						src_1_sel_0	<=	"0010";
					end if;
				
					if wb_addr_reg_1 =rd_ctrl_src_0_b and wb_reg_w_en_1 = '1' then
						src_2_sel_0	<=	"0010";
					end if;
					
					-- ALU	2  to mul-div-0
					if wb_addr_reg_2 = rd_ctrl_src_0_a and wb_reg_w_en_2 = '1' then
						src_1_sel_0	<=	"0011";
					end if;
				
					if wb_addr_reg_2 =rd_ctrl_src_0_b and wb_reg_w_en_2 = '1' then
						src_2_sel_0	<=	"0011";
					end if;
					
					-- ALU	3  to mul-div-0
					if wb_addr_reg_3 = rd_ctrl_src_0_a and wb_reg_w_en_3 = '1' then
						src_1_sel_0	<=	"0100";
					end if;
				
					if wb_addr_reg_3 =rd_ctrl_src_0_b and wb_reg_w_en_3 = '1' then
						src_2_sel_0	<=	"0100";
					end if;
										
					
					-- memory to mul-div-0
					if (wb_addr_reg_0 = rd_ctrl_src_0_a) and ctrl_0.mem_rd = '1' then
						src_1_sel_0	<=	"0111";
					end if;
					
					if (wb_addr_reg_0 =rd_ctrl_src_0_b) and ctrl_0.mem_rd = '1' then
						src_2_sel_0	<=	"0111";
					end if;		
				
					-- memory_1 to mul-div-0
					if (wb_addr_reg_1 = rd_ctrl_src_0_a) and ctrl_1.mem_rd = '1' then
						src_1_sel_0	<=	"1000";
					end if;
			
					if (wb_addr_reg_1 =rd_ctrl_src_0_b) and ctrl_1.mem_rd = '1' then
						src_2_sel_0	<=	"1000";
					end if;				
										
					-------------------------------------------------------------------------------------------
					
					-- ALU	0 to mul-div-1
					if wb_addr_reg_0 = rd_ctrl_src_1_a and wb_reg_w_en_0 = '1' then
						src_1_sel_1	<=	"0001";
					end if;
				
					if wb_addr_reg_0 =rd_ctrl_src_1_b and wb_reg_w_en_0 = '1' then
						src_2_sel_1	<=	"0001";
					end if;
					
					-- ALU	1  to mul-div-1
					if wb_addr_reg_1 = rd_ctrl_src_1_a and wb_reg_w_en_1 = '1' then
						src_1_sel_1	<=	"0010";
					end if;
				
					if wb_addr_reg_1 =rd_ctrl_src_1_b and wb_reg_w_en_1 = '1' then
						src_2_sel_1	<=	"0010";
					end if;
					
					-- ALU	2  to mul-div-1
					if wb_addr_reg_2 = rd_ctrl_src_1_a and wb_reg_w_en_2 = '1' then
						src_1_sel_1	<=	"0011";
					end if;
				
					if wb_addr_reg_2 =rd_ctrl_src_1_b and wb_reg_w_en_2 = '1' then
						src_2_sel_1	<=	"0011";
					end if;
					
					-- ALU	3  to mul-div-1
					if wb_addr_reg_3 = rd_ctrl_src_1_a and wb_reg_w_en_3 = '1' then
						src_1_sel_1	<=	"0100";
					end if;
				
					if wb_addr_reg_3 =rd_ctrl_src_1_b and wb_reg_w_en_3 = '1' then
						src_2_sel_1	<=	"0100";
					end if;
					
					
					-- memory to muldiv 1
					if (wb_addr_reg_0 = rd_ctrl_src_1_a) and ctrl_0.mem_rd = '1' then
						src_1_sel_1	<=	"0111";
					end if;
				
					if (wb_addr_reg_0 =rd_ctrl_src_1_b ) and ctrl_0.mem_rd = '1' then
						src_2_sel_1	<=	"0111";
					end if;	
					
					if (wb_addr_reg_1 = rd_ctrl_src_1_a) and ctrl_1.mem_rd = '1' then
						src_1_sel_1	<=	"1000";
					end if;
				
					if (wb_addr_reg_1 =rd_ctrl_src_1_b ) and ctrl_1.mem_rd = '1' then
						src_2_sel_1	<=	"1000";
					end if;
					
				else
					
					if src_1_mul_0_to_0 = '1' then
						src_1_sel_0	<=	"0101";
					end if;
					
					if src_2_mul_0_to_0 = '1' then
						src_2_sel_0	<=	"0101";
					end if;	
		
					if src_1_mul_1_to_0 = '1' then
						src_1_sel_0	<=	"0110";
					end if;
					
					if src_2_mul_1_to_0 = '1' then
						src_2_sel_0	<=	"0110";
					end if;
										
					
					if src_1_mul_0_to_1 = '1' then
						src_1_sel_1	<=	"0101";
					end if;
					
					if src_2_mul_0_to_1 = '1' then
						src_2_sel_1	<=	"0101";
					end if;	
					
					if src_1_mul_1_to_1 = '1' then
						src_1_sel_1	<=	"0110";
					end if;
					
					if src_2_mul_1_to_1 = '1' then
						src_2_sel_1	<=	"0110";
					end if;	
				
				end if;
				
				
			end if;
		end if;
	end process;
	
	-- mul to mul forward
	process	(clk, reset, wb_addr_reg_0 , rd_ctrl_src_0_a, rd_ctrl_src_0_b, wb_reg_w_en_0, 
											wb_addr_reg_1, rd_ctrl_src_1_a, rd_ctrl_src_1_b, wb_reg_w_en_1)											
											
	begin
		if reset = '1' then
			src_1_mul_0_to_0	<=	'0';
			src_2_mul_0_to_0	<=	'0';
			src_1_mul_1_to_0	<=	'0';
			src_2_mul_1_to_0	<=	'0';
		else
			if rising_edge(clk) and ex_stall = '0' then
					
				if mul_to_mul_rst_0 = '1' then
					src_1_mul_0_to_0	<= '0';
					src_2_mul_0_to_0	<= '0';
					src_1_mul_1_to_0	<= '0';
					src_2_mul_1_to_0	<= '0';				
				end if;
				
					-- mul_0 to mul_0
					if wb_addr_reg_0 = rd_ctrl_src_0_a and wb_reg_w_en_0 = '1' and ctrl_0.mul_div = '1'  and rd_ctrl_0_mul_div = '1' then
						src_1_mul_0_to_0	<=	'1';
					end if;				
				
					if wb_addr_reg_0 =rd_ctrl_src_0_b and wb_reg_w_en_0 = '1' and  ctrl_0.mul_div = '1' and rd_ctrl_0_mul_div = '1' then
						src_2_mul_0_to_0	<=	'1';
					end if;
					
					-- mul_1 to mul_0
					if wb_addr_reg_1 = rd_ctrl_src_0_a and wb_reg_w_en_1 = '1' and ctrl_1.mul_div = '1' and rd_ctrl_0_mul_div = '1' then
						src_1_mul_1_to_0	<=	'1';
					end if;				
				
					if wb_addr_reg_1 =rd_ctrl_src_0_b and wb_reg_w_en_1 = '1' and  ctrl_1.mul_div = '1'  and rd_ctrl_0_mul_div = '1' then
						src_2_mul_1_to_0	<=	'1';
					end if;	
				
				
				
			end if;
		end if;
	end process;
	
	
		-- mul to mul forward
	process	(clk, reset, wb_addr_reg_0 , rd_ctrl_src_0_a, rd_ctrl_src_0_b, wb_reg_w_en_0, 
											wb_addr_reg_1, rd_ctrl_src_1_a, rd_ctrl_src_1_b, wb_reg_w_en_1)											
											
	begin
		if reset = '1' then
			src_1_mul_0_to_1	<=	'0';
			src_2_mul_0_to_1	<=	'0';
			src_1_mul_1_to_1	<=	'0';
			src_2_mul_1_to_1	<=	'0';
		else
			if rising_edge(clk) and ex_stall = '0' then
					
				if mul_to_mul_rst_1 = '1' then
					src_1_mul_0_to_1	<= '0';
					src_2_mul_0_to_1	<= '0';
					src_1_mul_1_to_1	<= '0';
					src_2_mul_1_to_1	<= '0';				
				end if;
				
					-- mul_0 to mul_1
					if wb_addr_reg_1 = rd_ctrl_src_0_a and wb_reg_w_en_1 = '1' and ctrl_1.mul_div = '1'  and rd_ctrl_0_mul_div = '1' then
						src_1_mul_0_to_1	<=	'1';
					end if;				
				
					if wb_addr_reg_1 =rd_ctrl_src_0_b and wb_reg_w_en_1 = '1' and  ctrl_1.mul_div = '1' and rd_ctrl_0_mul_div = '1' then
						src_2_mul_0_to_1	<=	'1';
					end if;
					
					-- mul_1 to mul_1
					if wb_addr_reg_1 = rd_ctrl_src_1_a and wb_reg_w_en_1 = '1' and ctrl_1.mul_div = '1' and rd_ctrl_1_mul_div = '1' then
						src_1_mul_1_to_1	<=	'1';
					end if;				
				
					if wb_addr_reg_1 =rd_ctrl_src_1_b and wb_reg_w_en_1 = '1' and  ctrl_1.mul_div = '1'  and rd_ctrl_1_mul_div = '1' then
						src_2_mul_1_to_1	<=	'1';
					end if;	
				
								
			end if;
		end if;
	end process;
	
	

	process (clk, reset, out_enable, func_0_reg, mul_0_val, mulu_0_val, quo_0, rem_0, dest_reg_0_reg)
	begin
		if reset = '1' then
			val_0_int <= (val_0_int'range => '0');			
		else
			if rising_edge(clk) and out_enable = '1'  then	
					case func_0_reg is
					
						when ALU_MULL =>
							val_0_int <= mul_0_val(WORD_SIZE-1 downto 0);						
					
						when ALU_MULL64H => 
							val_0_int <= mul_0_val(2*WORD_SIZE-1 downto WORD_SIZE);
					
						when ALU_MULL64HU =>
							--val_0 <= mulu_0_val(2*WORD_SIZE-1 downto WORD_SIZE);
							val_0_int <= mulu_0_val(WORD_SIZE-1 downto 0);
							
						when ALU_DIVQ => 
							val_0_int <= quo_0;
					
						when ALU_DIVR =>
							val_0_int <= rem_0;
								
						when ALU_DIVQU => 
							val_0_int <= quou_0;
					
						when ALU_DIVRU =>
							val_0_int <= remu_0;
						
						when others =>
		
					end case;
							
			end if;
		end if;	
	
	end process;
	
	process (clk, reset, out_enable, func_1_reg, mul_1_val, mulu_1_val, dest_reg_1_reg)
	begin
		if reset = '1' then
			val_1_int <= (val_1_int'range => '0');
		else
			if rising_edge(clk) and out_enable = '1' then
					case func_1_reg is
					
						when ALU_MULL =>
							val_1_int <= mul_1_val(WORD_SIZE-1 downto 0);						
						
						when ALU_MULL64H => 
							val_1_int <= mul_1_val(2*WORD_SIZE-1 downto WORD_SIZE);	
	
						when ALU_MULL64HU =>
							val_1_int <= mulu_1_val(2*WORD_SIZE-1 downto WORD_SIZE);
				
--						when ALU_DIVQ => 
--							val_1 <= quo_1;
--					
--						when ALU_DIVR =>
--							val_1 <= rem_1;
						
						when others =>
					end case;	
			end if;
		end if;		
	end process;
	
	val_0 <= val_0_int;
	val_1 <= val_1_int;
	
	
	do_clk_state: process (clk, reset, mul_div_state, ctrl_0, func_0_reg, mul_div_0_reg, mul_div_0_sel_reg, ctrl_1, func_1_reg, mul_div_1_reg, mul_div_1_sel_reg, ex_stall)
	begin
		if reset = '1'  then
			mul_div_state <= IDLE;
			stall_cycles <= "0000";
			
		else
			if rising_edge (clk) then
				case mul_div_state is
					when IDLE =>
						stall_cycles <= "0000";
						
						if ex_stall = '0' then 
						
							if ctrl_0.mul_div = '1' or ctrl_1.mul_div = '1' then
								mul_div_state <= WAITING;							
							end if;	
							
							if ctrl_0.mul_div_sel = '1' or ctrl_1.mul_div_sel = '1' then
								mul_div_state <= REG;		
							end if;						
						
						end if;

					when REG => 
						mul_div_state <= WAITING;
					
					when WAITING =>
						stall_cycles <= stall_cycles + 1;
					
					   if stall_cycles = "1111" then				
							mul_div_state <= RESULT;	
						end if;
						
						--if ((func_0_reg = ALU_MULL or func_0_reg = ALU_MULL64H or func_0_reg = ALU_MULL64HU) and func_1_reg /= ALU_DIVQ) then
						if (mul_div_0_sel_reg = '0') then						
							mul_div_state <= RESULT;	
						end if;			
				
						--if ((func_1_reg = ALU_MULL or func_1_reg = ALU_MULL64H or func_1_reg = ALU_MULL64HU) and func_0_reg /= ALU_DIVQ) then
						if (mul_div_1_sel_reg = '0' and mul_div_0_sel_reg = '0') then
							mul_div_state <= RESULT;	
						end if;					
					
					when RESULT =>
						mul_div_state <= DONE;	
						
					when DONE =>
						mul_div_state <= IDLE;	
						
				end case;		
			end if;		
		end if;	
	end process;
	

	do_state_output: process (mul_div_state, ctrl_0, func_0_reg, mul_div_0_reg, ctrl_1, func_1_reg, mul_div_1_reg, dest_reg_0_reg, dest_reg_1_reg, ex_stall)
	begin
		stall 					<= '0';
		out_enable 			<= '0';
		reg_enable 			<= '1';
		mull_0_clk_en 	<= '0';
		mull_1_clk_en 	<= '0';
		mullu_0_clk_en 	<= '0';
		mullu_1_clk_en 	<= '0';
		div_0_clk_en     <= '0';
		divu_0_clk_en   <= '0';	
		wb_wait				 <= '0';
	
		val_rd_0	<= '0';
		val_rd_1	<= '0';
		
		wb_dest_reg_0 <= (wb_dest_reg_0'range => '0');
		wb_dest_reg_1 <= (wb_dest_reg_1'range => '0');
		
		mul_to_mul_rst_0 <= '0';
		mul_to_mul_rst_1 <= '0';
	
		case mul_div_state is
			when IDLE =>								
												
				if ctrl_0.mul_div = '1' and  ex_stall = '0' then
					stall 					<= '1';
					--mull_0_clk_en 	<= '1';
					--div_0_clk_en     <= '1';
					
					if src_1_mul_0_to_0 = '1' or src_2_mul_0_to_0 = '1' then
						mul_to_mul_rst_0 <= '1';
					end if;
					
					if src_1_mul_1_to_0 = '1' or src_2_mul_1_to_0 = '1' then
						mul_to_mul_rst_0 <= '1';
					end if;					
						
				end if;
				
				if ctrl_1.mul_div = '1' and ex_stall = '0' then
					stall 					<= '1';
					--mull_1_clk_en 	<= '1';
					--div_1_clk_en     <= '1';
					
					if src_1_mul_0_to_1 = '1' or src_2_mul_0_to_1 = '1' then
						mul_to_mul_rst_1 <= '1';
					end if;
					
					if src_1_mul_1_to_1 = '1' or src_2_mul_1_to_1 = '1' then
						mul_to_mul_rst_1 <= '1';
					end if;
					
				end if;				
		
			when REG => 
				stall 				<= '1';
				--div_0_clk_en <= '1';
				reg_enable	<= '0';
					wb_wait	<= '1';
				
		
			when WAITING =>
				stall 			<= '1';
				wb_wait			<= '1';
				reg_enable	<= '0';
							
				if func_0_reg = ALU_MULL or func_0_reg = ALU_MULL64H then
					mull_0_clk_en <= '1';
				end if;
				
				if func_1_reg = ALU_MULL or func_1_reg = ALU_MULL64H then
					mull_1_clk_en <= '1';
				end if;		
				
				if func_0_reg = ALU_MULL64HU then
					mullu_0_clk_en <= '1';
				end if;
				
				if func_1_reg = ALU_MULL64HU then
					mullu_1_clk_en <= '1';
				end if;
				
				if func_0_reg = ALU_DIVQ or func_0_reg = ALU_DIVR then
					div_0_clk_en <= '1';
				end if;
				
				if func_0_reg = ALU_DIVQU or func_0_reg = ALU_DIVRU then
					divu_0_clk_en <= '1';
				end if;
												
			when RESULT =>
				out_enable <= '1';
				stall 			<= '1';
				reg_enable	<= '0';
				wb_wait	<= '1';
				
				if mul_div_0_reg = '1' then				
					val_rd_0 				<= '1';
					wb_dest_reg_0 <= dest_reg_0_reg;
				end if;
				
				if mul_div_1_reg = '1' then				
					val_rd_1 				<= '1';
					wb_dest_reg_1 <= dest_reg_1_reg;
				end if;
				
			when DONE =>
				wb_wait	<= '1';
				reg_enable	<= '0';
					
			end case;
	end process;
	
	
	process (clk, reset, reg_enable, src1_in_0, src2_in_0, src1_in_1, src2_in_1, ctrl_0, ctrl_1)
	begin
	
		if reset = '1' then
			src1_in_0_reg <= (src1_in_0_reg'range => '0');
			src2_in_0_reg <= (src2_in_0_reg'range => '0');
			
			src1_in_1_reg <= (src1_in_1_reg'range => '0');
			src2_in_1_reg <= (src2_in_1_reg'range => '0');
	
			func_0_reg			<= (func_0_reg'range => '0');
			dest_reg_0_reg <= (dest_reg_0_reg'range => '0');
			mul_div_0_reg				<= '0';
			mul_div_0_sel_reg	<= '0';
			
			func_1_reg				<= (func_1_reg'range => '0');
			dest_reg_1_reg	 <= (dest_reg_1_reg'range => '0');
			mul_div_1_reg			<= '0';
			mul_div_1_sel_reg	<= '0';
		
		else
			if rising_edge(clk) and reg_enable = '1' then

				src1_in_0_reg <= src1_0_val;
				src2_in_0_reg <= src2_0_val;
				
				src1_in_1_reg <= src1_1_val;
				src2_in_1_reg <= src2_1_val;
				
				func_0_reg <= ctrl_0.alu_func;
				dest_reg_0_reg <= ctrl_0.dest_reg;
				mul_div_0_reg <= ctrl_0.mul_div;
				mul_div_0_sel_reg <= ctrl_0.mul_div_sel;
				
				func_1_reg <= ctrl_1.alu_func;
				dest_reg_1_reg <= ctrl_1.dest_reg;
				mul_div_1_reg <= ctrl_1.mul_div;
				mul_div_1_sel_reg <= ctrl_1.mul_div_sel;			
				
			end if;		
		end if;
	end process;
	
		
	mull_0 : mul_64_signed port map
	(
		clken		=> mull_0_clk_en,
		clock		=> clk,
		dataa		=> src1_in_0_reg,
		datab		=> src2_in_0_reg,
		result		=> mul_0_val
	);
	
	mull_1 : mul_64_signed port map
	(
		clken		=> mull_1_clk_en,
		clock		=> clk,
		dataa		=> src1_in_1_reg,
		datab		=> src2_in_1_reg,
		result		=> mul_1_val
	);
--	
--			
	mullu_0 : mul_64_unsigned port map
	(
		clken		=> mullu_0_clk_en,
		clock		=> clk,
		dataa		=> src1_in_0_reg,
		datab		=> src2_in_0_reg,
		result		=> mulu_0_val
	);
	
	mullu_1 : mul_64_unsigned port map
	(
		clken		=> mullu_1_clk_en,
		clock		=> clk,
		dataa		=> src1_in_1_reg,
		datab		=> src2_in_1_reg,
		result		=> mulu_1_val
	);
	
	div_0 : div_signed port map
	(
	   clken => div_0_clk_en,
		clock => clk,
		denom 	=> src2_in_0_reg,
		numer 	=> src1_in_0_reg,
		quotient => quo_0,
		remain	=> rem_0
	);
--
	divu_0 : div_unsigned port map
	(
	   clken => divu_0_clk_en,
		clock => clk,		
		denom 	=> src2_in_0_reg,
		numer 	=> src1_in_0_reg,
		quotient => quou_0,
		remain	=> remu_0
	);
	
	
	
--	div_1 : div_signed port map
--	(
--		denom 	=> src2_in_1,
--		numer 	=> src1_in_1,
--		quotient => quo_1,
--		remain	=> rem_1
--	);
	

end rtl;
