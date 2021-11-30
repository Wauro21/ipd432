module processing_core #(
  parameter CMD_WIDTH = 3
)
(
  input   logic clk,
  input   logic reset,
  input   logic cmd_flag,
  input   logic [CMD_WIDTH - 1:0] cmd_dec,
  input   logic bram_sel,
  input   logic [7:0] brama_read,
  output  logic brama_write_addr,
  output  logic brama_write_en,
  output  logic brama_read_addr,
  output  logic core_lock,
  output  logic tx_data
);
  
  typedef enum logic [3:0] {IDLE, WRITE_BRAM, READ_VEC, SUM_VEC, AVG_VEC, MAN_DIST, EUC_DIST, TO_HOST} state;

  localparam WRITE_CMD  = 3'd1;
  localparam READ_CMD   = 3'd2;
  localparam SUM_CMD    = 3'd3;
  localparam AVG_CMD    = 3'd4;
  localparam MAN_CMD    = 3'd5;
  localparam EUC_CMD    = 3'd6;
  
  state current_state, next_state;

  always_ff @(posedge clk) begin
    if (~reset) begin
      current_state <= IDLE;
    end
    else current_state <= next_state;
  end

  always_comb begin
    case (current_state)
      IDLE: begin
        if (cmd_flag) begin
          core_lock = 1'b1;
          case (cmd_dec)
            WRITE_CMD:  next_state = WRITE_BRAM;
            READ_CMD:   next_state = READ_VEC;
            SUM_CMD:    next_state = SUM_VEC;
            AVG_CMD:    next_state = AVG_VEC;
            MAN_CMD:    next_state = MAN_DIST;
            EUC_CMD:    next_state = EUC_DIST;
          endcase
        end
      end

      WRITE_BRAM: begin
        enable_write = 1'b1;
        next_state = WRITE_BRAM;

        if (write_done) next_state = IDLE;
      end

      READ_VEC: begin
        
      end

      SUM_VEC: begin
        
      end

      AVG_VEC: begin
        
      end

      MAN_DIST: begin
        
      end

      EUC_DIST: begin
        
      end

      TO_HOST: begin
        
      end
    endcase
  end