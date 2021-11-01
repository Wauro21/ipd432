`timescale 1ns / 1ps


module digital_clock(
  input CLK100MHZ,
  input reset,
  input BTNL,
  input BTNR,
  input SW[1:0],
  output logic [0:6] SEG,
  output logic [7:0] AN,
  output logic [15:0] LED
  );

  logic [5:0] segs_count, mins_count, hours_count, hours_formated, a_mins, a_hours, f_mins, f_hours, f_segs;
  logic [7:0] segs, n_segs, mins, n_mins, hours, n_hours;
  logic c_BTNR, c_BTNL, p_BTNR, p_BTNL, clock_BTNR, clock_BTNL, alarm_BTNR, alarm_BTNL;
  logic led_flag;
  //Buttons control
  // - > Debounce
  PB_Debouncer_FSM #(
  .DELAY(500)
  )
  DB_BTNR(
    .clk(CLK100MHZ),
    .rst(reset),
    .PB(BTNR),
    .PB_pressed_status(c_BTNR)
  );
  PB_Debouncer_FSM #(
  .DELAY(500)
  )
  DB_BTNL(
    .clk(CLK100MHZ),
    .rst(reset),
    .PB(BTNL),
    .PB_pressed_status(c_BTNL)
  );

  // - > level to pulse
  PB_FSM #(
  .N_INCREMENT_DELAY_CONTINUOUS(50000000)
  )
  PULSE_BTNR(
    .clk(CLK100MHZ),
    .rst(reset),
    .pressed_status(c_BTNR),
    .IncPulse_out(p_BTNR)
  );
  PB_FSM #(
  .N_INCREMENT_DELAY_CONTINUOUS(50000000)
  )
  PULSE_BTNL(
    .clk(CLK100MHZ),
    .rst(reset),
    .pressed_status(c_BTNL),
    .IncPulse_out(p_BTNL)
  );
  //Clock mechanism
  tictoc USER_CLOCK(
    .clk(CLK100MHZ),
    .reset(reset),
    .btnr(clock_BTNR),
    .btnl(clock_BTNL),
    .segs_count(segs_count),
    .mins_count(mins_count),
    .hours_count(hours_count)
  );

  // AM/PM selector
  always_comb begin
    if (SW[0]) begin
      LED[0] = 1;
      if(hours_count > 'd12) begin
        hours_formated = f_hours - 'd12;
      end
      else begin
        hours_formated = f_hours;
      end
    end
    else begin
      LED[0] = 0;
      hours_formated = f_hours;
    end
  end

  // ALARM
  FSM_ALARM ALARM_1(
  .clk(CLK100MHZ),
  .reset(reset),
  .SW(SW[1]),
  .BTNR(alarm_BTNR),
  .BTNL(alarm_BTNL),
  .minutes(mins_count),
  .hours(hours_count),
  .seconds(segs_count),
  .LED_flag(led_flag),
  .mins_count(a_mins),
  .hours_count(a_hours)
  );

  always_comb begin
    if(SW[1]) begin
      f_segs = 0;
      f_mins = a_mins;
      f_hours = a_hours;
      alarm_BTNR = p_BTNR;
      alarm_BTNL = p_BTNL;
      clock_BTNR = 'd0;
      clock_BTNL = 'd0;
    end
    else begin
      f_segs = segs_count;
      f_mins = mins_count;
      f_hours = hours_count;
      clock_BTNR = p_BTNR;
      clock_BTNL = p_BTNL;
      alarm_BTNR = 'd0;
      alarm_BTNL = 'd0;
    end
  end

  // Display control
  // -> Double dabble
  unsigned_to_bcd DD_SEGS(
  .clk(CLK100MHZ),
  .trigger(1'b1),
  .in(f_segs),
  .bcd(n_segs)
  );

  unsigned_to_bcd DD_MINS(
  .clk(CLK100MHZ),
  .trigger(1'b1),
  .in(f_mins),
  .bcd(n_mins)
  );

  unsigned_to_bcd DD_HOURS(
  .clk(CLK100MHZ),
  .trigger(1'b1),
  .in(hours_formated),
  .bcd(n_hours)
  );

  always_ff @(posedge CLK100MHZ) begin
    if(reset) begin
      segs <= 'd0;
      mins <= 'd0;
      hours <= 'd0;
    end

    else begin
      segs <= n_segs;
      mins <= n_mins;
      hours <= n_hours;
    end
  end

  display_hex(
  .numero_entrada({8'b0, hours, mins, segs}),
  .power_on(1'b1),
  .clk(CLK100MHZ),
  .SEG(SEG),
  .ANODO(AN)
  );

  LED_control LED_ALARM(
    .clk(CLK100MHZ),
    .reset(reset),
    .led_flag(led_flag),
    .leds(LED[15:1])
  );
endmodule
