module led (
    input clk,
    input write_enable,
    input [5:0] data_in,
    output reg [5:0] led
);

    reg [5:0] led_buffer;

    always @(posedge clk) begin
        if (write_enable) begin
            led <= led_buffer;
            led_buffer <= 0;

        end else begin
            led_buffer <= 0;
        end

    end

endmodule
