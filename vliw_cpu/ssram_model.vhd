LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

ENTITY ssram_model IS
   PORT
   (
      address	:  in STD_LOGIC_VECTOR (SSRAM_ADDR_SIZE-1 DOWNTO 0);
		clock		:	in STD_LOGIC;
		data		:  inout STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		:  in STD_LOGIC;	
	   rden		: in std_logic
   );
END ssram_model;



ARCHITECTURE rtl OF ssram_model IS
   TYPE mem IS ARRAY(0 TO 512) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL ram_block : mem;
	
	signal int_data	: word_t;
	
BEGIN
   PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (wren = '1') THEN
            ram_block(conv_integer(address)) <= data;
         END IF;
         
			if rden = '1' then			
				data <= ram_block(conv_integer(address));
			else
				data <= (data'range => 'Z');
			end if;
      END IF;
   END PROCESS;
	
--	process (rden, int_data)
--	begin
--		if rden = '1' then
--			data <= int_data;
--		else
--			data <= (data'range => 'Z');
--		end if;
--	
--	end process;
	
	

END rtl;