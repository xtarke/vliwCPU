--------------------------------------------------------------------------------
--  VLIW-RT CPU - Cache data buffer and fetch controller entity
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

entity cache_buffer is
port (
	clk      				: in std_logic;	
	reset    			: in std_logic;
	halt					: in std_logic;
	cache_stall	: in std_logic;
	cache_data_rdy : in std_logic;
	mem_stall    : in std_logic;
	dep_stall		 : in std_logic;	
	f_error				: in std_logic;
	next_pc			: in pc_t;
	cache_data	: in std_logic_vector(CACHE_LINE_SIZE-1 downto 0);	

	-- jump to register
	jump_reg_in : in std_logic;
	link_reg			: in pc_t;	
	pre_jr				: in std_logic;
	
	-- branch
	branch_in		: in std_logic;
	b_address	: in pc_t;
	
	-- goto
	goto_in			: in std_logic;	
	goto_addr	: in pc_t;		
	
	-- preload
	preld_en			: in std_logic;
	preload_addr	: in pc_t;
	
	-- stop bits for paralel instructions accouting
	exec_slot_mask : in std_logic_vector(3 downto 0);
	
	next_pc_reg		: out pc_t;
	decode_ld		: out std_logic;
	decode_ld_sel	: out std_logic;
	decode_en		: out std_logic;
	decode_reset	: out std_logic;
	
	decode_preld_en : out std_logic;
	-- recover address when branch-prediction is wrong
	recover			: in pc_t;
	
	bundle_out 		: out std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
	b_address_reg	: out pc_t;
	
	delay_dep			: out std_logic;
	
	n_ctrl_flow			: out word_t;
	
	
	cache_abort		: out std_logic;
	cache_address		: out pc_t
	
	);
end cache_buffer;

architecture rtl of cache_buffer is
	
	signal cache_data_reg	:	std_logic_vector(CACHE_LINE_SIZE-1 downto 0);

	signal bundle_sel				: std_logic;
	signal branch_bundle_sel	: std_logic;
	
	type cache_addr_state_type is (IDLE, ENC_ERROR, HALTED, STALL, B_L, INIT, INIT_2, FLOW_STALL, EX_STALL_SYNC_1, EX_STALL_SYNC_2,  
			GOTOIN, ENC_LOAD, EXSTALL, DEPSTALL, FLOW_EXSTALL, JUMP_REGIN, BRANCHIN, PRELD, BRANCH_PRED, PRED_INIT);
	signal cache_addr_state : cache_addr_state_type;
	
	signal cache_addr_state_reg : cache_addr_state_type;
	
	signal cache_data_reset  	: std_logic;
	signal cache_data_enable : std_logic;
	signal cache_addr_enable : std_logic;	
	signal reg_pc_enable		 : std_logic;
	
	signal addr_mux_sel			: std_logic_vector(2 downto 0);
					
	signal internal_address		: pc_t;
	signal next_pc_reg_int 		: pc_t;
	
	-- buffer high mask
	signal b1_mask						: std_logic_vector(3 downto 0);		--MSB mask using cache_data_reg
	signal slots									: std_logic_vector(1 downto 0);
	
	signal address_reset			: std_logic;	
			
	signal reg_state_enable : std_logic;
	
	signal branch_bundle_sel_reg	: std_logic;
	signal reg_branch_bundle_sel_en : std_logic;
	signal reg_branch_bundle_sel_rst : std_logic;
	
	signal dep_stall_reg_en : std_logic;
	signal dep_stall_reg 		  : std_logic;
	
	signal current_cache_line : std_logic_vector(INDEX_SIZE-1 downto 0);
	signal branch_cache_line : std_logic_vector(INDEX_SIZE-1 downto 0);
	-- cache line of the last instructions of a preld set (preld, compare, br)
	signal preld_set_cache_line : std_logic_vector(INDEX_SIZE-1 downto 0);
	signal exec_cache_line : std_logic_vector(INDEX_SIZE-1 downto 0);
	
	-- depency stall fallowed by a EX_STALL
	signal dep_ex_stall 		: std_logic;
	signal dep_ex_stall_en : std_logic;
		
	--
	signal branched : std_logic;
	signal branched_en : std_logic;
	
	signal goto_in_state	: std_logic;
	
	signal b_address_reg_en	: std_logic;
	signal b_address_reg_internal : pc_t;
	
	signal cache_address_int : pc_t;
	
	signal control_flow_counter : word_t;
	signal branch_cou_en : std_logic;
	
	signal cache_stall_reg : std_logic;
	
	signal preld_reg_en	: std_logic;
	signal preld_reg		: std_logic;
	
	signal preload_addr_reg : pc_t;
	
	signal recover_addr : pc_t;
	signal recover_en : std_logic;
	
	signal branch_inst_addr : pc_t;
	
	signal preld_miss_en : std_logic;
	signal preld_miss	: pc_t;
	
	
	signal resync_en : std_logic;
	signal fetch_resync : std_logic;
	
	signal fetch_error : std_logic;
	
	signal preld_en_addr : std_logic;
	signal preld_en_addr_en : std_logic;
	

