--------------------------------------------------------------------------------
--  VLIW-RT CPU - Core fetch entity
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

entity fetch is
port (
	clk      					: in std_logic;	
	reset    				: in std_logic;
	halt						: in std_logic;
	cache_busy 	: in std_logic;
	cache_data_rdy : in std_logic;
	mem_busy		: in std_logic;
	dep_stall : in std_logic;
	
	branch_in		: in std_logic;
	b_address		: in pc_t;
	
	goto_in : in std_logic;
	goto_addr : in pc_t;
	
	jump_reg	: in std_logic;
	link_reg		: in pc_t;
	
	preld_en			: in std_logic;
	preload_addr	: in pc_t;
	
	cache_line_in  : in  std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
	
	bundle_error	: out std_logic;
	
	cache_address	: out pc_t;
	next_pc_out			: out pc_t;	
	cache_abort 		: out std_logic;	
	
	slot_ctrl_0 	: out t_slot_ctrl;
	slot_ctrl_1 	: out t_slot_ctrl;
	slot_ctrl_2 	: out t_slot_ctrl;
	slot_ctrl_3 	: out t_slot_ctrl;
	
	ex_stall				: out std_logic;
	delay_dep			: out std_logic;
	
	-- debug
	n_ctrl_flow			: out word_t;
	
	slot_0 			: out word_t;
	slot_1 			: out word_t;
	slot_2 			: out word_t;
	slot_3 			: out word_t		
	);
end fetch;


architecture rtl of fetch is		
	
	component ins_buffer
		port (
			clk      	: in std_logic;	
			reset    	: in std_logic;
			enable		: in std_logic;	
			addr_ld		: in std_logic;
			preld			: in std_logic;
			addr_in		: in pc_t;	
			
			bundle_in : in std_logic_vector(CACHE_LINE_SIZE-1 downto 0);	
					
			slot_0			   : out word_t; 
			slot_1			   : out word_t;
			slot_2			   : out word_t;
			slot_3			   : out word_t;	
			
			error					: out std_logic;
			recover				: out pc_t;
			next_address 		: out pc_t	
	);
	end component ins_buffer;
	
	component cache_buffer
	port (
		clk      				: in std_logic;	
		reset    			: in std_logic;
		halt					: in std_logic;
		cache_stall	: in std_logic;
		cache_data_rdy : in std_logic;
		mem_stall    : in std_logic;
		dep_stall : in std_logic;
		goto_in			: in std_logic;		
		f_error					: in std_logic;
		next_pc				: in pc_t;
		goto_addr			: in pc_t;			
		next_pc_reg		: out pc_t;
		cache_data			: in std_logic_vector(CACHE_LINE_SIZE-1 downto 0);	
	
		-- jump to register
		jump_reg_in : in std_logic;
		link_reg			: in pc_t;
		pre_jr				: in std_logic;
		
		-- branch
		branch_in		: in std_logic;
		b_address	: in pc_t;
	
		-- preload
		preld_en			: in std_logic;
		preload_addr	: in pc_t;
		recover			: in pc_t;
		
		exec_slot_mask : in std_logic_vector(3 downto 0);
		
		delay_dep			: out std_logic;
		
		n_ctrl_flow			: out word_t;
	
		decode_ld			: out std_logic;
		decode_ld_sel		: out std_logic;
		decode_en			: out std_logic;
		decode_reset		: out std_logic;
		
		decode_preld_en : out std_logic;
		
		bundle_out 			: out std_logic_vector(CACHE_LINE_SIZE-1 downto 0);	
		cache_abort			: out std_logic;
		b_address_reg		: out pc_t;
		cache_address		: out pc_t
		
	);
	end component cache_buffer;
	
	signal controller_reset 	: std_logic;
	signal buffer_enable 		: std_logic;
	signal ins_buffer_addr_ld	: std_logic;			
	signal decode_ld_sel			: std_logic;
	signal ins_buffer_reset 	: std_logic;	
		
	signal ins_buffer_preset	: pc_t;
	signal ins_buffer_addr 		: pc_t;	
	signal ins_buffer_addr_in 	: pc_t;	
	signal cache_addr 			: pc_t;
	signal next_pc_reg			: pc_t;
	
	signal slot_0_int 			: word_t;
	signal slot_1_int				: word_t;
	signal slot_2_int				: word_t;
	signal slot_3_int 			: word_t;
	
	signal cache_bundle 			: std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
	
	signal b_address_reg			: pc_t;
	
	signal f_error : std_logic;
	
	signal contrl_delay_dep : std_logic;
	
	signal exec_slot_mask : std_logic_vector(3 downto 0);
	
	signal pre_jr : std_logic;
	
	signal inst_buffer_preld_en : std_logic;
	signal recover_addr 			: pc_t;
	
		
