# set QSYS_SIMDIR "./project/qsys/qsys/simulation/"

vlib work

vcom cpu_typedef_package.vhdl txt_util.vhdl ./altera-ip/rom_altera.vhd ./altera-ip/code_ram.vhd  ./cache/sram_tag.vhd ./altera-ip/cache/sram_tag_altera.vhd\
	./altera-ip/cache/sram.vhd ./cache/sram_v.vhd ./cache/cache.vhd ./fetch/cache_buffer.vhd ./altera-ip/fetch/slot_adder.vhd \
	./alu/alu_functions.vhd ./controller/opcodes.vhd ./controller/controller.vhd  ./controller/branch_controller.vhd ./controller/imm_controller.vhd\
	./fetch/ins_buffer.vhd ./fetch/fetch.vhd ./interlock/interlock.vhd \
	./altera-ip/alu/add_carry.vhd ./altera-ip/alu/mux_carry.vhd ./altera-ip/alu/compare_signed.vhd ./altera-ip/alu/compare_unsigned.vhd\
	./altera-ip/alu/forward_mux.vhd ./alu/salu.vhd ./alu/alu.vhd ./altera-ip/alu/mul_64_signed.vhd \
	./altera-ip/alu/mul_64_unsigned.vhd ./alu/mul_div_unit.vhd ./altera-ip/alu/div_signed.vhd ./altera-ip/alu/div_unsigned.vhd\
	./ld_st_unit/ld_st_unit.vhd ./altera-ip/ld_st/mem_addr.vhd ./ld_st_unit/tristate.vhd\
	./pred_reg_file/pred_reg_file.vhd ./altera-ip/pred_rf/mux_mem.vhd\
	./reg_file_lvt/reg_file_lvt.vhd ./altera-ip/rf/rd_mux.vhd ./altera-ip/rf/rd_for_mux.vhd  ./reg_file_lvt/lvt.vhd ./altera-ip/rf/sram_register.vhd\
	./ex_buffer/ex_buffer.vhd ./altera-ip/muxes/wb_mux.vhd ./wb_buffer/wb_buffer.vhd\
	./altera-ip/muxes/mux_0.vhd ./sram/sram_controller.vhd ./rom/rom_memory.vhd ./altera-ip/ld_st/sram_sim.vhd\
	./sdram/sdram_controller.vhd ./sdram/sim/mti_pkg.vhd ./sdram/sim/mt48lc8m16a2.vhd\
	./perf/perf_module.vhd\
	vliwcpu.vhd ssram_model.vhd cpu_sim_package.vhdl ./project/qsys/ tb.vhd

	
vsim -t ns -L work work.tb

run 600us

  


