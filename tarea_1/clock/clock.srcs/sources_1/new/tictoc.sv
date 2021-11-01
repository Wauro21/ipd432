`timescale 1ns / 1ps

module tictoc #(
  parameter COUNT_TO_SEG = 100000000,
  parameter SEGS_MAX = 60
  )(
  input logic clk,
  input logic reset,
  input logic btnr,
  input logic btnl,
  output logic [5:0] segs_count,
  output logic [5:0] mins_count,
  output logic [5:0] hours_count

    );

    //Declarations
    localparam  COUNT_WIDTH = $clog2(COUNT_TO_SEG);
    logic [COUNT_WIDTH-1:0] COUNTER;

    //FSM states type:
    typedef enum logic [1:0] {IDLE, SEGS, MINS, HOURS} state;
    state pr_state, nx_state;

    //FSM state register:
    always_ff @ (posedge clk) begin
      if(reset) begin
        pr_state <= IDLE;
      end
      else pr_state <= nx_state;
    end

    //FSM combinational logic:
    always_comb begin
      nx_state = IDLE;

      case(pr_state)

        IDLE: begin
          if(COUNTER >= COUNT_TO_SEG-1) nx_state = SEGS;
          else if(btnr) nx_state = MINS;
          else if(btnl) nx_state = HOURS;
        end

        SEGS: begin
          if(segs_count == 'd59) nx_state = MINS;
        end

        MINS: begin
          if(mins_count == 'd59) nx_state = HOURS;
        end

        HOURS: begin
          nx_state = IDLE;
        end

      endcase
    end

    // Counter
    always_ff @(posedge clk) begin
      if(reset) begin
        COUNTER <= 0;
        segs_count <= 0;
        mins_count <= 0;
        hours_count <= 0;
      end

      else begin
        case(pr_state)

          IDLE: begin
            if(COUNTER >= COUNT_TO_SEG-1) COUNTER <= 'd0;
            else COUNTER <= COUNTER + 'd1;
          end

          SEGS: begin
            if(segs_count == 59) segs_count <= 'd0;
            else segs_count <= segs_count + 'd1;
          end

          MINS: begin
            if(mins_count == 59) mins_count <= 'd0;
            else mins_count <= mins_count + 'd1;
          end

          HOURS:  begin
            if(hours_count == 23) hours_count <= 'd0;
            else hours_count <= hours_count + 'd1;
          end

        endcase
      end
    end
endmodule
