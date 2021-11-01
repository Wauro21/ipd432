`timescale 1ns / 1ps

module tic_toc_sim();
    logic clk, reset;
    logic [5:0] seg_count;
    logic [5:0] mins_count;
    logic [5:0] hours_count;
    
    tictoc #(
        .COUNT_TO_SEG(1)
    )
    testClock(
        .clk(clk),
        .reset(reset),
        .segs_count(seg_count),
        .mins_count(mins_count),
        .hours_count(hours_count)
    );
    
    
    always #1 clk=~clk;
    initial begin
    clk = 1'b0;
    reset = 1'b0;
    #50
    reset = 1'b1;
    #30
    reset = 1'b0;
    end
endmodule
