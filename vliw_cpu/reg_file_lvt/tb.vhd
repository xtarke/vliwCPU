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
	end component reg_file_lvt;
		
	signal clk : std_logic;

	signal reset : std_logic;
	
	
	signal pc		: word_t;

	
	signal pll_locked : std_logic;
	
	-- register file data
	signal port0_a_rd : 	word_t;
	signal port0_b_rd : 	word_t;
	signal port1_a_rd	: 	word_t;
	signal port1_b_rd : 	word_t; 
	signal port2_a_rd : 	word_t; 
	signal port2_b_rd : 	word_t; 
	signal port3_a_rd : 	word_t; 
	signal port3_b_rd : 	word_t;
	
	signal port0_w_addr	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port1_w_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port2_w_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port3_w_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal port0_a_rd_addr	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port0_b_rd_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port1_a_rd_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port1_b_rd_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port2_a_rd_addr	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port2_b_rd_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port3_a_rd_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	signal port3_b_rd_addr 	 : std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	
	signal port0_w_en 		 : std_logic;
	signal port1_w_en 		 : std_logic;
	signal port2_w_en 		 : std_logic; 
	signal port3_w_en 		 : std_logic;
	
	signal port0_w_data 		: word_t;
	signal port1_w_data 		: word_t;
	signal port2_w_data 		: word_t;
	signal port3_w_data 		: word_t;	
			
			
	signal porta_a 		: std_logic_vector(REG_ADDR_SIZE-1 downto 0);
			
	signal reset_2	: std_logic;		
			
BEGIN  -- beginning of architecture body


	reg_file_1: reg_file_lvt
	port map (
		clk     => clk,
		reset	  => reset,		
		port0_w_addr	 => port0_w_addr,
		port1_w_addr 	 => port1_w_addr,
		port2_w_addr 	 => port2_w_addr,
		port3_w_addr 	 => port3_w_addr,
		
		port0_w_data 	=> port0_w_data,
		port1_w_data 	=>	port1_w_data,
		port2_w_data 	=>	port2_w_data,
		port3_w_data 	=>	port3_w_data,
	
		port0_w_en 		 => port0_w_en,
		port1_w_en 		 => port1_w_en,
		port2_w_en 		 => port2_w_en, 
		port3_w_en 		 => port3_w_en,
		
		port0_a_rd_addr 	 => port0_a_rd_addr,
		port0_b_rd_addr 	 => port0_b_rd_addr,
		port1_a_rd_addr 	 => port1_a_rd_addr,
		port1_b_rd_addr 	 => port1_b_rd_addr,
		port2_a_rd_addr 	 => port2_a_rd_addr,
		port2_b_rd_addr 	 => port2_b_rd_addr,
		port3_a_rd_addr 	 => port3_a_rd_addr,
		port3_b_rd_addr 	 => port3_b_rd_addr,
		
		port0_a_rd 			 => port0_a_rd,
		port0_b_rd 			 => port0_b_rd,
		port1_a_rd			 => port1_a_rd,
		port1_b_rd 			 => port1_b_rd,
		port2_a_rd 			 => port2_a_rd,
		port2_b_rd 			 => port2_b_rd,
		port3_a_rd 			 => port3_a_rd,
		port3_b_rd 			 => port3_b_rd	
	);
	
		
	-- Process to create clock signal -- 50Mhz
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
				
		WAIT FOR 5 NS;
		reset <= '0';
		
	
		wait;
	end process;
	
	
	process
	begin		

	
		
		reset_2 <= '1';
	
	
		WAIT FOR 35 NS; 
		
		reset_2 <= '0';
	
		
	
		wait;
	end process;	
	
	
	process (clk, reset_2)
	begin
		if reset_2 = '1' then
			port0_a_rd_addr <= (port0_a_rd_addr'range => '0');
			port0_b_rd_addr <= (port0_a_rd_addr'range => '0');
		else
			if rising_edge(clk) then
				port0_b_rd_addr	<= port0_b_rd_addr + 2;
				port0_a_rd_addr	<= port0_a_rd_addr + 1;
			end if;
		end if;
		
	
	end process;
	
	process (clk, reset_2)
	begin
		if reset_2 = '1' then
			port0_a_rd_addr <= (port0_a_rd_addr'range => '0');
			port0_b_rd_addr <= (port0_a_rd_addr'range => '0');
		else
			if rising_edge(clk) then
				port0_b_rd_addr	<= port0_b_rd_addr + 2;
				port0_a_rd_addr	<= port0_a_rd_addr + 1;
			end if;
		end if;
		
	
	end process;
	
	
	
	process
	begin
		port0_w_en	<= '0';
			
		WAIT FOR 10 NS;

		wait for 21 NS;
		
		
		port0_w_en		<= '1';		
		port0_w_addr	<= "000010";
		port0_w_data	<= x"00000002";	
		
		wait for 20 NS;
		port0_w_en		<= '0';		
	
	
		wait;
	end process;
	
	process
	begin
		port1_w_en	<= '0';
			
		WAIT FOR 10 NS;
	
					
		
		wait for 41 NS;	
		
		port1_w_en		<= '1';		
		port1_w_addr	<= "000001";
		port1_w_data	<= x"00000001";	
		
		wait for 20 NS;
		port1_w_en		<= '0';		
		
	
		wait;
	end process;
	

			
END ARCHITECTURE stimulus;