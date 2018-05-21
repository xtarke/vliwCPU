LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

ENTITY sram_tag IS
   PORT
   (
      clock: 			 in   std_logic;
		data:  			 in   std_logic_vector (TAG_SIZE-1 DOWNTO 0);
      address:  	 in   std_logic_vector (INDEX_SIZE-1 DOWNTO 0);
 		we:    			 in   std_logic;
      q:     				out  std_logic_vector (TAG_SIZE-1 DOWNTO 0)
   );
END sram_tag;


ARCHITECTURE rtl OF sram_tag IS
   TYPE mem IS ARRAY(0 TO 15) OF std_logic_vector(TAG_SIZE-1 DOWNTO 0);
   
	function ram_init
		return mem is
		variable result	: mem;
	begin
		for i in 15 downto 0 loop
			result(i) := x"000000";
		end loop;
		return result;
	end ram_init;
	
	SIGNAL ram_block : mem := ram_init;
	
	
	BEGIN
   PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (we = '1') THEN
            ram_block(conv_integer(address)) <= data;
         END IF;
         q <= ram_block(conv_integer(address));
      END IF;
   END PROCESS;
	
	-- make output async, this make stall detection easier
--	process (address, ram_block)
--	begin
--		q <= ram_block(conv_integer(address));
--	end process;			
	
	
END rtl;