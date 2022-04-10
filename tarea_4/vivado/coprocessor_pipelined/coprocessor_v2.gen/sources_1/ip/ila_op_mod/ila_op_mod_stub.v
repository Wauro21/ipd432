// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
// Date        : Sat Apr  9 22:04:56 2022
// Host        : tarro running 64-bit elementary OS 6.1 Jólnir
// Command     : write_verilog -force -mode synth_stub
//               /mnt/shared/Linux/gdrive/usm/2021-s2/ipd432/ipd432_tarea_4/hls/vivado/coprocessor_pipelined/coprocessor_v2.gen/sources_1/ip/ila_op_mod/ila_op_mod_stub.v
// Design      : ila_op_mod
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2021.1" *)
module ila_op_mod(clk, probe0, probe1)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[0:0]" */;
  input clk;
  input [0:0]probe0;
  input [0:0]probe1;
endmodule
