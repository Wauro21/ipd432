`timescale 1us / 1us

module op_testbench ();
  logic [7:0] data_a, data_b;
  logic [15:0] data_c;
  
  // generate a clock signal that inverts its value every five time units
	always  #1 clk=~clk;

  initial begin
    data_a = 8'd127;
    data_b = 8'd255;
    
    #10 data_c = data_a - data_b;
  end

endmodule