library IEEE;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;

entity ins_buffer is
port (
	clk      			: in std_logic;	
	reset    			: in std_logic;
	enable				: in std_logic;
	
	bunble_in  			: in std_logic_vector(BUNDLE_SIZE-1 downto 0);	
	
	fresh_data			: in std_logic;
	
	slot_0			   : out word_t; 
	slot_1			   : out word_t;
	slot_2			   : out word_t;
	slot_3			   : out word_t;	
	
	issue_ins			: out std_logic_vector(2 downto 0);
	
	next_address 		: out word_t
	
	);
end ins_buffer;



architecture rtl of ins_buffer is
	-- instruction slots for data
	type data_slots_type is array (0 to 3) of word_t;
	-- instruction slots age, up to 8 instructions
	type data_age_type is array (0 to 7) of std_logic_vector(7 downto 0);
	-- is empty?
	type data_full_type is array (0 to 3) of std_logic;
	
	signal buffer_2  : data_slots_type;
	signal buffer_1  : data_slots_type;
	
	signal slots_age   : data_age_type;	
		
	signal buffer_1_issue_slots : data_full_type;
		
	signal word_0 : word_t;
	signal word_1 : word_t;
	signal word_2 : word_t;
	signal word_3 : word_t;
	
	signal nxt_slot : std_logic_vector(2 downto 0);
	--signal issue_ins : std_logic_vector(2 downto 0);
	signal mask : std_logic_vector(3 downto 0);
	
	signal address	: word_t;
	
