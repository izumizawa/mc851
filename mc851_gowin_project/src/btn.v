module btn #(
    parameter ADDR_WIDTH = 8
) (
    input clk,
    input btn1,
    input btn2,
    input read_enable,
    input [ADDR_WIDTH-1:0] address,
    output reg [31:0] data_out
);

    reg btn1_buffer = 0;

    always @(posedge clk) begin
        if (btn1 == 0)
            btn1_buffer <= 1;

        if (read_enable && btn1 == 1) begin
            data_out <= btn1_buffer;
            btn1_buffer <= 0;
        end
    end
endmodule