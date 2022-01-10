`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/09/2022 12:56:25 AM
// Design Name:
// Module Name: tx_fsm
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


module tx_fsm #(
	parameter N_INPUTS = 1024
	)
	(
	input logic clk,
	input logic reset,
	input logic enable,
	input logic tx_ready,
	input logic tx_busy,
	output logic tx_start,
	output logic mem_shift,
	output logic tx_done
    );

	// logic tx_enable, count, tx_busy, max_count;
	//
	// // FSM logic
	// typdef enum logic [2:0] {IDLE, TX, LOCK, COUNT_SHIFT, CHECK, DONE} state;
	// state pr_state, nx_state;
	//
	// always_ff @ (posedge clk) begin
	// 	if(reset) pr_state <= IDLE;
	// 	else pr_state <= nx_state;
	// end
	//
	// always_comb begin
	// 	nx_state = IDLE;
	// 	tx_enable = 1'b0;
	// 	tx_done = 1'b0;
	// 	count = 1'b0;
	// 	mem_shift = 1'b0;
	// 	case (pr_state)
	// 		IDLE: if(enable) nx_state = TX;
	//
	// 		TX: begin
	// 			tx_enable = 1'b1;
	// 			nx_state = LOCK;
	// 		end
	//
	// 		LOCK: begin
	// 			if(tx_busy) nx_state = LOCK;
	// 			else nx_state = COUNT_SHIFT;
	// 		end
	//
	// 		COUNT_SHIFT: begin
	// 			nx_state = CHECK;
	// 			count = 1'b1;
	// 			mem_shift = 1'b1;
	// 		end
	//
	// 		CHECK: begin
	// 			if(max_count) nx_state = DONE;
	// 			else nx_state = TX;
	// 		end
	//
	// 		DONE: begin
	// 			nx_state = IDLE;
	// 			tx_done = 1'b1;
	// 		end
	// 	endcase
	// end
	//
	// memory_counter #(
	// .N_VALUES(N_INPUTS)
	// )
	// COUNTER_MEM
	// (
	//   .clk(clk),
	//   .reset(reset),
	//   .enable(count),
	//   .clear(tx_done),
	//   .max_count(max_count)
	// );

endmodule
