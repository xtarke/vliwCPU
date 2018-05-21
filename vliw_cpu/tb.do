# set QSYS_SIMDIR "./project/qsys/qsys/simulation/"

vlib work

vcom cpu_typedef_package.vhdl ./controller/opcodes.vhd txt_util.vhdl cpu_sim_package.vhdl ./altera-ip/rom_altera.vhd ./altera-ip/code_ram.vhd  ./cache/sram_tag.vhd ./altera-ip/cache/sram_tag_altera.vhd\
	./altera-ip/cache/sram.vhd ./cache/sram_v.vhd ./cache/cache.vhd ./fetch/cache_buffer.vhd ./altera-ip/fetch/slot_adder.vhd \
	./alu/alu_functions.vhd ./controller/controller.vhd  ./altera-ip/branch_ctl/pc_adder.vhd ./controller/branch_controller.vhd ./controller/imm_controller.vhd\
	./fetch/ins_buffer.vhd ./fetch/fetch.vhd ./interlock/interlock.vhd \
	./altera-ip/alu/add_carry.vhd ./altera-ip/alu/mux_carry.vhd ./altera-ip/alu/compare_signed.vhd ./altera-ip/alu/compare_unsigned.vhd\
	./altera-ip/alu/forward_mux.vhd ./alu/salu.vhd ./alu/alu.vhd ./altera-ip/alu/mul_64_signed.vhd \
	./altera-ip/alu/mul_64_unsigned.vhd ./alu/mul_div_unit.vhd ./altera-ip/alu/div_signed.vhd ./altera-ip/alu/div_unsigned.vhd\
	./ld_st_unit/ld_st_unit.vhd ./altera-ip/ld_st/mem_addr.vhd ./altera-ip/dp_sp.vhd ./ld_st_unit/tristate.vhd\
	./pred_reg_file/pred_reg_file.vhd ./altera-ip/pred_rf/mux_mem.vhd\
	./reg_file_lvt/reg_file_lvt.vhd ./altera-ip/rf/rd_mux.vhd ./altera-ip/rf/rd_for_mux.vhd  ./reg_file_lvt/lvt.vhd ./altera-ip/rf/sram_register.vhd\
	./ex_buffer/ex_buffer.vhd ./altera-ip/muxes/wb_mux.vhd ./wb_buffer/wb_buffer.vhd\
	./altera-ip/muxes/mux_0.vhd ./sram/sram_controller.vhd ./rom/rom_memory.vhd ./altera-ip/ld_st/sram_sim.vhd\
	./sdram/sdram_controller.vhd ./sdram/sim/mti_pkg.vhd ./sdram/sim/mt48lc8m16a2.vhd\
	./perf/perf_module.vhd\
	./vga/char_mem.vhd  ./vga/font_rom.vhd  ./vga/hw_image_generator.vhd  ./vga/shift_reg.vhd  ./vga/vga_controller.vhd vliwcpu.vhd ssram_model.vhd tb.vhd

#do project/qsys/qsys/simulation/mentor/msim_setup.tcl
#dev_com
#com

#set StdArithNoWarnings 1
#libset NumericStdNoWarnings 1
	
# vsim -t ns -L work -L rst_controller -L sdram_ctrl -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiv_hssi_ver -L cycloneiv_pcie_hip_ver -L cycloneiv_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneiv_hssi -L cycloneiv_pcie_hip -L cycloneiv work.tb
vsim -t ns -L work work.tb
view wave
add wave -radix binary -label clk  /clk
add wave -radix binary -label mclk /mem_clk
add wave -radix binary -label reset /reset
add wave -radix binary -label cstall /cpu/stall
add wave -label cache_data_rdy /cpu/cache_1/cache_data_rdy
add wave -radix unsigned -label fetch_resync /cpu/fetch_1/cache_buffer_1/fetch_resync
add wave -radix unsigned -label caddr /cpu/address
add wave -radix unsigned -label pc /cpu/pc
add wave -radix unsigned -label preld_miss /cpu/fetch_1/cache_buffer_1/preld_miss


#add wave -radix unsigned -label current_cache_line /cpu/fetch_1/cache_buffer_1/current_cache_line
#add wave -radix unsigned -label exec_cache_line /cpu/fetch_1/cache_buffer_1/exec_cache_line

#add wave -radix unsigned -label resync_en /cpu/fetch_1/cache_buffer_1/resync_en


#add wave -radix unsigned /cpu/instructions
add wave -radix unsigned /cpu/ops
add wave -radix unsigned /cpu/alu_ops
add wave -radix unsigned /cpu/special_ops
add wave -radix unsigned /cpu/mem_ops
add wave -radix unsigned /cpu/branche_ops
#add wave -radix unsigned /cpu/n_ctrl_flow
#add wave -radix unsigned i_address

