--------------------------------------------------------------------------------
--  VLIW-RT CPU - Pipeline inter-stage buffer
--------------------------------------------------------------------------------
--
-- Copyright (c) 2016, Renan Augusto Starke <xtarke@gmail.com>
-- 
-- Departamento de Automação e Sistemas - DAS (Automation and Systems Department)
-- Universidade Federal de Santa Catarina - UFSC (Federal University of Santa Catarina)
-- Florianópolis, Brasil (Brazil)
--
-- This file is part of VLIW-RT CPU.

-- VLIW-RT CPU is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- VLIW-RT CPU is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with VLIW-RT CPU.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use work.cpu_typedef_package.all;

entity ex_buffer is
port (
	clk    : in std_logic;	
	reset  : in std_logic;
	
	ex_stall : in std_logic;
	
	ctrl_in_0     : in t_ctrl;
	ctrl_in_1   	 : in t_ctrl;
	ctrl_in_2     : in t_ctrl;
	ctrl_in_3     : in t_ctrl;
   
	pc						 : in pc_t;
	
	reg_src1_in_0		 : in word_t;
	reg_src2_in_0		 : in word_t;
	
	reg_src1_in_1		 : in word_t;
	reg_src2_in_1		 : in word_t;
	
	reg_src1_in_2		 : in word_t;
	reg_src2_in_2		 : in word_t;
	
	reg_src1_in_3		 : in word_t;
	reg_src2_in_3		 : in word_t;
	
	imm_in_0	 : in word_t;
	imm_in_1	 : in word_t;
	imm_in_2	 : in word_t;
	imm_in_3	 : in word_t;	
	
	f_pred	: in std_logic;
	
	scond_in_0			: in std_logic;
	scond_in_1			: in std_logic;
	scond_in_2			: in std_logic;
	scond_in_3			: in std_logic;
			
	ctrl_out_0 			: out t_ctrl;
	reg_src1_out_0		: out word_t;
	reg_src2_out_0		: out word_t;
	scond_out_0			: out std_logic;
	imm_out_0  			: out word_t;
	
	ctrl_out_1 				: out t_ctrl;
	reg_src1_out_1	: out word_t;
	reg_src2_out_1	: out word_t;
	scond_out_1			: out std_logic;
	imm_out_1  			: out word_t;
	
	ctrl_out_2 				: out t_ctrl;
	reg_src1_out_2	: out word_t;
	reg_src2_out_2	: out word_t;
	scond_out_2			: out std_logic;
	imm_out_2  			: out word_t;
	
	ctrl_out_3 				: out t_ctrl;
	reg_src1_out_3	: out word_t;
	reg_src2_out_3	: out word_t;
	scond_out_3			: out std_logic;
	imm_out_3  			: out word_t
	
	);
end ex_buffer;


architecture rtl of ex_buffer is

	signal ctrl_in_0_reg  : t_ctrl;
	signal ctrl_in_1_reg  : t_ctrl;
	signal ctrl_in_2_reg  : t_ctrl;
	signal ctrl_in_3_reg  : t_ctrl; 
	
	signal pc_reg			 : word_t;
	
	signal reg_src1_in_0_reg 		: word_t;
	signal reg_src2_in_0_reg		: word_t;
	
	signal reg_src1_in_1_reg		 : word_t;
	signal reg_src2_in_1_reg		 : word_t;
	
	signal reg_src1_in_2_reg		 : word_t;
	signal reg_src2_in_2_reg		 : word_t;
	
	signal reg_src1_in_3_reg		 : word_t;
	signal reg_src2_in_3_reg		 : word_t;
	
	signal imm_in_0_reg	 : word_t;
	signal imm_in_1_reg	 : word_t;
	signal imm_in_2_reg	 :  word_t;
	signal imm_in_3_reg	 :  word_t;
	
	signal scond_in_0_reg			: std_logic;
	signal scond_in_1_reg			: std_logic;
	signal scond_in_2_reg			: std_logic;
	signal scond_in_3_reg			: std_logic;
	
	signal stalled : std_logic;	
	signal par_on_off : std_logic;
	
