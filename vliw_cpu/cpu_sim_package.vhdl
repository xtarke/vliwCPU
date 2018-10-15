library STD;
use STD.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_typedef_package.all;
use work.opcodes.all;
use work.txt_util.all;
use IEEE.std_logic_textio.all;  
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;

package cpu_sim_package is		
	 function decode(slot, slot_imm : word_t) return string;
	 function long_imm(slot, slot_imm : word_t) return string;
	 function to_std_logic_vector(s: string) return std_logic_vector;	 	 
	 function f_pred (f: std_logic) return string;	 
		 
end cpu_sim_package;

package body cpu_sim_package is

 function f_pred (f: std_logic) return string is
 begin
	if f = '1' then
		return " (p)";
	else
		return ""; 
	end if;
 end function;

 
 function decode(slot, slot_imm : word_t) return string is		
		variable opcode 	  : std_logic_vector(OPCODE_SIZE-1 downto 0);
		variable ins_format : std_logic_vector(INS_FORMAT_SIZE-1 downto 0);
		variable cmp_opcode : std_logic_vector(CMP_OPCODE_SIZE-1 downto 0);
      			
	begin
	
		opcode 		:= slot(OPCODE_END downto OPCODE_INI);
		ins_format	:= slot(INS_FORMAT_END	downto INS_FORMAT_INI);
		cmp_opcode	:= slot(CMP_OPCODE_END downto CMP_OPCODE_INI);
		
		case ins_format is
			
			-- alu instructions
			when "00"	=> 				
			
				-- Int3R and Int3l instructions: bit 27,26 = 0      => Int3R
				--											bit 27 = 1, 26 = 0 => Int3l
				if (slot(M0) = '0') then		
								
					case opcode is
						when ADD_OP => 
							
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " add " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " add " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & long_imm(slot, slot_imm);
												--& ", " & str(to_integer(signed(slot(IMMEDIATE_END downto IMMEDIATE_INI))));						
							end if;
												
							
							
						when SUB_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " sub " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " sub " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
						
						when SHL_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " shl " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " shl " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
						
						when SHR_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " shr " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " shr " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;	
			
						when SHRU_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " shru " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " shru " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when SH1ADD_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " SH1ADD " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " SH1ADD " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when SH2ADD_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " SH2ADD " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " SH2ADD " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when SH3ADD_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " SH3ADD " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " SH23DD " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when AND_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " and " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " and " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when ANDC_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " andc " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " andc " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when OR_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " or " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " or " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when ORC_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " orc " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " orc " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when XOR_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " xor " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " xor " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
						
						when MAX_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " MAX " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& "," & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " MAX " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
						
						when MAXU_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " MAXU " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& "," & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " MAXU " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
						
						when MIN_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " MIN " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& "," & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " MIN " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
						
						when MINU_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " MINU " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& "," & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " MINU " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when MULL_OP => 
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " mull " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							
							else
								return f_pred(slot(30)) & " mull " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							end if;
							
						when DIVR_OP	=>
							if slot(M1) = '0' then
								return f_pred(slot(30)) & " divr " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
							end if;
							
						when DIVQ_OP	=>
								if slot(M1) = '0' then
									return f_pred(slot(30)) & " divq " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
								end if;
									
						when DIVRU_OP	=>
								if slot(M1) = '0' then
									return f_pred(slot(30)) & " divru " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
								end if;
						
						when DIVQU_OP	=>
								if slot(M1) = '0' then
									return f_pred(slot(30)) & " divqu " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& "," & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
								end if;
						      
			
						when MONADIC_OP =>
								case slot(IMMEDIATE_END downto IMMEDIATE_INI) is
									-- SXTB
									when SXTB_OP =>
										return f_pred(slot(30)) & " sxtb " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))));												
									
									when SXTH_OP =>
										return f_pred(slot(30)) & " sxth " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))));			
									when ZXTB_OP =>
										return f_pred(slot(30)) & " zxtb " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))));												
									
									when ZXTH_OP =>
										return f_pred(slot(30)) & " zxth " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))));					
																	
									when others =>
									
											
								end case;
					
							
						when others => 
				
				
					
				end case;
			else
				case cmp_opcode is
								
					when CMPEQ_OP => 
						if slot(M1) = '0' then								
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpeq " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& "," & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpeq $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpeq " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpeq $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;
					when CMPNE_OP => 
						if slot(M1) = '0' then								
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpne " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpne $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpne " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpne $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPGE_OP => 
					
						if slot(M1) = '0' then								
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpge " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpge $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpge " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpge $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPGEU_OP => 
						if slot(M1) = '0' then		
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpgeu " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpgeu $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpgeu " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpgeu $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPGT_OP => 
						if slot(M1) = '0' then	
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpgt " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpgt $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpgt " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpgt $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPGTU_OP =>
						if slot(M1) = '0' then		
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpgtu " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpgtu $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpgtu " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpgtu $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPLE_OP => 
						if slot(M1) = '0' then		
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmple " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmple $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmple " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmple $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPLEU_OP => 
						if slot(M1) = '0' then		
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpleu " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpleu $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpleu " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpleu $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPLT_OP =>
						if slot(M1) = '0' then		
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmplt " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmplt $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmplt " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmplt $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;	
					
					when CMPLTU_OP =>	
						if slot(M1) = '0' then			
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " cmpltu " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " cmpltu $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " cmpltu " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " cmpltu $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;
		
					when ANDL_OP => 
						if slot(M1) = '0' then			
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " andl " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " andl $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " andl " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " andl $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;					
					
					when NANDL_OP => 
						if slot(M1) = '0' then			
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " nandl " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " nandl $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " nandl " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " nandl $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;			
					
					when ORL_OP => 
						if slot(M1) = '0' then		
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " orl " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " orl $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " orl " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " orl $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;			
					
					
					when NORL_OP => 
						if slot(M1) = '0' then		
							if slot(CMP_DEST_SEL) = '0' then																	
								return f_pred(slot(30)) & " norl " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));			
							else								
								return f_pred(slot(30)) & " norl $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));											
							end if;							
						else
							if slot(CMP_DEST_SEL) = '0' then															
								return f_pred(slot(30)) & " norl " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
							else
								return f_pred(slot(30)) & " norl $br" & str(to_integer(unsigned(slot(IBDEST_END downto IBDEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));								
							
							end if;
						end if;			
					
					 when MUL64H_OP => 								
									return f_pred(slot(30)) & " mul64h " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
										
					when MUL64HU_OP =>
							return f_pred(slot(30)) & " mul64hu " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
											& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
											& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
					
					
					when others => 
				end case;						
						
			
			
			
			end if;
			
			when "01" => 
			
				if slot(M1) = '0' then
					case slot(26 downto 24) is
									
						when SLCT_OP =>
							return f_pred(slot(30)) & " slct " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))												
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
												& ", $br" & str(to_integer(unsigned(slot(SCOND_END downto SCOND_INI))));
									
						when SLCTF_OP => 
							return f_pred(slot(30)) & " slctf " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))												
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
												& ", $br" & str(to_integer(unsigned(slot(SCOND_END downto SCOND_INI))));
									
						when ADDCG_OP =>
							return f_pred(slot(30)) & " addcg " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& ", $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " &  "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
												& ", $br" & str(to_integer(unsigned(slot(SCOND_END downto SCOND_INI))));
						when SUBCG_OP =>
							return f_pred(slot(30)) & " subcg " & "$r" & str(to_integer(unsigned(slot(REG_DEST_END downto REG_DEST_INI))))
												& ", $br" & str(to_integer(unsigned(slot(BDEST_END downto BDEST_INI))))
												& " = " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))))
												& ", " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
												& ", $br" & str(to_integer(unsigned(slot(SCOND_END downto SCOND_INI))));
						when PAR_ON =>
							return " par on";
							
						when PAR_OFF =>
							return " par off";
									
						when DIVS_OP  =>
									
						when IMM_OP =>
							if slot(CTRFL_REG_IMM_SELL) = '1'  then
								return f_pred(slot(30)) & " immr " & str(to_integer(unsigned(slot(L_IMM_END downto L_IMM_INI))));
							else
								return f_pred(slot(30)) & " imml " & str(to_integer(unsigned(slot(L_IMM_END downto L_IMM_INI))));
							end if;
						
									
						when others =>		
					
					end case;
	
					else
						-- select with immediates
						
						if (slot(27 downto 21) = BREAK_OP ) then 
									return f_pred(slot(30)) & " BREAK" ;
						else											
							case slot(26 downto 24) is
								when SLCT_OP =>
									return f_pred(slot(30)) & " slct " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))	
														& " = $br" & str(to_integer(unsigned(slot(SCOND_END downto SCOND_INI))))
														& ", $r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
											
								when SLCTF_OP => 
									return f_pred(slot(30)) & " slctf " & "$r" & str(to_integer(unsigned(slot(IDEST_END downto IDEST_INI))))	
														& " = $br" & str(to_integer(unsigned(slot(SCOND_END downto SCOND_INI))))
														& ", $r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & ", " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))));
								
								when others => 
																								
								end case;
							end if;
							
					end if;
			
			--memory instructions
			when "10" =>
					case slot(MEMI_END downto MEMI_INI) is
								
								
								when LDH_OP =>
									return f_pred(slot(30)) & " ldh " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
											& " = " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "]";
								
								
								when LDW_OP	=>
									return f_pred(slot(30)) & " ldw " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
											& " = " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "]";
																	
								when STW_OP => 
									return f_pred(slot(30)) & " stw " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &  
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "] = " &
											 "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));						
								
								when LDHU_OP => 
									return f_pred(slot(30)) & " ldhu " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
											& " = " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "]";								
									
								when LDB_OP => 
									return f_pred(slot(30)) & " ldb " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
											& " = " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "]";
								
								when LDBU_OP => 
									return f_pred(slot(30)) & " ldbu " & "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))))
											& " = " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "]";							
									
								when STH_OP => 
									return f_pred(slot(30)) & " sth " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &  
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "] = " &
											 "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
																	
								when STB_OP =>
									return f_pred(slot(30)) & " stb " & str(to_integer(unsigned(slot(IMMEDIATE_END downto IMMEDIATE_INI))))  &  
											"[$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI)))) & "] = " &
											 "$r" & str(to_integer(unsigned(slot(REG_SRC2_END downto REG_SRC2_INI))));
									
									
								
								when others =>			
						end case;
	

	
			
			--branch instructions
			when "11"	=>
				-- goto / call instruction
				if slot(CTRFL_SELC) = '0' then
							
					-- call must store pc
					if slot(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_CALL then
						if slot(CTRFL_REG_IMM_SELL) = '1' then
							return f_pred(slot(30)) & " call " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))));
		
						else
							return " icall " & str(to_integer(signed(slot(BTARG_END downto BTARG_INI))));
						
						end if;
								
					end if;
							
					-- goto only jumps
					if slot(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_GOTO then 
						if slot(CTRFL_REG_IMM_SELL) = '1' then
							return " goto " & "$r" & str(to_integer(unsigned(slot(REG_SRC1_END downto REG_SRC1_INI))));		
						else
							return " igoto " & str(to_integer(signed(slot(BTARG_END downto BTARG_INI))));	
						end if;
							
					end if;
					
					if slot(CTRFL_FUNC_END downto CTRFL_FUNC_INI) = CTRFL_PRED then
						return " preld " & str(to_integer(signed(slot(BTARG_END downto BTARG_INI))));	
					end if;
							
					-- predicated branch instruction
				else
					if slot(CTRFL_BR_SELC) = '0' then
						return " br $br" & str(to_integer(unsigned(slot(BCOND_END downto BCOND_INI)))) & ", " & str(to_integer(signed(slot(BTARG_END downto BTARG_INI))));						
					else
						return " brf $br" & str(to_integer(unsigned(slot(BCOND_END downto BCOND_INI)))) & ", " & str(to_integer(signed(slot(BTARG_END downto BTARG_INI))));						
					end if;
						
							
							
				end if;
		
			when others	=> 
				return "ins not found";
			
		end case;
				
		return " ";
				
	end decode;
	
	
	function to_std_logic_vector(s: string) return std_logic_vector is 
		variable slv: std_logic_vector(s'high-s'low downto 0);
		variable k: integer;
	begin
		k := s'high-s'low;
		for i in s'range loop
			slv(k) := to_std_logic(s(i));
			k := k - 1;
		end loop;
		
		return slv;
	end to_std_logic_vector; 
 
 
 
 
  function long_imm(slot, slot_imm : word_t) return string is
	variable imm : word_t;
  begin
		if slot(IMMEDIATE_END) = '1'  then
			--return str(to_integer(signed("11111111111111111111111" & slot(IMMEDIATE_END downto IMMEDIATE_INI))));	
			imm := "11111111111111111111111" & slot(IMMEDIATE_END downto IMMEDIATE_INI);	
		else
			imm := "00000000000000000000000" & slot(IMMEDIATE_END downto IMMEDIATE_INI);
		end if;

		if slot_imm(29 downto 23) = "0101010" then
			imm := slot_imm(L_IMM_END downto L_IMM_INI) & slot(IMMEDIATE_END downto IMMEDIATE_INI);
		end if;		
		
		return str(to_integer(signed(imm)));
		
  
  end long_imm;
 
end cpu_sim_package;