#add wave -radix unsigned /cpu/cache_1/base_mem_addr_reg

#add wave -radix hex /cpu/cache_1/cache_line
#add wave -label cache_sram_en -radix unsigned /cpu/cache_1/sram_enable
#add wave -label sram_tag_data_out -radix unsigned /cpu/cache_1/sram_tag_data_out
#add wave -label tag -radix unsigned /cpu/cache_1/tag
#add wave -label tag_reg -radix unsigned /cpu/cache_1/tag_reg
#add wave -label sram_tag_wen -radix unsigned /cpu/cache_1/sram_tag_wen
#add wave -label base_mem_addr_reg -radix unsigned /cpu/cache_1/base_mem_addr_reg
#add wave -label mem_addr_en -radix unsigned /cpu/cache_1/mem_addr_en
#add wave -label base_mem_addr -radix unsigned /cpu/cache_1/base_mem_addr


add wave /cpu/cache_1/cache_state
add wave /cpu/cache_1/slow_mem_state


add wave -radix unsigned /cpu/cache_1/word_index
add wave -radix unsigned /cpu/cache_1/addr_add
#add wave -radix unsigned /cpu/cache_1/mem_enable_out
#add wave -radix unsigned /cpu/cache_1/mem_addr_out
#add wave -radix unsigned /cpu/cache_1/base_mem_addr_reg
#add wave -radix unsigned /cpu/cache_1/aborted
#add wave -radix unsigned /cpu/cache_1/mem_addr_en
#add wave -radix unsigned /cpu/cache_1/base_mem_addr
#add wave -radix unsigned /cpu/cache_1/latch_index

add wave -radix hex /cpu/cache_1/cache_line_data
#add wave -radix hex /cpu/cache_1/sram_tag_data_out
#add wave -radix hex /cpu/cache_1/v_bit_out
#add wave /cpu/cache_1/sram_vbit/ram_block



# Pipeline stages
add wave -radix hex -label cache /cpu/cache_line 
add wave -radix hex -label B /cpu/fetch_1/cache_bundle
add wave -radix hex -label BD /cpu/slot_0
add wave -radix unsigned -label OD /cpu/ctrl_0.dest_reg
add wave -radix unsigned -label E /cpu/ex_ctrl_0.dest_reg
add wave -radix unsigned -label WB /cpu/port0_w_addr

add wave -radix unsigned -label preld_en_addr /cpu/fetch_1/cache_buffer_1/preld_en_addr


#add wave -radix unsigned -label preld_reg /cpu/fetch_1/cache_buffer_1/preld_reg
#add wave -radix unsigned -label preload_addr_reg /cpu/fetch_1/cache_buffer_1/preload_addr_reg


#add wave /cpu/cache_1/mem_start

#add wave -radix hex /cpu/cache_1/line_en
#add wave -radix hex /cpu/cache_1/latch_index
#add wave -radix hex /cpu/cache_1/cache_line_data


add wave -label c_abort /cpu/cache_abort

add wave -label branch /cpu/fetch_1/branch_in


#add wave /cpu/branch_controller_1/pred_value
#add wave -radix unsigned /cpu/slot_ctrl_0.scond

#add wave /cpu/branch_controller_1/branch_ins
#add wave /cpu/branch_controller_1/br_true
#add wave /cpu/branch_controller_1/br_false



add wave -radix unsigned -label branch_addr /cpu/branch_addr
add wave -radix unsigned -label branch_en /cpu/branch_enable
add wave -radix unsigned -label pred_value /cpu/branch_controller_1/pred_value

add wave -radix unsigned -label goto_addr /cpu/goto_addr
add wave -radix unsigned -label goto_en /cpu/goto_enable

add wave -label branch_ins /cpu/branch_controller_1/branch_ins
add wave -label goto_addr /cpu/branch_controller_1/goto_addr

#add wave -label pc_adder_en /cpu/branch_controller_1/pc_adder_clk_en

add wave -label jump_reg_en /cpu/branch_controller_1/jump_reg_en
add wave -label r63 -radix unsigned /cpu/branch_controller_1/reg_addr

add wave -label preld_addr -radix unsigned /cpu/branch_controller_1/preload_addr
add wave -label preld_addr_sel -radix unsigned /cpu/branch_controller_1/preload_addr_sel
# add wave -label pc_adder_pred_clk_en -radix unsigned /cpu/branch_controller_1/pc_adder_pred_clk_en
add wave -label preld_en -radix unsigned /cpu/branch_controller_1/preld_en

add wave -label pre_jr /cpu/fetch_1/pre_jr
add wave -radix unsigned -label decode_en /cpu/fetch_1/cache_buffer_1/decode_en

