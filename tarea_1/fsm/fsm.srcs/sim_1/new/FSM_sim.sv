`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/30/2021 01:45:45 AM
// Design Name:
// Module Name: FSM_sim
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


module FSM_sim();
  logic clk, rst, PB;
  logic IncPulse_out;


  FSM test_FSM(
  .clk(clk),
  .rst(rst),
  .pressed_status(PB),
  .IncPulse_out(IncPulse_out)
  );

  always #1 clk=~clk;

  initial begin
    clk = 1'b0;
    rst = 1'b0;
    PB = 1'b0;
    #50
    rst = 1'b1;
    #30
    rst = 1'b0;
    #50
    PB = 1'b1;
    #10
    PB = 1'b0;
    #50
    PB = 1'b1;
    #500
    PB = 1'b0;
  end
endmodule
