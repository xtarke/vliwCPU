# set QSYS_SIMDIR "./project/qsys/qsys/simulation/"

vlib work

vcom cpu_typedef_package.vhdl txt_util.vhdl ./altera-ip/rom_altera.vhd ./altera-ip/code_ram.vhd  ./cache/sram_tag.vhd ./altera-ip/cache/sram_tag_altera.vhd\
	./altera-ip/cache/sram.vhd ./cache/sram_v.vhd ./cache/cache.vhd ./fetch/cache_buffer.vhd ./altera-ip/fetch/slot_adder.vhd \
	./alu/alu_functions.vhd ./controller/opcodes.vhd ./controller/controller.vhd  ./controller/branch_controller.vhd ./controller/imm_controller.vhd\
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
	./vga/char_mem.vhd  ./vga/font_rom.vhd  ./vga/hw_image_generator.vhd  ./vga/shift_reg.vhd  ./vga/vga_controller.vhd\
	vliwcpu.vhd ssram_model.vhd cpu_sim_package.vhdl ./project/qsys/ tb.vhd

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
add wave -radix unsigned -label caddr /cpu/address
add wave -radix unsigned -label pc /cpu/pc

#add wave -radix unsigned /cpu/instructions
#add wave -radix unsigned /cpu/alu_ops
#add wave -radix unsigned /cpu/special_ops
#add wave -radix unsigned /cpu/mem_ops
#add wave -radix unsigned /cpu/branche_ops
#add wave -radix unsigned /cpu/n_ctrl_flow
#add wave -radix unsigned i_address

#add wave -radix unsigned /cpu/cache_1/base_mem_addr_reg

#add wave -radix hex /cpu/cache_1/cache_line
#add wave -radix unsigned /cpu/cache_1/sram_enable
#add wave -radix unsigned /cpu/cache_1/sram_tag_data_out
#add wave -radix unsigned /cpu/cache_1/tag
#add wave -radix unsigned /cpu/cache_1/sram_tag_wen
#add wave -radix unsigned /cpu/cache_1/base_mem_addr_reg
#add wave -radix unsigned /cpu/cache_1/mem_addr_en
#add wave -radix unsigned /cpu/cache_1/base_mem_addr

#add wave -radix hex /cpu/cache_1/cache_line_data
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

add wave -label f_state /cpu/fetch_1/cache_buffer_1/cache_addr_state


add wave -label branch /cpu/fetch_1/branch_in


add wave -radix hex -label S0  /cpu/slot_0
add wave -radix hex -label S1 /cpu/slot_1
add wave -radix hex -label S2 /cpu/slot_2
add wave -radix hex -label S3 /cpu/slot_3


add wave -label F_en /cpu/fetch_1/cache_buffer_1/decode_en

add wave -radix binary -label clk  /clk
add wave -radix binary /reset

add wave row
add wave column
add wave disp_ena



#

add wave -label pixel_clk /pixel_clk 

add wave -label img_ctl_state /image_1/img_ctl_state
add wave -label char_read_addr -radix unsigned /image_1/char_read_addr
add wave -label char_read_value -radix hex /image_1/char_read_value

add wave -label char_read_value_shifted -radix hex /image_1/char_read_value_shifted

add wave -label f_addr_offset -radix hex /image_1/f_addr_offset

add wave -radix bin -label f_data /image_1/f_data
add wave -radix hex -label addr /image_1/f_addr


add wave -radix hex -label ld_st_state /cpu/ld_st_unit_0/ld_st_state
add wave -radix hex -label d_writedata_reg /cpu/ld_st_unit_0/d_writedata_reg

add wave -radix hex -label write_data /d_writedata
add wave -radix hex -label write /d_write
add wave -radix hex -label address /d_address
add wave -radix bin -label chipselect /d_chipselect
		

		
add wave -label char_write_addr -radix hex /image_1/char_mem_1/char_write_addr
add wave -label char_we -radix hex /image_1/char_mem_1/char_we
add wave -label char_write_value -radix hex /image_1/char_mem_1/char_write_value






# run 5us
run 80us

  
#view -undock -height 400 -width 400 wave
wave zoomfull
#write wave teste.ps



