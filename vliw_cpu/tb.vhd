-- Insert library and use clauses
library STD;
use STD.textio.all;
LIBRARY ieee;
use IEEE.std_logic_textio.all;  
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;
use work.cpu_typedef_package.all;
use work.cpu_sim_package.all;
use work.txt_util.all;

ENTITY tb IS

END ENTITY tb;

ARCHITECTURE stimulus OF tb IS
	
component rom_altera
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q_a		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;


	component code_ram
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			rden		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;
	
	component sram_sim
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			byteena		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '1');
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			rden		: IN STD_LOGIC  := '1';
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;
	
	component rom_memory 
	port (
	  -- inputs:
	  address 		: IN STD_LOGIC_VECTOR (DATA_ADDR_SIZE-1 DOWNTO 0);
	  read				: in std_logic;
	  byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	  chipselect 	: IN STD_LOGIC;
	  clk 					: IN STD_LOGIC;
	  clken 				: IN STD_LOGIC;
	  reset 				: IN STD_LOGIC;
	  reset_req 	: IN STD_LOGIC;
	  
	
	  -- outputs:
	  readdata 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	  waitrequest : out std_logic
	);
	end component;
	
	component sram_controller
	port (
		  -- inputs:
		  address 		: IN STD_LOGIC_VECTOR (DATA_ADDR_SIZE-1 DOWNTO 0);
		  byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		  chipselect 	: IN STD_LOGIC;
		  clk 					: IN STD_LOGIC;
		  clken 				: IN STD_LOGIC;
		  reset 				: IN STD_LOGIC;
		  reset_req 	: IN STD_LOGIC;
		  read				: in std_logic;
		  write 				: IN STD_LOGIC;
		  writedata 		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		  waitrequest : out std_logic;
		
		  -- outputs:
		  readdata 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			  
		 ADSC_N :  out std_logic;
		 ADSP_N :  out std_logic;
		 ADV_N :  out std_logic;
		 BE :  out std_logic_vector( 3  downto 0  );
		
		GW_N :  out std_logic;
		OE_N :  out std_logic;
		WE_N :  out std_logic;
		CE_0_N :  out std_logic;
		CE_1_N :  out std_logic;
		FS_ADDR :  out std_logic_vector( 19  downto 0  );
		FS_DQ :  inout std_logic_vector( 31  downto 0  )
	);
	end component sram_controller;
	
	component sdram_controller
	port (
	  -- inputs:
	  address 		: IN STD_LOGIC_VECTOR (DATA_ADDR_SIZE-1 DOWNTO 0);
	  byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	  chipselect 	: IN STD_LOGIC;
	  clk 					: IN STD_LOGIC;
	  clken 				: IN STD_LOGIC;
	  reset 				: IN STD_LOGIC;
	  reset_req 	: IN STD_LOGIC;
	  write 				: IN STD_LOGIC;
	  read				: in std_logic;
	  writedata 		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	  -- outputs:
	  readdata 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	  waitrequest : out std_logic;
	  
	 DRAM_ADDR :  out std_logic_vector( 12  downto 0  );
    DRAM_BA :  out std_logic_vector( 1  downto 0  );
    DRAM_CAS_N :  out std_logic;
    DRAM_CKE :  out std_logic;
    DRAM_CLK :  out std_logic;
    DRAM_CS_N :  out std_logic;
    DRAM_DQ :  inout std_logic_vector( 31  downto 0  );
    DRAM_DQM :  out std_logic_vector( 3  downto 0  );
    DRAM_RAS_N :  out std_logic;
    DRAM_WE_N :  out std_logic
	);
	end component sdram_controller;
		
	component mt48lc8m16a2
   PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => 'Z');
        Addr  : IN    STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0');
        Ba    : IN    STD_LOGIC_VECTOR := "00";
        Clk   : IN    STD_LOGIC := '0';
        Cke   : IN    STD_LOGIC := '0';
        Cs_n  : IN    STD_LOGIC := '1';
        Ras_n : IN    STD_LOGIC := '0';
        Cas_n : IN    STD_LOGIC := '0';
        We_n  : IN    STD_LOGIC := '0';
        Dqm   : IN    STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0')
    );
	END component;
	
	component tristate
	PORT (
		mybidir 		: INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		myinput 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		myenable 	: IN STD_LOGIC
	);
	end component tristate;
	
	component vliwcpu 
		port (
			clk     		 : in std_logic;	
			clk_mem  : in std_logic;
			reset  	 	 : in std_logic;
		
			i_address                  : out std_logic_vector(INS_ADDR_SIZE-1 downto 0);       -- address
			i_read                       : out std_logic;                                    											 -- read
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
			stall_out				: out std_logic	:= '0'
		);
	end component vliwcpu;
	
	component vga_controller
	port (
		pixel_clk	:	IN		STD_LOGIC;	--pixel clock at frequency of VGA mode being used
		reset_n		:	IN		STD_LOGIC;	--active low asycnchronous reset
		h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
		disp_ena	:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		refresh 		: out std_logic;
		column		:	OUT	INTEGER;		--horizontal pixel coordinate
		row				:	OUT	INTEGER;		--vertical pixel coordinate
		n_blank		:	OUT	STD_LOGIC;	--direct blacking output to DAC
		n_sync		:	OUT	STD_LOGIC); --sync-on-green output to DAC
	end component;

	component hw_image_generator
	port(
		clk_vga 				: in 	std_logic;
		clk_cpu				: in 	std_logic;
		reset			: in std_logic;
		disp_ena	:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row				:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		vga_reset_n	: out std_logic;
		refresh 		: in std_logic;
		
		char_write_addr	: in std_logic_vector(11 downto 0);
      char_we					 	: in std_logic;
      char_write_value : in std_logic_vector(7 downto 0);
		
		red				:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue				:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
	end component;
		
	signal   clk            : std_logic := '0';
	signal   clk2           : std_logic := '0';
	
	signal cpu_clk : std_logic := '0';
	signal reset : std_logic;
	signal mem_clk : std_logic := '0';
	
	signal ram_clk_en_out : std_logic;	
	
	signal pll_locked : std_logic;

	signal f_error		: std_logic;
	
	signal print	 : std_logic;
	signal print_0 : std_logic;
	signal print_1 : std_logic;
	signal print_2 : std_logic;
	signal print_3 : std_logic;
	
	signal sram_data	: word_t;
	
	signal sram_data_rd 	: word_t;
	signal sram_data_wr 	: word_t;
	signal sram_w					: std_logic;
	signal sram_r					: std_logic;
	signal sram_addr 			: std_logic_vector(SSRAM_ADDR_SIZE-1 downto 0);
	
	signal rom_addr	: std_logic_vector(INS_ADDR_SIZE-1 downto 0);
		
	signal halt				: std_logic;
	
	signal reset_n  : std_logic;
	
		-- Qsys	
	signal i_address            : std_logic_vector(INS_ADDR_SIZE-1 downto 0);
	signal i_read                 : std_logic;                                    								
	signal i_readdata          : std_logic_vector(31 downto 0);
	signal i_waitrequest      : std_logic;
	signal i_readdatavalid   : std_logic;
	signal i_chipselect		    : std_logic;

	signal d_address                :  std_logic_vector(DATA_ADDR_SIZE-1  downto 0);                    -- address
	signal d_byteenable           :  std_logic_vector(3 downto 0);                    -- byteenable
	signal d_read                     :  std_logic;                                     				   -- read
	signal d_readdata              :  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
	signal d_waitrequest          :  std_logic                     := 'X';             -- waitrequest
	signal d_write                     :  std_logic;                                        -- write
	signal d_writedata              :  std_logic_vector(31 downto 0);                    -- writedata
	signal d_readdatavalid       :  std_logic                     := 'X';             -- readdatavalid
		
	signal d_chipselect				  :  std_logic_vector(3 downto 0);
	
	
	-- sdram
	signal ADSC_N :  std_logic;
	signal ADSP_N :   std_logic;
	signal ADV_N :   std_logic;
	signal BE :   std_logic_vector( 3  downto 0  );
	
	signal GW_N :   std_logic;
	signal OE_N :   std_logic;
	signal WE_N :   std_logic;
	signal CE_0_N :   std_logic;
	signal CE_1_N :   std_logic;
	signal FS_ADDR : std_logic_vector( 19  downto 0  );
	signal FS_DQ :   std_logic_vector( 31  downto 0  );
	
	signal OE : std_logic;
	signal WE : std_logic;
	
	--
	signal sram_write_data : word_t;
	signal sram_read_data : word_t;
	
	signal d_waitrequest_sram : std_logic;
	signal d_waitrequest_sdram : std_logic;
	signal d_waitrequest_rom : std_logic;
	
	signal rom_rd_data	: word_t;
	signal sdram_data : word_t;
	---
	signal DRAM_ADDR :   std_logic_vector( 12  downto 0  );
	signal DRAM_BA :   std_logic_vector( 1  downto 0  );
	signal DRAM_CAS_N :   std_logic;
	signal DRAM_CKE :   std_logic;
	signal DRAM_CLK :   std_logic;
	signal DRAM_CS_N :   std_logic;
	 
	 signal DRAM_DQ : std_logic_vector(31 downto 0) ;
	signal DRAM_DQM :   std_logic_vector( 3  downto 0  );
	signal DRAM_RAS_N :   std_logic;
	signal DRAM_WE_N :   std_logic;
	
	---
	signal pc_reg : word_t;
	signal pc		: word_t;
	signal slot_0		: word_t;
	signal slot_1		: word_t;
	signal slot_2		: word_t;
	signal slot_3		: word_t;
	signal cpu_stall : std_logic;
	signal cache_stall : std_logic;
	
	-- performacne
	signal instructions		: word_t;		
	signal alu_ops 				: word_t;		-- format = "00"
	signal special_ops		: word_t;		-- format = "01"	
	signal mem_ops			: word_t;		-- format = "10"
	signal branche_ops : word_t;			-- format = "11"			
	
	signal cycles 		: word_t;
	signal ex_stalls : word_t;
	signal cache_stalls : word_t;
	
	signal n_ctrl_flow : word_t;
	
	-- VGA
	
	signal VGA_B :   std_logic_vector( 7  downto 0  );
   signal VGA_BLANK_N :   std_logic;
   signal VGA_CLK :   std_logic;
   signal VGA_G :   std_logic_vector( 7  downto 0  );
   signal VGA_HS :   std_logic;
   signal VGA_R :   std_logic_vector( 7  downto 0  );
   signal VGA_SYNC_N :   std_logic;
   signal VGA_VS :   std_logic;
	
	signal disp_ena : std_logic;	
	signal pixel_clk : std_logic;			
	signal column  : integer;
	signal row  : integer;		
	signal vga_reset_n : std_logic;	
	signal refresh : std_logic; 
	
	signal vga_en : std_logic;
	
	
BEGIN  -- beginning of architecture body
	
--	rom_1: rom_altera
--		port map (
--			address_a 	=>  ins_addr,
--			address_b    =>  rom_addr,
--			clock		=> mem_clk, 
--			q_a			=> ins_data,
--			q_b			=> rom_data
--		);

	rom_1:  code_ram port map	
	(
		address		=>  i_address,
		clock				=> mem_clk,
		rden				=> i_chipselect,
		q						=> i_readdata
	);
	
	cpu : vliwcpu
		port map (
			clk 	     => clk,		
			clk_mem    => mem_clk,
			reset      => reset,
		
			i_address      	=> i_address,
			i_read            	=> i_read,
			i_readdata     	 => i_readdata,
			i_waitrequest 	 => i_waitrequest,
			i_readdatavalid => i_readdatavalid,
	
			i_chipselect		=> i_chipselect,
			
			d_address   		 => d_address,
			d_byteenable   => d_byteenable,
			d_read           	 => d_read,
			d_readdata       => d_readdata,
			d_waitrequest   => d_waitrequest,
			d_write              => d_write,
			d_writedata       => d_writedata,
			d_readdatavalid    => d_readdatavalid,
			d_chipselect			=> d_chipselect,
		
			f_error		=> f_error,
			halt 			=> halt,

			-- sim debug
			pc_out				=> pc,
			slot_0_out		=> slot_0,
			slot_1_out		=> slot_1,
			slot_2_out		=> slot_2,
			slot_3_out		=> slot_3,
			
			instructions		=> instructions,
			alu_ops 				=> alu_ops,
			special_ops		=> special_ops,
			mem_ops			=> mem_ops,
			branche_ops => branche_ops,
			
			n_ctrl_flow => n_ctrl_flow,
			
			cache_stall_out  => cache_stall,
			stall_out				=> cpu_stall
		);
		
	reset_n <= not reset;
	
	rom_data:  rom_memory port map (
	  -- inputs:
	  address 		=> d_address,
	  read				=> d_read,
	  byteenable => d_byteenable,
	  chipselect => d_chipselect(0),
	  clk 					=> clk,
	  clken 			=> '1',
	  reset 			=> reset,
	  reset_req 	=> reset,	  
	
	  -- outputs:
	  readdata 		=> rom_rd_data,
	  waitrequest => d_waitrequest_rom
	);
	
	d_waitrequest <= d_waitrequest_sram or d_waitrequest_rom or d_waitrequest_sdram;
	
	sram_controller_0 : sram_controller port map(
		  -- inputs:
		  address 			=> d_address,
		  byteenable 	=> d_byteenable,
		  chipselect 		=> d_chipselect(1),
		  clk 							=> clk,
		  clken 					=> '1',
		  reset 					=> reset,
		  reset_req 		=> reset,
		  read					=> d_read,
		  write 					=> d_write,
		  writedata 			=> d_writedata,
		  waitrequest		=> d_waitrequest_sram,		
		  -- outputs:
		  readdata 			=> sram_data,
			  
		  ADSC_N	=>	ADSC_N,
		  ADSP_N 	=> ADSP_N,
		  ADV_N 		=> ADV_N,
		  BE 				=> BE,
		
		 GW_N			 => GW_N,
	    OE_N 			 => OE_N,
		 WE_N 		 => WE_N,
		 CE_0_N 	 => CE_0_N,
       CE_1_N 	 =>	CE_1_N,
		 FS_ADDR  => FS_ADDR,
		 FS_DQ		 => FS_DQ
	);
	
	sdram_controller_0: sdram_controller port map (
		address 			=> d_address,
		byteenable 	=> d_byteenable,
		chipselect 		=> d_chipselect(3),
		clk 						=> clk,
		clken 					=> '1',
		reset 					=> reset,
		reset_req 		=> reset,
		write 					=> d_write,
		read						=> d_read,
		writedata 			=> d_writedata,
		waitrequest		=> d_waitrequest_sdram,		
		-- outputs:
		readdata 			=> sdram_data,
				  
		DRAM_ADDR 	=> DRAM_ADDR,
		DRAM_BA 			=> DRAM_BA,
		DRAM_CAS_N 	=> DRAM_CAS_N,
		DRAM_CKE 			=> DRAM_CKE,
		DRAM_CLK 			=> DRAM_CLK,
		DRAM_CS_N 		=> DRAM_CS_N,
		DRAM_DQ 			=> DRAM_DQ,
		DRAM_DQM 		=> DRAM_DQM,
		DRAM_RAS_N 	=> DRAM_RAS_N,
		DRAM_WE_N 		=> DRAM_WE_N
	);
	
--	d_read_n <=  not d_read;
--	d_write_n <=  not d_write;
	
	process (d_chipselect, sram_data, rom_rd_data, sdram_data)
	begin
		
		case d_chipselect is			
			when "0001" =>
				d_readdata <= rom_rd_data;
			when "0010" =>
				d_readdata <= sram_data;
			when "0100" =>	
				d_readdata <= x"00000000";
			when "1000" =>	
				d_readdata <= sdram_data;
				
			when others => 
				d_readdata <= x"00000000";
			
		end case;	
	end process;
	
	
	
	OE <= not OE_N;
	WE <= not WE_N;
	
	ssram_1: sram_sim
		port map (
			address	=> FS_ADDR(10 downto 0),
			byteena	=> d_byteenable,
			clock			=> clk,
			data			=> sram_write_data,
			rden			=> OE,
			wren			=> WE,
			q					=> sram_read_data
		);
	
	B00: mt48lc8m16a2
		port map(
			Dq        =>   DRAM_DQ(15 downto 0),
			Addr      =>  DRAM_ADDR(11 downto 0),
			Ba        =>  DRAM_BA, 
			CLK       =>  clk2,
			Cke       =>  DRAM_CKE,
			Cs_n      => DRAM_CS_N,
			Cas_n     => DRAM_CAS_N,
			Ras_n     => DRAM_RAS_N,
			We_n      => DRAM_WE_N,
			Dqm       => DRAM_DQM(1 downto 0)
		);

	B01: mt48lc8m16a2
		port map(
			Dq        =>   DRAM_DQ(31 downto 16),
			Addr      =>  DRAM_ADDR(11 downto 0),
			Ba        =>  DRAM_BA, 
			CLK       =>  clk2,
			Cke       =>  DRAM_CKE,
			Cs_n      => DRAM_CS_N,
			Cas_n     => DRAM_CAS_N,
			Ras_n     => DRAM_RAS_N,
			We_n      => DRAM_WE_N,
			Dqm       => DRAM_DQM(3 downto 2)
		);
		
	vga_controller_1 : vga_controller port map
	(
		pixel_clk		=> pixel_clk,
		--reset_n		=> reset_n,
		reset_n		=> vga_reset_n,
		h_sync		=> VGA_HS,
		v_sync		=> VGA_VS,
		disp_ena	=> disp_ena,
		refresh => refresh,
		column		=> column,
		row				=> row,
		n_blank		=> VGA_BLANK_N,
		n_sync		=> VGA_SYNC_N			
	);
	
	
	vga_en  <= d_write and d_chipselect(2);
	
	image_1 : hw_image_generator port map
	(
		clk_cpu		=> clk,
		clk_vga		=> pixel_clk,
		reset 			=> reset,
		disp_ena	=> disp_ena,
		row				=> row,
		column		=> column,
		refresh => refresh,
		vga_reset_n => vga_reset_n,
		
				
		char_write_addr	=> d_address(11 downto 0),
      char_we					 	=> vga_en,
      char_write_value  => d_writedata(7 downto 0),
		
		
		red				=> VGA_R,
		green			=> VGA_G,
		blue				=> VGA_B
	);
	
		
		
--	ssram_2: sram_sim
--		port map (
--			address	=> FS_ADDR(18 downto 0),
--			byteena	=> d_byteenable,
--			clock			=> clk,
--			data			=> sram_write_data,
--			rden			=> OE,
--			wren			=> WE,
--			q					=> sram_read_data
--		);
		
	tristate_sram_data_rd	: tristate	port map (
		mybidir 		=> FS_DQ,
		myinput 		=> sram_read_data,
		myenable 	=> OE
	);
	
	tristate_sram_data_wr	: tristate	port map (
		mybidir 		=> sram_write_data,
		myinput 		=> FS_DQ,
		myenable 	=> WE
	);
					
	-- Process to create clock signal -- 50Mhz
	clk_proc : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 5 ns;		
		clk <= '1';
		WAIT FOR 5 ns;
	END PROCESS clk_proc;
--	
--	mem_clk_proc : PROCESS
--	BEGIN
--		mem_clk <= '0';
--		wait for 5 ns;
--		mem_clk <= '1';
--		
--		WAIT FOR 10 ns;
--		mem_clk <= '0';
--		WAIT FOR 5 ns;
--	END PROCESS mem_clk_proc;
	
	mem_clk_proc : PROCESS
	BEGIN
		mem_clk <= '0';
		WAIT FOR 5 ns;		
		mem_clk <= '1';
		WAIT FOR 5 ns;		
	END PROCESS mem_clk_proc;
	
	PROCESS
	BEGIN
		pixel_clk <= '0';
		WAIT FOR 25 ns;		
		pixel_clk <= '1';
		WAIT FOR 25 ns;		
	END PROCESS;
	

	process (clk, reset)
	begin
		if reset = '1' then
			cycles <= (others => '0');
		else
			if rising_edge(clk) then
				cycles <= cycles + 1;
			end if;
		end if;
	end process;
	
	process (clk, reset, cpu_stall)
	begin
		if reset = '1' then
			ex_stalls <= (others => '0');
		else
			if rising_edge(clk) and cpu_stall = '1' then
				ex_stalls <= ex_stalls + 1;
			end if;
		end if;
	end process;
	
	process (clk, reset, cache_stall)
	begin
		if reset = '1' then
			cache_stalls <= (others => '0');
		else
			if rising_edge(clk) and cache_stall = '1' then
				cache_stalls <= cache_stalls + 1;
			end if;
		end if;
	end process;
	
	reset_p : process
	begin
		reset <= '1';
				
		WAIT FOR 5 NS;
		reset <= '0';
		
		wait;
	end process;
	
	 process
    begin   
         clk2 <= '0';
         wait for 4000 ps;
         clk2 <= '1';
         wait for 5000 ps;
         clk2 <= '0';
         wait for 1000 ps;
 end process;
	
--	clock_gen : process (clk, ram_clk_en_out)
--	variable counter : natural := 0;
--	begin
--		if ram_clk_en_out = '0' then
--			mem_clk <= '0';
--		else
--			if rising_edge (clk) then
--				counter := counter +1;
--			end if;
--			
--			if counter >  1 then
--				counter := 0;
--				
--				if mem_clk = '0' then
--					mem_clk <= '1';
--				else
--					mem_clk <= '0';
--				end if;
--			end if;			
--		end if;	
--	end process;
	
	
	process (slot_0)
	begin
		if (slot_0 = x"00000000") or (slot_0 = x"8000000") then
			print_0 <= '0';
		else
			print_0 <= '1';
		end if;	
	end process;	
	
	process (slot_1)
	begin
		if (slot_1 = x"00000000") or (slot_1 = x"8000000") then
			print_1 <= '0';
		else
			print_1 <= '1';
		end if;	
	end process;
	
	process (slot_2)
	begin
		if (slot_2 = x"00000000") or (slot_2 = x"8000000") then
			print_2 <= '0';
		else
			print_2 <= '1';
		end if;	
	end process;
	
	process (slot_3)
	begin
		if (slot_3 = x"00000000")  or (slot_3 = x"8000000")then
			print_3 <= '0';
		else
			print_3 <= '1';
		end if;	
	end process;
	
	
	print <= print_0 or print_1 or print_2 or print_3;
	
	print_p: process (clk, reset, pc, slot_0, slot_1, slot_2, slot_3,
									print_1, print_0, print_2, print_3,
									print)
		variable my_line : line; 
		variable operations : integer;
		
		--variable teste : string(0 to 15);
		
		
		 file my_output : TEXT open WRITE_MODE is "sim.s";
		 
		alias swrite is write [line, string, side, width];
	begin
		
		if reset = '1' then
			--write(my_line, now); 
			--swrite(my_line, " Reset");			
			--writeline(my_output, my_line);
			operations := 0;
		else
			if rising_edge(clk)  and cpu_stall = '0' and halt = '0' then
				--write(my_line, now);     
				--swrite(my_line, "pc=");	
				 --hwrite(my_line, pc);				-- needs use IEEE.std_logic_textio.all;
				--write(my_line, conv_integer(pc));				
				--swrite(my_line, " ");	
				
				
				if  (slot_0 /= x"00000000") and (slot_0 /= x"8000000") then
					write(my_line, conv_integer(pc));				
					swrite(my_line, " ");	
					hwrite(my_line, slot_0);				-- needs use IEEE.std_logic_textio.all;
					write(my_line, decode(slot_0, slot_1) );										
					
					--write(my_line, now);	
					
					if slot_0(29 downto 28) = "11" then
						swrite(my_line, "  @");	
						write(my_line, now); 
					end if;
					write(my_line, LF);
					
				end if;
				
				if  (slot_1 /= x"00000000") and (slot_1 /= x"8000000") then		
					write(my_line, conv_integer(pc));				
					swrite(my_line, " ");	
					hwrite(my_line, slot_1);				-- needs use IEEE.std_logic_textio.all;
					write(my_line, decode(slot_1, slot_2) );										
					write(my_line, LF);
				end if;
--				
--				
			if  (slot_2 /= x"00000000") and (slot_2 /= x"8000000") then		
					write(my_line, conv_integer(pc));				
					swrite(my_line, " ");	
					hwrite(my_line, slot_2);				-- needs use IEEE.std_logic_textio.all;
					write(my_line, decode(slot_2, slot_3) );										
					write(my_line, LF);
				end if;
--				
			if  (slot_3 /= x"00000000") and (slot_3 /= x"8000000") then		
					write(my_line, conv_integer(pc));				
					swrite(my_line, " ");	
					hwrite(my_line, slot_3);				-- needs use IEEE.std_logic_textio.all;
					write(my_line, decode(slot_3, x"00000000") );										
					write(my_line, LF);
				end if;
				
				if (print = '1') then
                                        operations := conv_integer(alu_ops) + conv_integer(special_ops) + conv_integer(mem_ops) + conv_integer(branche_ops);
					--write(my_line, now); 
					--write(my_line, LF);
					
					swrite(my_line, ";;");	
					write(my_line, LF);
					--write(my_line, LF);
					--write(my_line, operations);
					--writeline(my_output, "\n");
					writeline(my_output, my_line);				-- needs use STD.textio.all;
				end if;
				
			end if;
		end if;
	end process;
			

	halt_p: process (halt)
		variable my_line : line;
		
		variable operations : integer;
		
		file my_output : TEXT open WRITE_MODE is "stats.txt";
		 
		alias swrite is write [line, string, side, width];
	begin
		
		if halt = '1' then
			
			operations := conv_integer(alu_ops) + conv_integer(special_ops) + conv_integer(mem_ops) + conv_integer(branche_ops);
			
			swrite(my_line, "halt @ ");	
			write(my_line, now);  
			writeline(my_output, my_line);
			
			writeline(my_output, my_line);			
			swrite(my_line, "Cycles | ");	
			write(my_line, conv_integer(cycles));				
			writeline(my_output, my_line);
			
			
			swrite(my_line, "Instructions | Operations");	
			writeline(my_output, my_line);
			write(my_line, conv_integer(instructions));
			swrite(my_line, " | ");
			write(my_line, operations);		
			writeline(my_output, my_line);
			
			writeline(my_output, my_line);
			
			swrite(my_line, "alu_ops | special_ops | mem_ops | branche_ops");	
			writeline(my_output, my_line);
			write(my_line, conv_integer(alu_ops));				
			swrite(my_line, " | ");	
			write(my_line, conv_integer(special_ops));	
			swrite(my_line, " | ");	
			write(my_line, conv_integer(mem_ops));
			swrite(my_line, " | ");
			write(my_line, conv_integer(branche_ops));	
			writeline(my_output, my_line);
				
		
			writeline(my_output, my_line);		
			
			swrite(my_line, "Ex_stalls | ");	
			write(my_line, conv_integer(ex_stalls));				
			writeline(my_output, my_line);
			
			swrite(my_line, "cache_stalls | ");	
			write(my_line, conv_integer(cache_stalls));				
			writeline(my_output, my_line);
			
			swrite(my_line, "n_ctrl_flow | ");	
			write(my_line, conv_integer(n_ctrl_flow));				
			writeline(my_output, my_line);
			
			assert false report "End of simulation" severity error;		
			
		end if;		
		
	end process;

	

			
END ARCHITECTURE stimulus;