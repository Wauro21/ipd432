`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/28/2021 02:24:50 AM
// Design Name:
// Module Name: adder_tree
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


module adder_tree #(
  // To be modified
  parameter INPUTS = 1024,
  parameter INPUT_WIDTH = 8,
  // Can be overwritten, but not recomended
  parameter N_STAGES = $clog2(INPUTS),
  parameter PWIDTH = 2**N_STAGES,
  parameter N_SUMS = PWIDTH-1,
  parameter ODATA_WIDTH = INPUT_WIDTH + N_STAGES
  )
  (
    //input logic clk,
    //input logic reset,
    input logic [INPUTS-1:0][INPUT_WIDTH-1:0] input_bus,
    output logic [ODATA_WIDTH-1:0] output_bus
  );
  // Instantation template
  /*------------------------------------------
  adder_tree #(
    .INPUTS(),
    .INPUT_WIDTH()
  )
  ADD_TREE
  (
    .input_bus(),
    .output_bus()
  );
  ------------------------------------------*/
  // [INTERNAL BUS]
  logic [N_SUMS-1:0][ODATA_WIDTH-1:0] internal_sum;

  // Pipeline

  genvar stage, sums;
  generate
    for (stage = 1; stage <= N_STAGES; stage++) begin
      localparam  NUM_SUMS = PWIDTH>>stage;
      localparam  SUM_INDEX = PWIDTH>>(stage-1);
      // First stage - Work with the INPUTS
      if(stage == 'd1) begin
        for(sums = 0; sums < NUM_SUMS; sums++) begin
          if(2*sums+1 < INPUTS) begin
            assign internal_sum[sums] = input_bus[2*sums] + input_bus[2*sums+1];
          end
          else if (2*sums < INPUTS) begin
            // Pair padded with a "zero"
            assign internal_sum[sums] = input_bus[2*sums];
          end
          else begin
            // Zero padding
            assign internal_sum[sums] = 'd0;
          end
        end
      end
      else begin
        for(sums = 0; sums < NUM_SUMS; sums++) begin
          assign internal_sum[SUM_INDEX+sums] = internal_sum[2*sums + OP_INDEX] + internal_sum[2*sums+1 + OP_INDEX];
        end
      end
    end
  endgenerate

  assign output_bus = internal_sum[N_SUMS-1];



endmodule
