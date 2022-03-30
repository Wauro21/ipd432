############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
############################################################
open_project eucDis
set_top eucDis
add_files eucMod.h
add_files eucMod.cpp
add_files -tb testbench.cpp -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb ../goldenreference.csv -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
open_solution "solution1" -flow_target vivado
set_part {xc7a100t-csg324-1}
create_clock -period 10 -name default
config_export -format ip_catalog -rtl verilog -version 1.0.0
source "./eucDis/solution1/directives.tcl"
csim_design -clean
csynth_design
cosim_design
export_design -rtl verilog -format ip_catalog -version "1.0.0"