begin

	ins_buffer_reset <= reset or controller_reset;	
	
	delay_dep <= contrl_delay_dep;
	
	exec_slot_mask <= slot_3_int(31) &  slot_2_int(31) &  slot_1_int(31) & slot_0_int(31);
		
	-- register ex_stall signal to pass to next pipeline stage
	process (clk, reset, mem_busy)
	begin
		if reset = '1' then 
			ex_stall <= '0';
		else
			if rising_edge(clk) then
				ex_stall	<=	mem_busy;
			end if;
		end if;
	end process;

	-----------------------------------
	-- 1st cycle: buffer cache data	--
	-----------------------------------	
	
	cache_buffer_1: cache_buffer
		port map ( 
			clk => clk,
			reset => reset,
			halt	=> halt,
			cache_stall	=> cache_busy,
			cache_data_rdy => cache_data_rdy,
			mem_stall => mem_busy,
			dep_stall => dep_stall,
			decode_reset => controller_reset,
			goto_in => goto_in,			
			next_pc 	  => ins_buffer_addr,
			next_pc_reg => next_pc_reg,
			cache_data => cache_line_in,
			
		   exec_slot_mask => exec_slot_mask,
			
			jump_reg_in => jump_reg,
			link_reg			=> link_reg,
			pre_jr				=> pre_jr,
			
			branch_in		=> branch_in,
			b_address	=> b_address,
			
			preld_en			=> preld_en,
			preload_addr	=> preload_addr,
			recover => recover_addr,
			
			n_ctrl_flow => n_ctrl_flow,
			
			bundle_out => cache_bundle,
			decode_ld	=> ins_buffer_addr_ld,
			decode_ld_sel => decode_ld_sel,
			decode_en => buffer_enable,
			
			decode_preld_en => inst_buffer_preld_en,
			
			goto_addr => goto_addr,
			b_address_reg => b_address_reg,
			f_error	=> f_error,
			delay_dep => contrl_delay_dep,
			cache_abort	=> cache_abort,
			cache_address => cache_addr
		);
	
	--------------------------------------------
	-- 2nd cycle: slot/instruction decoding	--
	-----------------------------------	--------
	
	ins_buffer_1: ins_buffer
		port map (
			clk => clk,			
			reset => ins_buffer_reset,
			enable => buffer_enable,
			addr_ld =>  ins_buffer_addr_ld,
			addr_in => ins_buffer_preset,
			
			preld	=> inst_buffer_preld_en,
			recover	=> recover_addr,
			
			bundle_in => cache_bundle,						
			slot_0 => slot_0_int,
			slot_1 => slot_1_int,
			slot_2 => slot_2_int,
			slot_3 => slot_3_int,			
			error		=> f_error,
			next_address => ins_buffer_addr			
		);
		
	bundle_error <= f_error;
		
	ins_buffer_addr_mux: process(decode_ld_sel, next_pc_reg, b_address_reg)
	--ins_buffer_addr_mux: process(decode_ld_sel, next_pc_reg, b_address)
	begin
		if decode_ld_sel = '0' then
			ins_buffer_preset <= next_pc_reg;
		else
			ins_buffer_preset <= b_address_reg;
			--ins_buffer_preset <= b_address;
		end if;	
	end process;
						
	--------------------------------
	-- outputs after 2nd cycle: 	--	
	--------------------------------
	slot_0 <= slot_0_int;
	slot_1 <= slot_1_int;
	slot_2 <= slot_2_int;
	slot_3 <= slot_3_int;
	
	
	-- presearch jumps
	process (slot_0_int)
	begin	
		--if (slot_0_int(29 downto 27)= "110") and (slot_0_int(23) = '1') then
		if (slot_0_int(29 downto 27)= "110") and slot_0_int(26 downto 24) /= "111" then		
			pre_jr <= '1';
		else
			pre_jr <= '0';									
		end if;
	end process;
		
	--register src1 address to keep value in branch instructions
	slot_ctrl_0.src_1	<=	slot_0_int(REG_SRC1_END downto REG_SRC1_INI);
	slot_ctrl_0.src_2	<=	slot_0_int(REG_SRC2_END downto REG_SRC2_INI);
	slot_ctrl_0.dest	<=	slot_0_int(REG_DEST_END downto REG_DEST_INI);
	slot_ctrl_0.b_dest <= slot_0_int(BDEST_END downto BDEST_INI);
	-- branch reads predicated register file in other bit field
	process (slot_0_int)
	begin
		if slot_0_int(INS_FORMAT_END downto INS_FORMAT_INI-1) = "111" then
			slot_ctrl_0.scond	 <= slot_0_int(BCOND_END downto BCOND_INI);
		else
			slot_ctrl_0.scond	 <= slot_0_int(SCOND_END downto SCOND_INI);
		end if;
	end process;
	--slot_ctrl_0.immediate <= "00000000000000000000000" & slot_0_int(IMMEDIATE_END downto IMMEDIATE_INI);
	
	slot_ctrl_1.src_1	<=	slot_1_int(REG_SRC1_END downto REG_SRC1_INI);
	slot_ctrl_1.src_2	<=	slot_1_int(REG_SRC2_END downto REG_SRC2_INI);
	slot_ctrl_1.dest	<=	slot_1_int(REG_DEST_END downto REG_DEST_INI);
	slot_ctrl_1.b_dest <= slot_1_int(BDEST_END downto BDEST_INI);