add wave -radix unsigned -label b_address_reg /cpu/fetch_1/cache_buffer_1/b_address_reg
add wave -radix unsigned -label b_address_reg_en /cpu/fetch_1/cache_buffer_1/b_address_reg_en
add wave -radix binary -label addr_mux_sel /cpu/fetch_1/cache_buffer_1/addr_mux_sel
add wave -radix unsigned -label b_address_reg_internal /cpu/fetch_1/cache_buffer_1/b_address_reg_internal
add wave -radix unsigned -label decode_ld /cpu/fetch_1/cache_buffer_1/decode_ld
add wave -radix unsigned -label recover_addr /cpu/fetch_1/cache_buffer_1/recover_addr
add wave -radix unsigned -label preld_set_cache_line /cpu/fetch_1/cache_buffer_1/preld_set_cache_line
add wave -radix unsigned -label current_cache_line /cpu/fetch_1/cache_buffer_1/current_cache_line
add wave -radix unsigned -label exec_cache_line /cpu/fetch_1/cache_buffer_1/exec_cache_line

#add wave -radix unsigned -label addr_in /cpu/fetch_1/ins_buffer_1/addr_in
#add wave -radix unsigned -label preld /cpu/fetch_1/ins_buffer_1/preld
#add wave -radix unsigned -label next_address /cpu/fetch_1/ins_buffer_1/next_address
#add wave -radix unsigned -label recover /cpu/fetch_1/ins_buffer_1/recover



add wave -radix hex  -label S0 /cpu/slot_0
add wave -radix hex  -label S1 /cpu/slot_1
add wave -radix hex  -label S2 /cpu/slot_2
add wave -radix hex  -label S3 /cpu/slot_3

add wave /cpu/delay_dep
add wave /cpu/dep_stall
add wave /cpu/fetch_1/mem_busy
add wave /cpu/fetch_ext_stall
 
#add wave -radix unsigned /cpu/jump_address
 
#add wave  -radix unsigned /cpu/slot_ctrl_0

#add wave /cpu/ctrl_0
#add wave /cpu/ctrl_1
#add wave /cpu/ctrl_2
#add wave /cpu/ctrl_3

#add wave /cpu/fetch_1/bundle_error
add wave -label cache_data_enable /cpu/fetch_1/cache_buffer_1/cache_data_enable
#add wave -radix unsigned /cpu/fetch_1/cache_buffer_1/internal_address
#add wave /cpu/fetch_1/cache_buffer_1/buffer_full
add wave -label b1_mask /cpu/fetch_1/cache_buffer_1/b1_mask
add wave -label slots /cpu/fetch_1/cache_buffer_1/slots
add wave -label decode_reset /cpu/fetch_1/cache_buffer_1/decode_reset

#add wave /cpu/fetch_1/cache_buffer_1/exec_slot_mask
add wave -label cache_addr_en /cpu/fetch_1/cache_buffer_1/cache_addr_enable
#add wave /cpu/fetch_1/cache_buffer_1/addr_mux_sel
add wave -label f_state /cpu/fetch_1/cache_buffer_1/cache_addr_state
add wave -label f_state_reg /cpu/fetch_1/cache_buffer_1/cache_addr_state_reg
add wave -label bundle_sel /cpu/fetch_1/cache_buffer_1/bundle_sel
add wave -label dep_stall_reg /cpu/fetch_1/cache_buffer_1/dep_stall_reg
add wave /cpu/fetch_1/cache_buffer_1/dep_ex_stall_en
add wave /cpu/fetch_1/cache_buffer_1/dep_ex_stall
#add wave /cpu/fetch_1/cache_buffer_1/reg_pc_enable
#add wave -radix unsigned /cpu/fetch_1/cache_buffer_1/next_pc_reg_int
#add wave -radix unsigned /cpu/fetch_1/cache_buffer_1/next_pc
add wave -radix unsigned /cpu/fetch_1/cache_buffer_1/branch_bundle_sel
#add wave -radix unsigned /cpu/fetch_1/cache_buffer_1/current_cache_line
#add wave -radix unsigned /cpu/fetch_1/cache_buffer_1/branch_cache_line
#add wave -radix unsigned /cpu/fetch_1/cache_buffer_1/addr_diff	

#add wave -radix unsigned /cpu/branch_controller_1/addr_sel
#add wave -radix unsigned /cpu/branch_controller_1/reg_addr_reg

add wave -radix unsigned -label port0_a_rd /cpu/port0_a_rd
add wave -radix unsigned -label port0_b_rd /cpu/port0_b_rd

add wave -radix unsigned -label port1_a_rd /cpu/port1_a_rd
add wave -radix unsigned -label port1_b_rd /cpu/port1_b_rd

