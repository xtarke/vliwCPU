--------------------------------------------------------------------------------
--  VLIW-RT CPU - CPU core entity
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

-- Insert library and use clauses
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;
use work.cpu_typedef_package.all;
-- use work.cpu_sim_package.all;

-- text debug
library STD;
use STD.textio.all;
use IEEE.std_logic_textio.all;  
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;


ENTITY vliwcpu IS
port (
	clk     		 : in std_logic;	
	clk_mem  : in std_logic;
	reset  	 	 : in std_logic;

	i_address                  : out std_logic_vector(INS_ADDR_SIZE-1 downto 0);       -- address
	i_read                       : out std_logic := '1';                                    											 -- read
	i_readdata                : in  std_logic_vector(31 downto 0) := (others => 'X'); 		-- readdata
	i_waitrequest            : in  std_logic                     := 'X';             							  -- waitrequest
	i_readdatavalid         : in  std_logic                     := 'X';            							 -- readdatavalid
	
	i_chipselect					: out std_logic;
	
	d_address                : out std_logic_vector(DATA_ADDR_SIZE-1  downto 0);                    -- address
	d_byteenable           : out std_logic_vector(3 downto 0);                    -- byteenable
	d_read                     : out std_logic;                                     				   -- read
	d_readdata              : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
	d_waitrequest          : in  std_logic                     := 'X';             -- waitrequest
	d_write                     : out std_logic;                                        -- write
	d_writedata              : out std_logic_vector(31 downto 0);                    -- writedata
	d_readdatavalid       : in  std_logic                     := 'X';             -- readdatavalid

	d_chipselect				  : out std_logic_vector(3 downto 0);

	f_error		: out std_logic;
	m_error  : out std_logic;
	halt			: out std_logic;

	-- sim debug
	pc_out				: out word_t;
	slot_0_out		: out word_t;
	slot_1_out		: out word_t;
	slot_2_out		: out word_t;
	slot_3_out		: out word_t;
	
	instructions		: out word_t;		
	alu_ops 				: out word_t;		-- format = "00"
	special_ops		: out word_t;		-- format = "01"	
	mem_ops			: out word_t;		-- format = "10"
	branche_ops : out word_t;		-- format = "11"	
	
	n_ctrl_flow      : out word_t;
	
	cache_stall_out : out std_logic := '0';
	stall_out					: out std_logic	:= '0'
	
	);
END ENTITY vliwcpu;