--	process (slot_1_int)
--	begin
--		if slot_1_int(INS_FORMAT_END downto INS_FORMAT_INI-1) = "111" then
--			slot_ctrl_1.scond	 <= slot_1_int(BCOND_END downto BCOND_INI);
--		else
		slot_ctrl_1.scond	 <= slot_1_int(SCOND_END downto SCOND_INI);
--		end if;
--	end process;
	--slot_ctrl_1.immediate <= "00000000000000000000000" & slot_1_int(IMMEDIATE_END downto IMMEDIATE_INI);
	
	slot_ctrl_2.src_1	<=	slot_2_int(REG_SRC1_END downto REG_SRC1_INI);
	slot_ctrl_2.src_2	<=	slot_2_int(REG_SRC2_END downto REG_SRC2_INI);
	slot_ctrl_2.dest	<=	slot_2_int(REG_DEST_END downto REG_DEST_INI);
	slot_ctrl_2.b_dest <= slot_2_int(BDEST_END downto BDEST_INI);
--	process (slot_2_int)
--	begin
--		if slot_2_int(INS_FORMAT_END downto INS_FORMAT_INI-1) = "111" then
--			slot_ctrl_2.scond	 <= slot_2_int(BCOND_END downto BCOND_INI);
--		else
		slot_ctrl_2.scond	 <= slot_2_int(SCOND_END downto SCOND_INI);
--		end if;
--	end process;
	--slot_ctrl_2.immediate <= "00000000000000000000000" & slot_2_int(IMMEDIATE_END downto IMMEDIATE_INI);
	
	slot_ctrl_3.src_1	<=	slot_3_int(REG_SRC1_END downto REG_SRC1_INI);
	slot_ctrl_3.src_2	<=	slot_3_int(REG_SRC2_END downto REG_SRC2_INI);
	slot_ctrl_3.dest	<=	slot_3_int(REG_DEST_END downto REG_DEST_INI);
	slot_ctrl_3.b_dest <= slot_3_int(BDEST_END downto BDEST_INI);
--	process (slot_3_int)
--	begin
--		if slot_3_int(INS_FORMAT_END downto INS_FORMAT_INI-1) = "111" then
--			slot_ctrl_3.scond	 <= slot_3_int(BCOND_END downto BCOND_INI);
--		else
	slot_ctrl_3.scond	 <= slot_3_int(SCOND_END downto SCOND_INI);
--		end if;
--	end process;
	--slot_ctrl_3.immediate <= "00000000000000000000000" & slot_3_int(IMMEDIATE_END downto IMMEDIATE_INI);
	
	cache_address	<=  cache_addr;		
	next_pc_out	<= next_pc_reg;
	

end rtl;
