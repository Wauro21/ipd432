-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
-- Date        : Sat Apr  9 22:04:56 2022
-- Host        : tarro running 64-bit elementary OS 6.1 Jólnir
-- Command     : write_vhdl -force -mode synth_stub
--               /mnt/shared/Linux/gdrive/usm/2021-s2/ipd432/ipd432_tarea_4/hls/vivado/coprocessor_pipelined/coprocessor_v2.gen/sources_1/ip/ila_op_mod/ila_op_mod_stub.vhdl
-- Design      : ila_op_mod
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_op_mod is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 0 to 0 )
  );

end ila_op_mod;

architecture stub of ila_op_mod is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[0:0],probe1[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2021.1";
begin
end;
