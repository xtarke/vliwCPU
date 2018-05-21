--------------------------------------------------------------------------------
--  VLIW-RT CPU - Instruction cache entity
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
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;

entity cache is
port (
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
	--data_out  : out std_logic_vector (BUNDLE_SIZE-1 downto 0);
	stall_out : out std_logic;
	cache_data_rdy : out std_logic;
	
	data_out  : out std_logic_vector (CACHE_LINE_SIZE-1 downto 0)
	
	);
end cache;


architecture rtl of cache is	
	-- data mem definition: BLOCK_SIZE words per cache line
	type data_latches_type is array (0 to BLOCK_SIZE-1) of word_t;
	
	-- fsm definition
	type cache_state_type is (C_COMP_TAG, C_RD_BLOCK, C_MEM_END, C_MEM_WRITE);	
	type slow_mem_state_type is (IDLE, ACC_1, DONE);
	
	--internal signals
	signal tag 		 : std_logic_vector(TAG_SIZE-1 downto 0);	
	signal index    : std_logic_vector(INDEX_SIZE-1 downto 0);
	--signal b_offset : std_logic_vector(BK_OFFSET_SIZE-1 downto 0);

	signal index_reg : std_logic_vector(INDEX_SIZE-1 downto 0);
	signal tag_reg : std_logic_vector(TAG_SIZE-1 downto 0);	
	
	signal base_mem_addr   : std_logic_vector(RAM_ADDR_SIZE-1 downto 0);	
	signal base_mem_addr_reg   : std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	signal word_index : std_logic_vector(BK_OFFSET_SIZE-1 downto 0); 
	--	sc_signal<sc_uint<BK_OFFSET_SIZE + 1> > word_index;

	signal hit         : std_logic;
	signal cache_state : cache_state_type;
	signal slow_mem_state : slow_mem_state_type;
	
	--cache storage		
	signal sram_enable  	    : std_logic;	
	signal sram_data_out 	 : std_logic_vector (255 DOWNTO 0);	
	signal sram_tag_data_out : std_logic_vector (TAG_SIZE-1 DOWNTO 0);
	signal sram_tag_wen		 : std_logic;
	
	signal cache_line       : std_logic_vector(255 downto 0);	
	signal latch_index      : std_logic_vector (2 downto 0);
	signal cache_line_data  : data_latches_type;		
	
	signal line_en	: std_logic;
	
	signal v_bit_in  : std_logic;
	signal v_bit_out : std_logic;
	
	signal addr_add : std_logic;
	
	signal mem_start : std_logic;
	signal mem_busy : std_logic;
	
	signal aborted				 : std_logic;
	signal mem_addr_en : std_logic;

	signal st_mem_end : std_logic;
	
	--256 words SRAM to store data
	component sram
	--component sram_data
	port
	(
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (255 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (255 DOWNTO 0)
	);
	end component;
	
	
	--16 words SRAM to store tag
--	component sram_tag 
--	port
--	(		
--		clock		:	in STD_LOGIC;
--		data		:  in std_logic_vector (TAG_SIZE-1 DOWNTO 0);
--		address  :  in std_logic_vector (INDEX_SIZE-1 DOWNTO 0);
--		we		   :  in STD_LOGIC;
--		q			:  out  STD_LOGIC_VECTOR (TAG_SIZE-1 DOWNTO 0)
--	);
--	end component;
	
	component sram_tag_altera
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		--wraddress		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (14 DOWNTO 0)
	);
	END component;

	
	-- register to store v_bit
	component sram_v
   port
   (
      clock: 			 in   std_logic;
		reset:			 in 	std_logic;
		data:  			 in   std_logic;
      rdaddress:  		 in   std_logic_vector (INDEX_SIZE-1 DOWNTO 0);
		wraddress:  		 in   std_logic_vector (INDEX_SIZE-1 DOWNTO 0);
 		we:    			 in   std_logic;
      q: 			    out  std_logic
   );
	end component;	
		
