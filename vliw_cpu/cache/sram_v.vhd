LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

ENTITY sram_v IS
   PORT
   (
      clock: 			 in   std_logic;
		reset:			 in 	std_logic;
		data:  			 in   std_logic;
      rdaddress:  		 in   std_logic_vector (INDEX_SIZE-1 DOWNTO 0);
		wraddress:  	 in   std_logic_vector (INDEX_SIZE-1 DOWNTO 0);
 		we:    			 in   std_logic;
      q: 			    out  std_logic
   );
END sram_v;


ARCHITECTURE rtl OF sram_v IS
   TYPE mem IS ARRAY(0 TO 31) OF std_logic;
   SIGNAL ram_block : mem;	
	
	BEGIN
   PROCESS (clock, reset)
   BEGIN
      if reset = '1' then
			ram_block(conv_integer(0)) <= '0';
			ram_block(conv_integer(1)) <= '0';
			ram_block(conv_integer(2)) <= '0';
			ram_block(conv_integer(3)) <= '0';
			ram_block(conv_integer(4)) <= '0';
			ram_block(conv_integer(5)) <= '0';
			ram_block(conv_integer(6)) <= '0';
			ram_block(conv_integer(7)) <= '0';
			ram_block(conv_integer(8)) <= '0';
			ram_block(conv_integer(9)) <= '0';
			ram_block(conv_integer(10)) <= '0';
			ram_block(conv_integer(11)) <= '0';
			ram_block(conv_integer(12)) <= '0';
			ram_block(conv_integer(13)) <= '0';
			ram_block(conv_integer(14)) <= '0';
			ram_block(conv_integer(15)) <= '0';	
			ram_block(conv_integer(16)) <= '0';
			ram_block(conv_integer(17)) <= '0';
			ram_block(conv_integer(18)) <= '0';
			ram_block(conv_integer(19)) <= '0';
			ram_block(conv_integer(20)) <= '0';
			ram_block(conv_integer(21)) <= '0';
			ram_block(conv_integer(22)) <= '0';
			ram_block(conv_integer(23)) <= '0';
			ram_block(conv_integer(24)) <= '0';
			ram_block(conv_integer(25)) <= '0';
			ram_block(conv_integer(26)) <= '0';
			ram_block(conv_integer(27)) <= '0';
			ram_block(conv_integer(28)) <= '0';
			ram_block(conv_integer(29)) <= '0';
			ram_block(conv_integer(30)) <= '0';
			ram_block(conv_integer(31)) <= '0';	
		else
			IF (clock'event AND clock = '1') THEN
				IF (we = '1') THEN
					ram_block(conv_integer(wraddress)) <= data;				
					q <= data;
				else				
					q <= ram_block(conv_integer(rdaddress));
				end if;
	
			END IF;
		end if;
   END PROCESS;
	
	-- make output async, this make stall detection easier
--	process (address, ram_block)
--	begin
--		q <= ram_block(conv_integer(address));
--	end process;			
	
	
END rtl;