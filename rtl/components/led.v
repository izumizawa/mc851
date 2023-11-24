module led (
    input clk,
    input write_enable,
    input [5:0] data_in,
    output reg [5:0] led
);

    always @(posedge clk) begin
        if (write_enable) begin
            led <= data_in;
        end

    end

endmodule
