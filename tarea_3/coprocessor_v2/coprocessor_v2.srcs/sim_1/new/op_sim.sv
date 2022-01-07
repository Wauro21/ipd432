`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/07/2022 12:27:21 AM
// Design Name:
// Module Name: op_sim
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module op_sim();
  logic clk, enable, bram_sel;
  enum logic [2:0]{WRITE = 3'd1, READ = 3'd2, SUM = 3'd3, AVG = 3'd4, MAN = 3'd5} commands;
  localparam  INPUTS = 1024;
  localparam  INPUT_WIDTH = 8;
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] A;
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] B;
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] buffer_a;
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] buffer_b;
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] out;
  logic [2:0] cmd;
  op_module #(
    .N_INPUTS(INPUTS),
    .I_WIDTH(INPUT_WIDTH)
  )
  OP_MOD
  (
    .cmd(cmd),
    .enable(enable),
    .bram_sel(bram_sel),
    .A(A),
    .B(B),
    .out(out)
  );

  genvar i;
  generate
    for (i = 0;  i < 1024 ; i++) begin
      assign buffer_a[i] = 'd100;
      assign buffer_b[i] = 'd50;
    end
  endgenerate
  always #1 clk = ~clk;
  initial begin
    clk = 0;
    A = 'd0;
    B = 'd0;
    cmd = READ;
    bram_sel = 1'b1;
    enable = 'd0;
    #20
    A = buffer_a;
    B = buffer_b;
    #10
    enable = 1'b1;
    #20
    bram_sel = 1'b0;
    #20
    cmd = SUM;
    #20
    cmd = AVG;
    #20
    cmd = MAN;
  end
endmodule
