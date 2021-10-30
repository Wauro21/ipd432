module T1_design1 #(
  parameter N_DEBOUNCER_DELAY = 10,
  parameter N_INCREMENT_DELAY_CONTINUOUS = 5
  )(
  input logic clk,
  input logic resetN,
  input logic PushButton,
  output logic IncPulse_out
  );

  //Declarations:
  logic resetP, PB_status;
  //Statements
  assign resetP = ~resetN;

  PB_Debouncer #(
  .DELAY(N_DEBOUNCER_DELAY)
  )
  PB_Debouncer(
  .clk(clk),
  .rst(resetP),
  .PB(PushButton),
  .PB_pressed_status(PB_status)
  );

  PB_FSM #(
  .N_INCREMENT_DELAY_CONTINUOUS(N_INCREMENT_DELAY_CONTINUOUS)
  )
  PB_FSM(
  .clk(clk),
  .rst(resetP),
  .pressed_status(PB_status),
  .IncPulse_out(IncPulse_out)
  );


endmodule