add wave -radix unsigned -label P0rda_addr /cpu/reg_file_1/port0_a_rd_addr
add wave -radix unsigned -label P0rdb_addr /cpu/reg_file_1/port0_b_rd_addr

add wave -radix unsigned -label P1rda_addr /cpu/reg_file_1/port1_a_rd_addr
add wave -radix unsigned -label P1rdb_addr /cpu/reg_file_1/port1_b_rd_addr

#add wave -radix unsigned /cpu/reg_file_1/port0_a_rd_addr
#add wave -radix unsigned /cpu/reg_file_1/port0_b_rd_addr

#add wave -radix unsigned /cpu/reg_file_1/lvt_out_0_a
#add wave -radix unsigned /cpu/reg_file_1/lvt_out_0_b

#add wave -radix unsigned /cpu/reg_file_1/port1_a_rd
#add wave -radix unsigned /cpu/reg_file_1/port1_b_rd


add wave -radix unsigned /cpu/ex_reg_src1_0
add wave -radix unsigned /cpu/ex_reg_src2_0
add wave -radix unsigned /cpu/alu_1000/src_2_sel_0

#add wave -radix unsigned /cpu/ex_imm_0
#add wave -radix unsigned /cpu/ex_reg_src1_0
#add wave -radix unsigned /cpu/ex_reg_src2_0

#add wave /cpu/fetch_1/cache_buffer_1/decode_en
#add wave /cpu/fetch_1/cache_buffer_1/msb_bundle
#add wave /cpu/fetch_1/cache_buffer_1/addr_mux_sel




#add wave /cpu/cache_abort 
#add wave -radix unsigned /cpu/fetch_1/ins_buffer_1/error
 
add wave -radix unsigned -label alu_0_func /cpu/alu_1000/func_0
#add wave -radix unsigned /cpu/alu_1000/func_1

#add wave -radix unsigned /cpu/ex_ctrl_0
#add wave -radix unsigned /cpu/ex_ctrl_1

#add wave -radix unsigned /cpu/alu_1000/src1_in_0
#add wave -radix unsigned /cpu/alu_1000/src2_in_0

add wave -radix unsigned -label alu_0 /cpu/alu_0_val
# add wave -radix unsigned -label alu_1_val /cpu/alu_1_val
#add wave -radix unsigned /cpu/alu_2_val
#add wave -radix unsigned /cpu/alu_3_val

#add wave /cpu/mul_div/mul_div_state


#add wave /cpu/mul_div/ex_stall
#add wave /cpu/mul_div/dep_stall

#add wave /cpu/mul_div/rd_ctrl_opc_0
#add wave  -radix unsigned /cpu/mul_div/wb_addr_reg_0
#add wave  -radix unsigned /cpu/mul_div/rd_ctrl_src_0_a
#add wave  -radix unsigned /cpu/mul_div/wb_reg_w_en_0
#add wave  -radix unsigned /cpu/mul_div/wb_alu_func_0

add wave -radix unsigned /cpu/mul_div/div_0_clk_en
add wave -radix unsigned -label den /cpu/mul_div/src1_in_0_reg
add wave -radix unsigned -label numer /cpu/mul_div/src2_in_0_reg
		
		
add wave -radix unsigned /cpu/mul_div/quou_0
add wave -radix unsigned /cpu/mul_div/remu_0

#add wave -radix unsigned /cpu/mul_div/quo_0
#add wave -radix unsigned /cpu/mul_div/rem_0

#add wave -radix unsigned /cpu/mul_div/val_0
#add wave -radix unsigned /cpu/mul_div/val_1

#add wave -radix unsigned /cpu/alu_2/src1_in
#add wave -radix unsigned /cpu/alu_2/src2_in

#add wave -radix unsigned /cpu/alu_1000/add_carry_val




add wave -radix hex /cpu/alu_1000/alu_0_src_1
add wave -radix hex /cpu/alu_1000/mux_src2_0_val

add wave -radix unsigned -label src1_in_1 /cpu/alu_1000/src1_in_1
add wave -radix unsigned -label src2_in_1 /cpu/alu_1000/src2_in_1

add wave -radix unsigned -label s1 /cpu/alu_1000/calc_0/s1
add wave -radix unsigned -label s2 /cpu/alu_1000/calc_0/s2

add wave -radix unsigned -label s3 /cpu/alu_1000/calc_0/s3
add wave -radix unsigned -label s4 /cpu/alu_1000/calc_0/s4

add wave -radix unsigned -label s5 /cpu/alu_1000/calc_0/s5
add wave -radix unsigned -label s6 /cpu/alu_1000/calc_0/s6

