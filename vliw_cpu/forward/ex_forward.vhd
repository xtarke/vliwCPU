library IEEE;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;


entity ex_forward is
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
	   
	-- alu mus selection	for eac alu port
	forward_a	: out STD_LOGIC_VECTOR (2 DOWNTO 0);
	forward_b	: out STD_LOGIC_VECTOR (2 DOWNTO 0)			
	);
end ex_forward;


architecture rtl of ex_forward is
begin	
	process	(clk, reset, rd_ctrl, ex_ctrl_0, ex_ctrl_1, ex_ctrl_2, ex_ctrl_3)
	begin
		if reset = '1' then
			forward_a	<=	"000";
			forward_b	<=	"000";
		else
			if rising_edge(clk) then
					
				forward_a	<=	"000";
				forward_b	<=	"000";
			
				-- ALU	0	--
				if ex_ctrl_0.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_0.reg_w_en = '1' then
					forward_a	<=	"001";
				end if;
			
				if ex_ctrl_0.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_0.reg_w_en = '1' then
					forward_b	<=	"001";
				end if;
				
				if ex_ctrl_0.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_0.mem_rd = '1' then
					forward_a	<=	"101";
				end if;
			
				if ex_ctrl_0.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_0.mem_rd = '1' then
					forward_b	<=	"101";
				end if;
				
				-- ALU	1	--
				if ex_ctrl_1.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_1.reg_w_en = '1' then
					forward_a	<=	"010";
				end if;
	
				if ex_ctrl_1.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_1.reg_w_en = '1' then
					forward_b	<=	"010";
				end if;
				
				if ex_ctrl_1.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_1.mem_rd = '1' then
					forward_a	<=	"101";
				end if;
	
				if ex_ctrl_1.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_1.mem_rd = '1' then
					forward_b	<=	"101";
				end if;					
				
				-- ALU	2	--
				if ex_ctrl_2.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_2.reg_w_en = '1' then
					forward_a	<=	"011";
				end if;
	
				if ex_ctrl_2.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_2.reg_w_en = '1' then
					forward_b	<=	"011";
				end if;
				
				if ex_ctrl_2.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_2.mem_rd = '1' then
					forward_a	<=	"101";
				end if;
	
				if ex_ctrl_2.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_2.mem_rd = '1' then
					forward_b	<=	"101";
				end if;
				
		
				-- ALU	3	--
				if ex_ctrl_3.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_3.reg_w_en = '1' then
					forward_a	<=	"100";
				end if;
	
				if ex_ctrl_3.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_3.reg_w_en = '1' then
					forward_b	<=	"100";
				end if;
				
				if ex_ctrl_3.dest_reg = rd_ctrl.src_1_reg and ex_ctrl_3.mem_rd = '1' then
					forward_a	<=	"101";
				end if;
	
				if ex_ctrl_3.dest_reg = rd_ctrl.src_2_reg and ex_ctrl_3.mem_rd = '1' then
					forward_b	<=	"101";
				end if; 
				
				
			end if;
		end if;
	
	
	
	end process;





end rtl;
