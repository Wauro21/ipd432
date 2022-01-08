`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/06/2022 11:35:51 PM
// Design Name:
// Module Name: op_module
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
// Instantation template
/*------------------------------------------
op_module #(
  .N_INPUTS(),
  .I_WIDTH()
)
OP_MOD
(
  .cmd(),
  .enable(),
  .bram_sel(),
  .A(),
  .B(),
  .out()
);
------------------------------------------*/

module op_module#(
  parameter N_INPUTS = 1024,
  parameter I_WIDTH = 8,
  parameter CMD_WIDTH = 3

  )
  (
    input logic [CMD_WIDTH-1:0] cmd,
    input logic enable,
    input logic bram_sel,
    input logic [N_INPUTS-1:0][I_WIDTH-1:0] A,
    input logic [N_INPUTS-1:0][I_WIDTH-1:0] B,
    output logic [N_INPUTS-1:0][I_WIDTH-1:0] out
  );

  enum logic [CMD_WIDTH-1:0]{WRITE = 3'd1, READ = 3'd2, SUM = 3'd3, AVG = 3'd4, MAN = 3'd5} commands;
  logic [N_INPUTS-1:0][I_WIDTH-1:0] result;
  logic [N_INPUTS-1:0][I_WIDTH-1:0] sum;

  genvar i;
  generate
    for(i = 0; i < N_INPUTS; i++) begin
      always_comb begin
        sum[i] = A[i] + B[i];
        case (cmd)
          READ: begin
            if(bram_sel) result[i] = B[i];
            else result[i] = A[i];
          end
          SUM: result[i] = sum[i];
          AVG: result[i] = (sum[i]>>1);
          MAN: begin
            if(A[i] >= B[i]) result[i] = A[i] - B[i];
            else result[i] = B[i] - A[i];
          end
          default: result[i] = 'd0;
        endcase
      end
    end
  endgenerate

  // TEMP ENABLE
  always_comb begin
    if(enable) out = result;
    else out = 'd0;
  end
endmodule
