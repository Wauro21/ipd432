`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/28/2021 02:31:53 AM
// Design Name:
// Module Name: read_tx
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


module read_control  #(
  parameter MEMORY_DEPTH = 8,
  parameter ADDRESS_WIDTH = 8,
  parameter WAIT_READ_CYCLES = 3
)
(
  input   logic clk,
  input   logic reset,
  input   logic fetch,
  output  logic [ADDRESS_WIDTH-1:0] read_address,
  output  logic done,
  output  logic byte_read
);

  // FSM logic
  typedef enum logic [2:0] {IDLE, READ, WAIT_READ, PUSH, ADDRESS, DONE} state;
  state current_state, next_state;

  // Inner Logic
  logic max_address, waited, count_enable, over_address;
  localparam  WAIT_WIDTH = $clog2(WAIT_READ_CYCLES);
  logic [WAIT_WIDTH - 1:0] wait_cycles;

  // FSM READ_TX
  always_ff @ (posedge clk) begin
    if(reset) current_state <= IDLE;
    else current_state <= next_state;
  end

  always_comb begin
    next_state = IDLE;
    done = 1'b0;
    count_enable = 1'b0;
    byte_read = 1'b0;

    case (current_state)
    
      IDLE: if (fetch) next_state = READ;

      READ: begin
        if (over_address) next_state = DONE;
        else next_state = WAIT_READ;
      end

      WAIT_READ: begin
        next_state = WAIT_READ;
        if (waited) next_state = PUSH;
      end

      PUSH: begin
        next_state = PUSH;
        byte_read = 1'b1;
        if (~fetch) begin
          next_state = ADDRESS;
        end
      end

      ADDRESS: begin
        count_enable = 1'b1;
        next_state = IDLE;
      end

      DONE: begin
        done = 1'b1;
        if (~fetch) begin
          next_state = IDLE;
        end
      end

    endcase
  end

  //address_counter
  address_counter #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  READ_ADDRESS
  (
    .clk(clk),
    .reset(reset),
    .enable(count_enable),
    .clear(done),
    .address(read_address),
    .max_address(max_address),
    .over_address(over_address)
  );


  // WAIT counter
  always_ff @ (posedge clk) begin
    if(reset) begin
      wait_cycles <= 'd0;
      waited <= 1'b0;
    end
    else begin
      if(current_state == WAIT_READ) begin
        if(wait_cycles == WAIT_READ_CYCLES-1) begin
          wait_cycles <= 'd0;
          waited <= 1'b1;
        end
        else begin
          wait_cycles <= wait_cycles + 'd1;
          waited <= 1'b0;
        end
      end
      else begin
        wait_cycles <= 'd0;
        waited <= 1'b0;
      end
    end
  end
endmodule
