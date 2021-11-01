module LED_control #(
  parameter LED_DURATION = 25000000
  )
  (
    input logic clk,
    input logic reset,
    input logic led_flag,
    output logic [14:0] leds
  );
  localparam  LED_COUNTER_WIDTH = $clog2(LED_DURATION);
  logic [LED_COUNTER_WIDTH-1:0] led_counter; // Counter for led animation
  logic [14:0] led_now, led_next;

 //Counter for led blink
 always_ff @(posedge clk) begin
   if(reset) begin
     led_now <= 'd0;
   end

   else led_now <= led_next;
 end

 always_ff @(posedge clk) begin
   if(reset) led_counter <= 'd0;
   else if(led_counter == LED_DURATION - 1) led_counter <= 'd0;
   else led_counter <= led_counter + 'd1;
 end

 always_comb begin
   if(led_counter == LED_DURATION - 1) led_next = ~led_now;
   else led_next = led_now;
 end

always_comb begin
  if(led_flag) leds = led_now;
  else leds = 'd0;
end

endmodule