begin	
	
	sram_data_1 : sram
	--sram_data_1 : sram_data	--coulnd't infer RAMBLOCK
		port map (
			clock => clk, 
			data => cache_line, 
			--rdaddress =>  index,		
			--wraddress => index_reg,
			address => index,
			wren => sram_enable, 
			q => sram_data_out
	);
			
	--sram_tag_data : sram_tag
	sram_tag_data : sram_tag_altera
		port map (
			clock => clk, 
			data => tag, 
			
			--address => index, 
			address => index ,
			--wraddress => index_reg,
			
			wren => sram_tag_wen, 
			q => sram_tag_data_out
		);	
	
	sram_vbit: sram_v
		port map (
			clock => clk, 
			reset => reset, 
			data => v_bit_in,
			rdaddress => index, 
			wraddress => index_reg,
			we => sram_tag_wen, 
			q => v_bit_out		
		);
	
	stall_out	<= not hit;	
	v_bit_in <= '1';
	
	do_cache_addr : process (reset, address)
	begin
		--if cache_state = C_COMP_TAG then
		if reset = '0' then
			tag      <= address(TAG_END downto TAG_INI);
			index    <= address(INDEX_END downto INDEX_INI);
			--b_offset <= address(BK_OFFSET_END downto BK_OFFSET_INI);
			
			--index * bloCK_SIZE	
			base_mem_addr <=  "000000000" & address(PC_SIZE-1 downto INDEX_INI) & "000";			
		else
			tag      <= (tag'range => '0');
			index    <= (index'range => '0');
			--b_offset <= (b_offset'range => 'Z');		
			base_mem_addr <= (base_mem_addr'range => '0');			
		end if;	
	end process;
	
	base_addr_reg : process (clk, reset, base_mem_addr, mem_addr_en, aborted)
	begin
		if reset = '1' then
			base_mem_addr_reg <= (others => '0');
		else
			--if rising_edge(clk) and aborted = '0' and mem_addr_en = '1' then
			if rising_edge(clk) and mem_addr_en = '1' then
				base_mem_addr_reg <= base_mem_addr;			
			end if;
		end if;
	end process;
	
	index_reg <= base_mem_addr_reg(INDEX_END downto INDEX_INI);
	tag_reg <= base_mem_addr_reg(TAG_END downto TAG_INI);
	
	process (clk, reset, abort)
	begin
		if reset = '1' then
			aborted <= '0';
		else
			if rising_edge(clk) then
				aborted <= abort;
			end if;		
		end if;	
	end process;
	
	
	do_clk_state: process (clk, reset, abort, mem_busy)
	begin
		if reset = '1' or abort = '1' then
			cache_state <= C_COMP_TAG;			
		else
			if rising_edge (clk) then
				case cache_state is
					when C_COMP_TAG =>
						if hit = '0' and aborted = '0' then
							cache_state <= C_RD_BLOCK;					
						end if;
								
					when C_RD_BLOCK =>	
						if mem_busy = '0' then
							cache_state <= C_MEM_END;
						end if;
					
					when C_MEM_END => 
						cache_state <= C_MEM_WRITE;
						
					when C_MEM_WRITE => 
						cache_state <= C_COMP_TAG;
						
				end case;		
			end if;		
		end if;	
	end process;
	
	ram_clk_en_out <= not hit;
	
	do_state_output: process (cache_state, sram_tag_data_out, v_bit_out, tag, tag_reg)
	begin
		--mem_enable_out <= '0';
		--hit <= '0';									-- let be a latch, if not, fmax has recovey problem
		sram_tag_wen <= '0';
		sram_enable	<= '0';
		mem_start			<= '0';
		mem_addr_en	<= '0';
		st_mem_end <= '0';
								
		case cache_state is
			when C_COMP_TAG =>	

				mem_addr_en <= '1';
				
				--if sram_tag_data_out = tag and v_bit_out = '1' then
				if sram_tag_data_out = tag_reg and v_bit_out = '1' then		
					hit <= '1';
					mem_start <= '0';					
				else
					hit <= '0';	
					mem_start <= '1';
				end if;
		
			when C_RD_BLOCK =>
				mem_start			<= '1';
			
			when C_MEM_END =>
				mem_start			<= '0';
				st_mem_end	<= '1';
				
			when C_MEM_WRITE =>				
				sram_enable	<= '1';
				sram_tag_wen <= '1';
				st_mem_end <= '1';
				
				hit <= '1';			
				
			end case;
	end process;
	
	
	do_clk_mem_acc_state: process (mem_clk, reset, abort, slow_mem_state)
	begin
		if reset = '1' or abort = '1' then
			slow_mem_state <= IDLE;			
		else
			if rising_edge (mem_clk) then
				case slow_mem_state is
					when IDLE =>
					
						if mem_start = '1' then
							slow_mem_state <= ACC_1;	
						end if;					
					
					when ACC_1 =>
						if latch_index = BLOCK_SIZE-1 then
							slow_mem_state <= DONE;						
						end if;				
						
					when DONE => 
						slow_mem_state <= IDLE;
				
				end case;		
			end if;		
		end if;	
	end process;
	
	
	process (clk, reset)
	begin
		if reset = '1' or abort = '1' then
			cache_data_rdy <= '0';
		else
			if rising_edge(clk) then
				cache_data_rdy <= st_mem_end;		
			end if;		
		end if;
	end process;
	
	do_clk_mem_acc_state_output: process (slow_mem_state, mem_start, latch_index)
	begin				
		--rom_addr	<= (rom_addr'range => '0');
		mem_busy <= '0';
		addr_add   <= '0';
		mem_enable_out <= '0';
		line_en <= '0';
		
		case slow_mem_state is
						
			when IDLE =>
			
				if mem_start = '1' then
					mem_busy <= '1';	
				end if;		
													
			when ACC_1 =>
				line_en		<= '1';
				addr_add   <= '1';
				mem_busy	<= '1';
				mem_enable_out <= '1';
				
				if latch_index = BLOCK_SIZE-1 then
					addr_add   <= '0';	
				end if;
				
			when DONE => 
				line_en		<= '1';
				--rom_addr <= addr_reg(INS_ADDR_SIZE+1 downto 2);
				mem_busy	<= '0';			
			end case;
	end process;
	
	
	
	do_mem_address_ouput: process (mem_clk, reset, abort, word_index, slow_mem_state, addr_add)
	begin
		if reset = '1' or abort = '1' then
			word_index <= (word_index'range => '0');			
		else		
			if rising_edge (mem_clk)  and addr_add = '1' then						
					word_index <= word_index + 1;		
				
			end if;		
		end if;
	end process;
	
	process (word_index, base_mem_addr_reg)
	begin
		mem_addr_out <= (base_mem_addr_reg + word_index);
	end process;
	

	--concatenate all words
	do_make_cache_line: process (cache_state, cache_line_data)
	begin
		if cache_state = C_MEM_WRITE then
			cache_line <= cache_line_data(7) & cache_line_data(6) &
									cache_line_data(5) & cache_line_data(4) &
									cache_line_data(3) & cache_line_data(2) &
									cache_line_data(1) & cache_line_data(0);
		else
			cache_line <= (cache_line'range => '0');	
		end if;
	end process;	
	
	do_cache_line_counter: process (mem_clk, reset, abort, line_en, latch_index, mem_data_in, word_index)
	begin
		if reset = '1' or abort = '1' then
			latch_index	<= (latch_index'range => '0');
		else
			if rising_edge (mem_clk) and line_en = '1' then			
				latch_index	<= word_index(2 downto 0);

				cache_line_data(conv_integer(latch_index)) <= mem_data_in;	
			end if;
		end if;		
	end process;

	
	data_out <= sram_data_out;
	

end rtl;

