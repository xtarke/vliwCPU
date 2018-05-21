library IEEE;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;


entity ex_forward_r01 is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	
	-- cycle that need forward
	rd_ctrl		: in t_ctrl;
	
	-- destination registers
	ex_ctrl_0	: in t_ctrl;
	ex_ctrl_1	: in t_ctrl;
	ex_ctrl_2	: in t_ctrl;
	ex_ctrl_3	: in t_ctrl;
	
	default	: in word_t; 	
	default_c: in std_logic;
	alu_0		: in  t_alu_val;
	alu_1		: in  t_alu_val;
	alu_2		: in  t_alu_val;
	alu_3		: in  t_alu_val;	
	mem		: in word_t;
	
	forward_a	: out t_alu_val;
	forward_b	: out t_alu_val
	);
end ex_forward_r01;


architecture rtl of ex_forward_r01 is

	signal sel_0 : std_logic_vector (2 downto 0);
	signal sel_1 : std_logic_vector (2 downto 0);


begin	
	process	(clk, reset, rd_ctrl, ex_ctrl_0, ex_ctrl_1, ex_ctrl_2, ex_ctrl_3)
	begin
		if reset = '1' then
			sel_0	<=	"000";
			sel_1	<=	"000";
		else
			if rising_edge(clk) then
					
				sel_0	<=	"000";
				sel_1	<=	"000";
			
				-- ALU	0	--
				if ex_ctrl_0.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_0.reg_w_en = '1' then
					sel_0	<=	"001";
				end if;
			
				if ex_ctrl_0.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_0.reg_w_en = '1' then
					sel_1	<=	"001";
				end if;
				
				if ex_ctrl_0.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_0.mem_rd = '1' then
					sel_0	<=	"101";
				end if;
			
				if ex_ctrl_0.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_0.mem_rd = '1' then
					sel_1	<=	"101";
				end if;
				
				-- ALU	1	--
				if ex_ctrl_1.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_1.reg_w_en = '1' then
					sel_0	<=	"010";
				end if;
	
				if ex_ctrl_1.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_1.reg_w_en = '1' then
					sel_1	<=	"010";
				end if;
				
				if ex_ctrl_1.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_1.mem_rd = '1' then
					sel_0	<=	"101";
				end if;
	
				if ex_ctrl_1.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_1.mem_rd = '1' then
					sel_1	<=	"101";
				end if;					
				
				-- ALU	2	--
				if ex_ctrl_2.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_2.reg_w_en = '1' then
					sel_0	<=	"011";
				end if;
	
				if ex_ctrl_2.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_2.reg_w_en = '1' then
					sel_1	<=	"011";
				end if;
				
				if ex_ctrl_2.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_2.mem_rd = '1' then
					sel_0	<=	"101";
				end if;
	
				if ex_ctrl_2.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_2.mem_rd = '1' then
					sel_1	<=	"101";
				end if;
				
		
				-- ALU	3	--
				if ex_ctrl_3.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_3.reg_w_en = '1' then
					sel_0	<=	"100";
				end if;
	
				if ex_ctrl_3.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_3.reg_w_en = '1' then
					sel_1	<=	"100";
				end if;
				
				if ex_ctrl_3.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_3.mem_rd = '1' then
					sel_0	<=	"101";
				end if;
	
				if ex_ctrl_3.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_3.mem_rd = '1' then
					sel_1	<=	"101";
				end if; 
				
				
			end if;
		end if;
	
	
	
	end process;
	
	
	process (sel_0, default, default_c, alu_0, alu_1, alu_2, alu_3, mem)
	begin
	
		case sel_0 is
			when "000" =>
				forward_a.alu_val	<=	default;			
				forward_a.carry_cmp	<=	default_c;			
			when "001" =>
				forward_a	<=	alu_0;
			when "010" =>
				forward_a	<=	alu_1;
			when "011" =>
				forward_a	<=	alu_2;
			when "100" =>
				forward_a	<=	alu_3;
			when "101" =>
				forward_a.alu_val	<=	mem;
				forward_a.carry_cmp	<=	'0';
			when others =>
				forward_a.alu_val			<=	default;
				forward_a.carry_cmp	<=	default_c;		
		end case;	
	end process;
end rtl;

--	if reset = '1' then
--			forward_a.alu_val			<=   (forward_a.alu_val'range => '0');
--			forward_a.carry_cmp	<=	'0';
--		else
--			if rising_edge(clk) then
--					
--				forward_a.alu_val			<=	default;
--				forward_a.carry_cmp	<=	default_c;
--				
--				forward_b.alu_val			<=	default;
--				forward_b.carry_cmp	<=	default_c;
--			
--				-- ALU	0	--
--				if ex_ctrl_0.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_0.reg_w_en = '1' then
--					forward_a	<=	alu_0;
--				end if;
--			
--				if ex_ctrl_0.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_0.reg_w_en = '1' then
--					forward_b	<=	alu_0;
--				end if;
--				
--				if ex_ctrl_0.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_0.mem_rd = '1' then
--					forward_a.alu_val			<= mem;
--					forward_a.carry_cmp <= '0';
--				end if;
--			
--				if ex_ctrl_0.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_0.mem_rd = '1' then
--					forward_b.alu_val			<= mem;
--					forward_b.carry_cmp <= '0';
--				end if;
--				
--				-- ALU	1	--
--				if ex_ctrl_1.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_1.reg_w_en = '1' then
--					forward_a	<=	alu_1;
--				end if;
--	
--				if ex_ctrl_1.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_1.reg_w_en = '1' then
--					forward_b	<=	alu_1;
--				end if;
--				
--				if ex_ctrl_1.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_1.mem_rd = '1' then
--					forward_a.alu_val			<= mem;
--					forward_a.carry_cmp <= '0';
--				end if;
--	
--				if ex_ctrl_1.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_1.mem_rd = '1' then
--					forward_b.alu_val			<= mem;
--					forward_b.carry_cmp <= '0';
--				end if;					
--				
--				-- ALU	2	--
--				if ex_ctrl_2.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_2.reg_w_en = '1' then
--					forward_a	<=	alu_2;
--				end if;
--	
--				if ex_ctrl_2.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_2.reg_w_en = '1' then
--					forward_b	<=	alu_2;
--				end if;
--				
--				if ex_ctrl_2.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_2.mem_rd = '1' then
--					forward_a.alu_val			<= mem;
--					forward_a.carry_cmp <= '0';
--				end if;
--	
--				if ex_ctrl_2.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_2.mem_rd = '1' then
--					forward_b.alu_val			<= mem;
--					forward_b.carry_cmp <= '0';
--				end if;
--						
--				-- ALU	3	--
--				if ex_ctrl_3.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_3.reg_w_en = '1' then
--					forward_a	<=	alu_3;
--				end if;
--	
--				if ex_ctrl_3.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_3.reg_w_en = '1' then
--					forward_b	<=	alu_3;
--				end if;
--				
--				if ex_ctrl_3.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_3.mem_rd = '1' then
--						forward_a.alu_val			<= mem;
--					forward_a.carry_cmp <= '0';
--				end if;
--	
--				if ex_ctrl_3.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_3.mem_rd = '1' then
--					forward_b.alu_val			<= mem;
--					forward_b.carry_cmp <= '0';
--				end if; 
--				
--			end if;
--		end if;
--	end process;
