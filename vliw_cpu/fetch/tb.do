

vlib work
vcom ../cpu_typedef_package.vhdl ../cache/rom.vhd ../cache/sram_tag.vhd \
		../cache/sram.vhd ../cache/cache.vhd double_buffer.vhd ins_buffer.vhd fetch.vhd tb.vhd
vsim -t ns work.tb
view wave
add wave -radix binary /clk
add wave -radix binary /mem_clk
add wave -radix binary /reset
add wave -radix binary /stall


add wave -radix dec /address

#add wave -radix binary /mem_enable_out
#add wave -radix dec /mem_addr_out

#add wave  -radix hex /mem_data_in
#add wave  -radix hex /cache_1/mem_addr

add wave /cache_1/cache_state
add wave -radix dec /cache_1/index
add wave -radix dec /cache_1/tag


#add wave -radix dec /cache_1/mem_addr
#add wave -radix dec /cache_1/word_index
#add wave -radix dec /cache_1/mem_data_in
add wave -radix binary /cache_1/hit

add wave -radix dec /cache_1/pre_tag
add wave -radix dec /cache_1/pre_index



add wave -radix hex /cache_data_out

# add wave -radix hex /cache_1/sram_tag_data_out
# add wave -radix dec /cache_1/index
# add wave -radix dec /cache_1/base_mem_addr

#add wave /cache_1/sram_tag_wen

#add wave /cache_1/sram_tag_data_out

#add wave -radix dec /cache_1/latch_index

#add wave -radix hex /cache_1/sram_data_out

#add wave -radix hex /cache_1/sram_enable

#add wave -radix hex /cache_1/cache_line_data

# add wave -radix hex /cache_1/cache_line

add wave -radix dec /fetch_1/cache_word_offset

add wave /fetch_1/fetch_state

add wave /f_error

add wave /fetch_1/buffer_enable

add wave -radix hex /fetch_1/slot_0
add wave -radix hex /fetch_1/slot_1
add wave -radix hex /fetch_1/slot_2
add wave -radix hex /fetch_1/slot_3

#add wave -radix hex /fetch_1/ins_buffer_1/bundle

add wave /fetch_1/bundle_error

add wave -radix dec /fetch_1/issue_ins

add wave -radix hex /fetch_1/ins_buffer_1/nxt_slot
add wave -radix hex /fetch_1/ins_buffer_1/bundle_in

add wave -radix dec /fetch_1/cache_address

add wave -radix dec /cache_1/tag
add wave -radix dec /cache_1/sram_tag_data_out

run 4us

  
#view -undock -height 400 -width 400 wave
wave zoomfull
#write wave alu.ps

