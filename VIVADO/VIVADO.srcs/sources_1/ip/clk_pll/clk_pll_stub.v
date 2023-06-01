// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon May 22 20:31:29 2023
// Host        : LAPTOP-E2CVF122 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/hp/Desktop/SOC_CORTEX_M3/VIVADO/VIVADO.srcs/sources_1/ip/clk_pll/clk_pll_stub.v
// Design      : clk_pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a75tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_pll(clk0_out, clk1_out, clk2_out, refclk)
/* synthesis syn_black_box black_box_pad_pin="clk0_out,clk1_out,clk2_out,refclk" */;
  output clk0_out;
  output clk1_out;
  output clk2_out;
  input refclk;
endmodule
