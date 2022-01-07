module top_sipo 
(
  input   logic CLK50MHZ,
  input   logic CPU_RESETN,
  input   logic UART_TXD_IN,
  output  logic UART_RXD_OUT,
  output logic [1:0] JA,
  output logic [6:0] CAT,
  output logic [7:0] AN
);
  localparam MEM_SIZE = 1024;

  logic rx_ready, tx_busy, write_enable, write_done, tx_start;
  logic [7:0] rx_data, tx_data;

  logic [MEM_SIZE - 1:0] [7:0] mem_data;

  sipo_reg #(
    .MEM_SIZE(MEM_SIZE)
  )
  mem_test
  (
    .clk(CLK50MHZ),
    .write_enable(write_enable),
    .data_in(rx_data),
    .data_out(mem_data)
  );

  uart_basic #(
    .CLK_FREQUENCY(100000000),
    .BAUD_RATE(115200)
  )
  uart
  (
    .clk(CLK50MHZ),
    .reset(~CPU_RESETN),
    .rx(UART_TXD_IN),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx(UART_RXD_OUT),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy)
  );

  // Memory write control
  write_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  write_controller
  (
    .clk(CLK50MHZ),
    .reset(~CPU_RESETN),
    .enable(1'b1),
    .rx_ready(rx_ready),
    .write_enable(write_enable),
    .done(write_done)
  );

endmodule