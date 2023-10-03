// TODO: implementar teste da RAM
module ram #(
    parameter ADDR_WIDTH = 8    // 256×4B = 1 KiB
) (
    input clk,
    input write_enable,
    input read_enable,
    input [ADDR_WIDTH-1:0] address,
    input [31:0] data_in,
    output reg [31:0] data_out
);

    reg [31:0] mem [0:2**ADDR_WIDTH-1];

    always @(posedge clk) begin
        if (read_enable)
            data_out <= mem[address];
        else
            data_out <= 0;

        if (write_enable) mem[address] <= data_in;
    end

endmodule
