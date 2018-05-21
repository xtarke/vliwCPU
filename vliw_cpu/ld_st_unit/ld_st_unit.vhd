--------------------------------------------------------------------------------
--  VLIW-RT CPU - Memory access entity (Load Store Unit)
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

LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.cpu_typedef_package.all;


entity ld_st_unit is
	port
	(
		clk					: in std_logic;
		clk_mem 	: in std_logic;
		reset			: in std_logic;
		ex_stall   	: in std_logic;
	
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
		rd_ctrl_mem_wr_0	   : in std_logic;		
		rd_ctrl_mem_rd_0	   : in std_logic;
			
		rd_ctrl_src_0_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_1_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_2_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_src_3_b		: in std_logic_vector(REG_ADDR_SIZE-1 downto 0);
		rd_ctrl_mem_wr_1	   : in std_logic;
		rd_ctrl_mem_rd_1	   : in std_logic;
		
		alu_val_0					: in word_t;
		alu_val_1					: in word_t;
		alu_val_2					: in word_t;
		alu_val_3					: in word_t;		
		
		 -- address computation
		imm0	: in	word_t;
		rega0	: in	word_t;
		 
		imm1	: in	word_t;
		rega1	: in	word_t;
				
		-- write data
		regw0	: in	word_t;
		regw1	: in	word_t;	
	

		-- external data interface
		d_address                : out std_logic_vector(DATA_ADDR_SIZE-1  downto 0);                    -- address
		d_byteenable           : out std_logic_vector(3 downto 0);                    -- byteenable
		d_read                      : out std_logic;                                     				   -- read
		d_readdata               : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
		d_waitrequest          : in  std_logic                     := 'X';             -- waitrequest
		d_write                      : out std_logic;                                        -- write
		d_writedata              : out std_logic_vector(31 downto 0);                    -- writedata
		d_readdatavalid       : in  std_logic                     := 'X';             -- readdatavalid
	
		d_chipselect				  : out std_logic_vector(3 downto 0);	

		-- write back
		memory_data	  : out word_t;		
		memory_data_1 : out word_t;
		
		-- stall
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
	end ld_st_unit;

architecture rtl of ld_st_unit is
	
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

	component mem_addr
	PORT
	(
		clken		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;

	type ld_st_state_type is (IDLE, MEM_CALC, WAITING, SP, TIMER,DONE);
	signal ld_st_state : ld_st_state_type;

	signal addr0	: word_t;
	signal addr1	: word_t;
	
	signal addr_reg	   			:	word_t;
	signal addr_reg_addr	   :	std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal src_1_sel_0	: std_logic_vector(3 downto 0);
	signal src_1_sel_1	: std_logic_vector(3 downto 0);
	signal src_2_sel_0	: std_logic_vector(3 downto 0);
	signal src_2_sel_1	: std_logic_vector(3 downto 0);	
	
	signal src1_0_val		: word_t;
	signal src1_1_val		: word_t;
	signal src2_0_val		: word_t;
	signal src2_1_val		: word_t;
	
	signal is_mem				: std_logic;
	signal mem_calc_en : std_logic;
	signal chip_sel_en 	: std_logic;
	signal input_reg_en  : std_logic;
	
	signal s0_wr_reg : std_logic;
	signal s0_rd_reg : std_logic;
	signal s1_wr_reg : std_logic;
	signal s1_rd_reg : std_logic;
	
	signal slot_0_mem_byteen_reg : std_logic_vector(1 downto 0);
	signal slot_1_mem_byteen_reg : std_logic_vector(1 downto 0);
	signal mem_byteen_reg					: std_logic_vector(1 downto 0);

	signal mem_sext_reg		: std_logic;	
	signal reg_mem_data_en : std_logic;
	
	signal chip_sel		: std_logic_vector(3 downto 0);
	
	signal byte_sel_0 : std_logic_vector(1 downto 0);
	signal byte_sel_1 : std_logic_vector(1 downto 0);
	
	signal aligment_error	: std_logic;
	signal error_en : std_logic;
	
	signal memory_data_reg : word_t;
	signal memory_data_1_reg : word_t;
	
	signal d_writedata_en : std_logic;
	signal d_writedata_reg : word_t;
	
	
	signal sp_a_dataw_reg : word_t;
	signal sp_b_dataw_reg : word_t;
	
	signal sp_a_rdsig		: std_logic;
	signal sp_b_rdsig	: std_logic;
	
	signal sp_a_rd_reg	: std_logic;
	signal sp_b_rd_reg	: std_logic;
	
	signal sp_a_data_mask : word_t;
	signal sp_b_data_mask : word_t;
	
	signal sp_a_byteen_sig : std_logic_vector(3 DOWNTO 0);		
	signal sp_b_byteen_sig : std_logic_vector(3 DOWNTO 0);		
	
	signal src_1_mem_0_to_0 : std_logic;
	signal src_2_mem_0_to_0 : std_logic;
	signal src_1_mem_1_to_0 : std_logic;
	signal src_2_mem_1_to_0 : std_logic;
	
	signal mem_to_mem_rst_0 : std_logic;
	
	signal src_1_mem_0_to_1 : std_logic;
	signal src_2_mem_0_to_1 : std_logic;
	signal src_1_mem_1_to_1 : std_logic;
	signal src_2_mem_1_to_1 : std_logic;
	
	signal mem_to_mem_rst_1 : std_logic;
	
	
	
	signal timer_val : word_t;
	signal timer_rd  : std_logic;
	
	
begin

   mem_byteen_reg <= slot_0_mem_byteen_reg or slot_1_mem_byteen_reg;
	is_mem <= slot_0_mem_wr or slot_0_mem_rd or slot_1_mem_wr or slot_1_mem_rd;
	d_read <= s0_rd_reg or s1_rd_reg;
		
	------------------------------------------------------------
	-- 1 cycle pipelined address computation	
	mem_addr_0_reg : mem_addr port map
	(
		clock => clk,
		clken => mem_calc_en,
		dataa => imm0,		
		datab => src1_0_val,
		result => addr0
	);
		
	mem_addr_1 : mem_addr port map
	(
		clock => clk, 
		clken => mem_calc_en,
		dataa => imm1,		
		datab => src1_1_val,
		result => addr1
	);

	------------------------------------------------------------
	-- Forward logic muxes		
	mux_forward_0_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> rega0,			-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> memory_data_reg,
		data6x		=> memory_data_1_reg,	
		data7x		=>  x"00000000",
		data8x		=>  x"00000000",	
		sel					=> src_1_sel_0,
		result			=> src1_0_val
	);
	
	mux_forward_1_src1: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> rega1,			-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> memory_data_reg,
		data6x		=> memory_data_1_reg,		
		data7x		=>  x"00000000",	
		data8x		=>  x"00000000",	
		sel					=> src_1_sel_1,
		result			=> src1_1_val
	);	
	
	mux_forward_0_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> regw0,			-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> memory_data_reg,
		data6x		=> memory_data_1_reg,	
		data7x		=>  x"00000000",
		data8x		=>  x"00000000",
		sel					=> src_2_sel_0,
		result			=> src2_0_val
	);
	
	mux_forward_1_src2: forward_mux port map	
	(
		--clock	=> clk,
		data0x		=> regw1,			-- read from register file
		data1x		=> alu_val_0,	-- forward from alu 0
		data2x		=> alu_val_1,	-- forward from alu 1
		data3x		=> alu_val_2,	-- forward from alu 2
		data4x		=> alu_val_3,	-- forward from alu 3
		data5x		=> memory_data_reg,
		data6x		=> memory_data_1_reg,			
		data7x		=>  x"00000000",
		data8x		=>  x"00000000",
		sel				=> src_2_sel_1,
		result			=> src2_1_val
	);	
	
	------------------------------------------------------------
	
	byte_sel_0 <= addr0(1 downto 0);
	byte_sel_1 <= addr1(1 downto 0);	
	
	-- register data to the bus data port
	process (clk, reset, d_writedata_en, src2_0_val, src_2_sel_1, slot_0_mem_wr, slot_1_mem_wr)
	begin
		
		if reset = '1' then
			d_writedata_reg <= (d_writedata_reg'range => '0');
		else
			if rising_edge(clk) and d_writedata_en = '1' then
			
				if slot_0_mem_wr = '1' then
					d_writedata_reg <= src2_0_val;
				
					sp_a_dataw_reg <= src2_0_val;
				end if;
				
				if slot_1_mem_wr = '1' then
					d_writedata_reg <= src2_1_val;
					
					sp_b_dataw_reg <= src2_1_val;
				end if;			
			end if;			
		end if;
	end process;
			
	-- Forward logic for data on Load from memory operations
	process	(clk, reset, slot_0_reg_addr , rd_ctrl_src_0_a, rd_ctrl_src_0_b, slot_0_reg_w_en, 
											slot_1_reg_addr , rd_ctrl_src_1_a, rd_ctrl_src_1_b, slot_1_reg_w_en, 
											slot_2_reg_addr , rd_ctrl_src_2_a, rd_ctrl_src_2_b, slot_2_reg_w_en, 
											slot_3_reg_addr , rd_ctrl_src_3_a, rd_ctrl_src_3_b, slot_3_reg_w_en,
											slot_0_mem_rd, slot_1_mem_rd)
	begin
		if reset = '1' then
			src_1_sel_0	<=	"0000";
			src_2_sel_0	<=	"0000";			
		else
			if rising_edge(clk) then
					
				
				if ex_stall = '0' then 
				
					src_1_sel_0	<=	"0000";
					src_2_sel_0	<=	"0000";
							
					-- ALU	0 to mem
					if slot_0_reg_addr = rd_ctrl_src_0_a and slot_0_reg_w_en = '1' then
						src_1_sel_0	<=	"0001";
					end if;
				
					if slot_0_reg_addr =rd_ctrl_src_0_b and slot_0_reg_w_en = '1' then
						src_2_sel_0	<=	"0001";
					end if;
					
					-- ALU	1 to mem
					if slot_1_reg_addr = rd_ctrl_src_0_a and slot_1_reg_w_en = '1' then
						src_1_sel_0	<=	"0010";
					end if;
				
					if slot_1_reg_addr =rd_ctrl_src_0_b and slot_1_reg_w_en = '1' then
						src_2_sel_0	<=	"0010";
					end if;
					
					-- ALU	2 to mem
					if slot_2_reg_addr = rd_ctrl_src_0_a and slot_2_reg_w_en = '1' then
						src_1_sel_0	<=	"0011";
					end if;
				
					if slot_2_reg_addr =rd_ctrl_src_0_b and slot_2_reg_w_en = '1' then
						src_2_sel_0	<=	"0011";
					end if;
					
					-- ALU	3 to mem
					if slot_3_reg_addr = rd_ctrl_src_0_a and slot_3_reg_w_en = '1' then
						src_1_sel_0	<=	"0100";
					end if;
				
					if slot_3_reg_addr =rd_ctrl_src_0_b and slot_3_reg_w_en = '1' then
						src_2_sel_0	<=	"0100";
					end if;				
				else	
				
					-- register memory to memory forward
					if src_1_mem_0_to_0 = '1' then
						src_1_sel_0	<=	"0101";
					end if;					
					
					if src_2_mem_0_to_0 = '1' then
						src_2_sel_0	<=	"0101";
					end if;
					
					if src_1_mem_1_to_0 = '1' then
						src_1_sel_0	<=	"0110";
					end if;				
					
					if src_2_mem_1_to_0 = '1' then
						src_2_sel_0	<=	"0110";
					end if;				
					
				end if;			
			end if;
		end if;
	end process;
	
	process	(clk, reset, slot_0_reg_addr , rd_ctrl_src_0_a, rd_ctrl_src_0_b, slot_0_reg_w_en, 
											slot_1_reg_addr , rd_ctrl_src_1_a, rd_ctrl_src_1_b, slot_1_reg_w_en, 
											slot_2_reg_addr , rd_ctrl_src_2_a, rd_ctrl_src_2_b, slot_2_reg_w_en, 
											slot_3_reg_addr , rd_ctrl_src_3_a, rd_ctrl_src_3_b, slot_3_reg_w_en,
											src_2_mem_0_to_1, src_2_mem_1_to_1)
	begin
		if reset = '1' then
			src_1_sel_1	<=	"0000";
			src_2_sel_1	<=	"0000";			
		else
			if rising_edge(clk) then
					
				if ex_stall = '0' then 
				
					src_1_sel_1	<=	"0000";
					src_2_sel_1	<=	"0000";
							
					-- ALU	0 to mem
					if slot_0_reg_addr = rd_ctrl_src_1_a and slot_0_reg_w_en = '1' then
						src_1_sel_1	<=	"0001";
					end if;
				
					if slot_0_reg_addr =rd_ctrl_src_1_b and slot_0_reg_w_en = '1' then
						src_2_sel_1	<=	"0001";
					end if;
					
					-- ALU	1 to mem
					if slot_1_reg_addr = rd_ctrl_src_1_a and slot_1_reg_w_en = '1' then
						src_1_sel_1	<=	"0010";
					end if;
				
					if slot_1_reg_addr =rd_ctrl_src_1_b and slot_1_reg_w_en = '1' then
						src_2_sel_1	<=	"0010";
					end if;
					
					-- ALU	2 to mem
					if slot_2_reg_addr = rd_ctrl_src_1_a and slot_2_reg_w_en = '1' then
						src_1_sel_1	<=	"0011";
					end if;
				
					if slot_2_reg_addr =rd_ctrl_src_1_b and slot_2_reg_w_en = '1' then
						src_2_sel_1	<=	"0011";
					end if;
					
					-- ALU	3 to mem
					if slot_3_reg_addr = rd_ctrl_src_1_a and slot_3_reg_w_en = '1' then
						src_1_sel_1	<=	"0100";
					end if;
				
					if slot_3_reg_addr =rd_ctrl_src_1_b and slot_3_reg_w_en = '1' then
						src_2_sel_1	<=	"0100";
					end if;
				
				else
				
					-- register memory to memory forward
					if src_1_mem_0_to_1 = '1' then
						src_1_sel_1	<=	"0101";
					end if;					
					
					if src_2_mem_0_to_1 = '1' then
						src_2_sel_1	<=	"0101";
					end if;
					
					if src_1_mem_1_to_1 = '1' then
						src_1_sel_1	<=	"0110";
					end if;			
			
					if src_2_mem_1_to_1 = '1' then
						src_2_sel_1	<=	"0110";
					end if;
				
					
			
				end if;
				
			end if;
		end if;
	end process;
	
	
	
	-- memory to memory forward
	process	(clk, reset, slot_0_reg_addr , rd_ctrl_src_0_a, rd_ctrl_src_0_b, slot_0_reg_w_en, 
											slot_1_reg_addr , rd_ctrl_src_1_a, rd_ctrl_src_1_b, slot_1_reg_w_en, 
											slot_2_reg_addr , rd_ctrl_src_2_a, rd_ctrl_src_2_b, slot_2_reg_w_en, 
											slot_3_reg_addr , rd_ctrl_src_3_a, rd_ctrl_src_3_b, slot_3_reg_w_en,
											slot_0_mem_rd, slot_1_mem_rd,
											mem_to_mem_rst_0, ex_stall,
											rd_ctrl_mem_wr_0)
	begin
		if reset = '1' then
			src_1_mem_0_to_0	<=	'0';
			src_2_mem_0_to_0	<=	'0';
			src_1_mem_1_to_0	<=	'0';
			src_2_mem_1_to_0	<=	'0';
		else
			if rising_edge(clk) and ex_stall = '0' then
					
				if mem_to_mem_rst_0 = '1' then
					src_1_mem_0_to_0	<= '0';
					src_2_mem_0_to_0	<= '0';
					src_1_mem_1_to_0	<= '0';
					src_2_mem_1_to_0	<= '0';
				end if;
					
				-- mem_0 to mem_0
				--if slot_0_reg_addr = rd_ctrl_src_0_a and slot_0_reg_w_en = '1' and slot_0_mem_rd = '1'  and rd_ctrl_mem_wr_0 = '1' then
				if slot_0_reg_addr = rd_ctrl_src_0_a and slot_0_reg_w_en = '1' and slot_0_mem_rd = '1' and (rd_ctrl_mem_wr_0 = '1' or rd_ctrl_mem_rd_0 = '1') then
					src_1_mem_0_to_0	<=	'1';
				end if;				
			
				--if slot_0_reg_addr =rd_ctrl_src_0_b and slot_0_reg_w_en = '1' and  slot_0_mem_rd = '1' and rd_ctrl_mem_wr_0 = '1' then
				if slot_0_reg_addr = rd_ctrl_src_0_b and slot_0_reg_w_en = '1' and  slot_0_mem_rd = '1' and (rd_ctrl_mem_wr_0 = '1' or rd_ctrl_mem_rd_0 = '1') then
					src_2_mem_0_to_0	<=	'1';
				end if;
				
				-- mem_1 to mem_0
				--if slot_1_reg_addr = rd_ctrl_src_0_a and slot_1_reg_w_en = '1' and slot_1_mem_rd = '1' and rd_ctrl_mem_wr_0 = '1' then
				if slot_1_reg_addr = rd_ctrl_src_0_a and slot_1_reg_w_en = '1' and slot_1_mem_rd = '1' and (rd_ctrl_mem_wr_0 = '1' or rd_ctrl_mem_rd_0 = '1') then
					src_1_mem_1_to_0	<=	'1';
				end if;				
			
				--if slot_1_reg_addr =rd_ctrl_src_0_b and slot_1_reg_w_en = '1' and  slot_1_mem_rd = '1'  and rd_ctrl_mem_wr_0 = '1' then
				if slot_1_reg_addr =rd_ctrl_src_0_b and slot_1_reg_w_en = '1' and  slot_1_mem_rd = '1' and (rd_ctrl_mem_wr_0 = '1' or rd_ctrl_mem_rd_0 = '1') then
					src_2_mem_1_to_0	<=	'1';
				end if;	
								
				
			end if;
		end if;
	end process;
	
	-- memory to memory forward
	process	(clk, reset, slot_0_reg_addr , rd_ctrl_src_0_a, rd_ctrl_src_0_b, slot_0_reg_w_en, 
											slot_1_reg_addr , rd_ctrl_src_1_a, rd_ctrl_src_1_b, slot_1_reg_w_en, 
											slot_2_reg_addr , rd_ctrl_src_2_a, rd_ctrl_src_2_b, slot_2_reg_w_en, 
											slot_3_reg_addr , rd_ctrl_src_3_a, rd_ctrl_src_3_b, slot_3_reg_w_en,
											mem_to_mem_rst_1, ex_stall,
											rd_ctrl_mem_wr_1)
	begin
		if reset = '1' then
			src_1_mem_0_to_1	<=	'0';
			src_2_mem_0_to_1	<=	'0';
			src_1_mem_1_to_1	<=	'0';
			src_2_mem_1_to_1	<=	'0';
		else
			if rising_edge(clk) and ex_stall = '0' then
					
				if mem_to_mem_rst_1 = '1' then
					src_1_mem_0_to_1	<= '0';
					src_2_mem_0_to_1	<= '0';
					src_1_mem_1_to_1	<= '0';
					src_2_mem_1_to_1	<= '0';
				end if;
				
				-- mem_0 to mem_1
				--if slot_0_reg_addr = rd_ctrl_src_1_a and slot_0_reg_w_en = '1' and slot_0_mem_rd = '1' and rd_ctrl_mem_wr_1 = '1' then
				if slot_0_reg_addr = rd_ctrl_src_1_a and slot_0_reg_w_en = '1' and slot_0_mem_rd = '1' and (rd_ctrl_mem_wr_1 = '1' or rd_ctrl_mem_rd_1 = '1') then
					src_1_mem_0_to_1	<=	'1';
				end if;				
			
				--if slot_0_reg_addr =rd_ctrl_src_1_b and slot_0_reg_w_en = '1' and  slot_0_mem_rd = '1' and rd_ctrl_mem_wr_1 = '1'  then
				if slot_0_reg_addr = rd_ctrl_src_1_b and slot_0_reg_w_en = '1' and  slot_0_mem_rd = '1' and (rd_ctrl_mem_wr_1 = '1' or rd_ctrl_mem_rd_1 = '1') then
					src_2_mem_0_to_1	<=	'1';
				end if;
				
				-- mem_1 to mem_1
				--if slot_1_reg_addr = rd_ctrl_src_1_a and slot_1_reg_w_en = '1' and slot_1_mem_rd = '1' and rd_ctrl_mem_wr_1 = '1' then
				if slot_1_reg_addr = rd_ctrl_src_1_a and slot_1_reg_w_en = '1' and slot_1_mem_rd = '1' and (rd_ctrl_mem_wr_1 = '1' or rd_ctrl_mem_rd_1 = '1') then
					src_1_mem_1_to_1	<=	'1';
				end if;				
			
				--if slot_1_reg_addr =rd_ctrl_src_1_b and slot_1_reg_w_en = '1' and  slot_1_mem_rd = '1'  and rd_ctrl_mem_wr_1 = '1' then
				if slot_1_reg_addr = rd_ctrl_src_1_b and slot_1_reg_w_en = '1' and  slot_1_mem_rd = '1' and (rd_ctrl_mem_wr_1 = '1' or rd_ctrl_mem_rd_1 = '1') then
					src_2_mem_1_to_1	<=	'1';
				end if;	
				
			end if;
		end if;
	end process;
	
	
	

	-- memory aligment and byte selection
	byte_en: process (reset, chip_sel_en, s0_wr_reg, s0_rd_reg, s1_wr_reg, s1_rd_reg, slot_0_mem_byteen_reg, slot_1_mem_byteen_reg,
											byte_sel_0, byte_sel_1, d_writedata_reg,
											sp_a_dataw_reg, sp_b_dataw_reg)
	begin
		if reset = '1' then
			d_byteenable <= "0000";	
			aligment_error	<= '0';
			
			sp_a_byteen_sig <= "0000";	
			sp_b_byteen_sig <= "0000";	
			
			sp_a_dataw <= (others => '0');
			sp_b_dataw <= (others => '0');		
					
		else			
			aligment_error	<= '0';
			d_byteenable <= "0000";
			
			sp_a_byteen_sig <= "0000";	
			sp_b_byteen_sig <= "0000";	
			
			sp_a_dataw <= (others => '0');
			sp_b_dataw <= (others => '0');			
			
		
			if chip_sel_en = '1' then			
							
			   -- activated if slot 0 is a memory access
				if (s0_wr_reg ='1' or s0_rd_reg = '1') then
										
					d_byteenable <= "0000";
					sp_a_byteen_sig  <= "0000";	
					
					sp_a_dataw <= sp_a_dataw_reg;
										
					case slot_0_mem_byteen_reg is
					
						-- when Word access
						when "00" =>				
							d_byteenable <= "1111";
							sp_a_byteen_sig	<= "1111";
							
							if byte_sel_0 /= "00" then								
								aligment_error <= '1';
							end if;									
							
						-- when Half Word access
						when "01" =>					
												
							if byte_sel_0 = "00" then
								d_byteenable <= "0011";	
								sp_a_byteen_sig <= "0011";	
								
							elsif byte_sel_0 = "10" then
								d_byteenable <= "1100";	
								sp_a_byteen_sig <= "1100";	
								
								sp_a_dataw <= sp_a_dataw_reg(15 downto 0) & x"0000";
								--d_writedata <= d_writedata_reg(15 downto 0) & x"0000";
							else
								aligment_error <= '1';							
							end if;			
									
						-- when Byte access
						when "10" =>
							
							case byte_sel_0 is
								when "00" => 
									d_byteenable <= "0001";	
									sp_a_byteen_sig	 <= "0001";	
								when "01" => 
									d_byteenable <= "0010";
									sp_a_byteen_sig  <= "0010";										
									sp_a_dataw <= x"0000" & sp_a_dataw_reg(7 downto 0) & x"00";	
																											
								when "10" => 
									d_byteenable <= "0100";	
									sp_a_byteen_sig <= "0100";									
									sp_a_dataw <= x"00" & sp_a_dataw_reg(7 downto 0) & x"0000";	
									
								when "11" => 
									d_byteenable <= "1000";	
									sp_a_byteen_sig  <= "1000";										
									sp_a_dataw <= sp_a_dataw_reg(7 downto 0) & x"000000";																			
								when others => 
							end case;						
						when others =>
					end case;				
				else
					sp_a_dataw <= (others => '0');				
				end if;				
				
				-- activated if slot 1 is a memory access
				if (s1_wr_reg ='1' or s1_rd_reg = '1') then
				
					d_byteenable <= "0000";	
					sp_b_byteen_sig <= "0000";	
					--d_writedata <= d_writedata_reg;
					
					sp_b_dataw <= sp_b_dataw_reg;
					
					case slot_1_mem_byteen_reg is
						
						-- when Word access
						when "00" =>
							d_byteenable <= "1111";	
							sp_b_byteen_sig <= "1111";	
						
							if byte_sel_1 /= "00" then								
								aligment_error <= '1';
							end if;
						
						-- when Half Word access
						when "01" =>
						
							if byte_sel_1 = "00" then
								d_byteenable <= "0011";	
								sp_b_byteen_sig <= "0011";	
							elsif byte_sel_1 = "10" then								
								d_byteenable <= "1100";
								sp_b_byteen_sig <= "1100";
								--d_writedata <= d_writedata_reg(15 downto 0) & x"0000";								
								sp_b_dataw <= sp_b_dataw_reg(15 downto 0) & x"0000";
							else
								aligment_error <= '1';							
							end if;						
						
						-- when Byte access
						when "10" =>
							case byte_sel_1 is
								when "00" => 
									d_byteenable <= "0001";	
									sp_b_byteen_sig <= "0001";	
								when "01" => 
									d_byteenable <= "0010";	
									sp_b_byteen_sig <= "0010";	
									--d_writedata <= x"0000" & d_writedata_reg(7 downto 0) & x"00";	
									sp_b_dataw <= x"0000" & sp_b_dataw_reg(7 downto 0) & x"00";	
								when "10" => 
									d_byteenable <= "0100";	
									sp_b_byteen_sig <= "0100";	
									--d_writedata <= x"00" & d_writedata_reg(7 downto 0) & x"0000";	
									sp_b_dataw <= x"00" & sp_b_dataw_reg(7 downto 0) & x"0000";	
								when "11" => 
									d_byteenable <= "1000";	
									sp_b_byteen_sig <= "1000";	
									--d_writedata <= d_writedata_reg(7 downto 0) & x"000000";	
									sp_b_dataw <= sp_b_dataw_reg(7 downto 0) & x"000000";	
								when others => 
							end case;
						
						when others =>
							
					end case;	
				else
					sp_b_dataw <= (others => '0');							
				end if;			
			
			end if;		
		end if;
	end process;
	
	d_writedata <= d_writedata_reg;
	
	sp_a_byteen <= sp_a_byteen_sig;
	sp_b_byteen <= sp_b_byteen_sig;
	
	
	chip_select: process (clk,  reset,
											addr0, addr1,
											chip_sel_en,
											s0_wr_reg, s0_rd_reg,
											s1_wr_reg, s1_rd_reg)									
	begin
		
		if reset = '1' then
			chip_sel <= "0000";
			d_address <= (d_address'range => '0');
			
			sp_a_addr <= (others => '0');
			sp_b_addr <= (others => '0');
			sp_a_rdsig <= '0';
			sp_b_rdsig <= '0';
			
			sp_a_wr <= '0';
			sp_b_wr <= '0';
			
			timer_rd <= '0';
		
		else
				chip_sel <= "0000";
				d_address <= (d_address'range => '0');
				
				sp_a_addr <= (others => '0');
				sp_b_addr <= (others => '0');
				sp_a_rdsig <= '0';
				sp_b_rdsig <= '0';
				
				sp_a_wr <= '0';
				sp_b_wr <= '0';
				
				timer_rd <= '0';
		
				if chip_sel_en = '1' then
				
					sp_a_addr <= (others => '0');
					sp_b_addr <= (others => '0');
					
					sp_a_rdsig <= '0';
					sp_b_rdsig <= '0';
				
					sp_a_wr <= '0';
					sp_b_wr <= '0';	
		
					timer_rd <= '0';
					
					-- CODE address space
					if addr0 < SRAM_INI and (s0_wr_reg ='1' or s0_rd_reg = '1') then
						chip_sel <= "0001";
						d_address	<= addr0(DATA_ADDR_SIZE-1  downto 0);
					end if;
					
					if addr1 < SRAM_INI and (s1_wr_reg ='1'  or s1_rd_reg = '1') then
						chip_sel <= "0001";
						d_address	<= addr1(DATA_ADDR_SIZE-1  downto 0);
					end if;
			
					-- SRAM
					if addr0 > CODE_END and addr0 <= SRAM_END and  (s0_wr_reg ='1' or s0_rd_reg = '1') then
						--chip_sel <= "00010"; 
						--d_address	<= addr0(DATA_ADDR_SIZE-1  downto 0);					
						
						
						sp_a_addr <=  addr0(SP_ADDR_SIZE+1 downto 2);
						sp_a_rdsig		<= s0_rd_reg;
						sp_a_wr    <= s0_wr_reg;
									
						
					end if;
			
					if addr1 > CODE_END and addr0 <= SRAM_END and  (s1_wr_reg ='1' or s1_rd_reg = '1') then
						--chip_sel <= "0010";
						--d_address	<= addr1(DATA_ADDR_SIZE-1  downto 0);	
						
						sp_b_addr <=  addr1(SP_ADDR_SIZE+1 downto 2);
						sp_b_rdsig		<= s1_rd_reg;
						sp_b_wr    <= s1_wr_reg;						
						
					end if;
					
					-- IO
					if addr0 >= x"80000000" and (s0_wr_reg ='1' or s0_rd_reg = '1') then
						
						if (addr0(11) = '0') then						
							chip_sel <= "0100"; 
							d_address	<= addr0(DATA_ADDR_SIZE-1  downto 0);
						else
							timer_rd <= '1';
						end if;
					end if;
			
					if addr1 >= x"80000000" and (s1_wr_reg ='1' or s1_rd_reg = '1') then
						chip_sel <= "0100"; 
						d_address	<= addr1(DATA_ADDR_SIZE-1  downto 0);
					end if;		
	
					
--					-- SDRAM
--					if addr0 >= x"80000000" and (s0_wr_reg ='1' or s0_rd_reg = '1') then
--						chip_sel <= "1000"; 
--						d_address	<= addr0(DATA_ADDR_SIZE-1  downto 0);
--					end if;
--			
--					if addr1 >= x"80000000" and (s1_wr_reg ='1' or s1_rd_reg = '1') then
--						chip_sel <= "1000"; 
--						d_address	<= addr1(DATA_ADDR_SIZE-1  downto 0);
--					end if;		
	
				end if;				
			end if;	
	end process;
	
	
	d_chipselect <= chip_sel;
	sp_a_rd <= sp_a_rdsig;
	sp_b_rd <= sp_b_rdsig;
	
	-- register sp rd signals
	process (clk, reset, sp_a_rdsig, sp_b_rdsig)
	begin
		if reset = '1' then
			sp_a_rd_reg <= '0';
			sp_b_rd_reg <= '0';
		else
			if rising_edge(clk) then
				sp_a_rd_reg <= sp_a_rdsig;
				sp_b_rd_reg <= sp_b_rdsig;
			end if;	
		end if;
	end process;
	
	
	-- register pipeline control commands
	process (clk, reset, input_reg_en, slot_0_mem_wr, slot_0_mem_rd, slot_1_mem_wr, slot_1_mem_rd,
						slot_0_mem_byteen,  slot_1_mem_byteen, slot_0_mem_sext, slot_1_mem_sext,
						sp_a_rdsig, sp_b_rdsig)
	begin
		if reset = '1'  then
			s0_wr_reg <= '0';
			s0_rd_reg <= '0';
			s1_wr_reg <= '0';
			s1_rd_reg <= '0';
			slot_0_mem_byteen_reg <= "00";
			slot_1_mem_byteen_reg <= "00";
			mem_sext_reg	<= '0';			
		else
				if rising_edge (clk) and input_reg_en = '1' then
					s0_wr_reg <= slot_0_mem_wr;
					s0_rd_reg <= slot_0_mem_rd;
					s1_wr_reg <= slot_1_mem_wr;
					s1_rd_reg <= slot_1_mem_rd;
					slot_0_mem_byteen_reg <= slot_0_mem_byteen;
					slot_1_mem_byteen_reg <= slot_1_mem_byteen;	
					
					mem_sext_reg <= slot_0_mem_sext or slot_1_mem_sext;
				end if;
		end if;
	end process;
	
	do_clk_state: process (clk, reset, ld_st_state, ex_stall)
	begin
		if reset = '1'  then
			ld_st_state <= IDLE;			
		else
			if rising_edge (clk) then
				case ld_st_state is
					when IDLE =>
						--if is_mem = '1' then
						if is_mem = '1' and ex_stall = '0' then
							ld_st_state <= MEM_CALC;
						end if;
														
					when MEM_CALC => 
						if d_waitrequest = '1' then
							ld_st_state <= WAITING;	
						elsif (sp_a_rdsig = '1' or sp_b_rdsig = '1') then
							ld_st_state <= SP;	
						elsif (timer_rd = '1') then
							ld_st_state <= TIMER;
						else
							ld_st_state <= DONE;
						end if;
					
					when SP =>
						ld_st_state <= IDLE;	
					
					when TIMER =>
						ld_st_state <= IDLE;						
					
					when WAITING =>
						if d_waitrequest = '0' then
							ld_st_state <= IDLE;
						end if;				
										
					when DONE =>
						ld_st_state <= IDLE;	
						
				end case;		
			end if;		
		end if;	
	end process;
	
	do_state_output: process (ex_stall, d_waitrequest, ld_st_state,  addr_reg_addr, is_mem, s0_wr_reg, s1_wr_reg, s0_rd_reg, s1_rd_reg,
																src_1_mem_0_to_0, src_2_mem_0_to_0, src_1_mem_0_to_1, src_2_mem_0_to_1)
	begin
		reg_mem_data_en <= '0';
		error_en <= '0';
		d_write <= '0';
		
		input_reg_en <= '0';
		chip_sel_en <= '0';
		mem_calc_en <= '0';
		stall <= '0';
		
		wb_wait		<= '0';
		
		d_writedata_en <= '0';
		
		mem_to_mem_rst_0 <= '0';
		mem_to_mem_rst_1 <= '0';
		
		log <= '0';
				
		case ld_st_state is
			when IDLE =>
			
				input_reg_en <= '1';
				d_writedata_en <= '1';
			
				if is_mem = '1' and ex_stall = '0' then
						stall <= '1';
						mem_calc_en <= '1';
						input_reg_en <= '1';						
						
						if src_1_mem_0_to_0 = '1' or src_2_mem_0_to_0 = '1' then
								mem_to_mem_rst_0 <= '1';
						end if;
						
						if src_1_mem_1_to_0 = '1' or src_2_mem_1_to_0 = '1' then
								mem_to_mem_rst_0 <= '1';
						end if;									
						
						if src_1_mem_0_to_1 = '1' or src_2_mem_0_to_1 = '1' then
								mem_to_mem_rst_1 <= '1';
						end if;	
	
						if src_1_mem_1_to_1 = '1' or src_2_mem_1_to_1 = '1' then
								mem_to_mem_rst_1 <= '1';
						end if;				
				end if;
							
			when MEM_CALC =>
				chip_sel_en <= '1';				
				stall 		<= '1';
				error_en	   <= '1';
				wb_wait		<= '1';		
								
				d_write <= s0_wr_reg or s1_wr_reg;
		
			when SP =>
				reg_mem_data_en <= '1';
				wb_wait	<= '1';
				chip_sel_en <= '1';
				log <= '1';
			
			when TIMER =>
				reg_mem_data_en <= '1';
				wb_wait	<= '1';
				chip_sel_en <= '1';	
		
			-- wait until data is avaliable			
			when WAITING =>
				wb_wait	<= '1';							
							
				d_write <= s0_wr_reg or s1_wr_reg;
				
				chip_sel_en	<= '1';
				reg_mem_data_en <= '1';
				
				if d_waitrequest = '1' then				
					stall <= '1';					
				else
					--stall <= '0';
					--reg_mem_data_en <= '0';
				end if;					
												
			when DONE =>				
				input_reg_en <= '1';				
								
			end case;
	end process;
	
	-- algiment error reporting 
	error_reg : process (clk, reset, error_en, aligment_error)
	begin
		if reset = '1' then
			error <= '0';
		else
			if rising_edge(clk) and error_en = '1' then
				error <= aligment_error;			
			end if;
		
		end if;
	
	end process;
	
	
	
	
	
	
	-- data registration and signal extension
	process (clk, reset, reg_mem_data_en, d_readdata, mem_sext_reg, slot_0_mem_byteen_reg, sp_a_rd_reg, timer_rd)
	begin
		if reset = '1' then
			memory_data_reg <= (memory_data_reg'range => '0');
		else
			if rising_edge(clk) and reg_mem_data_en = '1' then
				
				-- signal extension for LB and LHW
				if mem_sext_reg = '1'  then
					
					if sp_a_rd_reg = '1' then
						memory_data_reg <= sp_a_data_mask;					
					else
						memory_data_reg <= d_readdata;
					end if;
					
					-- signal extension wh
					case slot_0_mem_byteen_reg is
												
						-- when Half Word access
						when "01" =>
							if sp_a_rd_reg = '1' then
								if sp_a_data_mask(15) ='1' then
									memory_data_reg <= x"FFFF" & sp_a_data_mask(15 downto 0);
								end if;							
							else
								if d_readdata(15) = '1' then
									memory_data_reg <= x"FFFF" & d_readdata(15 downto 0);
								end if;
							end if;
													
						-- when Byte access
						when "10" =>
							if sp_a_rd_reg = '1' then
								if sp_a_data_mask(7) = '1' then								
									memory_data_reg <= x"FFFFFF" & sp_a_data_mask(7 downto 0);
								end if;
							else							
								if d_readdata(7) = '1' then
									memory_data_reg <= x"FFFFFF" & d_readdata(7 downto 0);
								end if;
							end if;
						
						when others => 
					end case;					
				else
					if sp_a_rd_reg = '1' then
						memory_data_reg <= sp_a_data_mask;
					elsif (timer_rd = '1') then
						memory_data_reg <= timer_val;
					else
						memory_data_reg <= d_readdata;
					end if;
				end if;					
			end if;		
		end if;
	end process;
	
	-- data registration and signal extension
	process (clk, reset, reg_mem_data_en, d_readdata, mem_sext_reg, slot_0_mem_byteen_reg, sp_b_rd_reg)
	begin
		if reset = '1' then
			memory_data_1_reg <= (memory_data_1_reg'range => '0');
		else
			if rising_edge(clk) and reg_mem_data_en = '1' then
				
				-- signal extension for LB and LHW
				if mem_sext_reg = '1'  then
					
					if sp_b_rd_reg = '1' then
						memory_data_1_reg <= sp_b_data_mask;
					else
						memory_data_1_reg <= d_readdata;
					end if;
					
					-- signal extension wh
					case slot_0_mem_byteen_reg is
												
						-- when Half Word access
						when "01" =>
							if sp_b_rd_reg = '1' then
								if sp_b_data_mask(15) ='1' then
									memory_data_1_reg <= x"FFFF" & sp_b_data_mask(15 downto 0);
								end if;							
							else
								if d_readdata(15) = '1' then
									memory_data_1_reg <= x"FFFF" & d_readdata(15 downto 0);
								end if;
							end if;
													
						-- when Byte access
						when "10" =>
							if sp_b_rd_reg = '1' then
								if sp_b_data_mask(15) = '1' then								
									memory_data_1_reg <= x"FFFFFF" & sp_b_data_mask(7 downto 0);
								end if;
							else							
								if d_readdata(7) = '1' then
									memory_data_1_reg <= x"FFFFFF" & d_readdata(7 downto 0);
								end if;
							end if;
						
						when others => 
					end case;					
				else
					if sp_b_rd_reg = '1' then
						memory_data_1_reg <= sp_b_data_mask;
					else
						memory_data_1_reg <= d_readdata;
					end if;
				end if;					
			end if;		
		end if;
	end process;
	
	
	--data output
	memory_data <= memory_data_reg;
	memory_data_1 <= memory_data_1_reg;
	
	
	-- sp data input mask
	process (sp_a_rd_reg, sp_a_data, sp_a_byteen_sig)
	 begin				
		
		case sp_a_byteen_sig is				
				when "0000" =>	
					sp_a_data_mask <= sp_a_data;			
				when "0001" => 
					sp_a_data_mask <= x"000000" & sp_a_data(7 downto 0);  				
				when "0010" =>
					sp_a_data_mask <=  x"000000" & sp_a_data(15 downto 8);				
				when "0100" => 
					sp_a_data_mask <= x"000000" & sp_a_data(23 downto 16);				
				when "1000" => 
					sp_a_data_mask <= x"000000" & sp_a_data(31 downto 24); 				
				when "1100" => 
					sp_a_data_mask <= x"0000" & sp_a_data(31 downto 16);				
				when "0011" =>
					sp_a_data_mask <= x"0000" & sp_a_data(15 downto 0); 				
				when "1111" =>						
					sp_a_data_mask <= sp_a_data;					
				when others =>
					sp_a_data_mask <= sp_a_data;
			end case; 
	 end process;
	 
	 -- sp data input mask
	process (sp_b_rd_reg, sp_b_data, sp_b_byteen_sig)
	 begin				
		
		case sp_b_byteen_sig is				
				when "0000" =>	
					sp_b_data_mask <= sp_b_data;			
				when "0001" => 
					sp_b_data_mask <= x"000000" & sp_b_data(7 downto 0);  				
				when "0010" =>
					sp_b_data_mask <=  x"000000" & sp_b_data(15 downto 8);				
				when "0100" => 
					sp_b_data_mask <= x"000000" & sp_b_data(23 downto 16);				
				when "1000" => 
					sp_b_data_mask <= x"000000" & sp_b_data(31 downto 24); 				
				when "1100" => 
					sp_b_data_mask <= x"0000" & sp_b_data(31 downto 16);				
				when "0011" =>
					sp_b_data_mask <= x"0000" & sp_b_data(15 downto 0); 				
				when "1111" =>						
					sp_b_data_mask <= sp_b_data;					
				when others =>
					sp_b_data_mask <= sp_b_data;
			end case; 
	 end process;
	 
	 
	 
	 -- timer process
	 process (clk, reset)
	 begin
		if reset = '1' then
			timer_val <= (others=>'0');
		else
			if rising_edge(clk) then
				timer_val <= timer_val + 1;
			end if;
		end if;
	 
	 end process;
	 
	 
	
end rtl;



--chip_select: process (clk,  reset,
--											addr0, addr1,
--											chip_sel_en,
--											s0_wr_reg, s0_rd_reg,
--											s1_wr_reg, s1_rd_reg)									
--	begin
--		
--		if reset = '1' then
--			chip_sel <= "0000";
--			d_address <= (d_address'range => '0');
--		else
--				chip_sel <= "0000";
--				d_address <= (d_address'range => '0');
--				
--				sp_a_addr <= (others => '0');
--				sp_b_addr <= (others => '0');
--				sp_a_rdsig <= '0';
--				sp_b_rdsig <= '0';
--				
--				sp_a_wr <= '0';
--				sp_b_wr <= '0';
--		
--				if chip_sel_en = '1' then
--				
--					sp_a_addr <= (others => '0');
--					sp_b_addr <= (others => '0');
--					
--					sp_a_rdsig <= '0';
--					sp_b_rdsig <= '0';
--				
--					sp_a_wr <= '0';
--					sp_b_wr <= '0';				
--					
--					-- CODE address space
--					if addr0 < SRAM_INI and (s0_wr_reg ='1' or s0_rd_reg = '1') then
--						chip_sel <= "0001";
--						d_address	<= addr0(DATA_ADDR_SIZE-1  downto 0);
--					end if;
--					
--					if addr1 < SRAM_INI and (s1_wr_reg ='1'  or s1_rd_reg = '1') then
--						chip_sel <= "0001";
--						d_address	<= addr1(DATA_ADDR_SIZE-1  downto 0);
--					end if;
--			
--					-- SRAM
--					if addr0 > CODE_END and addr0 <= SRAM_END and  (s0_wr_reg ='1' or s0_rd_reg = '1') then
--						--chip_sel <= "00010"; 
--						--d_address	<= addr0(DATA_ADDR_SIZE-1  downto 0);					
--						
--						
--						sp_a_addr <=  addr0(SP_ADDR_SIZE+1 downto 2);
--						sp_a_rdsig		<= s0_rd_reg;
--						sp_a_wr    <= s0_wr_reg;
--						
--					end if;
--			
--					if addr1 > CODE_END and addr0 <= SRAM_END and  (s1_wr_reg ='1' or s1_rd_reg = '1') then
--						--chip_sel <= "0010";
--						--d_address	<= addr1(DATA_ADDR_SIZE-1  downto 0);	
--						
--						sp_b_addr <=  addr1(SP_ADDR_SIZE+1 downto 2);
--						sp_b_rdsig		<= s1_rd_reg;
--						sp_b_wr    <= s1_wr_reg;						
--						
--					end if;		
--					
--					-- IO					
--					
----					-- SDRAM
----					if addr0 >= x"80000000" and (s0_wr_reg ='1' or s0_rd_reg = '1') then
----						chip_sel <= "1000"; 
----						d_address	<= addr0(DATA_ADDR_SIZE-1  downto 0);
----					end if;
----			
----					if addr1 >= x"80000000" and (s1_wr_reg ='1' or s1_rd_reg = '1') then
----						chip_sel <= "1000"; 
----						d_address	<= addr1(DATA_ADDR_SIZE-1  downto 0);
----					end if;		
--	
--				end if;				
--			end if;	
--	end process;