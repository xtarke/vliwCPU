

vlib work
vcom ../cpu_typedef_package.vhdl rd_mux.vhd sram_register.vhd lvt.vhd reg_file_lvt.vhd rd_for_mux.vhd tb.vhd
	  
vsim -t ns work.tb
view wave
add wave -radix binary /clk
add wave /reg_file_1/neg_clock
add wave -radix binary /reset

add wave /reset_2

add wave port0_w_en
add wave port1_w_en
add wave port2_w_en
add wave port3_w_en

add wave -radix unsigned port0_a_rd_addr
add wave -radix unsigned port0_b_rd_addr
add wave -radix unsigned port1_a_rd_addr
add wave -radix unsigned port1_b_rd_addr

add wave /reg_file_1/port0_w_en


add wave -radix unsigned /reg_file_1/port0_w_addr
add wave -radix unsigned /reg_file_1/port1_w_addr


#add wave -radix hex /reg_file_1/ram_0
#add wave -radix hex /reg_file_1/ram_1
#add wave -radix hex /reg_file_1/ram_2
#add wave -radix hex /reg_file_1/ram_3


add wave -radix unsigned port0_a_rd
add wave -radix unsigned port0_b_rd

add wave -radix unsigned port1_a_rd
add wave -radix unsigned port1_b_rd

add wave /reg_file_1/lvt_1/port0_a_rd
add wave /reg_file_1/lvt_1/port0_b_rd

add wave -radix unsigned /reg_file_1/p0_b_for_sel


add wave -radix unsigned /reg_file_1/port0_b_rd_addr
add wave -radix unsigned /reg_file_1/port0_b_rd_addr_reg

add wave -radix unsigned /reg_file_1/ram_0_0_b
add wave -radix unsigned /reg_file_1/ram_1_0_b
add wave -radix unsigned /reg_file_1/ram_2_0_b
add wave -radix unsigned /reg_file_1/ram_3_0_b

add wave -radix unsigned /reg_file_1/ram_0_0_a
add wave -radix unsigned /reg_file_1/ram_1_0_a
add wave -radix unsigned /reg_file_1/ram_2_0_a
add wave -radix unsigned /reg_file_1/ram_3_0_a

add wave /reg_file_1/lvt_1/registers

run 300ns

  
#view -undock -height 400 -width 400 wave
wave zoomfull
#write wave teste.ps

