`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 06:35:09 PM
// Design Name:
// Module Name: operations_block
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


module operations_block #(
  parameter CMD_WIDTH = 3
  )
  (
  input logic clk,
  input logic reset,
  input logic [CMD_WIDTH-1:0] cmd_dec,
  input logic bram_sel,
  input logic [7:0] A,
  input logic [7:0] B,
  input logic tx_busy,
  input logic read_flag,
  output logic next_read,
  output logic tx_start,
  output logic [7:0] tx_data
  );

  enum logic [CMD_WIDTH-1:0] {WRITE_CMD = 3'd1, READ_CMD = 3'd2, SUM_CMD = 3'd3, AVG_CMD = 3'd4, MAN_CMD = 3'd5, EUC_CMD = 3'd6} commands;

  logic done, sum_enable, avg_enable, tx_enable, sum_tx_enable, sum_done, avg_tx_enable, avg_done, man_enable, man_tx_enable, man_done, man_next_data, man_read_flag, euc_enable, euc_tx_enable, euc_done, euc_next_data, euc_read_flag;
  logic [7:0] sum_tx_data, avg_tx_data, man_tx_data, euc_tx_data;

  always_comb begin
    tx_enable = 1'b0;
    sum_enable = 1'b0;
    avg_enable = 1'b0;
    man_enable = 1'b0;
    man_read_flag = 1'b0;
    euc_enable = 1'b0;
    euc_read_flag = 1'b0;
    next_read = 1'b0;
    tx_data = 'd0;
    case (cmd_dec)
      READ_CMD: begin
        tx_enable = read_flag;
        next_read = done;
        if(bram_sel) tx_data = B;
        else tx_data = A;
      end

      SUM_CMD: begin
        sum_enable = read_flag;
        tx_enable = sum_tx_enable;
        next_read = sum_done;
        tx_data = sum_tx_data;
      end

      AVG_CMD: begin
        avg_enable = read_flag;
        tx_enable  = avg_tx_enable;
        next_read = avg_done;
        tx_data = avg_tx_data;
      end

      MAN_CMD: begin
        man_enable = 1'b1;
        man_read_flag = read_flag;
        tx_enable = man_tx_enable;
        next_read = man_next_data;
        tx_data = man_tx_data;
      end

      EUC_CMD: begin
        euc_enable = 1'b1;
        euc_read_flag = read_flag;
        tx_enable = euc_tx_enable;
        next_read = euc_next_data;
        tx_data = euc_tx_data;
      end


    endcase
  end


  // UART- TX - Control
  tx_control TX_CONTROL(
    .clk(clk),
    .reset(reset),
    .enable(tx_enable),
    .tx_busy(tx_busy),
    .tx_start(tx_start),
    .done(done)
  );

  // SUM_CTRL_SEND
  sum_wrapper #(
  .MEMORY_DEPTH(8)
  )
  SUM_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(sum_enable),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(sum_tx_enable),
    .op_done(sum_done),
    .tx_data(sum_tx_data)
  );

  // AVG_CTRL_SEND
  avg_wrapper #(
  .MEMORY_DEPTH(8)
  )
  AVG_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(avg_enable),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(avg_tx_enable),
    .op_done(avg_done),
    .tx_data(avg_tx_data)
  );

  man_wrapper #(
  .MEMORY_DEPTH(8)
  )
  MAN_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(man_enable),
    .read_flag(man_read_flag),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(man_tx_enable),
    .op_done(man_done),
    .tx_data(man_tx_data),
    .next_data(man_next_data)
  );

  euc_wrapper #(
  .MEMORY_DEPTH(8)
  )
  EUC_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(euc_enable),
    .read_flag(euc_read_flag),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(euc_tx_enable),
    .op_done(euc_done),
    .tx_data(euc_tx_data),
    .next_data(euc_next_data)
  );
endmodule
