library IEEE;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;

entity cache_buffer is
port (
	clk      			: in std_logic;	
	reset    			: in std_logic;
	cache_stall			: in std_logic;
	branch_in			: in std_logic;		
	address				: in word_t;		
	cache_data			: in std_logic_vector(CACHE_LINE_SIZE-1 downto 0);	

	decode_en			: out std_logic;
	decode_reset		: out std_logic;
	bundle_out 			: out std_logic_vector(BUNDLE_SIZE-1 downto 0);		
	cache_address		: out word_t
	
	);
end cache_buffer;

architecture rtl of cache_buffer is
	signal latched_data	:	std_logic_vector(CACHE_LINE_SIZE-1 downto 0);

	signal bundle_sel	: std_logic;	
	
	type cache_addr_state_type is (IDLE, STALL, B_0, B_1, B_1_BR, B_0_BR, BRANCHIN);
	signal cache_addr_state : cache_addr_state_type;
			
	signal latch_data_enable : std_logic;
	signal latch_addr_enable : std_logic;	
	
	signal addr_mux_sel			: std_logic_vector(1 downto 0);
	signal addr_mux_out			: word_t;
	
	signal fast_br					: std_logic;
	
	signal addr_l_enable			: std_logic;
	
	signal internal_address		: word_t;
	
begin

	--selects the bundle
	bundle_sel <= address(BK_OFFSET_END);
		
	--fsm state progression
	do_clk_state: process (clk, branch_in, cache_stall, reset, bundle_sel)
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
						
					when B_0 => 						
						
						if bundle_sel = '1' then
							cache_addr_state <= B_1;
						else
							cache_addr_state <= B_0;
						end if;
						
						if branch_in = '1' then 
							cache_addr_state <= BRANCHIN;
						end if;


					when STALL => 
						if cache_stall = '1' then
							cache_addr_state <= STALL;
						else
							cache_addr_state <= B_0;
						end if;
						
						if branch_in = '1' then
							cache_addr_state <= BRANCHIN;
						end if;
						
						
					when BRANCHIN =>			
						if bundle_sel = '0' then
							cache_addr_state <= B_0_BR;				
						end if;
						
						if bundle_sel = '1' then
							cache_addr_state <= B_1_BR;
						end if;
						
						if cache_stall = '1' then
							cache_addr_state <= STALL;
						end if;
					
					when B_1 =>								
						if bundle_sel = '0' then
							cache_addr_state <= B_0_BR;
						else
							cache_addr_state <= B_1;
						end if;
						
						if cache_stall = '1' and bundle_sel = '0' then
							cache_addr_state <= STALL;
						end if;
						
						if branch_in = '1' then 
							cache_addr_state <= BRANCHIN;
						end if;
						
					when B_1_BR => 
						if bundle_sel = '1' then
							cache_addr_state <= B_1_BR;
						else
							cache_addr_state <= B_0_BR;
						end if;
						
					when B_0_BR => 
						if bundle_sel = '1' then
							cache_addr_state <= B_1;
						else
							cache_addr_state <= B_0_BR;
						end if;
						
						if branch_in = '1' then 
							cache_addr_state <= BRANCHIN;
						end if;
									
				end case;		
			end if;		
		end if;	
	end process;
	
	
	--fsm ouput progression
	do_state_output: process (cache_addr_state, cache_stall, address, cache_data, branch_in, bundle_sel)
	begin
		
		decode_en			<= '1';
		latch_data_enable <= '0';
		latch_addr_enable <= '0';
		addr_mux_sel		<= "00";
		fast_br				<= '0';
		decode_reset		<= '0';
	
		addr_l_enable		<= '0';
	
		case cache_addr_state is
			when IDLE =>				
										
					latch_data_enable <= '1';
					latch_addr_enable	<= '1';
					addr_l_enable		<= '1';
				
			when STALL =>				
				latch_data_enable <= '1';
				decode_en			<= '0';
				decode_reset		<= '1';
			when B_0 => 				
				
				if bundle_sel = '1' then					
					addr_mux_sel <= "01";
					latch_addr_enable <= '1';					
					addr_l_enable <= '1';
				
				end if;

				if branch_in = '1' then 
					addr_mux_sel	<= "00";
					latch_addr_enable <= '1';
				end if;			 
				
			when BRANCHIN =>
				latch_data_enable <= '1';
				
				if cache_stall = '0' then
					if bundle_sel = '1' then					
						fast_br <= '1';
						addr_l_enable <= '1';					
					else 
						addr_mux_sel	<= "10";
						latch_addr_enable <= '1';
					end if;
				end if;				
					
			when B_1 =>				
				
				if bundle_sel = '0' and cache_stall = '0'then
					addr_mux_sel <= "10";
					latch_addr_enable <= '1';			
					addr_l_enable		<= '1';
					latch_data_enable <= '1';
				end if;

				if bundle_sel = '0' and cache_stall = '1' then
					decode_en			<= '0';				
				end if;
				
				
				if branch_in = '1' then 
					addr_mux_sel	<= "00";
					latch_addr_enable <= '1';
				end if;
			
			when B_1_BR => 			
			
				if bundle_sel = '0' then
					latch_data_enable <= '1';					
					addr_mux_sel <= "10";					
					latch_addr_enable <= '1';				
					addr_l_enable <= '1';					
				end if;	


			when B_0_BR =>
				addr_l_enable <= '1';

			end case;
	end process;

	do_write: process (bundle_sel, latched_data)
	begin
			if bundle_sel = '0' then
				bundle_out <= latched_data(BUNDLE_SIZE-1 downto 0);
			else
				bundle_out <= latched_data(2*BUNDLE_SIZE-1 downto BUNDLE_SIZE);				
			end if;		
	end process;
	
	
	--data latch
	process(latch_data_enable, cache_data, bundle_sel)
	begin
		if (latch_data_enable = '1') then
			latched_data <= cache_data;			
		end if;
	end process;
	
	
	process(clk, reset, branch_in, fast_br, addr_mux_out, latch_addr_enable, address)
	begin
		if reset = '1' or branch_in = '1' or fast_br = '1' then			
			if reset = '1' then				
				internal_address <= (internal_address'range => '0');
			else			
				-- for fast branches, if this selector is removed, 1 cycle branch penalty is added	
				if fast_br = '1' then
					internal_address <= address + 4;
				else
					internal_address <= address;
				end if;
					
			end if;
		else
			if rising_edge(clk) and latch_addr_enable = '1' then
				internal_address <= addr_mux_out;				
			end if;
		end if;
	end process;
	
	process(addr_mux_sel, address)
	begin
		case addr_mux_sel is
			when "00" =>
				addr_mux_out <= address;
			when "01" =>
				addr_mux_out <= address + 4;
			when "10" =>
				addr_mux_out <= address + 8;
			when others =>
				addr_mux_out <= address; 
			end case;		
	end process;
	
	--addr latch
	process(internal_address, addr_l_enable, branch_in)
	begin
		if (addr_l_enable = '1' or branch_in = '1') then
			cache_address <= internal_address;			
		end if;
	end process;	
end rtl;