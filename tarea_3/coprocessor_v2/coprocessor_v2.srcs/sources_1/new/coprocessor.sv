`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/07/2021 06:45:21 PM
// Design Name:
// Module Name: coprocessor
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


module coprocessor #(
    parameter CMD_WIDTH = 3,
    parameter MEMORY_DEPTH = 8,
    parameter ADDRESS_WIDTH = 3,
    parameter WAIT_READ_CYCLES = 3,
	parameter N_INPUTS = 1024
  )
  (
    input logic clk,
    input logic reset,
    input logic cmd_flag,
    input logic [CMD_WIDTH-1:0] cmd_dec,
    input logic bram_sel,
    input logic [7:0] rx_data,
    input logic rx_ready,
    input logic tx_busy,
    input logic [MEMORY_DEPTH - 1:0] [7:0] read_data_a,
    input logic [MEMORY_DEPTH - 1:0] [7:0] read_data_b,
    output logic write_enable_a,
    output logic [7:0] write_data_a,
    output logic write_enable_b,
    output logic [7:0] write_data_b,
    output logic tx_start,
    output logic core_lock,
    output logic [MEMORY_DEPTH - 1:0] [7:0] out_data,
    output logic out_write,
    output logic out_shift,
    output logic [6:0] CAT,
    output logic [7:0] AN
  );
  // Operation definition
  enum logic [CMD_WIDTH-1:0] {WRITE_CMD = 3'd1, READ_CMD = 3'd2, SUM_CMD = 3'd3, AVG_CMD = 3'd4, MAN_CMD = 3'd5, EUC_CMD = 3'd6} commands;

  // Main FSM
  // typedef enum logic [2:0] {IDLE, OP_SEL, WRITE,READ, OP, INVALID} state;
  // state current_state, next_state;
  // Outputs
  logic write_enable, write_done, read_block_enable, read_done, tx_done, tx_enable;
  logic op_done, op_fsm_enable, op_fsm_done, op_enable;

  assign out_write = op_done;

  fsm_main_ctrl MAIN_CTRL (
    .clk(clk),
    .reset(~reset),
    .cmd_flag(cmd_flag),
    .op_fsm_done(op_fsm_done),
    .tx_done(tx_done),
    .core_lock(core_lock),
    .op_fsm_enable(op_fsm_enable),
    .tx_enable(tx_enable)
  );

  fsm_op_ctrl #(
	  .CMD_WIDTH(CMD_WIDTH)
	)
  OP_CTRL
	(
    .clk(clk),
    .reset(~reset),
    .enable(op_fsm_enable),
    .op_done(op_done),
    .write_done(write_done),
    .cmd(cmd_dec),
    .write_enable(write_enable),
    .op_enable(op_enable),
    .module_done(op_fsm_done)
  );

  //------------------------------------------------------------------[OP LOGIC]
  logic read_flag, next_read;

  op_module #(
    .N_INPUTS(MEMORY_DEPTH),
    .CMD_WIDTH(CMD_WIDTH)
  )
  OP_MOD
  (
  	.clk(clk),
  	.reset(~reset),
    .cmd(cmd),
    .enable(op_enable), // may change
    .bram_sel(bram_sel),
    .A(read_data_a),
    .B(read_data_b),
    .out(out_data),
  	.op_done(op_done)
  );

  // -------------------------------------------------------------------[Memory]
  // Memory logic
  logic common_write_enable;

  // Memory write control
  write_module #(
    .N_VALUES(N_INPUTS)
  )
  COMMON_WRITE_CONTROL
  (
    .clk(clk),
    .reset(~reset),
    .enable(write_enable),
    .rx_ready(rx_ready),
	.bram_sel(bram_sel),
	.write_enable_a(write_enable_a),
	.write_enable_b(write_enable_b),
	.done(write_done)
  );

  tx_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  (
    .clk(clk),
    .reset(~reset),
    .enable(tx_enable),
    .tx_busy(tx_busy),
    .tx_start(tx_start),
    .shift(out_shift),
    .done(tx_done)
  );

  // Memory Write block selector

  always_comb begin
    if(bram_sel) begin
      // Enable block B
      write_data_b = rx_data;
      // Disable block A
      write_data_a = 8'd0;
    end
    else begin
      //Enable block A
      write_data_a = rx_data;
      // Disable block B
      write_data_b = 8'd0;
    end
  end

endmodule
