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
	mem_stall    : in std_logic;
	dep_stall : in std_logic;
	branch_in		: in std_logic;	
	f_error				: in std_logic;
	next_pc			: in word_t;
	b_address		: in word_t;		
	cache_data	: in std_logic_vector(CACHE_LINE_SIZE-1 downto 0);	

	next_pc_reg		: out word_t;
	decode_ld			: out std_logic;
	decode_ld_sel	: out std_logic;
	decode_en			: out std_logic;
	decode_reset	: out std_logic;
	bundle_out 		: out std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
	b_address_reg	: out word_t;
	
	delay_dep			: out std_logic;
	
	cache_abort		: out std_logic;
	cache_address		: out word_t
	
	);
end cache_buffer;

architecture rtl of cache_buffer is
	signal cache_data_reg	:	std_logic_vector(CACHE_LINE_SIZE-1 downto 0);

	signal bundle_sel				: std_logic;
	signal branch_bundle_sel	: std_logic;
	
	type cache_addr_state_type is (IDLE, ENC_ERROR, HALTED, STALL, B_L, INIT, INIT_2, BRANCH_STALL,  BRANCHIN, ENC_LOAD, EXSTALL, DEPSTALL, BRANCH_EXSTALL);
	signal cache_addr_state : cache_addr_state_type;
	
	signal cache_addr_state_reg : cache_addr_state_type;
	
	signal cache_data_reset  	: std_logic;
	signal cache_data_enable : std_logic;
	signal cache_addr_enable : std_logic;	
	signal reg_pc_enable		 : std_logic;
	
	signal addr_mux_sel			: std_logic_vector(2 downto 0);
					
	signal internal_address		: word_t;
	signal next_pc_reg_int 		: word_t;
	
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
	
	-- depency stall fallowed by a EX_STALL
	signal dep_ex_stall 		: std_logic;
	signal dep_ex_stall_en : std_logic;
		
	--
	signal branched : std_logic;
	signal branched_en : std_logic;
	
	signal branch_in_state	: std_logic;
	
	signal b_address_reg_en	: std_logic;
	signal b_address_reg_internal : word_t;
	
	signal cache_address_int : word_t;