ARCHITECTURE rtl OF vliwcpu IS

	----------------------------------
	-- 1st cycle: cache transaction --
	----------------------------------	
		
	COMPONENT cache		
		port(	
			
		clk     : in std_logic;
		mem_clk : in std_logic;
		reset   : in std_logic;
		abort   : in std_logic;		
		address         : in pc_t;
		
		--RAM memory read control
		mem_data_in    : in word_t;
		mem_addr_out   : out word_t;
		mem_enable_out : out std_logic; 	
		ram_clk_en_out : out std_logic;

		--cache data out
		data_out  : out std_logic_vector (CACHE_LINE_SIZE-1 downto 0);
		cache_data_rdy : out std_logic;
		stall_out : out std_logic
		
		);	
	END COMPONENT cache;
	
	
	----------------------------------
	-- 1st cycle: cache buffer	
	-- 2nd cycle: instruction buffer
	----------------------------------	
	
	component fetch
		port(
			clk      			: in std_logic;	
			halt					: in std_logic;
			reset    			: in std_logic;
			cache_busy 			: in std_logic;
			cache_data_rdy : in std_logic;
			mem_busy				: in std_logic;
			dep_stall 			: in std_logic;
			
			branch_in		: in std_logic;
			b_address	: in pc_t;
			
			goto_in : in std_logic;
			goto_addr : in pc_t;
			
			jump_reg	: in std_logic;
			link_reg	: in pc_t;
			
			preld_en			: in std_logic;
			preload_addr	: in pc_t;
			
			cache_line_in  : in  std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
			
			bundle_error		: out std_logic;
			cache_address	: out pc_t;
			next_pc_out			: out pc_t;
			cache_abort 		: out std_logic;
			
			n_ctrl_flow 	: out word_t;

			slot_ctrl_0 	: out t_slot_ctrl;
			slot_ctrl_1 	: out t_slot_ctrl;
			slot_ctrl_2 	: out t_slot_ctrl;
			slot_ctrl_3 	: out t_slot_ctrl;
			
			ex_stall     	: out std_logic;
			delay_dep	: out std_logic;
			
			slot_0 			: out word_t;
			slot_1 			: out word_t;
			slot_2 			: out word_t;
			slot_3 			: out word_t			
		);
	end component;
	
	
	-------------------------------------------
	-- 3rd cycle: register read, 
	-- 			  bundle instrunction decoding
	-------------------------------------------
	
	component reg_file_lvt
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
	end component;
	
	component pred_reg_file
	port (
		clk     : in std_logic;
		reset	  : in std_logic;
		
		port0_w_en 			: in std_logic;
		port1_w_en 			: in std_logic;
		port2_w_en 			: in std_logic;
		port3_w_en 			: in std_logic;
		port4_w_en 			: in std_logic;
		
		port0_w_data		: in std_logic;
		port1_w_data		: in std_logic;
		port2_w_data		: in std_logic;
		port3_w_data		: in std_logic;
		port4_w_data		: in std_logic;
		
		
		port0_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port1_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port2_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port3_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port4_w_addr 		: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		
		port0_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		--port0_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port1_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		--port1_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port2_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		--port2_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port3_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		--port3_b_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		port4_a_rd_addr 	: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);	
		
		port0_a_rd			: out std_logic;
		--port0_b_rd			: out std_logic;
		port1_a_rd			: out std_logic;
		--port1_b_rd			: out std_logic;
		port2_a_rd			: out std_logic;
		--port2_b_rd			: out std_logic;
		port3_a_rd			: out std_logic;
		--port3_b_rd			: out std_logic;
		port4_a_rd			: out std_logic

		);
	end component;	
	
	component controller	
		port (
		clk  					  : in std_logic;	
		reset 				  : in std_logic;
		dep_stall		  : in std_logic;
		delay_dep	  : in std_logic;
		ex_stall			  : in std_logic;
		
		slot_in  : in word_t;	
		
		-- performance monitoring
		alu_ops 				: out word_t;		-- format = "00"
		special_ops		: out word_t;		-- format = "01"	
		mem_ops			: out word_t;		-- format = "10"
		branche_ops : out word_t;		-- format = "11"
		
		ctrl   : out t_ctrl		
	);
	end component;
	
	component imm_controller
	port (
			clk    : in std_logic;	
			reset  : in std_logic;
				
			slot_0_in : in word_t;
			slot_1_in : in word_t;
			slot_2_in : in word_t;
			slot_3_in : in word_t;
					
			imm_0_out		 : out word_t;
			imm_1_out		 : out word_t;
			imm_2_out		 : out word_t;
			imm_3_out		 : out word_t	
	);
	end component imm_controller;
	
	component ex_buffer
	port (
		clk    : in std_logic;	
		reset  : in std_logic;
		
		ex_stall : in std_logic;
		
		ctrl_in_0     : in t_ctrl;
		ctrl_in_1   	 : in t_ctrl;
		ctrl_in_2     : in t_ctrl;
		ctrl_in_3     : in t_ctrl;
		
		pc						 : in pc_t;
		
		reg_src1_in_0		 : in word_t;
		reg_src2_in_0		 : in word_t;
		
		reg_src1_in_1		 : in word_t;
		reg_src2_in_1		 : in word_t;
		
		reg_src1_in_2		 : in word_t;
		reg_src2_in_2		 : in word_t;
		
		reg_src1_in_3		 : in word_t;
		reg_src2_in_3		 : in word_t;
		
		imm_in_0	 : in word_t;
		imm_in_1	 : in word_t;
		imm_in_2	 : in word_t;
		imm_in_3	 : in word_t;
		
		f_pred	: in std_logic;
		
		scond_in_0			: in std_logic;
		scond_in_1			: in std_logic;
		scond_in_2			: in std_logic;
		scond_in_3			: in std_logic;
				
		ctrl_out_0 				: out t_ctrl;
		reg_src1_out_0	: out word_t;
		reg_src2_out_0	: out word_t;
		scond_out_0			: out std_logic;
		imm_out_0  			: out word_t;
		
		ctrl_out_1 				: out t_ctrl;
		reg_src1_out_1	: out word_t;
		reg_src2_out_1	: out word_t;
		scond_out_1			: out std_logic;
		imm_out_1  			: out word_t;
		
		ctrl_out_2 				: out t_ctrl;
		reg_src1_out_2	: out word_t;
		reg_src2_out_2	: out word_t;
		scond_out_2			: out std_logic;
		imm_out_2  			: out word_t;
		
		ctrl_out_3 				: out t_ctrl;
		reg_src1_out_3	: out word_t;
		reg_src2_out_3	: out word_t;
		scond_out_3			: out std_logic;
		imm_out_3  			: out word_t		
	);
	end component ex_buffer;
	
	component mux_branch is
	port
	(
		--clock		: IN STD_LOGIC ;
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data3x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);	
		data4x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel					: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		result			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component mux_branch;
	
	component branch_controller is
	port (
		clk    	: in std_logic;	
		reset  : in std_logic;
		
		slot_0_in		 : in word_t;
		reg_addr 		 : in word_t;
		
		-- branch prediction
		slot_1_in		 : in word_t;
		slot_2_in		 : in word_t;
		slot_3_in		 : in word_t;
	
		dep_stall		 : in std_logic;
		ex_stall			 : in std_logic;
		delay_dep	 : in std_logic;	-- true when ex stall happens with a dep_stall
	
		pc					: in pc_t;
		pred_value 		: in std_logic;
		
		branch_en		: out std_logic;	
		branch_addr		: out pc_t;
	
		goto_en			: out std_logic;
		goto_addr		: out pc_t;
	
		jump_reg_en 	: out  std_logic;
		
		preld_en			: out std_logic;
		preload_addr	: out pc_t
		
		);
	end component branch_controller;
	
	component mem_addr
		PORT
		(
			clock		: IN STD_LOGIC ;
			dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;
	
	component interlock
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
	end component;	
	
	--------------------------------
	-- 4th cycle: execution units	-- 			 
	--------------------------------
	
	component salu is
	port (
		clk    : in std_logic;	
		reset  : in std_logic;
		ex_stall : in std_logic;
		
		-- cycle that need forward
		rd_ctrl_src_0_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_1_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_2_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_3_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		
		rd_ctrl_src_0_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_1_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_2_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_3_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		
		scond_0					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		scond_1					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		scond_2					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		scond_3					: in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		
		branch_en				: in std_logic;	
		
		-- immediates	
		imm_0							: word_t;
		imm_1							: word_t;
		imm_2							: word_t;
		imm_3							: word_t;
		
		-- register / immediate selection
		src_2_sel_0				: IN STD_LOGIC;
		src_2_sel_1				: IN STD_LOGIC;
		src_2_sel_2				: IN STD_LOGIC;
		src_2_sel_3				: IN STD_LOGIC;
		
		-- destination registers
		wb_addr_reg_0		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		wb_reg_w_en_0	: in std_logic;
			
		wb_addr_reg_1		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		wb_reg_w_en_1	: in std_logic;
		
		wb_addr_reg_2		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		wb_reg_w_en_2	: in std_logic;
		
		wb_addr_reg_3		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		wb_reg_w_en_3	: in std_logic;
		
		wb_mem_rd_0			: in std_logic;
		wb_mem_rd_1			: in std_logic;
	
		wb_mul_div_0		: in std_logic;
		wb_mul_div_1		: in std_logic;
		
		-- destination predicates
		wb_addr_pred_0 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		wb_pred_w_en_0: in std_logic;
		
		wb_addr_pred_1 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		wb_pred_w_en_1: in std_logic;
		
		wb_addr_pred_2 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		wb_pred_w_en_2: in std_logic;
		
		wb_addr_pred_3 : in std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		wb_pred_w_en_3: in std_logic;	
			
		func_0   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
		func_1   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
		func_2   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
		func_3   : in std_logic_vector(ALU_FUN_SIZE-1 downto 0);	
		
		carry_in_0		 : in std_logic;
		carry_in_1		 : in std_logic;
		carry_in_2		 : in std_logic;
		carry_in_3		 : in std_logic;
		
		src1_in_0		 : in word_t;
		src2_in_0		 : in word_t;
		
		src1_in_1		 : in word_t;
		src2_in_1		 : in word_t;
		
		src1_in_2		 : in word_t;
		src2_in_2		 : in word_t;
		
		src1_in_3		 : in word_t;
		src2_in_3		 : in word_t;
		
		memory_data			: in word_t;
		memory_data_1	: in word_t;
		
		mul_div_0_data	: in word_t;
		mul_div_1_data	: in word_t;
					
		alu_out_0		: out t_alu_val;
		alu_out_1		: out t_alu_val;
		alu_out_2		: out t_alu_val;
		alu_out_3		: out t_alu_val
		);
	end component salu;
	

	component mul_div_unit is
	port (
		clk    : in std_logic;	
		reset  : in std_logic;
		ex_stall : in std_logic;
		
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
		wb_reg_w_en_0	: in std_logic;
			
		wb_addr_reg_1		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		wb_reg_w_en_1	: in std_logic;
		
		wb_addr_reg_2		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		wb_reg_w_en_2	: in std_logic;
		
		wb_addr_reg_3		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		wb_reg_w_en_3	: in std_logic;
		
		alu_val_0					: in word_t;
		alu_val_1					: in word_t;
		alu_val_2					: in word_t;
		alu_val_3					: in word_t;
	
		memory_data					: in word_t;
		memory_data_1				: in word_t;	
		
		src1_in_0		 : in word_t;
		src2_in_0		 : in word_t;
		
		src1_in_1		 : in word_t;
		src2_in_1		 : in word_t;
		
		src1_in_2		 : in word_t;
		src2_in_2		 : in word_t;
		
		src1_in_3		 : in word_t;
		src2_in_3		 : in word_t;				
					
		stall			: out std_logic;	
--		dep_stall			: out std_logic;			
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
	end component mul_div_unit;

	
	component mux_sram is
	port
	(
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data3x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data4x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component mux_sram;
	
	component ld_st_unit 
	port
	(
		clk				: in std_logic;
		clk_mem : in std_logic;
		reset			 : in std_logic;
		ex_stall    : in std_logic;
	
		-- control interface
		slot_0_reg_addr		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		slot_0_mem_wr		: in std_logic;
		slot_0_mem_rd			: in std_logic;
		slot_0_mem_byteen	: in std_logic_vector(1 downto 0);
		slot_0_mem_sext		: in std_logic;
		slot_0_reg_w_en		: in std_logic;
		
		slot_1_reg_addr		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		slot_1_mem_wr		: in std_logic;
		slot_1_mem_rd			: in std_logic;
		slot_1_mem_byteen	: in std_logic_vector(1 downto 0); 
		slot_1_mem_sext		: in std_logic;
		slot_1_reg_w_en		: in std_logic;
		
		slot_2_reg_addr		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		slot_2_reg_w_en		: in std_logic;
		
		slot_3_reg_addr		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		slot_3_reg_w_en		: in std_logic;

		-- forward logic
		rd_ctrl_src_0_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_1_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_2_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_3_a		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
		rd_ctrl_src_0_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_1_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_2_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_3_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		
		rd_ctrl_mem_wr_0	   : in std_logic;
		rd_ctrl_mem_wr_1	   : in std_logic;
		rd_ctrl_mem_rd_0		: in std_logic;
		rd_ctrl_mem_rd_1		: in std_logic;
		
		alu_val_0					: in word_t;
		alu_val_1					: in word_t;
		alu_val_2					: in word_t;
		alu_val_3					: in word_t;		
				
		 -- address computation
		imm0		: in	word_t;
		rega0	: in	word_t;
		 
		imm1		: in	word_t;
		rega1	: in	word_t;
				
		-- values to write
		regw0	: in	word_t;
		regw1	: in	word_t;	
--		regw2	: in	word_t;
--		regw3	: in	word_t;		
	
		d_address                : out std_logic_vector(DATA_ADDR_SIZE-1  downto 0);                    -- address
		d_byteenable           : out std_logic_vector(3 downto 0);                    -- byteenable
		d_read                     : out std_logic;                                     				   -- read
		d_readdata              : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
		d_waitrequest          : in  std_logic                     := 'X';             -- waitrequest
		d_write                     : out std_logic;                                        -- write
		d_writedata              : out std_logic_vector(31 downto 0);                    -- writedata
		d_readdatavalid       : in  std_logic                     := 'X';             -- readdatavalid
	
		d_chipselect				  : out std_logic_vector(3 downto 0);
		
		memory_data	  : out word_t;
		
		memory_data_1 : out word_t;
					
		wb_wait				: out std_logic;
		stall						: out std_logic;
		
		-- internal ScratchPad data interface
		sp_a_rd : out std_logic;
		sp_b_rd : out std_logic;
	
		sp_a_wr : out std_logic;
		sp_b_wr : out std_logic;
	
		sp_a_data : in word_t;
		sp_b_data : in word_t;
	
		sp_a_dataw : out word_t;
		sp_b_dataw : out word_t;
	
		sp_a_addr : out std_logic_vector(SP_ADDR_SIZE-1 downto 0);
		sp_b_addr : out std_logic_vector(SP_ADDR_SIZE-1 downto 0);
	
		sp_a_byteen : out std_logic_vector(3 DOWNTO 0);
		sp_b_byteen : out std_logic_vector(3 DOWNTO 0);	
	
		log : out std_logic;
		
		-- ld_st error
		error						: out std_logic

	);
	end component ld_st_unit;
	
	
	-------------------------------------------
	-- 5th cycle: write register/memory back --
	-------------------------------------------
	
	component wb_buffer is
	port (
		clk    : in std_logic;	
		reset  : in std_logic;
		stall :in std_logic;
			
		ctrl_in      : in t_ctrl;
		
		mul_div_w_addr_in	: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		mul_div_w_en_in		: in std_logic;
		
		pred_reg_w_addr	:	out std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
		pred_reg_w_en		:	out std_logic;	
		
		halt					: out std_logic;
			
		reg_w_addr	: out std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		reg_w_en		: out std_logic;
		wb_mux_sel  : out std_logic_vector(1 downto 0)
	);
	end component wb_buffer;
	
	component wb_mux IS
	port
	(
		data0x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data2x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data3x		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel				: IN STD_LOGIC_VECTOR(1 downto 0) ;
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component wb_mux;
	
	component dp_sp
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		byteena_a		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
		byteena_b		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
		clock		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rden_a		: IN STD_LOGIC  := '1';
		rden_b		: IN STD_LOGIC  := '1';
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;
	
	component perf_module is
	port (
		clk    				  : in std_logic;	
		reset				  : in std_logic;
		
		dep_stall		  : in std_logic;	-- current interlock dependecy detection	
		delay_dep	  : in std_logic;	-- true when ex stall happens with a dep_stall
		ex_stall			  : in std_logic;	-- execution stage dependecy
		
		instructions   : out word_t;
			
		slot_0_in  : in word_t	
	);
	end component perf_module;
	
	----------------------- signals ------------------
	
	--signal data_out_enable : std_logic;	
	signal address         : pc_t;
	
	signal rom_addr       : std_logic_vector(INS_ADDR_SIZE-1 downto 0);     
	
	--RAM memory read control
	signal mem_data_in    : word_t;
	signal mem_addr_out   : std_logic_vector (RAM_ADDR_SIZE-1 downto 0);
	signal mem_enable_out : std_logic; 

	--cache data out
	signal cache_line : std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
	signal stall 		: std_logic;
	
	signal slot_ctrl_0 	: t_slot_ctrl;
	signal slot_ctrl_1 	: t_slot_ctrl;
	signal slot_ctrl_2 	: t_slot_ctrl;
	signal slot_ctrl_3 	: t_slot_ctrl;
	
	signal ctrl_0			: t_ctrl;
	signal ctrl_1			: t_ctrl;
	signal ctrl_2			: t_ctrl;
	signal ctrl_3			: t_ctrl;
	
	-- debug
	signal slot_0 : word_t;
	signal slot_1 : word_t;
	signal slot_2 : word_t;
	signal slot_3 : word_t; 
	
	-- branch
	signal branch_enable     : std_logic;
	signal branch_addr  : pc_t;
	signal goto_enable     : std_logic;
	signal goto_addr  : pc_t;
	
	signal jump_reg_enable : std_logic;
	
	signal preld_en		: std_logic;
	signal preload_addr	: pc_t;
	
	-- pc
	signal pc				: pc_t;
	
	-- register file data
	signal port0_a_rd : 	word_t;
	signal port0_b_rd : 	word_t;
	signal port1_a_rd	: 		word_t;
	signal port1_b_rd : 	word_t; 
	signal port2_a_rd : 	word_t; 
	signal port2_b_rd : 	word_t; 
	signal port3_a_rd : 	word_t; 
	signal port3_b_rd : 	word_t;
	
	signal port0_w_addr	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port1_w_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port2_w_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port3_w_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal port0_w_en 		 : std_logic;
	signal port1_w_en 		 : std_logic;
	signal port2_w_en 		 : std_logic; 
	signal port3_w_en 		 : std_logic;
	
	signal port0_w_data 		: word_t;
	signal port1_w_data 		: word_t;
	signal port2_w_data 		: word_t;
	signal port3_w_data 		: word_t;
	
	-- pred register file data
	
	signal pred_port0_a_rd : 	std_logic;
	--signal port0_b_rd : 	word_t;
	signal pred_port1_a_rd	: 	std_logic;
	--signal port1_b_rd : 	word_t; 
	signal pred_port2_a_rd : 	std_logic; 
	--signal port2_b_rd : 	word_t; 
	signal pred_port3_a_rd : 	std_logic; 
	--signal port3_b_rd : 	word_t;
	signal pred_port4_a_rd : 	std_logic; 
	
	signal pred_port0_w_addr	 : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal pred_port1_w_addr 	 : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal pred_port2_w_addr 	 : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal pred_port3_w_addr 	 : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	signal pred_port4_w_addr 	 : std_logic_vector(PRED_ADDR_SIZE-1 downto 0);
	
	signal pred_port0_w_en 		 : std_logic;
	signal pred_port1_w_en 		 : std_logic;
	signal pred_port2_w_en 		 : std_logic; 
	signal pred_port3_w_en 		 : std_logic;
	signal pred_port4_w_en 		 : std_logic;
	
	signal pred_port0_w_data 		: word_t;
	signal pred_port1_w_data 		: word_t;
	signal pred_port2_w_data 		: word_t;
	signal pred_port3_w_data 		: word_t;	
	signal pred_port4_w_data 		: word_t;
	
	-- ex signals	
	signal ex_ctrl_0				: t_ctrl;
	signal ex_ctrl_1				: t_ctrl;
	signal ex_ctrl_2				: t_ctrl;
	signal ex_ctrl_3				: t_ctrl;
	
	signal ex_reg_src1_0			: word_t;
	signal ex_reg_src2_0			: word_t;
	signal ex_reg_scond_0		: std_logic;
	
	signal ex_reg_src1_1			: word_t;
	signal ex_reg_src2_1			: word_t;
	signal ex_reg_scond_1		: std_logic;
	
	signal ex_reg_src1_2			: word_t;
	signal ex_reg_src2_2			: word_t;
	signal ex_reg_scond_2		: std_logic;
	
	signal ex_reg_src1_3			: word_t;
	signal ex_reg_src2_3			: word_t;
	signal ex_reg_scond_3		: std_logic;
	
	signal ex_addr0						: word_t;
	signal ex_addr1						: word_t;
	signal ex_addr2						: word_t;
	signal ex_addr3						: word_t;
		
	signal alu_0_val				: t_alu_val;
	signal alu_1_val				: t_alu_val;
	signal alu_2_val				: t_alu_val;
	signal alu_3_val				: t_alu_val;
	
	signal imm_0	      	: word_t;
	signal imm_1	      	: word_t;
	signal imm_2	      	: word_t;
	signal imm_3	      	: word_t;
	
	signal mul_div_0	   : word_t;
	signal mul_div_1	   : word_t;
	signal mul_div_2	   : word_t;
	signal mul_div_3	   : word_t;
	
	signal ex_imm_0	      	: word_t;
	signal ex_imm_1	      	: word_t;
	signal ex_imm_2	      	: word_t;
	signal ex_imm_3	      	: word_t;
	
	signal mux_src2_0_val		: word_t;
	signal mux_src2_1_val		: word_t;
	signal mux_src2_2_val		: word_t;
	signal mux_src2_3_val		: word_t;
	
	
	signal ld_st_ssram_data_sel : std_logic_vector (2 downto 0);
	--signal ssram_data_w_data : word
	
	-- wb signals
	signal reg_data_0		: word_t;
	signal reg_data_1		: word_t;
	signal reg_data_2		: word_t;
	signal reg_data_3		: word_t;
	
	signal wb_mux_sel_0 : std_logic_vector(1 downto 0);
	signal wb_mux_sel_1 : std_logic_vector(1 downto 0);
	signal wb_mux_sel_2 : std_logic_vector(1 downto 0);
	signal wb_mux_sel_3 : std_logic_vector(1 downto 0);
	
	signal mul_div_val_rd_0 : std_logic;
	signal mul_div_val_rd_1 : std_logic;
	
	signal mul_div_dest_reg_0 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal mul_div_dest_reg_1 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal slow_mem_w_en_2 : std_logic;
	signal slow_mem_w_en_3 : std_logic;
	
   signal halt_0 : std_logic;
	signal halt_1 : std_logic;
	signal halt_2 : std_logic;
	signal halt_3 : std_logic;
		
	-- branch logic	
	signal cache_abort :std_logic;
	
	signal all_halt			 : std_logic;	
	signal mem_stall   : std_logic;
	
	signal dep_stall				: std_logic;
	
	signal mul_div_dep_stall	: std_logic;
	signal mul_div_ex_stall	: std_logic;
	
	signal ex_stall	: std_logic;
	signal fetch_ext_stall : std_logic;
	signal delay_dep : std_logic;
	
	signal wb_stall 			: std_logic;
	signal ld_st_wb_stall : std_logic;
	signal mul_div_wb_stall : std_logic;
	signal wb_mem_rd		: std_logic;
	
	signal ins_addr_32 : word_t;
	signal data_addr_32 : word_t;
	
	signal memory_data : word_t;	
	
	signal memory_data_1 : word_t;	
	
	signal ld_st_error		: std_logic;					
	
	-- performance counters
	signal s0_alu_ops 				: word_t;		-- format = "00"
	signal s0_special_ops		: word_t;		-- format = "01"	
	signal s0_mem_ops			: word_t;		-- format = "10"
	signal s0_branche_ops :  word_t;		-- format = "11"
	
	signal s1_alu_ops 				: word_t;		-- format = "00"
	signal s1_special_ops		: word_t;		-- format = "01"	
	signal s1_mem_ops			: word_t;		-- format = "10"
	signal s1_branche_ops :  word_t;		-- format = "11"
	
	signal s2_alu_ops 				: word_t;		-- format = "00"
	signal s2_special_ops		: word_t;		-- format = "01"	
	signal s2_mem_ops			: word_t;		-- format = "10"
	signal s2_branche_ops :  word_t;		-- format = "11"
	
	signal s3_alu_ops 				: word_t;		-- format = "00"
	signal s3_special_ops		: word_t;		-- format = "01"	
	signal s3_mem_ops			: word_t;		-- format = "10"
	signal s3_branche_ops :  word_t;		-- format = "11"
	
	signal ops : word_t;
	
	-- internal scratchpad
	signal sp_a_rd : std_logic;
	signal sp_b_rd : std_logic;
	
	signal sp_a_wr : std_logic;
	signal sp_b_wr : std_logic;
	
	signal sp_a_data : word_t;
	signal sp_b_data : word_t;
	
	signal sp_a_dataw : word_t;
	signal sp_b_dataw : word_t;
	
	signal sp_a_addr : std_logic_vector(SP_ADDR_SIZE-1 downto 0);
	signal sp_b_addr : std_logic_vector(SP_ADDR_SIZE-1 downto 0);
	
	signal sp_a_byteen : std_logic_vector(3 DOWNTO 0);
	signal sp_b_byteen : std_logic_vector(3 DOWNTO 0);
	
	signal cache_data_rdy : std_logic;
	
	
	
	signal log : std_logic;
		
BEGIN  -- beginning of architecture body

	--all_halt <= halt_0 or halt_1 or halt_2 or halt_3 or ld_st_error;		-- waits until halt reaches WB stage
	all_halt <= ctrl_0.halt or ld_st_error;		-- halt when controller 
	halt		<= all_halt;
	
	cache_stall_out  <= stall;
	
	m_error <= ld_st_error;
	
	ex_stall <= mem_stall or mul_div_ex_stall;
	
	wb_stall <= ld_st_wb_stall or mul_div_wb_stall;
	
	i_address <= ins_addr_32(INS_ADDR_SIZE-1 downto 0);
	
	cache_1 : cache
		PORT MAP (
			clk => clk, mem_clk => clk_mem, 
			reset => reset, 
			abort => cache_abort,			
			address => address, 
			mem_data_in => i_readdata, 
			mem_addr_out => ins_addr_32,		
			mem_enable_out => i_chipselect,  
			ram_clk_en_out => i_read, 
			data_out => cache_line,			
			cache_data_rdy => cache_data_rdy,
			stall_out => stall
		);
		
	fetch_1: fetch
		port map ( 
			clk => clk, 
			reset => reset, 
			halt  => all_halt,			
			cache_busy => stall,
			cache_data_rdy => cache_data_rdy,
			mem_busy => ex_stall,
			--mem_busy	=> mul_div_ex_stall,
			dep_stall => dep_stall,
			branch_in => branch_enable,
			b_address	=> branch_addr,
			
			goto_in => goto_enable,
			goto_addr => goto_addr,
		
			jump_reg	=> jump_reg_enable,
			link_reg		=> port0_a_rd(PC_SIZE-1 downto 0),
			
			preld_en			=> preld_en,
			preload_addr	=> preload_addr,
			
			n_ctrl_flow => n_ctrl_flow,
			
			cache_abort	=> cache_abort,
			cache_line_in => cache_line,
			bundle_error => f_error,
			cache_address => address,
			next_pc_out => pc,
			ex_stall        => fetch_ext_stall,
			delay_dep	=> delay_dep,
			slot_ctrl_0 => slot_ctrl_0,
			slot_ctrl_1 => slot_ctrl_1,
			slot_ctrl_2 => slot_ctrl_2, 
			slot_ctrl_3 => slot_ctrl_3,		
			slot_0 => slot_0,
			slot_1 => slot_1,
			slot_2 => slot_2,
			slot_3 => slot_3			
		);
		
	reg_file_1: reg_file_lvt
	port map (
		clk     => clk,
		reset	  => reset,		
		port0_w_addr	 => port0_w_addr,
		port1_w_addr 	 => port1_w_addr,
		port2_w_addr 	 => port2_w_addr,
		port3_w_addr 	 => port3_w_addr,
	
		port0_w_en 		 => port0_w_en,
		port1_w_en 		 => port1_w_en,
		port2_w_en 		 => port2_w_en,
		port3_w_en 		 => port3_w_en,
		
		port0_w_data	=> reg_data_0,
		port1_w_data	=> reg_data_1,
		port2_w_data	=> reg_data_2,
		port3_w_data	=> reg_data_3,
		
		port0_a_rd_addr 	 => slot_ctrl_0.src_1,
		port0_b_rd_addr 	 => slot_ctrl_0.src_2,
		port1_a_rd_addr 	 => slot_ctrl_1.src_1,
		port1_b_rd_addr 	 => slot_ctrl_1.src_2,
		port2_a_rd_addr 	 => slot_ctrl_2.src_1,
		port2_b_rd_addr 	 => slot_ctrl_2.src_2,
		port3_a_rd_addr 	 => slot_ctrl_3.src_1,
		port3_b_rd_addr 	 => slot_ctrl_3.src_2,
		
		port0_a_rd 			 => port0_a_rd,
		port0_b_rd 			 => port0_b_rd,
		port1_a_rd			=> port1_a_rd,
		port1_b_rd 			 => port1_b_rd,
		port2_a_rd 			 => port2_a_rd,
		port2_b_rd 			 => port2_b_rd,
		port3_a_rd 			 => port3_a_rd,
		port3_b_rd 			 => port3_b_rd	
	);
	
	pred_reg_file_1: pred_reg_file
	port map (
		clk     				=> clk,
		reset	 				 => reset,		
		port0_w_addr	 => pred_port0_w_addr,
		port1_w_addr 	 => pred_port1_w_addr,
		port2_w_addr 	 => pred_port2_w_addr,
		port3_w_addr 	 => pred_port3_w_addr,
		port4_w_addr 	 => "000",
	
		port0_w_en 		 => pred_port0_w_en,
		port1_w_en 		 => pred_port1_w_en,
		port2_w_en 		 => pred_port2_w_en,
		port3_w_en 		 => pred_port3_w_en,
		port4_w_en 		 => '0',
		
		port0_w_data	=> alu_0_val.carry_cmp,
		port1_w_data	=> alu_1_val.carry_cmp,
		port2_w_data	=> alu_2_val.carry_cmp,
		port3_w_data	=> alu_3_val.carry_cmp,
		port4_w_data	=> '0',
		
		port0_a_rd_addr 	 => slot_ctrl_0.scond,
		--port0_b_rd_addr 	 => slot_ctrl_0.src_2,
		port1_a_rd_addr 	 => slot_ctrl_1.scond,
		--port1_b_rd_addr 	 => slot_ctrl_1.src_2,
		port2_a_rd_addr 	 => slot_ctrl_2.scond,
		--port2_b_rd_addr 	 => slot_ctrl_2.src_2,
		port3_a_rd_addr 	 => slot_ctrl_3.scond,
		--port3_b_rd_addr 	 => slot_ctrl_3.src_2,
		port4_a_rd_addr 	 => "100",
		
		port0_a_rd 			 => pred_port0_a_rd,
		--port0_b_rd 			 => port0_b_rd,
		port1_a_rd			 => pred_port1_a_rd,
		--port1_b_rd 			 => port1_b_rd,
		port2_a_rd 			 => pred_port2_a_rd,
		--port2_b_rd 			 => port2_b_rd,
		port3_a_rd 			 => pred_port3_a_rd,
		--port3_b_rd 			 => port3_b_rd	
		port4_a_rd 			 => pred_port4_a_rd
	);
		
	controller_s0: controller
		port map ( 
			clk => clk,
			reset => reset,
			dep_stall		=> dep_stall,
			delay_dep	=> delay_dep,
			ex_stall => ex_stall,
			
			alu_ops 				=> s0_alu_ops,
			special_ops		=> s0_special_ops,
			mem_ops			=> s0_mem_ops,
			branche_ops => s0_branche_ops,
						
			slot_in  => slot_0,			
			ctrl   =>  ctrl_0
		);
		
	controller_s1: controller
	port map ( 
		clk 		=> clk,
		reset 	=> reset,	
		dep_stall	=> dep_stall,
		delay_dep	=> delay_dep,
		ex_stall => ex_stall,
		
		alu_ops 				=> s1_alu_ops,
		special_ops		=> s1_special_ops,
		mem_ops			=> s1_mem_ops,
		branche_ops => s1_branche_ops,		
		
		slot_in  => slot_1,	
		ctrl   	=>  ctrl_1
	);
	
	controller_s2: controller
	port map ( 
		clk => clk,
		reset => reset,	
		dep_stall	=> dep_stall,
		delay_dep	=> delay_dep,
		ex_stall => ex_stall,
		
		alu_ops 				=> s2_alu_ops,
		special_ops		=> s2_special_ops,
		mem_ops			=> s2_mem_ops,
		branche_ops => s2_branche_ops,		
		
		slot_in  => slot_2,		
		ctrl   =>  ctrl_2
	);
	
	controller_s3: controller
	port map ( 
		clk => clk,
		reset => reset,	
		dep_stall	=> dep_stall,
		delay_dep	=> delay_dep,
		ex_stall => ex_stall,
		
		alu_ops 			=> s3_alu_ops,
		special_ops		=> s3_special_ops,
		mem_ops			=> s3_mem_ops,
		branche_ops => s3_branche_ops,			
		
		slot_in => slot_3,			
		ctrl   =>  ctrl_3
	);
	
	imm_controller_0 :  imm_controller
	port map (
		clk    => clk,
		reset  => reset,
			
		slot_0_in => slot_0,
		slot_1_in => slot_1,
		slot_2_in => slot_2,
		slot_3_in => slot_3,
		
		imm_0_out		=> imm_0,
		imm_1_out		=> imm_1,
		imm_2_out		=> imm_2,
		imm_3_out		=> imm_3
	);	
	
	
	branch_controller_1: branch_controller port map
	(
		clk    => clk,
		reset  => reset, 
			
		slot_0_in => slot_0,
		pc  => pc,
		
		slot_1_in	=> slot_1,
		slot_2_in	=> slot_2,
		slot_3_in	=> slot_3,
		
		delay_dep	=> delay_dep,
		dep_stall		 => dep_stall,
		ex_stall			 => ex_stall,
		
		
		reg_addr => port0_a_rd,			
		pred_value => pred_port0_a_rd,						
					
		branch_en => branch_enable,				
		branch_addr	=> branch_addr,			
		
		goto_en			=> goto_enable, 
		goto_addr	=> goto_addr,
		
		jump_reg_en	=> jump_reg_enable,
		
		preld_en			=> preld_en,
		preload_addr	=> preload_addr		
		
		);
				
	
	interlock_1: interlock port map(
		clk    	=> clk,
		reset  =>	reset,
		
		-- cycle that need forward
		rd_ctrl_src_0_a		=> slot_ctrl_0.src_1,
		rd_ctrl_src_1_a		=> slot_ctrl_1.src_1,
		rd_ctrl_src_2_a		=> slot_ctrl_2.src_1,
		rd_ctrl_src_3_a		=> slot_ctrl_3.src_1,
		
		rd_ctrl_src_0_b		=> slot_ctrl_0.src_2,
		rd_ctrl_src_1_b		=> slot_ctrl_0.src_2,
		rd_ctrl_src_2_b		=> slot_ctrl_0.src_2,
		rd_ctrl_src_3_b		=> slot_ctrl_0.src_2,
		
		rd_ctrl_opc_0			=> slot_0(DECOD_END downto DECOD_INI),
		rd_ctrl_opc_1			=> slot_1(DECOD_END downto DECOD_INI),
		rd_ctrl_opc_2			=> slot_2(DECOD_END downto DECOD_INI),
		rd_ctrl_opc_3			=> slot_3(DECOD_END downto DECOD_INI),
		
		-- destination registers and functions
		wb_addr_reg_0		=> ctrl_0.dest_reg,
		wb_reg_w_en_0	=> ctrl_0.reg_w_en,
		wb_mul_div_0		=> ctrl_0.mul_div,
		wb_mem_rd_0     => ctrl_0.mem_rd,
		wb_b_dest_0	  			=> ctrl_0.b_dest,	
		wb_pred_w_en_0	=> ctrl_0.pred_reg_w_en,	
		
		wb_addr_reg_1		=> ctrl_1.dest_reg,
		wb_reg_w_en_1	=> ctrl_1.reg_w_en,
		wb_mul_div_1		=> ctrl_1.mul_div,
		wb_mem_rd_1     => ctrl_1.mem_rd,
		wb_b_dest_1	  			=> ctrl_1.b_dest,		
		wb_pred_w_en_1	=> ctrl_1.pred_reg_w_en,		
		
		wb_addr_reg_2		=> ctrl_2.dest_reg,
		wb_reg_w_en_2	=> ctrl_2.reg_w_en,
		wb_mul_div_2		=> ctrl_2.mul_div,
		wb_mem_rd_2     => '0',
		wb_b_dest_2	  			=> ctrl_2.b_dest,		
		wb_pred_w_en_2	=> ctrl_2.pred_reg_w_en,		
		
		wb_addr_reg_3		=> ctrl_3.dest_reg,
		wb_reg_w_en_3	=> ctrl_3.reg_w_en,
		wb_mul_div_3		=> ctrl_3.mul_div,
		wb_mem_rd_3     => '0',
		wb_b_dest_3	  			=> ctrl_3.b_dest,		
		wb_pred_w_en_3	=> ctrl_3.pred_reg_w_en,		
	
		dep_stall			=> dep_stall	
	);

	ex_buffer_0: ex_buffer
	port map (
		clk     => clk,
		reset => reset,
		
		ex_stall => fetch_ext_stall,
		
		ctrl_in_0  => ctrl_0,
		ctrl_in_1  => ctrl_1,
		ctrl_in_2  => ctrl_2,
		ctrl_in_3  => ctrl_3,
		
		pc				=> pc,
		
		reg_src1_in_0	=> port0_a_rd,
		reg_src2_in_0	=> port0_b_rd,
		
		reg_src1_in_1	=> port1_a_rd,
		reg_src2_in_1	=> port1_b_rd,
		
		reg_src1_in_2	=> port2_a_rd,
		reg_src2_in_2	=> port2_b_rd,
		
		reg_src1_in_3	=> port3_a_rd,
		reg_src2_in_3	=> port3_b_rd,
		
		imm_in_0	=> imm_0,
		imm_in_1	=> imm_1,
		imm_in_2	=> imm_2,
		imm_in_3	=> imm_3,
		
		f_pred => pred_port4_a_rd,
		
		scond_in_0		=> pred_port0_a_rd,
		scond_in_1		=> pred_port1_a_rd,
		scond_in_2		=> pred_port2_a_rd,
		scond_in_3		=> pred_port3_a_rd,
				
		ctrl_out_0 				=> ex_ctrl_0,
		reg_src1_out_0	=> ex_reg_src1_0,
		reg_src2_out_0	=> ex_reg_src2_0,
		scond_out_0			=> ex_reg_scond_0,
		imm_out_0  			=> ex_imm_0,
		
		ctrl_out_1 				=> ex_ctrl_1,
		reg_src1_out_1	=> ex_reg_src1_1,
		reg_src2_out_1	=> ex_reg_src2_1,
		scond_out_1			=> ex_reg_scond_1,
		imm_out_1  			=> ex_imm_1,
		
		ctrl_out_2 				=> ex_ctrl_2,
		reg_src1_out_2	=> ex_reg_src1_2,
		reg_src2_out_2	=> ex_reg_src2_2,
		scond_out_2			=> ex_reg_scond_2,
		imm_out_2  			=> ex_imm_2,
		
		ctrl_out_3 				=> ex_ctrl_3,
		reg_src1_out_3	=> ex_reg_src1_3,
		reg_src2_out_3	=> ex_reg_src2_3,
		scond_out_3			=> ex_reg_scond_3,
		imm_out_3  			=> ex_imm_3

		);	
	
	wb_mem_rd	<= ex_ctrl_0.mem_rd or ex_ctrl_1.mem_rd;

	alu_1000 :  salu	port  map(
		clk    	=> clk,
		reset  =>	reset,
		ex_stall => fetch_ext_stall,
		
		-- cycle that need forward
		rd_ctrl_src_0_a		=> ctrl_0.src_1_reg,
		rd_ctrl_src_1_a		=> ctrl_1.src_1_reg,
		rd_ctrl_src_2_a		=> ctrl_2.src_1_reg,
		rd_ctrl_src_3_a		=> ctrl_3.src_1_reg,
		
		rd_ctrl_src_0_b		=> ctrl_0.src_2_reg,
		rd_ctrl_src_1_b		=> ctrl_1.src_2_reg,
		rd_ctrl_src_2_b		=> ctrl_2.src_2_reg,
		rd_ctrl_src_3_b		=> ctrl_3.src_2_reg,
		
		scond_0	=> ctrl_0.scond,
		scond_1	=> ctrl_1.scond,		
		scond_2	=> ctrl_2.scond,
		scond_3	=> ctrl_3.scond,
		
		imm_0							=> ex_imm_0,
		imm_1							=> ex_imm_1,
		imm_2							=> ex_imm_2,
		imm_3							=> ex_imm_3,
		
		src_2_sel_0			=> ex_ctrl_0.alu_mux,
		src_2_sel_1		   => ex_ctrl_1.alu_mux,
		src_2_sel_2			=> ex_ctrl_2.alu_mux,
		src_2_sel_3			=> ex_ctrl_3.alu_mux,
		
		branch_en => ctrl_0.branch_en,
		
		-- destination registers
		wb_addr_reg_0		=> ex_ctrl_0.dest_reg,
		wb_reg_w_en_0	=> ex_ctrl_0.reg_w_en,
			
		wb_addr_reg_1		=> ex_ctrl_1.dest_reg,
		wb_reg_w_en_1	=> ex_ctrl_1.reg_w_en,
		
		wb_addr_reg_2		=> ex_ctrl_2.dest_reg,
		wb_reg_w_en_2	=> ex_ctrl_2.reg_w_en,
		
		wb_addr_reg_3		=> ex_ctrl_3.dest_reg,
		wb_reg_w_en_3	=> ex_ctrl_3.reg_w_en,
		
		wb_mem_rd_0		=>  ex_ctrl_0.mem_rd,
		wb_mem_rd_1		=>  ex_ctrl_1.mem_rd,
		
		wb_mul_div_0		=> ex_ctrl_0.mul_div,
		wb_mul_div_1		=> ex_ctrl_1.mul_div,		
		
		---------------------------------------------------------		
		wb_addr_pred_0  => ex_ctrl_0.b_dest,
		wb_pred_w_en_0 => ex_ctrl_0.pred_reg_w_en,
		
		wb_addr_pred_1  => ex_ctrl_1.b_dest,
		wb_pred_w_en_1 => ex_ctrl_1.pred_reg_w_en,
		
		wb_addr_pred_2  => ex_ctrl_2.b_dest,
		wb_pred_w_en_2 => ex_ctrl_2.pred_reg_w_en,
		
		wb_addr_pred_3  => ex_ctrl_3.b_dest,
		wb_pred_w_en_3 => ex_ctrl_3.pred_reg_w_en,
		
		-----------------------
		
		func_0   => ex_ctrl_0.alu_func,
		func_1   => ex_ctrl_1.alu_func,
		func_2   => ex_ctrl_2.alu_func,
		func_3  	=> ex_ctrl_3.alu_func,
		
		carry_in_0		 => ex_reg_scond_0,
		carry_in_1		 => ex_reg_scond_1,
		carry_in_2		 => ex_reg_scond_2,
		carry_in_3		 => ex_reg_scond_3,
		
		src1_in_0		=> ex_reg_src1_0,
		src2_in_0		=> ex_reg_src2_0,
		
		src1_in_1		=> ex_reg_src1_1,
		src2_in_1		=> ex_reg_src2_1,
		
		src1_in_2		=> ex_reg_src1_2,
		src2_in_2		=> ex_reg_src2_2,
		
		src1_in_3		=> ex_reg_src1_3,
		src2_in_3		=> ex_reg_src2_3,
		
		memory_data		=> memory_data,
		memory_data_1	=> memory_data_1,
		
		
		mul_div_0_data	=> mul_div_0,
		mul_div_1_data	=> mul_div_1,
							
		alu_out_0		=> alu_0_val,
		alu_out_1		=> alu_1_val,
		alu_out_2		=> alu_2_val,
		alu_out_3		=> alu_3_val
			
	);
	
	
	mul_div:  mul_div_unit	port  map(
		clk    	=> clk,
		reset  =>	reset,
		ex_stall => fetch_ext_stall,
						
		-- control input
		ctrl_0   => ex_ctrl_0,
		ctrl_1   => ex_ctrl_1,
		ctrl_2   => ex_ctrl_2,
		ctrl_3  	=> ex_ctrl_3,
		
		--forward logic
		rd_ctrl_src_0_a		=> ctrl_0.src_1_reg,
		rd_ctrl_src_1_a		=> ctrl_1.src_1_reg,
		rd_ctrl_src_2_a		=> ctrl_2.src_1_reg,
		rd_ctrl_src_3_a		=> ctrl_3.src_1_reg,
		rd_ctrl_0_mul_div		=> ctrl_0.mul_div,
		
		rd_ctrl_src_0_b		=> ctrl_0.src_2_reg,
		rd_ctrl_src_1_b		=> ctrl_1.src_2_reg,
		rd_ctrl_src_2_b		=> ctrl_2.src_2_reg,
		rd_ctrl_src_3_b		=> ctrl_3.src_2_reg,
		rd_ctrl_1_mul_div		=> ctrl_1.mul_div,
		
		wb_addr_reg_0		=> ex_ctrl_0.dest_reg,
		wb_reg_w_en_0	=> ex_ctrl_0.reg_w_en,
			
		wb_addr_reg_1		=> ex_ctrl_1.dest_reg,
		wb_reg_w_en_1	=> ex_ctrl_1.reg_w_en,
		
		wb_addr_reg_2		=> ex_ctrl_2.dest_reg,
		wb_reg_w_en_2	=> ex_ctrl_2.reg_w_en,
		
		wb_addr_reg_3		=> ex_ctrl_3.dest_reg,
		wb_reg_w_en_3		=> ex_ctrl_3.reg_w_en,
		
		alu_val_0				=> alu_0_val.alu_val,
		alu_val_1				=> alu_1_val.alu_val,
		alu_val_2				=> alu_2_val.alu_val,
		alu_val_3				=> alu_3_val.alu_val,
		
		memory_data				=> memory_data,
		memory_data_1			=> memory_data_1,
		---------------------------------------------------------			
	
		src1_in_0		=> ex_reg_src1_0,
		src2_in_0		=> ex_reg_src2_0,
		
		src1_in_1		=> ex_reg_src1_1,
		src2_in_1		=> ex_reg_src2_1,
		
		src1_in_2		=> ex_reg_src1_2,
		src2_in_2		=> ex_reg_src2_2,
		
		src1_in_3		=> ex_reg_src1_3,
		src2_in_3		=> ex_reg_src2_3,
		
		val_rd_0			=> mul_div_val_rd_0,
		val_rd_1			=> mul_div_val_rd_1,
	
		wb_dest_reg_0		=> mul_div_dest_reg_0,
		wb_dest_reg_1		=> mul_div_dest_reg_1,
		
		stall	 => mul_div_ex_stall,
--		dep_stall => mul_div_dep_stall,
		wb_wait   => mul_div_wb_stall,


					
		val_0		=> mul_div_0,
		val_1		=> mul_div_1,
		val_2		=> mul_div_2,
		val_3		=> mul_div_3
			
	);
	
	ld_st_unit_0	:	ld_st_unit port map
	(
		clk		=> clk,
		clk_mem 	=> clk_mem,
	   reset		=> reset,
		ex_stall => fetch_ext_stall,
		
		slot_0_reg_addr		=> ex_ctrl_0.dest_reg,
		slot_0_mem_wr			=> ex_ctrl_0.mem_wr,
		slot_0_mem_rd			=> ex_ctrl_0.mem_rd,
		slot_0_mem_byteen		=> ex_ctrl_0.mem_byteen,
		slot_0_mem_sext		=> ex_ctrl_0.mem_sig_ex,
		slot_0_reg_w_en		=> ex_ctrl_0.reg_w_en,
		
		slot_1_reg_addr		=> ex_ctrl_1.dest_reg,
		slot_1_mem_wr			=> ex_ctrl_1.mem_wr,
		slot_1_mem_rd			=> ex_ctrl_1.mem_rd,
		slot_1_mem_byteen 	=> ex_ctrl_1.mem_byteen,
		slot_1_mem_sext		=> ex_ctrl_1.mem_sig_ex,
		slot_1_reg_w_en		=> ex_ctrl_1.reg_w_en,
		 
		slot_2_reg_addr		=> ex_ctrl_2.dest_reg,
		slot_2_reg_w_en		=> ex_ctrl_2.reg_w_en,

		slot_3_reg_addr		=> ex_ctrl_3.dest_reg,
		slot_3_reg_w_en		=> ex_ctrl_3.reg_w_en,

		--forward logic
		rd_ctrl_src_0_a		=> ctrl_0.src_1_reg,
		rd_ctrl_src_1_a		=> ctrl_1.src_1_reg,
		rd_ctrl_src_2_a		=> ctrl_2.src_1_reg,
		rd_ctrl_src_3_a		=> ctrl_3.src_1_reg,
		
		rd_ctrl_mem_wr_0 => ctrl_0.mem_wr,
		rd_ctrl_mem_rd_0 => ctrl_0.mem_rd,
		rd_ctrl_mem_wr_1 => ctrl_1.mem_wr,
		rd_ctrl_mem_rd_1 => ctrl_1.mem_rd,
					
		rd_ctrl_src_0_b		=> ctrl_0.src_2_reg,
		rd_ctrl_src_1_b		=> ctrl_1.src_2_reg,
		rd_ctrl_src_2_b		=> ctrl_2.src_2_reg,
		rd_ctrl_src_3_b		=> ctrl_3.src_2_reg,
   
		
----		wb_addr_reg_0		=> ex_ctrl_0.dest_reg,
----		wb_reg_w_en_0	=> ex_ctrl_0.reg_w_en,
----			
----		wb_addr_reg_1		=> ex_ctrl_1.dest_reg,
----		wb_reg_w_en_1	=> ex_ctrl_1.reg_w_en,
--		
--		wb_addr_reg_2		=> ex_ctrl_2.dest_reg,
--		wb_reg_w_en_2	=> ex_ctrl_2.reg_w_en,
--		
--		wb_addr_reg_3		=> ex_ctrl_3.dest_reg,
--		wb_reg_w_en_3		=> ex_ctrl_3.reg_w_en,
--		
--		wb_mem_rd_0		=> ex_ctrl_0.mem_rd,
--		wb_mem_rd_1		=> ex_ctrl_1.mem_rd,
--				
		alu_val_0				=> alu_0_val.alu_val,
		alu_val_1				=> alu_1_val.alu_val,
		alu_val_2				=> alu_2_val.alu_val,
		alu_val_3				=> alu_3_val.alu_val,

		-- address computation
		imm0	=> ex_imm_0,
		rega0	=> ex_reg_src1_0,
		 
		imm1	=> ex_imm_1,
		rega1	=> ex_reg_src1_1,
	

		regw0	=> ex_reg_src2_0,
		regw1	=> ex_reg_src2_1,


		d_address          => d_address,
		d_byteenable     => d_byteenable,
		d_read               => d_read,
		d_readdata        => d_readdata,
		d_waitrequest    => d_waitrequest,
		d_write               => d_write,
		d_writedata        => d_writedata,
		d_readdatavalid   => d_readdatavalid,
	
		d_chipselect			=> d_chipselect,
		
		memory_data			=> memory_data,
		memory_data_1  => memory_data_1,
		
		wb_wait		=> ld_st_wb_stall,
		stall			 => mem_stall,
		
		-- internal ScratchPad data interface
		sp_a_rd  => sp_a_rd,
		sp_b_rd  => sp_b_rd,
	
		sp_a_wr =>  sp_a_wr,
		sp_b_wr =>  sp_b_wr,
	
		sp_a_data =>  sp_a_data,
		sp_b_data =>  sp_b_data,
	
		sp_a_dataw =>  sp_a_dataw,
		sp_b_dataw =>  sp_b_dataw,
	
		sp_a_addr =>  sp_a_addr,
		sp_b_addr =>  sp_b_addr,
	
		sp_a_byteen =>  sp_a_byteen,
		sp_b_byteen =>  sp_b_byteen,
		
		log => log,
		
		----
		
		error 	=> ld_st_error
		
	);
	
	scratchpad : dp_sp port map
	(
		clock		=> clk,
				
		address_a	=> sp_a_addr,
		address_b	=> sp_b_addr,
		byteena_a	=> sp_a_byteen,
		byteena_b	=> sp_b_byteen,
		
		data_a	=> sp_a_dataw,
		data_b	=> sp_b_dataw,
		rden_a	=> sp_a_rd,
		rden_b	=> sp_b_rd,
		wren_a	=> sp_a_wr,
		wren_b	=> sp_b_wr,
		
		q_a		=> sp_a_data,
		q_b		=> sp_b_data
	);
	
	
	
--	process (clk, reset)
--	
--		file my_output : TEXT open WRITE_MODE is "sp_log.txt";
--		variable my_line : line; 					 
--		alias swrite is write [line, string, side, width];
--	
--	begin
--		
--		if rising_edge(clk) then
--			if sp_a_rd = '1' and log = '1' then
--				swrite(my_line, "sp_a_rd: ");
--				write(my_line, CONV_INTEGER("0" & sp_a_addr));
--				swrite(my_line, " : ");
--				hwrite(my_line, sp_a_data);
--				swrite(my_line, " @ ");
--				write(my_line, now); 
--				writeline(my_output, my_line);			
--			end if;
--			
--			if sp_b_rd = '1' and log = '1' then
--				swrite(my_line, "sp_b_rd: ");
--				write(my_line, CONV_INTEGER("0" & sp_b_addr));
--				swrite(my_line, " : ");
--				hwrite(my_line, sp_b_data);
--				swrite(my_line, " @ ");
--				write(my_line, now); 
--				writeline(my_output, my_line);					
--			end if;
--			
--			if sp_a_wr = '1' then
--				swrite(my_line, "sp_a_wr: ");
--				write(my_line, CONV_INTEGER("0" & sp_a_addr));
--				swrite(my_line, " : ");
--				hwrite(my_line, sp_a_dataw);
--				swrite(my_line, " @ ");
--				write(my_line, now); 
--				writeline(my_output, my_line);
--			end if;
--			
--			if sp_b_wr = '1' then
--				swrite(my_line, "sp_b_wr: ");
--				write(my_line, CONV_INTEGER("0" & sp_b_addr));
--				swrite(my_line, " : ");
--				hwrite(my_line, sp_b_dataw);
--				swrite(my_line, " @ ");
--				write(my_line, now); 
--				writeline(my_output, my_line);			
--			end if;
--		
----			if d_chipselect = "0001" then
----				swrite(my_line, "ROM_ACCESS: ");
----				write(my_line, CONV_INTEGER("0" & d_address));
----				swrite(my_line, " @ ");
----				write(my_line, now); 
----				writeline(my_output, my_line);
----			end if;
--	
--		
--		end if;
--	
--	
--	end process;
	
	
	--------------------------
	--------	write back	-----	
	wb_buffer_0 : wb_buffer port map (
		clk    => clk,
		reset  => reset,
		ctrl_in => ex_ctrl_0, 
		stall => wb_stall,
		
		mul_div_w_addr_in	=>  mul_div_dest_reg_0,
		mul_div_w_en_in		=> mul_div_val_rd_0,
		
		pred_reg_w_addr	=>	pred_port0_w_addr,
		pred_reg_w_en		=> pred_port0_w_en,			
		reg_w_addr	=> port0_w_addr,
		reg_w_en		=> port0_w_en,
		halt					=> halt_0,
		wb_mux_sel  => wb_mux_sel_0
	);
	
	wb_buffer_1 : wb_buffer port map (
		clk    => clk,
		reset  => reset,
		stall => wb_stall,
		ctrl_in => ex_ctrl_1,	
		
		mul_div_w_addr_in	=>  mul_div_dest_reg_1,
		mul_div_w_en_in		=> mul_div_val_rd_1,
   	
		pred_reg_w_addr	=>	pred_port1_w_addr,
		pred_reg_w_en		=> pred_port1_w_en,			
		reg_w_addr	=> port1_w_addr,
		reg_w_en		=> port1_w_en,
		halt					=> halt_1,
		wb_mux_sel  => wb_mux_sel_1
	);
	
	wb_buffer_2 : wb_buffer port map (
		clk    => clk,
		reset  => reset,
		stall => wb_stall,
		ctrl_in => ex_ctrl_2,
		
		mul_div_w_addr_in	=>  "000000",
		mul_div_w_en_in		=> '0',
	
   	pred_reg_w_addr	=>	pred_port2_w_addr,
		pred_reg_w_en		=> pred_port2_w_en,					
		reg_w_addr	=> port2_w_addr,
		reg_w_en		=> port2_w_en,
		halt					=> halt_2,
		wb_mux_sel  => wb_mux_sel_2
		
	);
	
	wb_buffer_3 : wb_buffer port map (
		clk    => clk,
		reset  => reset,
		stall => wb_stall,
		ctrl_in => ex_ctrl_3,
			
		mul_div_w_addr_in	=>  "000000",
		mul_div_w_en_in		=> '0',
			
		pred_reg_w_addr	=>	pred_port3_w_addr,
		pred_reg_w_en		=> pred_port3_w_en,			
   	
		reg_w_addr	=> port3_w_addr,
		reg_w_en		=> port3_w_en,
		wb_mux_sel  => wb_mux_sel_3,
		halt					=> halt_3
		
	);
	
	wb_mux_0	: wb_mux port map(
		data0x	=> alu_0_val.alu_val,
		data1x => memory_data,
		data2x => mul_div_0,
		data3x => x"00000000",
		sel			=> wb_mux_sel_0,
		result   => reg_data_0
	);
	
		wb_mux_1	: wb_mux port map(
		data0x	=> alu_1_val.alu_val,
		data1x => memory_data_1,
		data2x => mul_div_1,
		data3x => x"00000000",
		sel			=> wb_mux_sel_1,
		result   => reg_data_1
	);
	
		wb_mux_2	: wb_mux port map(
		data0x	=> alu_2_val.alu_val,
		data1x => x"00000000",
		data2x => x"00000000",
		data3x => x"00000000",		
		sel			=> wb_mux_sel_2,
		result   => reg_data_2
	);
	
		wb_mux_3	: wb_mux port map(
		data0x	=> alu_3_val.alu_val,
		data1x =>x"00000000",
		data2x => x"00000000",
		data3x => x"00000000",
		sel			=> wb_mux_sel_3,
		result   => reg_data_3
	);
	
	-- performance monitor/counters	
	perf_module_0 : perf_module port  map (
		clk    				=> clk,
		reset				=> reset,
		
		dep_stall		=> dep_stall,
		delay_dep	=> delay_dep,
		ex_stall => ex_stall,
		
		instructions => instructions,
	
		slot_0_in  => slot_0		
	);
	
	
	process (port0_w_en, port1_w_en, port2_w_en, port3_w_en, 
		port0_w_addr, port1_w_addr, port2_w_addr, port3_w_addr)
		
	begin
	
		if (port0_w_en = '1' and port0_w_addr = "000000") then
			assert false report "Error: Write in R$0 in P0" severity error;		
		end if;
		
		if (port1_w_en = '1' and port1_w_addr = "000000") then
			assert false report "Error: Write in R$0 in P1" severity error;		
		end if;
		
		if (port2_w_en = '1' and port2_w_addr = "000000") then
			assert false report "Error: Write in R$0 in P2" severity error;		
		end if;
		
		if (port3_w_en = '1' and port3_w_addr = "000000") then
			assert false report "Error: Write in R$0 in P3" severity error;		
		end if;
	
	end process;
	
	process (ld_st_error)
	begin
		if ld_st_error = '1' then
			assert false report "Memory error" severity error;			
		end if;	
	end process;
		
	alu_ops 	 <= s0_alu_ops + s1_alu_ops + s2_alu_ops + s3_alu_ops;
	special_ops	 <= s0_special_ops + s1_special_ops + s2_special_ops + s3_special_ops;
	mem_ops		 <= s0_mem_ops + s1_mem_ops + s2_mem_ops + s3_mem_ops;
	branche_ops      <= s0_branche_ops + s1_branche_ops + s2_branche_ops + s3_branche_ops;
	
	--debugger	
	pc_out	<=	"000000000" & pc;
	stall_out <= ex_stall or dep_stall or delay_dep;	
	slot_0_out <= slot_0;
	slot_1_out <= slot_1;
	slot_2_out <= slot_2;
	slot_3_out <= slot_3;
			
END ARCHITECTURE rtl;