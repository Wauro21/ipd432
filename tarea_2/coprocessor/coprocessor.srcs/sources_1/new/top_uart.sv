`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/21/2021 02:15:54 AM
// Design Name:
// Module Name: top_uart
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


module top_uart(
  input CLK100MHZ,
  input CPU_RESETN,
  input UART_RXD_OUT,
  output UART_TXD_IN
  );

  uart_basic#(
      .CLK_FREQUENCY(100000000),
      .BAUD_RATE(115200)
  )
  UART(
  .clk(CLK100MHZ),
  .reset(CPU_RESETN),
  .rx(UART_RXD_OUT),
  .rx_data(),
  .rx_ready(),
  .tx(UART_TXD_IN),
  .tx_start,
  .tx_data(),
  .tx_busy()
  );


endmodule