begin

	-- cache lines	
	branch_cache_line <= b_address(INDEX_END downto INDEX_INI);
	
	--selects the bundle
	bundle_sel <= next_pc(BK_OFFSET_END);
	
	branch_bundle_sel <= b_address_reg_internal(BK_OFFSET_END);
	slots <= next_pc(1 downto 0);
	
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
					branched <= branch_in_state;
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
	process (clk, reset, b_address, b_address_reg_en)
	begin
		if reset = '1' then 
			b_address_reg_internal <= (b_address_reg_internal'range => '0');
		else
			if rising_edge(clk) and b_address_reg_en = '1' then
				b_address_reg_internal	<=	b_address;
			end if;
		end if;
	end process;
	
	b_address_reg <= b_address_reg_internal;
		
	--fsm state progression
	do_clk_state: process (clk, branch_in, cache_stall, mem_stall, dep_stall, halt, reset, bundle_sel, b1_mask, cache_addr_state_reg, next_pc, f_error, branched)
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
							
					when EXSTALL => 
						if mem_stall = '0'  then								
								if cache_addr_state_reg = STALL and cache_stall = '0' then
									cache_addr_state <= INIT;	
								else														
									cache_addr_state <= B_L; --	cache_addr_state_reg
								end if;
						end if;
--						
						--if cache_stall = '1' and next_pc(2 downto 0) = "000" and mem_stall = '0' then 
											
						--if cache_stall = '1' and next_pc = cache_address_int and mem_stall = '0' then 
						if cache_stall = '1' and next_pc >= cache_address_int and mem_stall = '0' and dep_stall_reg = '0' then				
							cache_addr_state <= STALL;							
						end if;						
						
						if branch_in = '1' and branched = '0' then
							cache_addr_state <= BRANCH_EXSTALL;
						end if;
					
					when BRANCH_EXSTALL =>
							if mem_stall = '0'  then
									cache_addr_state <= BRANCHIN;
							end if;
					
					when DEPSTALL => 						
					
					when HALTED => 
					
					when ENC_ERROR => 
				
					when INIT =>					
						cache_addr_state <= INIT_2;							
						
					when INIT_2 => 
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
						if cache_stall = '1' then
							cache_addr_state <= STALL;
						else
							cache_addr_state <= INIT;
						end if;
						
						if mem_stall = '1' then
							cache_addr_state <=STALL;
						end if;
						
						if branch_in = '1' and branched = '0' then
							cache_addr_state <= BRANCHIN;
						end if;						
						
					when BRANCHIN =>
				
						cache_addr_state <= ENC_LOAD;		
		
						if cache_stall = '1' then
							cache_addr_state <= BRANCH_STALL;
						end if;
						
						if mem_stall = '1' then
							cache_addr_state <= BRANCHIN;
						end if;

					when BRANCH_STALL => 	
						
							if cache_stall = '1' then							
								cache_addr_state <= STALL;
							else
								cache_addr_state <= B_L;
							end if;
					
--						if halt = '1' then
--							cache_addr_state <= HALTED;
--						end if;	
					
					
					when B_L =>
								
						--if cache_stall = '1' and next_pc(2 downto 0) = "000"  and mem_stall = '0' then        --and buffer_full = '0' then
						
						--if cache_stall = '1' and next_pc = internal_address then 
						
							if f_error = '1' then
							cache_addr_state <= ENC_ERROR;							
						end if;								
						
						--if cache_stall = '1' and next_pc(2 downto 0) = "000" and dep_stall = '0' then
						if cache_stall = '1' and next_pc >= cache_address_int and dep_stall = '0' then						
							cache_addr_state <= STALL;							
						end if;
						
--						if cache_stall = '1' and  cache_address_int > next_pc and branch_bundle_sel = '1' and b1_mask  = "1000" then
--							cache_addr_state <= STALL;					
--						end if;
						
						if branch_in = '1' and branched = '0' then 
							cache_addr_state <= BRANCHIN;
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
	
	
	--fsm ouput progression
	do_state_output: process (cache_addr_state, cache_stall, next_pc, cache_data, 
										branch_in, bundle_sel, b1_mask, slots,  f_error, mem_stall, dep_stall,
										branch_bundle_sel, branch_bundle_sel_reg, dep_stall_reg,
										branch_cache_line, current_cache_line, dep_ex_stall, branched,
										next_pc_reg_int, cache_address_int)
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
		branch_in_state <= '0';
		
		branched_en <= '1';
		
		b_address_reg_en <= '0';
		
					
		case cache_addr_state is
			when IDLE =>					

			when HALTED =>
				decode_en				<= '0';
			
			when ENC_ERROR =>
				decode_en				<= '0';			
					
			when INIT =>
				reg_pc_enable				<= '0';
				decode_ld						<= '1';		
				cache_data_enable 	<= '1';		
				
				addr_mux_sel			<= "000";
				cache_addr_enable <= '1';
				
			when INIT_2 =>
				decode_en				<= '0';
				
			when EXSTALL => 	
				decode_en					<= '0';
				reg_state_enable	<= '0';				
				dep_stall_reg_en		<= '0';
				dep_ex_stall_en		<= '0';
				reg_pc_enable 			<= '0';				
				
				if branch_in = '1' then 
					decode_en					<= '1';
					reg_state_enable	<= '1';
				end if;
					
				if mem_stall = '0' and dep_stall_reg = '0'  then
					decode_en					<= '1';
					--reg_pc_enable 			<= '1';
					--cache_data_enable <= '1';
				end if;
				
				if mem_stall = '0' and dep_stall_reg = '0' then
					reg_pc_enable 			<= '1';
				end if;
				
				-- do not enable decoder if a branch instruction is stalled, if this happens
				-- branches to $lr could not work
				if branch_in = '1' and mem_stall = '1' then
					decode_en					<= '0';					
				end if;
									
				-- if all instrunction of this bundle have been execute, enable de cache_data, but decode is only enable when stall is off
				if  cache_stall = '0' and next_pc(2 downto 0) = "000" then					
						
					--only enable data cache if there is no depency stall followed by a ex_stall : 6 : ld 4, 20[sp] ; 7 add 8,4,5
					if dep_ex_stall = '0' and bundle_sel = '1'  then
						cache_data_enable <= '1';
					end if;
						
				end if;
										
				-- when cache stall is faster than bundle (bundle has lots of slow memory instructions)
				if cache_stall = '0' and bundle_sel = '1' then
					
					if mem_stall = '0' and dep_stall_reg = '0' then
					
						case b1_mask is					
								when "1111" =>
										if slots = "11" then
											cache_data_enable <= '1';
											cache_addr_enable <= '1';
										end if;
								
								when "1100" => 							
									if slots = "11" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;
								
								when "1010" =>
									if slots = "10" then
										cache_data_enable <= '1';
									end if;
									
								when "1011" =>
									if slots = "10" then
										cache_data_enable <= '1';
										cache_addr_enable <= '1';
									end if;		
								
								
								when "1001" =>
									if slots = "01" then
										cache_addr_enable <= '1';
										cache_data_enable <= '1';	
									end if;
									
								when "1000" =>
									cache_data_enable <= '1';									
									cache_addr_enable <= '1';
									
			
								when others =>
										
						end case;					
					end if;		
				end if;
				
				-- At stall, executing last instrution of the bundle
				if cache_stall = '0' and next_pc = internal_address and bundle_sel = '0'  then
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
				
			when BRANCH_EXSTALL =>
				decode_en					<= '0';
				decode_reset			<= '1';
				reg_state_enable	<= '0';
				reg_pc_enable			<= '0';
				
				--if cache_stall = '1' and mem_stall = '0' then
				if mem_stall = '0' then
					cache_addr_enable <= '1';												
					addr_mux_sel	<= "100";
				end if;
				
				-- do not reset decoder if a branch istructions is stalled, if this happens
				-- branches to $lr could not work
				if branch_in = '1' and mem_stall = '1' then
					decode_reset			<= '0';
				end if;
				
				if mem_stall = '0' then
					b_address_reg_en <= '1';
				end if;
				
				
			when DEPSTALL =>
				reg_state_enable <= '0';			
				
			when STALL =>
			
				branched_en 	<= '0';						
				reg_pc_enable <= '0';
				
				
				if mem_stall = '0' then					
					reg_pc_enable				<= '0';
					cache_data_reset		<= '1';	
				else
					decode_en						<= '0';				
				end if;
			
				if branch_in = '1' and branched = '0' then				
					
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
						decode_reset				<= '1';							
					--end if;						
				end if;	
				
			when BRANCHIN =>			

				branch_in_state <= '1';
				branched_en		<= '1';

			
				cache_data_reset <= '1';
				cache_abort			<= '1';					
				
				cache_addr_enable <= '1';					
				cache_data_enable <= '1';
				
				-- load new address to ins buffer, ld and en must be 1
				decode_ld				<= '1';					
				decode_en				<= '1';
				decode_ld_sel		<= '1';
				-- disable pc register here, register in BRANCH_STALL state
				reg_pc_enable			<= '0';
				
					
				-- controls address generation based on branch MSB bundle
				if branch_bundle_sel = '0'  then
					-- loads branch address					
					addr_mux_sel		<= "110";					
					--addr_mux_sel		<= "001";					
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
				 
								
			when BRANCH_STALL => 
				branched_en 		<= '0';			
				decode_en				<= '0';
									
				if cache_stall = '0'  then					
					cache_data_enable 					<= '1';
									
					-- new addres must be generated to B_1 logic works after a branch, if desativated, full parallel bundles dont work after branch
					-- when branching to a MSB bundle, new address are generated on BRANCHIN state
					if branch_bundle_sel = '0'  and mem_stall = '0' then--  and branch_b0_mask = "1000" then
						addr_mux_sel			<= "000";
						cache_addr_enable <= '1';				
					end if;
			
				
				-- BRANCHIN has to enable cache_addres when branching to MSB bundle, it is necessary when there is no cache stall
				-- unfortunately branchin does not know if branch address is a miss.
				-- if a miss occurs, BRANCH_STALL have to correct the address				
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
				
				-- BRANCHIN has to enable cache_addres when branching to MSB bundle, it is necessary when there is no cache stall
				-- unfortunately branchin does not know if branch address is a miss.
				-- if a miss occurs, BRANCH_STALL have to correct the address				
				else
					if branch_bundle_sel = '1' then
						addr_mux_sel <= "110";
						cache_addr_enable <= '1';
					end if;						
				end if;
				
				
				if mem_stall = '1' then
					cache_addr_enable 		<= '0';	
				end if;
								
			when B_L =>
					reg_pc_enable			<= '1';
					
					if bundle_sel = '0' then 					
						cache_data_enable 					<= '0';
						reg_branch_bundle_sel_rst <= '1';
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
									if branch_bundle_sel = '1' then										
										cache_addr_enable	<= '0';
									else
										cache_addr_enable <= '1';									
									end if;
									
									cache_data_enable <= '1';								
								when others =>							
							end case;					
						end if;						
					end if;										
					
				if branch_in = '1' then
					reg_pc_enable			<= '0';
					cache_addr_enable <= '1';
					decode_en					<= '0';	
					b_address_reg_en <= '1';
					
					-- do not execute next instrunction, compiler doest not support delay slot yet					
					if branched = '0' then
						decode_reset				<= '1';
					end if;
					
					-- do not reset decoder if a branch istructions is stalled, if this happens
					-- branches do $lr could not work
					if mem_stall = '1' then
						decode_reset				<= '0';
					end if;
														
					--cache_data_reset	<= '1';
					addr_mux_sel	<= "100";
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
					internal_address <= internal_address(WORD_SIZE-1 downto 3) & "000" + 8;
				when "001" =>
					internal_address <= b_address_reg_internal + 8;							
				when "010" =>
					internal_address <= next_pc + 12;				
				when "011" =>
					internal_address <= internal_address(WORD_SIZE-1 downto 3) & "000" + 8;					
				when "100" =>
					internal_address <= b_address;
				when "101" =>
					internal_address <= internal_address(WORD_SIZE-1 downto 3) & "000" + 8;
				when "110" =>
					internal_address <= b_address_reg_internal;
				
				when others =>
					internal_address <= next_pc + 4;
			end case;		

								
			end if;
		end if;
	end process;
	
	
	cache_address_int <= internal_address(WORD_SIZE-1 downto 3) & "000";	
	cache_address 		<= internal_address(WORD_SIZE-1 downto 3) & "000";
	
	
	process (clk, reset, internal_address)
	begin
		if reset = '1' then
			current_cache_line <= (others => '0');
		else
			if rising_edge(clk)  then
				current_cache_line <= internal_address(INDEX_END downto INDEX_INI);
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
	
end rtl;