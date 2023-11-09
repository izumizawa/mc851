// TODO: implementar teste da ROM
module rom #(
    parameter ADDR_WIDTH = 8,  // 256×4B = 1 KiB
    parameter ROMFILE="../../src/memdump/addi.mem"
) (
    input clk,
    input read_enable,
    input [ADDR_WIDTH-1:0] address,
    output reg [31:0] data_out
);

    reg [31:0] mem [0:2**ADDR_WIDTH-1];

    initial begin
        $readmemh(ROMFILE, mem);
    end

    always @(posedge clk) begin
        if (read_enable)
            data_out <= mem[address];
        else
            data_out <= 0;
    end

endmodule