begin
	--separate words of the bundle
	word_0 <= bunble_in(WORD_SIZE-1 downto 0);
	word_1 <= bunble_in(2*WORD_SIZE-1 downto WORD_SIZE);
	word_2 <= bunble_in(3*WORD_SIZE-1 downto 2*WORD_SIZE);
	word_3 <= bunble_in(4*WORD_SIZE-1 downto 3*WORD_SIZE);

	do_read: process (clk, reset, enable)
	begin
		if reset = '1' then			
			buffer_1(0) <= (buffer_1(0)'range => '0');
			buffer_1(1) <= (buffer_1(1)'range => '0');
			buffer_1(2) <= (buffer_1(2)'range => '0');
			buffer_1(3) <= (buffer_1(3)'range => '0');
				
			address <= (address'range => '0');
		else
			if rising_edge (clk) and enable = '1' then	
				
				if buffer_1_issue_slots(0) = '0' and 
					buffer_1_issue_slots(1) = '0' and
					buffer_1_issue_slots(2) = '0' and
					buffer_1_issue_slots(3) = '0' then 
				
					buffer_1(0) <= word_0;
					buffer_1(1) <= word_1;
					buffer_1(2) <= word_2;
					buffer_1(3) <= word_3;				
				end if;			
			end if;
		end if;
	end process;

	next_address <= address;
	
	detect_stop_bit: process (clk, reset, buffer_1, fresh_data)		
	begin
		if reset = '1' then 
			nxt_slot <= "000";
			
			slot_0 <= (slot_0'range => '0');
			slot_1 <= (slot_1'range => '0');
			slot_2 <= (slot_2'range => '0');
			slot_3 <= (slot_3'range => '0');
			
			buffer_1_issue_slots(0) <= '0';
			buffer_1_issue_slots(1) <= '0';
			buffer_1_issue_slots(2) <= '0';
			buffer_1_issue_slots(3) <= '0';
		
			issue_ins <= "000";
		else
			if rising_edge (clk) and enable = '1' then
			 
				if fresh_data = '1' then
					slot_0 <= (slot_0'range => '0');
					slot_1 <= (slot_1'range => '0');
					slot_2 <= (slot_2'range => '0');
					slot_3 <= (slot_3'range => '0');
					issue_ins <= "000";
					
					buffer_1_issue_slots(0) <= '0';
					buffer_1_issue_slots(1) <= '0';
					buffer_1_issue_slots(2) <= '0';
					buffer_1_issue_slots(3) <= '0';
			
					case nxt_slot is
						when "000" => 
							if buffer_1(conv_integer(0))(31) = '1' then
								nxt_slot <= nxt_slot + "001";
								
								slot_0 <= buffer_1(conv_integer(0));
								issue_ins <= "001";
								
								buffer_1_issue_slots(0) <= '1';
								
							elsif buffer_1(conv_integer(1))(31) = '1' then 
								nxt_slot  <= nxt_slot + "010";
						
								slot_0 <= buffer_1(conv_integer(0));
								slot_1 <= buffer_1(conv_integer(1));
								issue_ins <= "010";
							
								buffer_1_issue_slots(0) <= '1';
								buffer_1_issue_slots(1) <= '1';
				
							elsif buffer_1(conv_integer(2))(31) = '1' then  
								nxt_slot <=  nxt_slot + "011";
							
								slot_0 <= buffer_1(conv_integer(0));
								slot_1 <= buffer_1(conv_integer(1));	
								slot_2 <= buffer_1(conv_integer(2));
							
								issue_ins <= "011";
								
								buffer_1_issue_slots(0) <= '1';
								buffer_1_issue_slots(1) <= '1';
								buffer_1_issue_slots(2) <= '1';
								
						
							elsif buffer_1(conv_integer(3))(31) = '1' then 
								nxt_slot <= nxt_slot + "100";
			
								slot_0 <= buffer_1(conv_integer(0));
								slot_1 <= buffer_1(conv_integer(1));
								slot_2 <= buffer_1(conv_integer(2));
								slot_3 <= buffer_1(conv_integer(3));
								
								issue_ins <= "100";
								
								buffer_1_issue_slots(0) <= '1';
								buffer_1_issue_slots(1) <= '1';
								buffer_1_issue_slots(2) <= '1';
								buffer_1_issue_slots(3) <= '1';
								
							end if;
			
						when "001" =>					
							if buffer_1(conv_integer(1))(31) = '1' then 
								nxt_slot  <= nxt_slot + "001";
							
								slot_1 <= buffer_1(conv_integer(1));
								issue_ins <= "001";
								
								buffer_1_issue_slots(1) <= '1';
								
							elsif buffer_1(conv_integer(2))(31) = '1' then  
								nxt_slot <= nxt_slot + "010";
						
								slot_1 <= buffer_1(conv_integer(1));
								slot_2 <= buffer_1(conv_integer(2));
								issue_ins <= "010";
								
								buffer_1_issue_slots(1) <= '1';
								buffer_1_issue_slots(2) <= '1';
				
							elsif buffer_1(conv_integer(3))(31) = '1' then 
								nxt_slot <= nxt_slot + "011";
			
								slot_1 <= buffer_1(conv_integer(1));
								slot_2 <= buffer_1(conv_integer(2));
								slot_3 <= buffer_1(conv_integer(3));
								issue_ins <= "011";
								
								buffer_1_issue_slots(1) <= '1';
								buffer_1_issue_slots(2) <= '1';
								buffer_1_issue_slots(3) <= '1';
			
							end if;
						
						when "010" => 
							if buffer_1(conv_integer(2))(31) = '1' then  
								nxt_slot <=  nxt_slot + "001";
						
								slot_2 <= buffer_1(conv_integer(2));
								issue_ins <= "001";	
		
								buffer_1_issue_slots(2) <= '1';
				
							elsif buffer_1(conv_integer(3))(31) = '1' then 
								nxt_slot <= nxt_slot + "010";
									
								slot_2 <= buffer_1(conv_integer(2));							
								slot_3 <= buffer_1(conv_integer(3));
								issue_ins <= "010";
								
								buffer_1_issue_slots(2) <= '1';
								buffer_1_issue_slots(3) <= '1';
			
							end if;
							
						when "011" => 
							if buffer_1(conv_integer(3))(31) = '1' then 
								nxt_slot <= "000";	
					
								slot_3 <= buffer_1(conv_integer(3));
								issue_ins <= "001";
								
								buffer_1_issue_slots(3) <= '1';
							end if;
						when others =>
							nxt_slot <= "000";
							issue_ins <= "000";					
					end case;			
					
					mask <= buffer_1(3)(31) & buffer_1(2)(31) & buffer_1(1)(31) & buffer_1(0)(31);					
				else
					issue_ins <= "000";	
				end if;
			end if;
		end if;
	end process;
end rtl;