add wave -radix unsigned -label carry_forw_0 /cpu/alu_1000/carry_forw_0
add wave -radix dec -label alu_0_src_1 /cpu/alu_1000/alu_0_src_1
add wave -radix dec -label mux_src2_0_val /cpu/alu_1000/mux_src2_0_val
add wave -radix unsigned -label carry_out_0 /cpu/alu_1000/carry_out_0
add wave -radix dec -label add_carry_val_0 /cpu/alu_1000/add_carry_val_0

add wave -radix unsigned -label alu_0_sel_1 /cpu/alu_1000/alu_0_sel_1
add wave -radix unsigned -label alu_0_sel_2 /cpu/alu_1000/alu_0_sel_2

add wave -radix unsigned /cpu/alu_1000/wb_addr_reg_0
add wave -radix unsigned /cpu/alu_1000/rd_ctrl_src_0_a
add wave -radix unsigned /cpu/alu_1000/wb_reg_w_en_0
add wave -radix unsigned /cpu/alu_1000/branch_en
add wave -radix unsigned /cpu/alu_1000/ex_stall

add wave -radix unsigned /cpu/alu_1000/wb_reg_w_en_1
add wave -radix unsigned /cpu/alu_1000/rd_ctrl_src_0_a
add wave -radix unsigned /cpu/alu_1000/wb_addr_reg_1


add wave -radix unsigned /cpu/alu_1000/func_0

#add wave -radix unsigned /cpu/alu_1000/alu_2_sel_1
#add wave -radix unsigned /cpu/alu_1000/alu_val_2.alu_val
#add wave -radix unsigned /cpu/alu_1000/alu_2_src_1
#add wave -radix unsigned /cpu/alu_1000/mux_src2_2_val

#add wave -radix unsigned /cpu/alu_1000/wb_addr_reg_1
#add wave -radix unsigned /cpu/alu_1000/rd_ctrl_src_1_a
#add wave -radix unsigned /cpu/alu_1000/wb_reg_w_en_1


#add wave -radix unsigned /cpu/alu_0/src1_in
#add wave -radix unsigned /cpu/alu_0/src2_in

#add wave -radix unsigned /cpu/alu_1/src1_in
#add wave -radix unsigned /cpu/alu_1/src2_in

#dd wave -radix unsigned /cpu/alu_2/src1_in
#dd wave -radix unsigned /cpu/alu_2/src2_in

#dd wave -radix unsigned /cpu/alu_3/src1_in
#dd wave -radix unsigned /cpu/alu_3/src2_in

add wave -radix unsigned /cpu/port0_w_addr
add wave -radix unsigned /cpu/port1_w_addr
add wave -radix unsigned /cpu/port2_w_addr
add wave -radix unsigned /cpu/port3_w_addr

add wave -radix unsigned /cpu/reg_data_0
add wave -radix unsigned /cpu/reg_data_1
add wave -radix unsigned /cpu/reg_data_2
add wave -radix unsigned /cpu/reg_data_3

add wave -radix unsigned /cpu/port0_w_en
add wave -radix unsigned /cpu/port1_w_en
add wave -radix unsigned /cpu/port2_w_en
add wave -radix unsigned /cpu/port3_w_en

add wave -label ctrl_0_par /cpu/ex_buffer_0/ctrl_in_0.par_on
add wave -label par_on_off /cpu/ex_buffer_0/par_on_off
add wave -label ctrl_0_fpred /cpu/ex_buffer_0/ctrl_in_0.f_pred
add wave -label f_pred /cpu/ex_buffer_0/f_pred;

#add wave -radix unsigned /cpu/ctrl_0.src_1_reg
#add wave -radix unsigned /cpu/ctrl_0.src_2_reg
#add wave -radix unsigned /cpu/ctrl_1.src_1_reg
#add wave -radix unsigned /cpu/ctrl_1.src_2_reg
#add wave -radix unsigned /cpu/ctrl_2.src_1_reg
#add wave -radix unsigned /cpu/ctrl_2.src_2_reg
#add wave -radix unsigned /cpu/ctrl_3.src_1_reg
#add wave -radix unsigned /cpu/ctrl_3.src_2_reg
#add wave -radix unsigned /cpu/ctrl_0.dest_reg
#add wave /cpu/ctrl_0.reg_w_en

#add wave -radix unsigned /cpu/ex_ctrl_2
#add wave -radix unsigned /cpu/ex_ctrl_1.dest_reg
#add wave -radix unsigned /cpu/ex_ctrl_2.dest_reg
#add wave -radix unsigned /cpu/ex_ctrl_3.dest_reg
#add wave -radix unsigned /cpu/ex_ctrl_0.src_1_reg
#add wave -radix unsigned /cpu/ex_ctrl_0.src_2_reg
#add wave /cpu/ex_ctrl_0.reg_w_en

#add wave /cpu/pred_port0_a_rd
#add wave /cpu/pred_port1_a_rd
#add wave /cpu/pred_port2_a_rd
#add wave /cpu/pred_port3_a_rd


