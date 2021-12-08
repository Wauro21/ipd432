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
  parameter ADDRESS_WIDTH = 3
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
    input logic [7:0] read_data_a,
    input logic [7:0] read_data_b,
    output logic write_enable_a,
    output logic [7:0] write_data_a,
    output logic [ADDRESS_WIDTH-1:0] write_address_a,
    output logic write_enable_b,
    output logic [7:0] write_data_b,
    output logic [ADDRESS_WIDTH-1:0] write_address_b,
    output logic [ADDRESS_WIDTH-1:0] read_address_a,
    output logic [ADDRESS_WIDTH-1:0] read_address_b,
    output logic tx_start,
    output logic core_lock,
    output logic [7:0] tx_data
  );
  // Operation definition
  enum logic [CMD_WIDTH-1:0] {WRITE_CMD = 3'd1, READ_CMD = 3'd2, SUM_CMD = 3'd3, AVG_CMD = 3'd4, MAN_CMD = 3'd5, EUC_CMD = 3'd6} commands;


  // Main FSM
  typedef enum logic [2:0] {IDLE, OP_SEL, WRITE,READ,OP, INVALID} state;
  state current_state, next_state;
  // Outputs
  logic write_block_enable, write_done, read_block_enable, read_done;


  always_ff @ (posedge clk) begin
    if(~reset) current_state <= IDLE;
    else current_state <= next_state;
  end


  always_comb begin
    next_state = IDLE;
    write_block_enable = 1'b0;
    read_block_enable = 1'b0;
    core_lock = 1'b0;
    case (current_state)

      IDLE: if(cmd_flag) next_state = OP_SEL;

      OP_SEL: begin
        next_state = INVALID;
        case (cmd_dec)
          WRITE_CMD: next_state = WRITE;
          READ_CMD: next_state = READ;
        endcase
      end

      WRITE: begin
        write_block_enable = 1'b1;
        core_lock = 1'b1;
        if(write_done) next_state = IDLE;
        else next_state = WRITE;
      end

      READ: begin
        read_block_enable = 1'b1;
        core_lock = 1'b1;
        if(read_done) next_state = IDLE;
        else next_state = READ;
      end

      INVALID: begin
        core_lock = 1'b1;
        next_state = IDLE;
      end

    endcase
  end

  // -------------------------------------------------------------------[Memory]
  // Memory logic
  logic [ADDRESS_WIDTH-1:0] write_common_address, read_common_address;
  logic common_write_enable;
  logic [MEMORY_DEPTH-1:0] read_common_tx_data;

  // Memory full read control
  read_tx #(
  .MEMORY_DEPTH(MEMORY_DEPTH),
  .ADDRESS_WIDTH(ADDRESS_WIDTH),
  .WAIT_READ_CYCLES(3)
  )
  FULL_READ
  (
    .clk(clk),
    .reset(~reset),
    .enable(read_block_enable),
    .tx_busy(tx_busy),
    .read_address(read_common_address),
    .done(read_done),
    .tx_start(tx_start)
  );

  // Memory full read block selector
  always_comb begin
    if(bram_sel) begin
      read_address_b = read_common_address;
      read_address_a = 'd0;
      read_common_tx_data = read_data_b;
    end
    else begin
      read_address_a = read_common_address;
      read_address_b = 'd0;
      read_common_tx_data = read_data_a;
    end
  end

  // Memory write control
  write_control #(
  .MEMORY_DEPTH(MEMORY_DEPTH),
  .ADDRESS_WIDTH(ADDRESS_WIDTH)
  ) COMMON_WRITE_CONTROL
  (
    .clk(clk),
    .reset(~reset),
    .enable(write_block_enable),
    .rx_ready(rx_ready),
    .write_enable(common_write_enable),
    .done(write_done),
    .address(write_common_address)
  );

  // Memory Write block selector

  always_comb begin
    if(bram_sel) begin
      // Enable block B
      write_enable_b = common_write_enable;
      write_address_b = write_common_address;
      write_data_b = rx_data;
      // Disable block A
      write_enable_a = 1'b0;
      write_address_a = 'd0;
      write_data_a = 8'd0;
    end
    else begin
      //Enable block A
      write_enable_a = common_write_enable;
      write_address_a = write_common_address;
      write_data_a = rx_data;
      // Disable block B
      write_enable_b = 1'b0;
      write_address_b = 'd0;
      write_data_b = 8'd0;
    end
  end
  //-------------------------------------------------------------------[TX_DATA]
  always_comb begin
    tx_data = 'd0;
    case(current_state)
      READ: tx_data = read_common_tx_data;
    endcase
  end
endmodule
