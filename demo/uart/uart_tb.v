module test();
  reg clk = 0;
  reg uart_rx = 1;
  wire uart_tx;
  wire [5:0] led;
  reg btn = 1;

  uart #(8'd8) u(
    clk,
    uart_rx,
    uart_tx,
    led,
    btn
  );

    always
    #1  clk = ~clk;

  initial begin
    $display("Starting UART RX"); // display prints only once
    $monitor("LED Value %b", led); // monitor prints every time the value chngegs
    // %b binary representation
    // %h hex, %d decimal, %s string...
    #10 uart_rx=0;
    #16 uart_rx=1;
    #16 uart_rx=0;
    #16 uart_rx=0;
    #16 uart_rx=0;
    #16 uart_rx=0;
    #16 uart_rx=1;
    #16 uart_rx=1;
    #16 uart_rx=0;
    #16 uart_rx=1;
    #1000 $finish;
  end

  initial begin
    $dumpfile("uart.vcd"); // dumpfile chooses name of file
    $dumpvars(0,test); // dumpvars choosing what to save and how many levels of nested objects
  end

endmodule
