module rom #(
    parameter MEMORY_SIZE = 1024,  // 1 KiB
    parameter ROMFILE="teste.mem"
) (
    input clk,
    input [31:0] address,
    output reg  [31:0] data_out
);
    localparam WORD_WIDTH = 32;
    localparam NUM_WORDS = MEMORY_SIZE / WORD_WIDTH;

    reg [WORD_WIDTH-1:0] mem [0:NUM_WORDS-1];

    initial begin
        $readmemh(ROMFILE, mem);
    end

    always @(posedge clk) begin
        data_out <= mem[address];
    end

endmodule