#add wave -radix unsigned /cpu/rom_addr
#add wave -radix hex /cpu/rom_data
#add wave -radix hex /cpu/rom_data_reg


#add wave -radix unsigned /cpu/ld_st_unit_0/ssram_data	

#add wave -radix unsigned ssram_1/data

#add wave -radix unsigned /cpu/reg_data_2
#add wave -radix unsigned /cpu/reg_data_3


#add wave /cpu/alu_1000/ex_stall

#add wave /cpu/alu_1000/wb_mem_rd

add wave /cpu/halt
add wave /cpu/f_error
add wave /cpu/m_error

#add wave /cpu/slot_1_bf
#add wave /cpu/ctrl_1.branch_en

#add wave /cpu/pred_port1_a_rd

#add wave /cpu/pred_port0_w_en

#add wave /cpu/alu_0_val.carry_cmp

#add wave -radix unsigned /cpu/pred_port0_w_addr


#add wave -radix unsigned /cpu/slot_ctrl_0.scond
#add wave -radix unsigned /cpu/slot_ctrl_1.scond
#add wave -radix unsigned /cpu/slot_ctrl_2.scond
#add wave -radix unsigned /cpu/slot_ctrl_3.scond

#add wave -radix unsigned /cpu/ex_forward_sel_1_src1
#add wave -radix unsigned /cpu/ex_forward_sel_1_src2

#add wave -radix unsigned /cpu/slot_ctrl_0.scond
#add wave /cpu/ctrl_0.branch_en
#add wave /cpu/slot_0_bf
#add wave /cpu/slot_0_bt
#add wave /cpu/pred_port0_a_rd
#add wave /cpu/branch_enable

add wave /cpu/pred_port0_w_addr
add wave /cpu/pred_port0_w_en
add wave /cpu/alu_0_val.carry_cmp

add wave /cpu/pred_port1_w_addr
add wave /cpu/pred_port1_w_en
add wave /cpu/alu_1_val.carry_cmp

#add wave /cpu/ld_st_unit_0/inst_acc_state
#add wave /cpu/ld_st_unit_0/ins_mem_acc
#add wave /cpu/mem_stall

add wave -radix hex /cpu/memory_data

add wave -radix hex /cpu/ld_st_unit_0/s0_rd_reg
add wave -radix hex /cpu/ld_st_unit_0/s1_rd_reg

add wave -radix hex /cpu/ld_st_unit_0/regw0

add wave -radix hex /cpu/ld_st_unit_0/wb_wait
add wave -radix hex /cpu/ld_st_unit_0/d_chipselect
add wave /cpu/ld_st_unit_0/ld_st_state
add wave -radix hex /cpu/ld_st_unit_0/addr0
add wave -radix hex /cpu/ld_st_unit_0/addr1
add wave -radix hex /cpu/ld_st_unit_0/byte_sel_0
add wave -radix hex /cpu/ld_st_unit_0/d_waitrequest
add wave -radix hex /cpu/ld_st_unit_0/d_readdata
add wave -radix unsigned /cpu/ld_st_unit_0/d_write
add wave  /cpu/ld_st_unit_0/d_chipselect

add wave -radix hex -label src_1_mem_0_to_0 /cpu/ld_st_unit_0/src_1_mem_0_to_0
add wave -radix hex -label src_2_mem_0_to_0 /cpu/ld_st_unit_0/src_2_mem_0_to_0
add wave -radix hex -label src_1_mem_0_to_1 /cpu/ld_st_unit_0/src_1_mem_0_to_1
add wave -radix hex -label src_2_mem_0_to_1 /cpu/ld_st_unit_0/src_2_mem_0_to_1
add wave -radix hex -label src_1_mem_1_to_1 /cpu/ld_st_unit_0/src_1_mem_1_to_1
add wave -radix hex -label src_2_mem_1_to_1 /cpu/ld_st_unit_0/src_2_mem_1_to_1

add wave -radix hex -label mem_to_mem_rst_0 /cpu/ld_st_unit_0/mem_to_mem_rst_0
add wave -radix hex -label mem_to_mem_rst_1 /cpu/ld_st_unit_0/mem_to_mem_rst_1

add wave -radix unsigned /cpu/ld_st_unit_0/reg_mem_data_en

add wave -radix unsigned /cpu/ld_st_unit_0/src_1_sel_0
add wave -radix unsigned /cpu/ld_st_unit_0/src_2_sel_0

add wave -radix unsigned /cpu/ld_st_unit_0/src_1_sel_1
add wave -radix unsigned /cpu/ld_st_unit_0/src_2_sel_1



