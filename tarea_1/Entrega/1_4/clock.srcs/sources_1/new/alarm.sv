module FSM_ALARM #(
  parameter DURATION = 250000000
  )
  (
    input logic clk,
    input logic reset,
    input logic SW,
    input logic BTNR,
    input logic BTNL,
    input logic [5:0] minutes,
    input logic [5:0] hours,
    input logic [5:0] seconds,
    output logic LED_flag,
    output logic [5:0] mins_count,
    output logic [5:0] hours_count
  );

  // Declarations
  localparam   COUNTER_WIDTH = $clog2(DURATION);
  logic [COUNTER_WIDTH-1:0] counter; // Counter for led animation

  //FSM states type:
  typedef enum logic [2:0] {IDLE, SET, ALARM, MINS, HOURS} state;
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
    LED_flag = 0;
    case(pr_state)

      IDLE: begin
        if(SW) nx_state = SET;
        else if((mins_count == minutes) && (hours_count == hours) && (seconds < 'd5)) nx_state = ALARM;
      end

      SET: begin
        if(SW) begin
          nx_state = SET;
          if(BTNR) nx_state = MINS;
          else if(BTNL) nx_state = HOURS;
        end
      end

      MINS: begin
        if(mins_count == 'd59) nx_state = HOURS;
      end

      HOURS: begin
        nx_state = IDLE;
      end

      ALARM:  begin
        LED_flag = 1;
        if(counter >= DURATION -1) nx_state = IDLE;
        else nx_state = ALARM;
      end
    endcase
  end

  // Counter
  always_ff @(posedge clk) begin
    if(reset) begin
      counter <= 0;
      mins_count <= 0;
      hours_count <= 0;
    end

    else begin
      case(pr_state)

        MINS: begin
          if(mins_count == 59) mins_count <= 'd0;
          else mins_count <= mins_count + 'd1;
        end

        HOURS:  begin
          if(hours_count == 23) hours_count <= 'd0;
          else hours_count <= hours_count + 'd1;
        end

        ALARM:  begin
          if(counter >= DURATION -1 ) counter <= 0;
          else counter <= counter + 1;
        end

        default:  begin
          counter <= 0;
          mins_count <= mins_count;
          hours_count <= hours_count;

        end

      endcase
    end
  end


endmodule
