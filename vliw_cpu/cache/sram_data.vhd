LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.cpu_typedef_package.all;

ENTITY sram_data IS
   PORT
   (
      address	:  in STD_LOGIC_VECTOR (INDEX_SIZE-1 DOWNTO 0);
		clock		:	in STD_LOGIC;
		data		:  in STD_LOGIC_VECTOR (255 DOWNTO 0);
		wren		:  in STD_LOGIC;
		q			:  out  STD_LOGIC_VECTOR (255 DOWNTO 0)
   );
END sram_data;



ARCHITECTURE rtl OF sram_data IS
   TYPE mem IS ARRAY(0 TO 15) OF STD_LOGIC_VECTOR (255 DOWNTO 0);
   SIGNAL ram_block : mem;
BEGIN
   PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (wren = '1') THEN
            ram_block(conv_integer(address)) <= data;
         END IF;
         q <= ram_block(conv_integer(address));
      END IF;
   END PROCESS;

END rtl;