add wave -radix unsigned /cpu/ld_st_unit_0/slot_0_mem_wr
add wave -radix unsigned /cpu/ld_st_unit_0/slot_1_mem_wr
add wave -radix unsigned /cpu/ld_st_unit_0/slot_0_mem_rd
add wave -radix unsigned /cpu/ld_st_unit_0/slot_1_mem_rd


add wave -radix unsigned /cpu/ld_st_unit_0/d_writedata

#add wave -radix unsigned /cpu/ld_st_unit_0/wb_addr_reg_0
#add wave -radix unsigned /cpu/ld_st_unit_0/rd_ctrl_src_1_a
#add wave -radix unsigned /cpu/ld_st_unit_0/wb_reg_w_en_0
#add wave -radix unsigned /cpu/ld_st_unit_0/rd_ctrl_src_1_b

add wave -radix unsigned /cpu/ld_st_unit_0/src1_0_val
add wave -radix unsigned /cpu/ld_st_unit_0/src2_0_val

add wave -radix unsigned /cpu/ld_st_unit_0/src1_1_val
add wave -radix unsigned /cpu/ld_st_unit_0/src2_1_val



add wave -radix unsigned /cpu/sp_a_rd
add wave -radix unsigned /cpu/sp_b_rd


add wave -radix unsigned /cpu/sp_a_wr
add wave -radix unsigned /cpu/sp_b_wr

add wave -radix unsigned /cpu/ld_st_unit_0/sp_a_rd_reg
add wave -radix unsigned /cpu/ld_st_unit_0/sp_b_rd_reg

add wave -radix unsigned /cpu/sp_a_data
add wave -radix unsigned /cpu/sp_b_data

add wave -radix hex -label sp_a_byteen_sig /cpu/ld_st_unit_0/sp_a_byteen_sig
add wave -radix hex -label sp_a_data_mask /cpu/ld_st_unit_0/sp_a_data_mask

add wave -radix unsigned /cpu/sp_a_dataw
add wave -radix unsigned /cpu/sp_b_dataw

add wave -radix unsigned /cpu/sp_a_addr
add wave -radix unsigned /cpu/sp_b_addr

add wave -radix hex -label timer_rd /cpu/ld_st_unit_0/timer_rd
add wave -radix unsigned -label timer /cpu/ld_st_unit_0/timer_val


#add wave -radix unsigned -label src_2_mem_0_to_0 /cpu/ld_st_unit_0/src_2_mem_0_to_0

#add wave -radix unsigned -label rd_ctrl_src_0_b /cpu/ld_st_unit_0/rd_ctrl_src_0_b

#add wave -radix unsigned -label rd_ctrl_mem_rd_0 /cpu/ld_st_unit_0/rd_ctrl_mem_wr_0


#add wave -radix unsigned -label ctrl_0 /cpu/ctrl_0
#add wave -radix unsigned -label ex_ctrl_0 /cpu/ex_ctrl_0


#add wave -radix unsigned /cpu/ld_st_unit_0/chip_sel_en
#add wave -radix unsigned /cpu/ld_st_unit_0/chip_sel
#add wave -radix unsigned /cpu/d_address
#add wave -radix unsigned /cpu/d_write
#add wave -radix unsigned /cpu/d_readdata
#add wave -radix unsigned /cpu/d_writedata
# add wave -radix unsigned /sram_controller_0/mem_state
# add wave -radix unsigned /sram_controller_0/waitrequest
# add wave -radix unsigned /sram_controller_0/chipselect
# add wave -radix unsigned /sram_controller_0/byteenable
# add wave -radix unsigned /sram_controller_0/d_write
# add wave -radix unsigned /sram_controller_0/byteenable_reg
# add wave -radix unsigned /sram_controller_0/in_reg_en
# add wave -radix unsigned /sram_controller_0/address(26)




#add wave /rom_data/mem_state
#add wave  -radix hex /rom_data/rom_data
#add wave  -radix hex /rom_data/readdata



#add wave -radix unsigned FS_ADDR
#add wave -radix unsigned FS_DQ

#add wave -radix unsigned /sram_controller_0/ADSC_N
#add wave -radix unsigned /sram_controller_0/ADSP_N
#add wave -radix unsigned /sram_controller_0/ADV_N
#add wave -radix unsigned /sram_controller_0/BE
#add wave -radix unsigned /sram_controller_0/GW_N
#add wave -radix unsigned /sram_controller_0/OE_N
#add wave -radix unsigned /sram_controller_0/WE_N
#add wave -radix unsigned /sram_controller_0/CE_0_N
#add wave -radix unsigned /sram_controller_0/CE_1_N


add wave -radix unsigned /cpu/mul_div/mul_div_state
add wave -label mul_div_0_sel_reg -radix unsigned /cpu/mul_div/mul_div_0_sel_reg
add wave -label mul_div_1_sel_reg -radix unsigned /cpu/mul_div/mul_div_1_sel_reg

