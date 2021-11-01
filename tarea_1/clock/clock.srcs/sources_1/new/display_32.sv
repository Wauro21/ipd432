`timescale 1ns / 1ps

module display_hex(
    input [31:0] numero_entrada,
    input power_on, clk, // prende el display
	
    output logic [6:0] SEG,
    output logic [7:0] ANODO
	);
	logic clk_display;
	localparam COUNTER_MAX = (100000000/(2*480))-1;
    logic [2:0] contador_anodo = 3'b0;
    logic [31:0] contador_display = 'd0;
    logic [3:0] bus_out;
    
    always @(posedge clk) begin
        	if (contador_display == COUNTER_MAX)
        	begin
        		contador_display <= 'd0;
        		clk_display <= ~clk_display;
        	end
        	else
        	begin
        		contador_display <= contador_display + 'd1;
        		clk_display <= clk_display;
        	end
        end
    
    always @(posedge clk_display) begin
    	contador_anodo = contador_anodo + 3'b1;
    end
    
	always_comb begin
		if (power_on == 1'b0)
		begin
    		ANODO[7:0] = 8'b11111111;
    	end
    	else 
    	begin
     		case (contador_anodo) 
        		3'd0 : ANODO[7:0] = 8'b11111110;
        		3'd1 : ANODO[7:0] = 8'b11111101;
				3'd2 : ANODO[7:0] = 8'b11111011;
				3'd3 : ANODO[7:0] = 8'b11110111;                              
				3'd4 : ANODO[7:0] = 8'b11101111;
				3'd5 : ANODO[7:0] = 8'b11011111;
				3'd6 : ANODO[7:0] = 8'b10111111;
				3'd7 : ANODO[7:0] = 8'b01111111;        
          		default : ANODO[7:0] = 8'b11111111;
      		endcase
 		end
 	end

	always_comb begin
    	case (contador_anodo) 
    		3'd0 :  bus_out = numero_entrada[3:0];
			3'd1 :  bus_out = numero_entrada[7:4];
			3'd2 :  bus_out = numero_entrada[11:8];
			3'd3 :  bus_out = numero_entrada[15:12];
			3'd4 :  bus_out = numero_entrada[19:16];
			3'd5 :  bus_out = numero_entrada[23:20];
			3'd6 :  bus_out = numero_entrada[27:24];
			3'd7 :  bus_out = numero_entrada[31:28];
			default: bus_out = 4'b0000;                            
    	endcase
 	end
    
	always_comb begin
    	case(bus_out)
			4'd0:  SEG = 7'b0000001;
			4'd1:  SEG = 7'b1001111; 
			4'd2:  SEG = 7'b0010010;
			4'd3:  SEG = 7'b0000110;
			4'd4:  SEG = 7'b1001100;
			4'd5:  SEG = 7'b0100100;
			4'd6:  SEG = 7'b0100000;
			4'd7:  SEG = 7'b0001111;
			4'd8:  SEG = 7'b0000000;
			4'd9:  SEG = 7'b0001100;
			4'd10: SEG = 7'b0001000; 
			4'd11: SEG = 7'b1100000;
			4'd12: SEG = 7'b0110001;
			4'd13: SEG = 7'b1000010;
			4'd14: SEG = 7'b0110000;
			4'd15: SEG = 7'b0111000;
			default: SEG = 7'b1111111;
     	endcase
 	end
endmodule
