module cmd_decoder #(
  parameter CMD_WIDTH = 3
)
(
  input logic clk,
  input logic reset,
  input logic rx_ready,
  input logic [7:0] rx_data,
  input logic core_lock,
  output logic cmd_flag,
  output logic [CMD_WIDTH - 1:0] cmd_dec,
  output logic bram_sel
);

  // FSM Logic
  typedef enum logic [1:0] {IDLE, DECODING, LOCK} state;

  state current_state, next_state;
  logic cmd_store_flag;

  // FSM
  always_ff @(posedge clk) begin
    if (~reset) begin
      current_state <= IDLE;
      cmd_dec <= 3'd0;
      bram_sel <= 1'b0;
    end
    else current_state <= next_state;
    
    if (current_state == IDLE) cmd_dec <= 'd0;
    
    if (cmd_flag) begin
      cmd_dec <= rx_data[2:0];
      bram_sel <= rx_data[4];
    end    
  end

  always_comb begin
    next_state = IDLE;
    cmd_flag = 1'b0;

    case (current_state)
      IDLE: begin
        if (rx_ready) next_state = DECODING;
      end

      DECODING: begin
        cmd_flag = 1'b1;
        if (core_lock) next_state = LOCK;
        else next_state = DECODING;
      end
      
      LOCK: begin
        if (~core_lock) begin
          next_state = IDLE;
        end
        else next_state = LOCK;
      end
    endcase
  end
  
endmodule