add wave -label mul_reg_en -radix unsigned /cpu/mul_div/reg_enable
add wave -label mul_div_0_sel -radix unsigned /cpu/mul_div/ctrl_0.mul_div_sel
add wave -label mul_div_1_sel -radix unsigned /cpu/mul_div/ctrl_1.mul_div_sel

 

add wave -radix dec /cpu/mul_div/src1_in_0_reg
add wave -radix dec /cpu/mul_div/src2_in_0_reg


add wave -radix dec -label quo_0 /cpu/mul_div/quo_0
add wave -radix dec -label rem_0 /cpu/mul_div/rem_0

add wave -radix dec -label val_0 /cpu/mul_div/val_0
add wave -radix dec -label val_1 /cpu/mul_div/val_1

add wave -radix dec -label mul_0_val /cpu/mul_div/mul_0_val
add wave -radix dec -label mul_1_val /cpu/mul_div/mul_0_val



#add wave -radix unsigned /cpu/mul_div/src1_in_0_reg
#add wave -radix unsigned /cpu/mul_div/src2_in_0_reg

#add wave -radix unsigned /cpu/mul_div/src1_0_val
#add wave -radix unsigned /cpu/mul_div/src2_0_val

add wave -radix unsigned -label mul_wb_addr_reg_0 /cpu/mul_div/wb_addr_reg_0
add wave -radix unsigned -label mul_rd_ctrl_src_0_b /cpu/mul_div/rd_ctrl_src_0_b
add wave -radix unsigned -label rd_ctrl_0_mul_div /cpu/mul_div/rd_ctrl_0_mul_div

add wave -radix unsigned -label src_1_mul_0_to_0 /cpu/mul_div/src_1_mul_0_to_0
add wave -radix unsigned -label src_2_mul_0_to_0 /cpu/mul_div/src_2_mul_0_to_0

add wave -radix unsigned -label src_1_mul_1_to_0 /cpu/mul_div/src_1_mul_1_to_0
add wave -radix unsigned -label src_2_mul_1_to_0 /cpu/mul_div/src_2_mul_1_to_0


add wave -radix unsigned -label src_2_sel_0 /cpu/mul_div/src_2_sel_0

#add wave -radix unsigned /cpu/mul_div/src1_in_1_reg
#add wave -radix unsigned /cpu/mul_div/src2_in_1_reg

#add wave -radix unsigned /cpu/mul_div/src1_1_val
#add wave -radix unsigned /cpu/mul_div/src2_1_val

#add wave -radix unsigned /cpu/mul_div_0
#add wave -radix unsigned /cpu/mul_div_1

#add wave -radix unsigned /cpu/mul_div/val_0
#add wave -radix unsigned /cpu/mul_div/val_1

#add wave -radix unsigned /cpu/mul_div/mul_0_val
#add wave -radix unsigned /cpu/mul_div/mul_1_val

#add wave -radix unsigned /cpu/mul_div/func_1_reg

#add wave -radix unsigned /cpu/mul_div/out_enable



#add wave -radix unsigned /cpu/mul_div/div_0_clk_en
#add wave -radix unsigned /cpu/mul_div/quo_0
#add wave -radix unsigned /cpu/mul_div/rem_0


add wave -radix hex sram_write_data
add wave -radix hex sram_read_data

add wave -radix hex sdram_data


add wave clk

#add wave d_waitrequest_sdram
#add wave d_read
#add wave d_write

#add wave /sdram_controller_0/mem_state
#add wave /sdram_controller_0/byteenable


#add wave -radix unsigned /sdram_controller_0/wait_cycles

#add wave -radix unsigned /sdram_controller_0/DRAM_ADDR

#add wave -radix unsigned /sdram_controller_0/DRAM_CS_N
#add wave -radix unsigned /sdram_controller_0/DRAM_CKE
#add wave -radix unsigned /sdram_controller_0/DRAM_RAS_N
#add wave -radix unsigned /sdram_controller_0/DRAM_CAS_N    
#add wave -radix unsigned /sdram_controller_0/DRAM_WE_N    
#add wave -radix unsigned /sdram_controller_0/DRAM_DQ

#add wave -radix unsigned /sdram_controller_0/row_addr
#add wave -radix unsigned /sdram_controller_0/col_addr
#add wave -radix unsigned /sdram_controller_0/bank_addr


add wave /VGA_HS
add wave /VGA_VS

add wave -label img_we /image_1/char_we
add wave -radix unsigned -label vga_addr /image_1/char_write_addr
add wave -radix unsigned -label vga_val /image_1/char_write_value



#run 10us
#run 135us
run 8000us

  
#view -undock -height 400 -width 400 wave
wave zoomfull
#write wave teste.ps
cat stats.txt


