module processing_core #(
  parameter CMD_WIDTH = 3,
  parameter MEMORY_DEPTH = 1024
)
(
  input   logic clk,
  input   logic reset,
  input   logic rx_ready,
  input   logic tx_busy,
  input   logic cmd_flag,
  input   logic [CMD_WIDTH - 1:0] cmd_dec,
  input   logic bram_sel,
  input   logic [7:0] brama_read,
  input   logic [7:0] bramb_read,
  output  logic [9:0] brama_write_addr,
  output  logic [9:0] brama_read_addr,
  output  logic brama_write_en,
  output  logic [9:0] bramb_write_addr,
  output  logic [9:0] bramb_read_addr,
  output  logic bramb_write_en,
  output  logic core_lock,
  output  logic [7:0] tx_data
);
  
  typedef enum logic [CMD_WIDTH - 1:0] {IDLE, WRITE_BRAM, READ_VEC, FETCH, OP, TO_HOST} state;

  localparam WRITE_CMD  = 3'd1;
  localparam READ_CMD   = 3'd2;
  localparam SUM_CMD    = 3'd3;
  localparam AVG_CMD    = 3'd4;
  localparam MAN_CMD    = 3'd5;
  localparam EUC_CMD    = 3'd6;

  localparam ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
  localparam WAIT_READ_CYCLES = 3;
  
  state current_state, next_state;
  logic write_done, enable_write, write_enable, tx_start;
  logic [ADDRESS_WIDTH - 1:0] write_address;

  logic brama_read_done, brama_byte_read, brama_fetch, brama_queued;
  logic bramb_read_done, bramb_byte_read, bramb_fetch, bramb_queued;

  logic [19:0] dist_accum;
  logic [15:0] diff;

  logic man_accum_flag, man_accum_done;
  logic euc_accum_flag, euc_accum_done;

  always_ff @(posedge clk) begin
    if (~reset) begin
      current_state <= IDLE;
    end
    else current_state <= next_state;

    // bramx_write_addr setters
    if (brama_write_en) brama_write_addr <= write_address;
    if (bramb_write_en) bramb_write_addr <= write_address;
    
    // dist_accum setters
    if (current_state == IDLE) dist_accum <= 20'd0; 
    // Manhattan distance accumulator
    if (man_accum_flag) begin
      dist_accum <= dist_accum + diff;
    end
    // Euclidean distance accumulator
    if (euc_accum_flag) begin
      dist_accum <= dist_accum + (diff * diff);
    end
  end

  always_comb begin
    core_lock = 1'b0;
    man_accum_flag = 1'b0;
    euc_accum_flag = 1'b0;
    brama_fetch = 1'b0;
    bramb_fetch = 1'b0;

    brama_write_en = 1'b0;
    bramb_write_en = 1'b0;

    // COMPLETE DEFAULT VALUES
    
    case (current_state)

      IDLE: begin
        diff = 16'd0;

        if (cmd_flag) begin
          case (cmd_dec)
            WRITE_CMD:  next_state = WRITE_BRAM;
            READ_CMD:   next_state = READ_VEC;
            default: next_state = OP;
          endcase
        end
      end

      WRITE_BRAM: begin
        core_lock = 1'b1;
        enable_write = 1'b1;
        next_state = WRITE_BRAM;

        if (~bram_sel) begin
          brama_write_en = write_enable;
        end 
        else begin
          bramb_write_en = write_enable;
        end

        if (write_done) next_state = IDLE;
      end

      READ_VEC: begin
        core_lock = 1'b1;
        next_state = READ_VEC;

        if (~bram_sel) begin
          brama_fetch = 1'b1;  

          if (brama_byte_read) begin
            tx_data = brama_read;
            tx_start = 1'b1;       
            next_state = TO_HOST;
          end
        end
        else begin
          bramb_fetch = 1'b1;

          if (bramb_byte_read) begin
            tx_data = bramb_read;
            tx_start = 1'b1;       
            next_state = TO_HOST;
          end
        end

        if (brama_read_done | bramb_read_done) begin
          next_state = IDLE;
        end
      end

      FETCH: begin
        core_lock = 1'b1;
        next_state = FETCH;

        brama_fetch = 1'b1;
        bramb_fetch = 1'b1;

        if (brama_byte_read & bramb_byte_read) next_state = OP;
        if (brama_read_done & bramb_read_done) begin
          if ((cmd_dec == MAN_CMD) | (cmd_dec == EUC_CMD)) next_state = OP;
          else next_state = IDLE;
        end
        
      end

      OP: begin
        core_lock = 1'b1;
        next_state = OP;

        case (cmd_dec)

          SUM_CMD: begin
            if (brama_read_done & bramb_read_done)

            tx_data = brama_read + bramb_read;
            tx_start = 1'b1;

            next_state = TO_HOST;
          end

          AVG_CMD: begin
            tx_data = brama_read >> 1 + bramb_read >> 1;
            tx_start = 1'b1;
            next_state = TO_HOST;
          end

          MAN_CMD: begin
            if (brama_read_done & bramb_read_done) begin
              tx_data = dist_accum >> ADDRESS_WIDTH;
              tx_start = 1'b1;
              next_state = TO_HOST;
            end
            else begin
              if (brama_read > bramb_read) diff = brama_read - bramb_read;
              else diff = bramb_read - brama_read;
              
              man_accum_flag = 1'b1;
              next_state = FETCH; // Maybe check man_accum_done before
            end 
          end

          EUC_CMD:
            if (brama_read_done & bramb_read_done) begin
              tx_data = dist_accum >> ADDRESS_WIDTH;
              tx_start = 1'b1;
              next_state = TO_HOST;
            end
            else begin
              if (brama_read > bramb_read) diff = brama_read - bramb_read;
              else diff = bramb_read - brama_read;

              euc_accum_flag = 1'b1; // Maybe check euc_accum_done before
              next_state = FETCH;
            end

        endcase
      end

      TO_HOST: begin
        core_lock = 1'b1;
        if (~tx_busy) begin
          case (cmd_dec)
            WRITE_CMD:  next_state = WRITE_BRAM;
            READ_CMD:   next_state = READ_VEC;
            SUM_CMD:    next_state = FETCH;
            AVG_CMD:    next_state = FETCH;
            MAN_CMD:    next_state = IDLE;
            EUC_CMD:    next_state = IDLE;
          endcase
        end
      end

    endcase
  end

  // FSM WRITE
  write_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  FSM_WRITE
  (
    .clk(CLK100MHZ),
    .reset(~reset),
    .enable(enable_write),
    .rx_ready(rx_ready),
    .write_enable(write_enable),
    .done(write_done),
    .address(write_address)
  );

  // FSM READ & TX FOR BRAMA
  read_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
  )
  FSM_READ_BRAMA
  (
    .clk(CLK100MHZ),
    .reset(~reset),
    .fetch(brama_fetch),
    .read_address(brama_read_addr),
    .done(brama_read_done),
    .byte_read(brama_byte_read)
  );

  // FSM READ & TX FOR BRAMB
  read_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
  )
  FSM_READ_BRAMB
  (
    .clk(CLK100MHZ),
    .reset(~reset),
    .fetch(bramb_fetch),
    .read_address(bramb_read_addr),
    .done(bramb_read_done),
    .byte_read(bramb_byte_read)
  );

endmodule