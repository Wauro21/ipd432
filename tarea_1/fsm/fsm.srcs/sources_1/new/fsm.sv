module PB_FSM #(
	parameter N_INCREMENT_DELAY_CONTINUOUS = 10
	)
(
	input logic clk,
	input logic rst,
	input logic pressed_status,
	output logic IncPulse_out
);
	//Declarations:-----------------------------
	localparam COUNTER_WIDTH = $clog2(N_INCREMENT_DELAY_CONTINUOUS);
	logic [COUNTER_WIDTH-1:0] t;
	//FSM states type:
	typedef enum logic [1:0] {S0,S1,S2} state;
	state pr_state, nx_state;

 //Statements:--------------------------------
 //FSM state register:
    always_ff @(posedge clk) begin
        if(rst) pr_state <= S0;
        else pr_state <= nx_state;
    end

	//FSM combinational logic:
	always_comb begin
	    nx_state = S0;
	    IncPulse_out = 0;
		case(pr_state)

			S0:  begin
			 if(pressed_status) nx_state <= S1;
			end

			S1:  begin
			 IncPulse_out <= 1;
			 if(pressed_status) nx_state <= S2;
			end

			S2:	begin
				if(t < N_INCREMENT_DELAY_CONTINUOUS-1 && pressed_status) nx_state = S2;
				else if(t >= N_INCREMENT_DELAY_CONTINUOUS-1 && pressed_status) nx_state = S1;
			end
		endcase
	end

	always_ff @(posedge clk) begin
		if(rst) t <= 0;
		else if (pr_state != nx_state) t <= 0;
		else t <= t + 1;
	end

endmodule
