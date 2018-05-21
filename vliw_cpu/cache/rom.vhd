library IEEE	;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

entity rom is
port (
	clk     : in std_logic;
	enable  : in std_logic;
	
	rd     : in std_logic;
	-- address
	rd_addr : std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	-- data	
	data_out : out word_t );
end rom;

architecture logic of rom is
	type rom is array (0 to 255) of word_t;
	
	constant data: rom := (
    --mem init
	 
0=>x"08063040",
1=>x"08004080",
2=>x"080050C0",
3=>x"88006100",
4=>x"00000000",
5=>x"00000000",
6=>x"00000000",
7=>x"80007081",
8=>x"00207081",
9=>x"00008103",
10=>x"00000000",
11=>x"80000000",
12=>x"00000000",
13=>x"00000000",
14=>x"00000000",
15=>x"80000000",







		  16 => x"16666666",
		  17 => x"17777777",
		  18 => x"18888888",
		  19 => x"f9999999",
		  
		  20 => x"19888888",
		  21 => x"11111111",
		  22 => x"12222222",
		  23 => x"f3333333",
		  
		  24 => x"18333333",
		  25 => x"14333333",
		  26 => x"15333333",
		  27 => x"f6333333",
		  
		  28 => x"18889888",
		  29 => x"18333333",
		  30 => x"19333333",
		  31 => x"f0333333",
		  
		  32 => x"18888899",
		  33 => x"15555555",
		  34 => x"16666666",
		  35 => x"f7777777",
		  
		  
		  
		  others => x"00000000"	
	);  
	

begin	
	-- read process
	process (clk, rd, enable, rd_addr)
	begin
		--data_out <= "ZZZZZZZZZZZZZZZZ";
		if enable = '1' and rd = '1' then
			if rising_edge (clk) then
				data_out <= data(conv_integer(rd_addr));			
			end if;
		--else
		--	data_out <= (data_out'range => 'Z');
		end if;		
	end process;
end logic;           