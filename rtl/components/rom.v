module rom #(
    parameter ADDR_WIDTH = 8,  // 256×4B = 1 KiB
    parameter ROMFILE=""
) (
    input clk,
    input read_enable,
    input [ADDR_WIDTH-1:0] address,
    output [31:0] data_out
);

    reg [31:0] mem [0:2**ADDR_WIDTH-1];

    initial begin
        $readmemh(ROMFILE, mem);
    end

    assign data_out = read_enable ? mem[address] : 0;
endmodule
