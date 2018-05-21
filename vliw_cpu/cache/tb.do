

vlib work
vcom ../cpu_typedef_package.vhdl rom.vhd sram_tag.vhd sram_v.vhd sram.vhd cache.vhd tb.vhd
vsim -t ns work.tb
view wave
add wave -radix binary /clk
add wave -radix binary /mem_clk
add wave -radix binary /reset
add wave -radix binary /stall_out


add wave -radix dec /address

add wave -radix binary /mem_enable_out
add wave -radix dec /mem_addr_out

add wave  -radix hex /mem_data_in

#add wave -radix binary /aluop
#add wave -radix dec /result_lsb
#add wave -radix dec /result_msb

#add wave -radix hex /result_lsb
#add wave -radix hex /result_msb

#add wave -radix dec /alu_1/reg_teste

#add wave -radix dec /alu_1/x

add wave -radix binary /cache_1/cache_state

add wave -radix unsigned /cache_1/word_index
add wave -radix dec /cache_1/mem_data_in
add wave -radix binary /cache_1/hit

add wave -radix hex /cache_1/sram_tag_data_out
add wave -radix dec /cache_1/index
add wave -radix dec /cache_1/base_mem_addr

add wave /cache_1/sram_tag_wen

add wave /cache_1/sram_tag_data_out



add wave -radix hex /cache_1/sram_data_out

add wave -radix hex /cache_1/sram_enable

add wave -radix hex /cache_1/cache_line_data

add wave -radix hex /cache_1/cache_line

add wave -radix hex /cache_1/data_out

add wave  /cache_1/line_en
add wave -radix unsigned /cache_1/latch_index


run 4us

  
#view -undock -height 400 -width 400 wave
wave zoomfull
#write wave alu.ps