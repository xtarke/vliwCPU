//lpm_compare CBX_SINGLE_OUTPUT_FILE="ON" LPM_REPRESENTATION="UNSIGNED" LPM_TYPE="LPM_COMPARE" LPM_WIDTH=8 aeb agb ageb alb aneb dataa datab
//VERSION_BEGIN 13.1 cbx_mgl 2013:10:17:04:34:36:SJ cbx_stratixii 2013:10:17:04:07:49:SJ cbx_util_mgl 2013:10:17:04:07:49:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2013 Altera Corporation
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, Altera MegaCore Function License 
//  Agreement, or other applicable license agreement, including, 
//  without limitation, that your use is for the sole purpose of 
//  programming logic devices manufactured by Altera and sold by 
//  Altera or its authorized distributors.  Please refer to the 
//  applicable agreement for further details.



//synthesis_resources = lpm_compare 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mg7qc
	( 
	aeb,
	agb,
	ageb,
	alb,
	aneb,
	dataa,
	datab) /* synthesis synthesis_clearbox=1 */;
	output   aeb;
	output   agb;
	output   ageb;
	output   alb;
	output   aneb;
	input   [7:0]  dataa;
	input   [7:0]  datab;

	wire  wire_mgl_prim1_aeb;
	wire  wire_mgl_prim1_agb;
	wire  wire_mgl_prim1_ageb;
	wire  wire_mgl_prim1_alb;
	wire  wire_mgl_prim1_aneb;

	lpm_compare   mgl_prim1
	( 
	.aeb(wire_mgl_prim1_aeb),
	.agb(wire_mgl_prim1_agb),
	.ageb(wire_mgl_prim1_ageb),
	.alb(wire_mgl_prim1_alb),
	.aneb(wire_mgl_prim1_aneb),
	.dataa(dataa),
	.datab(datab));
	defparam
		mgl_prim1.lpm_representation = "UNSIGNED",
		mgl_prim1.lpm_type = "LPM_COMPARE",
		mgl_prim1.lpm_width = 8;
	assign
		aeb = wire_mgl_prim1_aeb,
		agb = wire_mgl_prim1_agb,
		ageb = wire_mgl_prim1_ageb,
		alb = wire_mgl_prim1_alb,
		aneb = wire_mgl_prim1_aneb;
endmodule //mg7qc
//VALID FILE
