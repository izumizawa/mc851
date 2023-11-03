module ram #(
    parameter ADDR_WIDTH = 8    // 256×4B = 1 KiB
) (
    input clk,
    input write_enable,
    input read_enable,
    input [ADDR_WIDTH-1:0] address,
    input [31:0] data_in,
    output [31:0] data_out
);

    reg [31:0] mem [0:2**ADDR_WIDTH-1];

    always @(posedge clk) begin
        if (write_enable) mem[address] <= data_in;
    end

    assign data_out = read_enable ? mem[address] : 0;
endmodule
