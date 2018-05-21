-- Insert library and use clauses
library STD;
use STD.textio.all;
LIBRARY ieee;
use IEEE.std_logic_textio.all;  
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;
use work.cpu_typedef_package.all;

ENTITY tb IS

END ENTITY tb;

ARCHITECTURE stimulus OF tb IS

	-- Component declaration for the DUT
	component rom
		port (
			clk     : in std_logic;
			enable  : in std_logic;
	
			rd     : in std_logic;
			-- address
			rd_addr : std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
			-- data	
			data_out : out  word_t
		);
	end component rom;


	COMPONENT cache		
		port(	
			
		clk     : in std_logic;
		mem_clk : in std_logic;
		reset   : in std_logic;
		data_out_enable : in std_logic;	
		address         : in word_t;
		
		--RAM memory read control
		mem_data_in    : in word_t;
		mem_addr_out   : out std_logic_vector (RAM_ADDR_SIZE-1 downto 0);
		mem_enable_out : out std_logic; 	
		ram_clk_en_out : out std_logic;

		--cache data out
		data_out  : out std_logic_vector (BUNDLE_SIZE-1 downto 0);
		stall_out : out std_logic;

		data_out_l  : out std_logic_vector (CACHE_LINE_SIZE-1 downto 0)
		);	
	END COMPONENT cache;
	
	component fetch
		port(
			clk      		: in std_logic;	
			reset    		: in std_logic;
			cache_busy 		: in std_logic;
			
			branch_in		: in std_logic;
			b_address		: in word_t;
			
			bunble_in  		: in  std_logic_vector(BUNDLE_SIZE-1 downto 0);
			cache_line_in  : in  std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
			
			bundle_error	: out std_logic;
			next_pc_out		: out word_t;		
			
			slot_0 			: out word_t;
			slot_1 			: out word_t;
			slot_2 			: out word_t;
			slot_3 			: out word_t
		);
	end component;
	
	component controller	
		port (
			clk      		: in std_logic;	
			reset    		: in std_logic;
		
			slot_0 			: in word_t;
	
			branch_enable  : out std_logic;
			address_out		: out word_t
		
			);
	end component;		

	signal clk     :  std_logic;
	signal mem_clk :  std_logic;
	signal reset   :  std_logic;
	signal data_out_enable : std_logic;	
	signal address         : word_t;
	
	--RAM memory read control
	signal mem_data_in    : word_t;
	signal mem_addr_out   : std_logic_vector (RAM_ADDR_SIZE-1 downto 0);
	signal mem_enable_out : std_logic; 	
	signal ram_clk_en_out : std_logic;

	--cache data out
	signal cache_data_out  : std_logic_vector (BUNDLE_SIZE-1 downto 0);
	signal stall 			  : std_logic;

	signal rom_enable : std_logic;
	signal rom_rd : std_logic;
	
	signal f_error : std_logic;
	
	signal slot_0 : word_t;
	signal slot_1 : word_t;
	signal slot_2 : word_t;
	signal slot_3 : word_t; 
	
	signal jump_address : word_t;
	signal branch_enable : std_logic;
	
	
	signal cache_line : std_logic_vector(CACHE_LINE_SIZE-1 downto 0);
		
BEGIN  -- beginning of architecture body

	rom_1: rom
		port map (
			clk => mem_clk, enable => mem_enable_out, rd => mem_enable_out, rd_addr => mem_addr_out, 
			data_out => mem_data_in 		
		);

	cache_1 : cache
		PORT MAP (
			clk => clk, mem_clk => mem_clk, reset => reset, data_out_enable => data_out_enable, 
			address => address, mem_data_in => mem_data_in, mem_addr_out => mem_addr_out,
			mem_enable_out => mem_enable_out,  ram_clk_en_out => ram_clk_en_out, data_out => cache_data_out,			
			stall_out => stall, data_out_l => cache_line
		);
		
	fetch_1: fetch
		port map ( 
			clk => clk, 
			reset => reset, 
			cache_busy => stall,
			branch_in => branch_enable,
			b_address => jump_address,
			bunble_in => cache_data_out, 			
			cache_line_in => cache_line,
			bundle_error => f_error,
			next_pc_out => address,
			slot_0 => slot_0,
			slot_1 => slot_1,
			slot_2 => slot_2,
			slot_3 => slot_3		
		);
		
	controller_1: controller
		port map ( 
			clk => clk,
			reset => reset,			
			slot_0  => slot_0,
			branch_enable => branch_enable,
			address_out => jump_address
		);
			
	-- Process to create clock signal
	clk_proc : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 10 NS;
		clk <= '1';
		WAIT FOR 10 NS;
	END PROCESS clk_proc;

	reset_p : process
	begin
		reset <= '1';
		rom_enable <= '0';
		rom_rd <= '0';
		
		
		WAIT FOR 5 NS;
		rom_enable <= '1';
		rom_rd <= '1';
		reset <= '0';
		
		wait;	
	end process;
	
	clock_gen : process (clk, ram_clk_en_out)
	variable counter : natural := 0;
	begin
		if ram_clk_en_out = '0' then
			mem_clk <= '0';
		else
			if rising_edge (clk) then
				counter := counter +1;
			end if;
			
			if counter >  1 then
				counter := 0;
				
				if mem_clk = '0' then
					mem_clk <= '1';
				else
					mem_clk <= '0';
				end if;
			end if;
			
		end if;
	
	
	end process;
	
	
	print: process (cache_data_out)
		variable my_line : line; 
		alias swrite is write [line, string, side, width];
	begin
		 swrite(my_line, "cache_data_out=");	
		 hwrite(my_line, cache_data_out);		-- needs use IEEE.std_logic_textio.all;
		writeline(output, my_line);				-- needs use STD.textio.all;
	end process;

	
	
	
	

			
END ARCHITECTURE stimulus;