begin
	-- cache lines	
	--branch_cache_line <= goto_addr(INDEX_END downto INDEX_INI); 
	branch_cache_line <= b_address_reg_internal(INDEX_END downto INDEX_INI);	
	
	--selects the bundle
	bundle_sel <= next_pc(BK_OFFSET_END);
	
	branch_bundle_sel <= b_address_reg_internal(BK_OFFSET_END);
	slots <= next_pc(1 downto 0);

	-- control_flow_counter
	n_ctrl_flow <= control_flow_counter;
	
	-- possible address of a br instruction when preld, preld is always 3 instructions earlier br
	branch_inst_addr <= next_pc + 1;
		
	process (clk, reset, cache_stall)
	begin
		if reset = '1' then
			cache_stall_reg <= '0';
		else
			if rising_edge(clk) then
				cache_stall_reg <= cache_stall;
			end if;
		end if;	
	end process;
	
	
	process (clk, reset)
	begin
		if reset = '1' then
			preld_en_addr <= '0';
		else
			if rising_edge(clk) and preld_en_addr_en = '1' then
				
				if preld_en_addr = '1' then
					preld_en_addr <= '0';
				else
					preld_en_addr <= '1';
				end if;				
				
			end if;
		end if;
	end process;
	
	
	
	process (clk, reset)
	begin
		if reset = '1' then
			preld_reg <= '0';
			recover_addr <= (recover_addr'range => '0');
			
		else
			if rising_edge(clk) and preld_reg_en = '1' then
				preld_reg <= preld_en;
				preload_addr_reg <= preload_addr;
				
				recover_addr 		<= next_pc;
				
			end if;
		end if;	
	end process;
	
	process (clk, reset)
	begin
		if reset = '1' then
			preld_miss <= (preld_miss'range => '0');
		else
			if rising_edge(clk) and preld_miss_en = '1' then
				preld_miss <= preld_miss + 1;
			end if;
		end if;	
	end process;
	
	process (clk, reset)
	begin
		if reset = '1' then
			fetch_resync <= '0';
		else
			if rising_edge(clk) then			
								
				if exec_cache_line /= "00000" and cache_data_rdy = '1' then						
					fetch_resync <= '1';
				end if;
				
				if resync_en = '1' then
					fetch_resync <= '0';
				end if;
				
			end if;
		end if;
	end process;

	
	reg_state: process (clk, reset, mem_stall, cache_addr_state, reg_state_enable)
	begin
		if reset = '1' then
				cache_addr_state_reg <= IDLE;
		else
				if rising_edge (clk) and reg_state_enable = '1' then
					cache_addr_state_reg	<= cache_addr_state;				
				end if;
		end if;
	end process;
	
	reg_branch: process (clk, reset, branched_en)
	begin
		if reset = '1' then
				branched <= '0';
		else
				if rising_edge (clk) and branched_en = '1' then
					branched <= goto_in_state;
				end if;
		end if;
	end process;
	
	
	--register dep_stall signal: usefull when mem_stall and dep_stall ocurs at same time
	-- fetch has to remember to disable encoder for one more cycle
	process (clk, reset, dep_stall, dep_stall_reg_en)
	begin
		if reset = '1' then
			 dep_stall_reg <= '0';
		else
			if rising_edge(clk) and dep_stall_reg_en = '1' then
				dep_stall_reg <= dep_stall;
			end if;			
		end if;	
	end process;
	
	--register dep_stall signal: usefull when mem_stall occurs after a dep_stall 
	-- fetch has to remember to disable data_cache in EX_STALL state
	process (clk, reset, dep_stall, dep_ex_stall_en)
	begin
		if reset = '1' then
			 dep_ex_stall <= '0';
		else
			if rising_edge(clk) and dep_ex_stall_en = '1' then
				dep_ex_stall <= dep_stall;
			end if;			
		end if;	
	end process;
	
	-- register input branch address
	process (clk, reset, goto_addr, b_address, b_address_reg_en)
	begin
		if reset = '1' then 
			b_address_reg_internal <= (b_address_reg_internal'range => '0');
		else
			if rising_edge(clk) and b_address_reg_en = '1' then
				
				if goto_in = '1' then				
					b_address_reg_internal	<=	goto_addr;			
				end if;
				
				if branch_in ='1' then
					b_address_reg_internal	<=	b_address;					
				end if;
				
				if jump_reg_in = '1' then
					b_address_reg_internal	<=	link_reg;
				end if;
				
				if preld_en = '1' then
					b_address_reg_internal	<=	preload_addr;					
				end if;
				
				if recover_en = '1' then
					b_address_reg_internal	<=	recover;					
				end if;
				
			end if;
		end if;
	end process;
	
	b_address_reg <= b_address_reg_internal;
		
	--fsm state progression
	do_clk_state: process (clk, goto_in, cache_stall, mem_stall, dep_stall, halt, reset, bundle_sel, b1_mask, cache_addr_state_reg, 
						next_pc, f_error, branched, fetch_resync)
	begin
		if reset = '1' then
			cache_addr_state <= IDLE;
		else			
			if rising_edge (clk) then
				case cache_addr_state is
					when IDLE =>
						if cache_stall = '1' then
							cache_addr_state <= STALL;
						end if;
							
					when EX_STALL_SYNC_1 => 
						cache_addr_state <= EX_STALL_SYNC_2;
					
					when EX_STALL_SYNC_2 => 
						cache_addr_state <= B_L;
						
						if cache_stall = '1' then
								cache_addr_state <= STALL;
						end if;
						
						if mem_stall = '1' then
							cache_addr_state <= EX_STALL_SYNC_2;
						end if;
					
					when EXSTALL => 
						if mem_stall = '0'  then								
--								if cache_addr_state_reg = STALL and cache_stall = '0' then
--									cache_addr_state <= INIT;	
--								else														
									
									if cache_data_rdy = '0' then
										cache_addr_state <= B_L;
		
										if fetch_resync = '1' and current_cache_line = exec_cache_line and dep_stall_reg = '0' then
											cache_addr_state <= STALL;
										end if;
		
									else
										if cache_stall_reg = '1' then
											cache_addr_state <= INIT_2;
										else
											cache_addr_state <= STALL;										
										end if;	
																													
									end if;
									
									if preld_reg = '1' then
										cache_addr_state <= PRELD;
									end if;
									
								--end if;
						end if;
--						
						--if cache_stall = '1' and next_pc(2 downto 0) = "000" and mem_stall = '0' the											
						--if cache_stall = '1' and next_pc = cache_address_int and mem_stall = '0' then 
						--if cache_stall = '1' and next_pc >= cache_address_int and mem_stall = '0' and dep_stall_reg = '0' then				
						if cache_stall_reg = '1' and mem_stall = '0' and dep_stall_reg = '0' then				
														
							if next_pc >= cache_address_int then
								cache_addr_state <= STALL;	
							else
								-- there are other cases
--								if bundle_sel = '1' and b1_mask = "1011" and slots = "10" then
--									cache_addr_state <= EX_STALL_SYNC_1;	
--								end if;
							end if;
							
							if preld_reg = '1' and cache_stall = '0' then
									cache_addr_state <= PRELD;
							end if;	
						end if;						
						
						--if goto_in = '1' and branched = '0' and mem_stall = '0' then
--						if goto_in = '1' and branched = '0' and mem_stall = '0' then
--							--cache_addr_state <= FLOW_EXSTALL;
--							cache_addr_state <= GOTOIN;
--						end if;
--						
--						if jump_reg_in = '1' and branched = '0' then
--							cache_addr_state <= FLOW_EXSTALL;
--						end if;

						if goto_in = '1' and branched = '0' and mem_stall = '0' then 
							cache_addr_state <= GOTOIN;
						end if;

						if jump_reg_in = '1' and branched = '0' and mem_stall = '0' then
							cache_addr_state <= JUMP_REGIN;
						end if;
						
						if branch_in = '1' and branched = '0' and mem_stall = '0' then
							cache_addr_state <= BRANCHIN;
						end if;
						
					
					when FLOW_EXSTALL =>
							if mem_stall = '0'  then
									cache_addr_state <= B_L;									
									
									if goto_in = '1' then									
										cache_addr_state <= GOTOIN;
									end if;
									
									if jump_reg_in = '1' then
										cache_addr_state <= JUMP_REGIN;
									end if;									
							end if;
					
					when DEPSTALL => 
						cache_addr_state <= PRED_INIT;
					
					when HALTED => 
					
					when ENC_ERROR => 
				
					when INIT =>					
						cache_addr_state <= INIT_2;

						if cache_stall = '1' then
							cache_addr_state <= STALL;
						end if;
						
--						if mem_stall = '1' then
--							cache_addr_state <= INIT;
--						end if;
						
					when INIT_2 => 
						cache_addr_state	<= B_L;
						
					when PRED_INIT =>	
						cache_addr_state	<= B_L;
				
					when ENC_LOAD =>
						if cache_stall = '1' then
							cache_addr_state	<= STALL;
						else						
							cache_addr_state	<= B_L;
						end if;
						
						if mem_stall = '1' then
								cache_addr_state	<= ENC_LOAD;
						end if;
						
					when STALL => 
						if cache_stall = '1' or cache_addr_state_reg = FLOW_STALL or dep_ex_stall = '1' then
							cache_addr_state <= STALL;
						else
							cache_addr_state <= INIT;
						end if;
						
						if mem_stall = '1' then
							cache_addr_state <=STALL;
						end if;
						
						if goto_in = '1' and branched = '0' and mem_stall = '0' then
							cache_addr_state <= GOTOIN;
						end if;						
						
						--if jump_reg_in = '1' and branched = '0' and mem_stall = '0' then
						if jump_reg_in = '1'  then
							cache_addr_state <= JUMP_REGIN;
						end if;	
						
						if branch_in = '1'  then
							cache_addr_state <= BRANCHIN;
						end if;	
						
					when GOTOIN =>
				
						cache_addr_state <= ENC_LOAD;		
		
						if cache_stall = '1' then
							cache_addr_state <= FLOW_STALL;
						end if;
				
						-- if commented, jumping to MSB bundle does not work
						if mem_stall = '1' then
							cache_addr_state <= GOTOIN;
						end if;
						
					when JUMP_REGIN =>
						cache_addr_state <= ENC_LOAD;		
		
						if cache_stall = '1' then
							cache_addr_state <= FLOW_STALL;
						end if;
						
						if mem_stall = '1' then
							cache_addr_state <= JUMP_REGIN;
						end if;

					when BRANCHIN => 
						cache_addr_state <= ENC_LOAD;		
		
						if cache_stall = '1' then
							cache_addr_state <= FLOW_STALL;
						end if;
						
						if mem_stall = '1' then
							cache_addr_state <= BRANCHIN;
						end if;						

					when FLOW_STALL => 	
						
							if cache_stall = '1' then							
								cache_addr_state <= STALL;
							else
								cache_addr_state <= B_L;
							end if;
										
							if mem_stall = '1' then
								cache_addr_state <= FLOW_STALL;
							end if;
					
--						if halt = '1' then
--							cache_addr_state <= HALTED;
--						end if;	
					
					when PRELD => 
						
						if dep_stall = '0' then						
							cache_addr_state <= BRANCH_PRED;					
						end if;
						
						if mem_stall = '1' then
							cache_addr_state <= EXSTALL;
						end if;
						
					when BRANCH_PRED =>
											
						if branch_in = '1' then
							cache_addr_state <= PRED_INIT;
							
--							if b1_mask = "1000" and bundle_sel = '1' then
--								cache_addr_state <= DEPSTALL;
--							end if;
							
							if cache_stall = '1' then
								cache_addr_state <= STALL;
							end if;							
						else
							cache_addr_state <= BRANCHIN;
						end if;
					
					when B_L =>
								
						--if cache_stall = '1' and next_pc(2 downto 0) = "000"  and mem_stall = '0' then        --and buffer_full = '0' then
						
						--if cache_stall = '1' and next_pc = internal_address then 
						
						if f_error = '1' then
							cache_addr_state <= ENC_ERROR;							
						end if;								
						
						--if cache_stall = '1' and next_pc(2 downto 0) = "000" and dep_stall = '0' then
						if cache_stall = '1' and next_pc >= cache_address_int and dep_stall = '0' and preld_reg = '0' then						
							cache_addr_state <= STALL;							
						end if;
						
						-- fetch resync when cache is faster than instruction exetucion
						if fetch_resync = '1' and current_cache_line = exec_cache_line then
						--if fetch_resync = '1' and next_pc >= cache_address_int then
							cache_addr_state <= STALL;
						end if;
						
						if goto_in = '1' and branched = '0' then 
							cache_addr_state <= GOTOIN;
						end if;

						if jump_reg_in = '1' then
							cache_addr_state <= JUMP_REGIN;
						end if;
						
						if branch_in = '1' then
							cache_addr_state <= BRANCHIN;
						end if;
						
						--if preld_reg = '1' then
--						if preld_en = '1' and  exec_cache_line = preld_set_cache_line then
--							cache_addr_state <= PRELD;
--						end if;
							
						if preld_en = '1' then
							--cache_addr_state <= PRELD;
							
							if cache_stall = '0' or (exec_cache_line = preld_set_cache_line) then
								cache_addr_state <= PRELD;
							end if;
							
							if cache_stall = '1' and exec_cache_line /= preld_set_cache_line then
								cache_addr_state <= B_L;
							end if;
										
						end if;
												
						if mem_stall = '1' then 
							cache_addr_state <= EXSTALL;
						end if;
																					
						if halt = '1' then
							cache_addr_state <= HALTED;
						end if;					
									
				end case;		
			end if;		
		end if;	
	end process;
	
	
	process (fetch_error)
	begin
		if fetch_error = '1' then
			assert false report "Fetch error" severity error;			
		end if;	
	end process;	
	
	--fsm ouput progression
	do_state_output: process (cache_addr_state, cache_stall, next_pc, cache_data, 
										bundle_sel, b1_mask, slots,  f_error, mem_stall, dep_stall,
										branch_bundle_sel, branch_bundle_sel_reg, dep_stall_reg,
										branch_cache_line, current_cache_line, dep_ex_stall, branched,
										next_pc_reg_int, cache_address_int, internal_address, 
										pre_jr,
										goto_in,
										branch_in,
										jump_reg_in)
	begin
		
		--default controller optons
		decode_en				<= '1';	-- instrunction buffer
		cache_data_enable <= '0';	-- internal data register
		cache_addr_enable <= '0';	-- internal adddr register
		cache_data_reset	<= '0';	-- internal data register reset
		decode_reset		<= '0';	-- instrunction buffer reset	
		reg_pc_enable		<= '1';	-- pc register enable
		decode_ld				<= '0';	-- instrunction buffer preset
		decode_ld_sel		<= '0';	-- instrunction buffer preset select			
		addr_mux_sel		<= "000";	-- internal adddr register preset selector
		
		reg_state_enable	<= '1';		
		cache_abort				<= '0';
		reg_branch_bundle_sel_en	<= '0';
		reg_branch_bundle_sel_rst  <= '0';
		
		dep_stall_reg_en	<= '1';
		delay_dep				<= '0';
		
		dep_ex_stall_en <= '1';
		goto_in_state <= '0';
		
		branched_en <= '1';
		
		b_address_reg_en <= '0';
		
		branch_cou_en  <= '0';
		preld_reg_en	<= '0';
		
		decode_preld_en <= '0';
		recover_en		<= '0';
		preld_miss_en	<= '0';
		
		resync_en <= '0';
		
		fetch_error <= '0';	
		preld_en_addr_en	<= '0';
					
		case cache_addr_state is
			when IDLE =>	
				

			when HALTED =>
				decode_en				<= '0';
			
			when ENC_ERROR =>
				decode_en				<= '0';	
				fetch_error		<= '1';
					
			when INIT =>
			
				resync_en <= '1';
				
				reg_pc_enable			<= '0';
				decode_ld				<= '1';		
				
				if cache_stall = '0' then
					cache_data_enable 	<= '1';						
					addr_mux_sel			<= "000";
					cache_addr_enable <= '1';
				end if;
				
			when INIT_2 =>
				resync_en <= '1';
				decode_en				<= '0';
				
				if cache_addr_state_reg = EXSTALL then
					cache_data_enable <= '1';
				end if;
				
			when PRED_INIT => 
				
				--if branch_bundle_sel = '1' then									
				if bundle_sel = '1' then									
										
--					if b1_mask = "1000" then
--						cache_addr_enable <= '1';
--					end if;
--
--					cache_data_enable <= '1';
					
					case b1_mask is					
								when "1111" =>
									if slots = "11" then
										cache_data_enable <= '1';								
--										cache_addr_enable <= '1';													
									end if;						
								
								when "1110" => 
									if slots = "11" then
										cache_data_enable <= '1';
--										cache_addr_enable <= '1';
									end if;
									
								when "1101" => 
									if slots = "11" then
										cache_data_enable <= '1';
--										cache_addr_enable <= '1';
									end if;
									
								when "1100" => 							
									if slots = "11" then
										cache_data_enable <= '1';
--										cache_addr_enable <= '1';
									end if;
								
								when "1011" =>
									if slots = "10" then
										cache_data_enable <= '1';
--										cache_addr_enable <= '1';
									end if;					
							
								when "1010" => 
									if slots = "10" then
										cache_data_enable <= '1';
--										cache_addr_enable <= '1';
									end if;										
								
								when "1001" =>
									if slots = "01" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
									
								when "1000" =>
									cache_data_enable <= '1';									
									cache_addr_enable <= '1';
									
								when others =>
										
						end case;				
				end if;
										
			when EX_STALL_SYNC_1 =>
				decode_en	<= '0';
				delay_dep  <= '1';
				
				if cache_stall = '0' then
					cache_data_enable <= '1';									
					cache_addr_enable <= '1';
				end if;
			
				
			when EX_STALL_SYNC_2 => 
				decode_en			<= '0';
				delay_dep 			<= '1';
				
				if cache_stall = '0' then
					cache_data_enable <= '1';		
				else
					--enable pipeline to execute at least on time de stalled instruction
					--if mem_stall = '1
					delay_dep <= '0';
				end if;
				
			
			when EXSTALL => 	
				decode_en					<= '0';
				reg_state_enable	<= '0';				
				dep_stall_reg_en		<= '0';
				dep_ex_stall_en		<= '0';
				reg_pc_enable 			<= '0';				
				
				if goto_in = '1' then 
					decode_en			<= '1';
					reg_state_enable	<= '1';
				end if;
					
				if mem_stall = '0' and dep_stall_reg = '0'  then
					decode_en				<= '1';
					reg_pc_enable 			<= '1';
					
					dep_ex_stall_en		<= '1';
				
								
					if goto_in = '1' or jump_reg_in = '1' or branch_in ='1'  then
						reg_pc_enable		 <= '0';
						cache_addr_enable	 <= '1';
						decode_en			<= '0';	
						b_address_reg_en  <= '1';
						
						delay_dep	<= '1';
																		
						if goto_in = '1' or branch_in = '1' then
							addr_mux_sel	<= "100";
						else					
							addr_mux_sel	<= "111";
						end if;
						
					end if;				
				end if;
				
					
				-- do not enable decoder if a branch instruction is stalled, if this happens
				-- branches to $lr could not work
				if goto_in = '1' and mem_stall = '1' then
					decode_en					<= '0';					
				end if;
									
				-- if all instrunction of this bundle have been execute, enable de cache_data, but decode is only enable when stall is off
				if  cache_stall = '0' and next_pc(2 downto 0) = "000" then					
						
					--only enable data cache if there is no depency stall followed by a ex_stall : 6 : ld 4, 20[sp] ; 7 add 8,4,5
					if dep_ex_stall = '0' and bundle_sel = '1'  then
						cache_data_enable <= '1';
					end if;
						
				end if;
				
				if pre_jr = '1' then
					decode_en				<= '0';
				end if;
				
														
				-- when cache stall is faster than bundle (bundle has lots of slow memory instructions)
				if cache_stall = '0' and bundle_sel = '1' then
					
					if mem_stall = '0' and dep_stall_reg = '0' and preld_reg = '0' then
					
						reg_state_enable <= '1';
												
						case b1_mask is					
								when "1111" =>
									if slots = "11" then
										cache_data_enable <= '1';								
										cache_addr_enable <= '1';													
									end if;						
								
								when "1110" => 
									if slots = "11" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
									
								when "1101" => 
									if slots = "11" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
									
								when "1100" => 							
									if slots = "11" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
								
								when "1011" =>
									if slots = "10" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;					
							
								when "1010" => 
									if slots = "10" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;										
								
								when "1001" =>
									if slots = "01" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
									
								when "1000" =>
									cache_data_enable <= '1';									
									cache_addr_enable <= '1';									
			
								when others =>
										
						end case;					
					end if;		
				end if;
				
				-- At stall, executing last instrution of the bundle
				if cache_stall = '0' and next_pc = internal_address and bundle_sel = '0' and mem_stall = '0'  then
					cache_data_enable <= '1';					
				end if;				
		
				if dep_stall_reg = '1' then
					delay_dep <= '1';
				end if;
				
				if cache_stall = '1' and next_pc_reg_int = cache_address_int and dep_stall_reg = '0' then
					decode_en			<= '0';
					delay_dep			<= '1';
					reg_pc_enable			<= '0';
				end if;
				
				
				-- this logic advaces cache address to next bundle when preload jumps to a MSB bundle but there is a memory stall 
				-- during PRELOAD state
				if preld_reg = '1' and preld_en_addr = '1' and mem_stall = '0' then
					preld_en_addr_en <= '1';
					
					if branch_bundle_sel = '1' then
						addr_mux_sel		<= "000";					
						cache_addr_enable <= '1';
					end if;					
				end if;
				
				
			when FLOW_EXSTALL =>
				decode_en					<= '0';				
				reg_state_enable	<= '0';
				reg_pc_enable			<= '0';
				
				--cache_data_reset	<= '1';
				
				--if cache_stall = '1' and mem_stall = '0' then
				if mem_stall = '0' then
					cache_addr_enable <= '1';												
					addr_mux_sel	<= "110";
				end if;
				
				-- do not reset decoder if a branch istructions is stalled, if this happens
				-- branches to $lr could not work
				if goto_in = '1' and mem_stall = '1' then
					decode_reset			<= '0';					
				end if;
				
				delay_dep <= '1';
				
--				if mem_stall = '0' then
--					b_address_reg_en <= '1';  -- corrupt address
--				end if;
				
				
			when DEPSTALL =>
				cache_data_enable <= '1';
				delay_dep <= '1';
				
			when STALL =>
			
				resync_en <= '1';
				branched_en 	<= '0';						
				reg_pc_enable <= '0';

				-- disable preld in stall state
				preld_reg_en	<= '1';
				
				if mem_stall = '0' then					
					reg_pc_enable				<= '0';
					cache_data_reset		<= '1';	
				else
					decode_en						<= '0';				
				end if;
			
				if goto_in = '1' and branched = '0' and mem_stall = '0' then				
					delay_dep	<= '1';
					
					b_address_reg_en <= '1'; 
					cache_addr_enable <= '1';					
					cache_data_reset	<= '1';
					addr_mux_sel			<= "100";					
					
					--works on jumping to cache addresses
					reg_pc_enable				<= '0';
					
					if bundle_sel = '1' then
						decode_reset				<= '1';
					end if;
				else
					-- only reset encoder and register when execution reaches next cache address
--					if internal_address = next_pc then						
					--if mem_stall = '0'  and dep_stall_reg = '0' and next_pc_reg_int = cache_address_int then						
					--if next_pc_reg_int = cache_address_int then				
					
					if dep_ex_stall = '0' then
						decode_reset				<= '1';				
					end if;						
				end if;	
				
				if jump_reg_in = '1'  then				
					delay_dep	<= '1';
					
					b_address_reg_en <= '1'; 
					cache_addr_enable <= '1';					
					
					cache_data_reset		<= '0';
					decode_reset				<= '0';						
					
					addr_mux_sel			<= "111";
									
					--works on jumping to cache addresses
					reg_pc_enable				<= '0';		
				
					delay_dep			<= '1';
		
				end if;	
				
				if branch_in = '1'  then				
					delay_dep	<= '1';
					
					b_address_reg_en <= '1'; 
					cache_addr_enable <= '1';					
					
					cache_data_reset		<= '1';
					decode_reset				<= '1';						
					
					addr_mux_sel			<= "100";
					cache_abort			<= '1';					
					
					--works on jumping to cache addresses
					reg_pc_enable				<= '0';		
				
					delay_dep			<= '1';
		
				end if;	
				
	
			when GOTOIN =>		
				branch_cou_en <= '1';
			
				goto_in_state <= '1';
				branched_en		<= '1';
			
				cache_data_reset <= '1';
				cache_abort			<= '1';					
				
				cache_addr_enable <= '1';					
				cache_data_enable <= '1';
				
				--reset fetch resync
				resync_en <= '1';
				
				-- load new address to ins buffer, ld and en must be 1
				decode_ld				<= '1';					
				decode_en				<= '1';
				decode_ld_sel		<= '1';
				-- disable pc register here, register in FLOW_STALL state
				reg_pc_enable			<= '0';
				
				delay_dep <= '1';
		
				-- controls address generation based on branch MSB bundle
				if branch_bundle_sel = '0'  then
					-- loads branch address					
					addr_mux_sel		<= "110";					
				else
					-- loads branch address + 8 
					addr_mux_sel		<= "001";	
				end if;
			
				-- disable new address generation if branch ocurs to same cache line and it is already in stall				
				if cache_stall = '1' and (branch_cache_line = current_cache_line) then
					cache_addr_enable <= '0';
				end if;

				if mem_stall = '1' then
					cache_addr_enable <= '0';
				end if;
				
			when JUMP_REGIN =>
			
				branch_cou_en <= '1';
			
				goto_in_state <= '1';
				branched_en		<= '1';
			
				cache_data_reset <= '1';
				cache_abort			<= '1';					
				
				cache_addr_enable <= '1';					
				cache_data_enable <= '1';
				
				decode_ld_sel		<= '1';
				-- disable pc register here, register in FLOW_STALL state
				reg_pc_enable			<= '0';
				
				delay_dep <= '1';
				
				--reset fetch resync
				resync_en <= '1';
		
				-- controls address generation based on branch MSB bundle
				if branch_bundle_sel = '0'  then
					-- loads branch address					
					--addr_mux_sel		<= "111";					
					addr_mux_sel		<= "110";
				else
					-- loads branch address + 8 
					addr_mux_sel		<= "001";	
				end if;
											
--				-- disable new address generation if branch ocurs to same cache line and it is already in stall				
				if cache_stall = '1' and (branch_cache_line = current_cache_line) then
					cache_addr_enable <= '0';
				end if;

				if mem_stall = '1' then
					cache_addr_enable <= '0';
					cache_data_enable <= '0';
					decode_ld				<= '0';					
					decode_en				<= '0';
				else
					-- load new address to ins buffer, ld and en must be 1
					decode_ld				<= '1';					
					decode_en				<= '1';
				end if;
			
			when BRANCHIN =>
				preld_reg_en	<= '1';
				branch_cou_en <= '1';
			
				delay_dep	<= '1';
			
				goto_in_state <= '1';
				branched_en		<= '1';
			
				cache_data_reset <= '1';
				cache_abort			<= '1';					
				
				cache_addr_enable <= '1';					
				cache_data_enable <= '1';
				
				--reset fetch resync
				resync_en <= '1';
				
							
				-- load new address to ins buffer, ld and en must be 1
				decode_ld				<= '1';					
				decode_en				<= '1';
				decode_ld_sel			<= '1';
				-- disable pc register here, register in FLOW_STALL state
				reg_pc_enable			<= '0';
						
				-- controls address generation based on branch MSB bundle
				if branch_bundle_sel = '0'  then
					-- loads branch address					
					addr_mux_sel		<= "110";					
				else
					-- loads branch address + 8 
					addr_mux_sel		<= "001";	
				end if;
			
				-- disable new address generation if branch ocurs to same cache line and it is already in stall				
				if cache_stall = '1' and (branch_cache_line = current_cache_line) then
					cache_addr_enable <= '0';
				end if;

				if mem_stall = '1' then
					cache_addr_enable <= '0';
				end if;
			
							
			when FLOW_STALL => 
				branched_en 		<= '0';			
				decode_en				<= '0';
									
				if cache_stall = '0'  then					
					cache_data_enable 					<= '1';
											
					-- new addres must be generated to B_1 logic works after a branch, if desativated, full parallel bundles dont work after branch
					-- when branching to a MSB bundle, new address are generated on GOTOIN state
					if branch_bundle_sel = '0'  and mem_stall = '0' then--  and branch_b0_mask = "1000" then
						addr_mux_sel			<= "000";
						cache_addr_enable <= '1';				
					end if;
					
					
					if branch_bundle_sel = '1'  and mem_stall = '0' then--  and branch_b0_mask = "1000" then
						addr_mux_sel			<= "001";
						cache_addr_enable <= '1';				
					end if;					
				
				-- GOTOIN has to enable cache_addres when branching to MSB bundle, it is necessary when there is no cache stall
				-- unfortunately GOTOIN does not know if branch address is a miss.
				-- if a miss occurs, FLOW_STALL have to correct the address				
				else
					if branch_bundle_sel = '1' then
						addr_mux_sel <= "110";
						cache_addr_enable <= '1';
					end if;				
					
				end if;
			
			when ENC_LOAD =>
		
				branched_en 		<= '0';			
				
				if cache_stall = '0' then					
					decode_en							<= '0';	
					cache_data_enable 		<= '1';		
					cache_addr_enable 		<= '1';	
					
					-- controls address generation based on branch MSB bundle
					if branch_bundle_sel = '0'  then
						-- loads branch address
						addr_mux_sel		<= "000";	
					else
						-- loads branch address + 8 
						addr_mux_sel		<= "001";	
					end if;
				
				-- GOTOIN has to enable cache_addres when branching to MSB bundle, it is necessary when there is no cache stall
				-- unfortunately GOTOIN does not know if branch address is a miss.
				-- if a miss occurs, FLOW_STALL have to correct the address				
				else
					if branch_bundle_sel = '1' then
						addr_mux_sel <= "110";
						cache_addr_enable <= '1';
					end if;						
				end if;
				
				
				if mem_stall = '1' then
					cache_addr_enable 		<= '0';	
					--cache_data_enable 		<= '0';	
				end if;
				
			when PRELD =>
				
				decode_en		<= '0';
				delay_dep		<= '1';
				reg_pc_enable	<= '0';
								
				cache_abort <= '1';
				
				if mem_stall = '1' then
					preld_en_addr_en <= '1';
				end if;
				
				if mem_stall = '0' then
					
					if dep_stall = '0' then				
						cache_data_enable <= '1';
											
						-- enable decoder ld address
						decode_en			<= '1';
						decode_ld			<= '1';			
						decode_ld_sel		<= '1';
						decode_preld_en 	<= '1';		
						
						-- execute branch and register pc
						delay_dep	<= '0';
						reg_pc_enable	<= '0';
						
						--fetch next cache address					
						if branch_bundle_sel = '0' then
							addr_mux_sel		<= "000";					
							cache_addr_enable <= '1';					
--						else
--							addr_mux_sel		<= "001";					
--							cache_addr_enable <= '1';					
						end if;
					else	
						if branch_bundle_sel = '1' then
							addr_mux_sel		<= "000";					
							cache_addr_enable <= '1';
						end if;					
					end if;
				end if;
				
			when BRANCH_PRED =>
				
				-- if predicted correct
				if branch_in = '1' then				
														
					preld_reg_en <= '1';
					delay_dep	<= '1';				
					
					-- include another stall cycle if next instruction is full 4 operation
					if b1_mask = "1000" then
						--decode_en <= '0';
						cache_data_enable <= '1';						
												
						if branch_bundle_sel = '1' then
							cache_addr_enable <= '1';							
						end if;
					end if;
										
					--addr_mux_sel		<= "000";
					--cache_addr_enable <= '1';					
					--cache_data_enable <= '1';					
				else
					-- initiate recover process					
					preld_miss_en <= '1';
					delay_dep	<= '1';
					decode_en	<= '0';
					reg_pc_enable	<= '0';
					
					addr_mux_sel		<= "101";
					cache_addr_enable <= '1';
		
					b_address_reg_en <= '1';
					recover_en		<= '1';		
				end if;
				
								
			when B_L =>
					reg_pc_enable			<= '1';
					
					--resync_en <= '1';
					
					if bundle_sel = '0' then 					
						cache_data_enable 	  	<= '0';
						reg_branch_bundle_sel_rst <= '1';
						
							--try to recover from d-sync -> edn example, lost sync after ex_stall
--							if slots = "00" and b1_mask = "000" and cache_addr_state_reg = EXSTALL then
--									delay_dep <= '1';
--									decode_en <= '0';
--										
--									cache_data_enable <= '1';
--							end if;
						
					else												
						cache_addr_enable <= '0';
	
						-- controls address generation
						if cache_stall = '0' then
							case b1_mask is					
								when "1111" =>
									if slots = "11" then
										cache_data_enable <= '1';								
										cache_addr_enable <= '1';													
									end if;						
								
								when "1110" => 
									if slots = "11" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
									
								when "1101" => 
									if slots = "11" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
									
								when "1100" => 							
									if slots = "11" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
								
								when "1011" =>
									if slots = "10" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;					
							
								when "1010" => 
									if slots = "10" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;										
								
								when "1001" =>
									if slots = "01" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
							
								when "1000" =>
									
									-- if cpu branches to a msb bundle, disable cache addr generation
									--if branch_bundle_sel_reg = '1' then										
--									if branch_bundle_sel = '1' then										
--										cache_addr_enable	<= '0';
--									else
--										cache_addr_enable <= '1';									
--									end if;
									
									cache_addr_enable <= '1';
									cache_data_enable <= '1';								
								when others =>							
							end case;
		
		
							--// added for ADPCM desync
							if cache_data_rdy = '1' and fetch_resync = '0' then
								cache_data_enable <= '0';
								cache_addr_enable <= '0';								
							end if;
							
		
						end if;						
					end if;										
					
				if goto_in = '1' or jump_reg_in = '1' or branch_in ='1'  then
					reg_pc_enable		 <= '0';
					cache_addr_enable	 <= '1';
					decode_en			<= '0';	
					b_address_reg_en  <= '1';
					
					delay_dep	<= '1';
																	
					if goto_in = '1' or branch_in = '1' then
						addr_mux_sel	<= "100";
					else					
						addr_mux_sel	<= "111";
					end if;
					
				end if;	
				
				if branch_in = '1' then
					preld_reg_en <= '1';
				end if;
				
	
				if f_error = '1' then
					decode_en				<= '0';	
				end if;
								
				--if cache_stall = '1' and next_pc_reg_int = cache_address_int and dep_stall_reg = '0' then
				--if cache_stall = '1' and next_pc_reg_int = cache_address_int and dep_stall_reg = '0' then
				if cache_stall = '1' and next_pc_reg_int = cache_address_int and dep_stall_reg = '0' then
					decode_en			<= '0';
					delay_dep			<= '1';
					reg_pc_enable			<= '0';
				end if;
				
				-- next state is stall: added for adpcm
				if fetch_resync = '1' and current_cache_line = exec_cache_line then
					decode_en			<= '0';
					delay_dep			<= '1';
					reg_pc_enable			<= '0';
					
					-- rember any dependecy stall fallowed by a ex_stall
					dep_ex_stall_en	<= '0';
				end if;
			
				if mem_stall = '1' then
					decode_en				<= '0';
					reg_pc_enable 		<= '0';
					
					cache_data_enable <= '0';				
					cache_addr_enable <= '0';
										
					-- rember any dependecy stall fallowed by a ex_stall
					dep_ex_stall_en	<= '0';
				
				end if;
			
				if dep_stall = '1' then
					decode_en				<= '0';
					cache_data_enable <= '0';
					cache_addr_enable <= '0';				
					reg_pc_enable <= '0';
					
					dep_ex_stall_en	<= '1';
				end if;
				
            -- safe but preloads sometimes doest not work
-- 				if preld_en = '1' and exec_cache_line = preld_set_cache_line then
-- 						addr_mux_sel <= "011";
-- 						cache_addr_enable <= '1';
-- 						cache_abort <= '1';
-- 						preld_reg_en <= '1';					
-- 						b_address_reg_en <= '1';				
-- 				end if;

           if preld_en = '1' then 					
					
					if cache_stall = '0' or (exec_cache_line = preld_set_cache_line) then
						  addr_mux_sel <= "011";
						  cache_addr_enable <= '1';
						  cache_abort <= '1';
						  preld_reg_en <= '1';					
						  b_address_reg_en <= '1';
					 end if;
					 		
 
					 if cache_stall = '1' and exec_cache_line /= preld_set_cache_line then
						  addr_mux_sel <= "000";
						  cache_addr_enable <= '0';
						  cache_abort <= '0';
						  preld_reg_en <= '0';					
						  b_address_reg_en <= '0';                                                                   
					 end if;						 
		
				end if;											
				
				if pre_jr = '1' then
					decode_en	<= '0';					
				end if;			
							
		end case;			
	end process;
	
	
	
	
	
	reg_branch_bundle_sel: process (clk, reset, branch_bundle_sel, reg_branch_bundle_sel_en, reg_branch_bundle_sel_rst)
	begin 
		if reset = '1' or reg_branch_bundle_sel_rst = '1' then
			branch_bundle_sel_reg <= '0';
		else
			if rising_edge(clk) and (reg_branch_bundle_sel_en = '1') then
					branch_bundle_sel_reg <= branch_bundle_sel;	
			end if;
		end if;
	end process;
	
	b1_mask	<= cache_data_reg(255) & cache_data_reg(223) & cache_data_reg(191) & cache_data_reg(159);
		
	bundle_out <= cache_data_reg;
			
	--data latch
	process(clk, cache_data_reset, reset, cache_data_enable, cache_data)
	begin
		if reset = '1' or cache_data_reset = '1' then 
			cache_data_reg <= (cache_data_reg'range => '0');
		else	
			if rising_edge(clk) and (cache_data_enable = '1') then
				cache_data_reg <= cache_data;
			end if;
		end if;
	end process;
	
			
	process(clk, reset, cache_addr_enable, next_pc, internal_address)
	begin
		if reset = '1' then			
			internal_address <= (internal_address'range => '0');		
		else
			if rising_edge(clk) and cache_addr_enable = '1' then
							
			case addr_mux_sel is
				when "000" =>
					internal_address <= internal_address(PC_SIZE-1 downto 3) & "000" + 8;
				when "001" =>
					internal_address <= b_address_reg_internal + 8;							
				when "010" =>
					internal_address <= next_pc + 12;				
				when "011" =>
					--internal_address <= internal_address(PC_SIZE-1 downto 3) & "000" + 8;					
					internal_address <= preload_addr;
				when "100" =>
					internal_address <= goto_addr;
					--internal_address <= b_address_reg_internal;
				when "101" =>
					--internal_address <= internal_address(PC_SIZE-1 downto 3) & "000" + 8;
					internal_address <= recover;
				when "110" =>
					internal_address <= b_address_reg_internal;				
					
				when "111" =>
					internal_address <= link_reg;
				
				when others =>
					internal_address <= next_pc + 4;
			end case;		

								
			end if;
		end if;
	end process;
	
	
	cache_address_int <= internal_address(PC_SIZE-1 downto 3) & "000";	
	cache_address 		<= internal_address(PC_SIZE-1 downto 3) & "000";
	
	
	process (clk, reset, internal_address)
	begin
		if reset = '1' then
			current_cache_line <= (others => '0');
			preld_set_cache_line <= (others => '0');
			exec_cache_line <= (others => '0');
		else
			if rising_edge(clk)  then
				current_cache_line <= internal_address(INDEX_END downto INDEX_INI);
				preld_set_cache_line  <= branch_inst_addr(INDEX_END downto INDEX_INI);
				exec_cache_line <= next_pc(INDEX_END downto INDEX_INI);
			end if;
		end if;
	end process;
	
	
	-- program counter register
	pc_register :process (clk, reset, next_pc, cache_stall, reg_pc_enable)
	begin
		if reset = '1' then 
			next_pc_reg_int <= (next_pc_reg_int'range => '0');
		else
			if rising_edge(clk) and reg_pc_enable = '1' then
				next_pc_reg_int <= next_pc;
			end if;
		end if;	
	end process;
	
	next_pc_reg	<= next_pc_reg_int;

	
	process (branch_cou_en, reset)
	begin
	
		if reset = '1' then
			control_flow_counter <= (control_flow_counter'range => '0');
		else
			if rising_edge(branch_cou_en)  then
					control_flow_counter <= control_flow_counter + 1;
			end if;
		end if;			
	end process;
	
end rtl;