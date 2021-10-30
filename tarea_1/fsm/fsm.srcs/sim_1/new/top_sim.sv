`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/30/2021 02:37:58 AM
// Design Name:
// Module Name: top_sim
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


module top_sim();
  logic clk, resetN, PushButton, IncPulse_out;

  T1_design1 test(
  .clk(clk),
  .resetN(resetN),
  .PushButton(PushButton),
  .IncPulse_out(IncPulse_out)
  );

  always #1 clk = ~clk;
  initial begin
    clk = 1'b0;
    resetN = 1'b1;
    PushButton = 1'b0;
    #60 resetN = 1'b0;
    #30 resetN = 1'b1;
    #50 PushButton = 1'b1;
    #100 PushButton = 1'b0;
    #50 PushButton = 1'b1;
    #3  PushButton = 1'b0;
    #20 PushButton = 1'b1;
    #80 PushButton = 1'b0;
  end
endmodule