begin

	process (clk, reset,  stalled, par_on_off,
							ctrl_in_0, reg_src1_in_0, reg_src2_in_0, imm_in_0, scond_in_0,
							ctrl_in_1, reg_src1_in_1, reg_src2_in_1, imm_in_1, scond_in_1,
							ctrl_in_2, reg_src1_in_2, reg_src2_in_2, imm_in_2, scond_in_2,
							ctrl_in_3, reg_src1_in_3, reg_src2_in_3, imm_in_3, scond_in_3)
	begin
		if reset = '1' then
			ctrl_out_0.alu_func	<= (ctrl_out_0.alu_func'range => '0');
			ctrl_out_0.dest_reg	<= (ctrl_out_0.dest_reg'range => '0');
			ctrl_out_0.branch_en	<= '0';
			ctrl_out_0.reg_w_en 	<= '0';
			ctrl_out_0.alu_mux	<= '0';			
			ctrl_out_0.pred_reg_w_en	<= '0';
			ctrl_out_0.b_dest				<= (ctrl_out_0.b_dest'range => '0');
			
			
			reg_src1_out_0   <= (reg_src1_out_0'range => '0');
			reg_src2_out_0   <= (reg_src2_out_0'range => '0');
			imm_out_0		  	<= (imm_out_0'range => '0');
			scond_out_0			<= '0';
			
			ctrl_out_1.alu_func	<= (ctrl_out_1.alu_func'range => '0');
			ctrl_out_1.dest_reg	<= (ctrl_out_1.dest_reg'range => '0');
			ctrl_out_1.branch_en 	<= '0';
			ctrl_out_1.reg_w_en 		<= '0';
			ctrl_out_1.alu_mux		<= '0';
			ctrl_out_1.pred_reg_w_en	<= '0';
			ctrl_out_1.b_dest				<= (ctrl_out_1.b_dest'range => '0');		
			
			
			reg_src1_out_1   <= (reg_src1_out_1'range => '0');
			reg_src2_out_1   <= (reg_src2_out_1'range => '0');
			imm_out_1			  	<= (imm_out_1'range => '0');
			scond_out_1			<= '0';
			
			ctrl_out_2.alu_func		<= (ctrl_out_2.alu_func'range => '0');
			ctrl_out_2.dest_reg		<= (ctrl_out_2.dest_reg'range => '0');
			ctrl_out_2.branch_en 	<= '0';
			ctrl_out_2.reg_w_en 		<= '0';
			ctrl_out_2.alu_mux		<= '0';
			ctrl_out_2.pred_reg_w_en	<= '0';
			ctrl_out_2.b_dest				<= (ctrl_out_2.b_dest'range => '0');
			
			reg_src1_out_2   	<= (reg_src1_out_2'range => '0');
			reg_src2_out_2   	<= (reg_src2_out_2'range => '0');
			imm_out_2			<= (imm_out_2'range => '0');
			scond_out_2			<= '0';
			
			ctrl_out_3.alu_func	<= (ctrl_out_2.alu_func'range => '0');
			ctrl_out_3.dest_reg	<= (ctrl_out_2.dest_reg'range => '0');
			ctrl_out_3.branch_en 		<= '0';
			ctrl_out_3.reg_w_en 			<= '0';
			ctrl_out_3.alu_mux			<= '0';
			ctrl_out_3.pred_reg_w_en	<= '0';
			ctrl_out_3.b_dest				<= (ctrl_out_3.b_dest'range => '0');
			
			reg_src1_out_3   	<= (reg_src1_out_3'range => '0');
			reg_src2_out_3   	<= (reg_src2_out_3'range => '0');
			imm_out_3		  	<= (imm_out_3'range => '0');
			scond_out_3			<= '0';
			
			par_on_off <= '0';
			
		else
			if rising_edge(clk) then
				
				if ex_stall = '0' then					
	
						ctrl_out_0    	<= ctrl_in_0;
						ctrl_out_1    	<= ctrl_in_1;
						ctrl_out_2    	<= ctrl_in_2;
						ctrl_out_3    	<= ctrl_in_3;
						scond_out_0	 <= scond_in_0;
						scond_out_1	 <= scond_in_1;
						scond_out_2	 <= scond_in_2;
						scond_out_3	 <= scond_in_3;
						
						-- turn on full predication in paralization mode
						if ctrl_in_0.par_on = '1' or ctrl_in_1.par_on = '1' or ctrl_in_2.par_on = '1' or ctrl_in_3.par_on = '1'then
							par_on_off <= '1';
						end if;
--						
--						-- turn off full predication in paralization mode
						if ctrl_in_0.par_off = '1' or ctrl_in_1.par_off = '1' or ctrl_in_2.par_off = '1' or ctrl_in_3.par_off = '1'then
							par_on_off <= '0';
						end if;
												
						-- when writing to link register
						if ctrl_in_0.dest_reg = "111111" and ctrl_in_0.branch_en = '1' then
							reg_src1_out_0 <= "000000000" & pc;			
							reg_src2_out_0 <= (reg_src2_out_0'range => '0');
						else
							reg_src1_out_0 <= reg_src1_in_0;
							reg_src2_out_0 <= reg_src2_in_0;
						end if;
						
						-- full predication for all slots						
						-- normal mode, only check if f_pred is true
						if par_on_off = '0' then						
							if ctrl_in_0.f_pred = '1' then
								if f_pred = '0' then
										ctrl_out_0.reg_w_en <= '0';
										ctrl_out_0.alu_func <= (ctrl_out_0.alu_func'range => '0');
										ctrl_out_0.mul_div <= '0';
										ctrl_out_0.mem_wr	<= '0';
										ctrl_out_0.mem_rd	<= '0';
								end if;					
							end if;
							
							if ctrl_in_1.f_pred = '1' then
								if f_pred = '0' then
										ctrl_out_1.reg_w_en <= '0';
										ctrl_out_1.alu_func <= (ctrl_out_1.alu_func'range => '0');
										ctrl_out_1.mul_div <= '0';
										ctrl_out_1.mem_wr	<= '0';
										ctrl_out_1.mem_rd	<= '0';
								end if;					
							end if;
							
							if ctrl_in_2.f_pred = '1' then
								if f_pred = '0' then
										ctrl_out_2.reg_w_en <= '0';
										ctrl_out_2.alu_func <= (ctrl_out_2.alu_func'range => '0');
										ctrl_out_2.mul_div <= '0';
										ctrl_out_2.mem_wr	<= '0';
										ctrl_out_2.mem_rd	<= '0';
								end if;					
							end if;
							
							if ctrl_in_3.f_pred = '1' then
								if f_pred = '0' then
										ctrl_out_3.reg_w_en <= '0';
										ctrl_out_3.alu_func <= (ctrl_out_3.alu_func'range => '0');
										ctrl_out_3.mul_div <= '0';
										ctrl_out_3.mem_wr	<= '0';
										ctrl_out_3.mem_rd	<= '0';
								end if;					
							end if;
						-- enhanced mode, check if f_pred is true and false acording to bit 30
						else
							if ((ctrl_in_0.f_pred xor f_pred) = '1') then
								ctrl_out_0.reg_w_en <= '0';
								ctrl_out_0.alu_func <= (ctrl_out_0.alu_func'range => '0');
								ctrl_out_0.mul_div <= '0';
								ctrl_out_0.mem_wr	<= '0';
								ctrl_out_0.mem_rd	<= '0';										
							end if;
							
							if ((ctrl_in_1.f_pred xor f_pred) = '1') then
								ctrl_out_1.reg_w_en <= '0';
								ctrl_out_1.alu_func <= (ctrl_out_0.alu_func'range => '0');
								ctrl_out_1.mul_div <= '0';
								ctrl_out_1.mem_wr	<= '0';
								ctrl_out_1.mem_rd	<= '0';										
							end if;
							
							if ((ctrl_in_2.f_pred xor f_pred) = '1') then
								ctrl_out_2.reg_w_en <= '0';
								ctrl_out_2.alu_func <= (ctrl_out_0.alu_func'range => '0');
								ctrl_out_2.mul_div <= '0';
								ctrl_out_2.mem_wr	<= '0';
								ctrl_out_2.mem_rd	<= '0';										
							end if;
							
							if ((ctrl_in_3.f_pred xor f_pred) = '1') then
								ctrl_out_3.reg_w_en <= '0';
								ctrl_out_3.alu_func <= (ctrl_out_0.alu_func'range => '0');
								ctrl_out_3.mul_div <= '0';
								ctrl_out_3.mem_wr	<= '0';
								ctrl_out_3.mem_rd	<= '0';										
							end if;						
						end if;
											
						reg_src1_out_1 <= reg_src1_in_1;
						reg_src2_out_1 <= reg_src2_in_1;
						
						reg_src1_out_2 <= reg_src1_in_2;
						reg_src2_out_2 <= reg_src2_in_2;
						
						reg_src1_out_3 <= reg_src1_in_3;
						reg_src2_out_3 <= reg_src2_in_3;
						
						imm_out_0 <= imm_in_0;		
						imm_out_1 <= imm_in_1;		
						imm_out_2 <= imm_in_2;		
						imm_out_3 <= imm_in_3;					
					
					end if;
					
			end if;	
		end if;	
	end process;
end rtl;
