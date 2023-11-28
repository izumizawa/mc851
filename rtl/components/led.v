module led #(
    parameter ADDR_WIDTH = 8
)(
    input clk,
    input write_enable,
    input [ADDR_WIDTH-1:0] address,
    input [31:0] data_in,
    output [5:0] led
);

    reg [5:0] led_data_out;

    always @(posedge clk) begin
        if (write_enable) begin
            led_data_out <= data_in[5:0];
        end

    end

    assign led = led_data_out;

endmodule
