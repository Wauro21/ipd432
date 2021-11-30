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

  // FSM
  always_ff @(posedge clk) begin
    if (~reset) begin
      current_state <= IDLE;
      cmd_dec <= 'b0;
      cmd_flag <= 1'b0;
      bram_sel <= 1'b0;
    end
    else current_state <= next_state;
  end

  always_comb begin
    next_state = IDLE;
    cmd_flag = 1'b0;

    case (current_state)
      IDLE: begin
        if (rx_ready) next_state = DECODING;
      end

      DECODING: begin
        cmd_dec = rx_data[2:0];
        bram_sel = rx_data[4];
        cmd_flag = 1'b1;
        next_state = LOCK;
      end
      
      LOCK: begin
        if (~core_lock) begin
          next_state = IDLE;
          cmd_dec = 'b0;
          cmd_flag = 1'b0;
        end
        else next_state = CORE_LOCK;
      end
    endcase
  end