module l1_instruction_cache #(
    parameter OFFSET_WIDTH = 2,
    parameter INDEX_WIDTH = 6
) (
    input clk, reset_n,
    input [31:0] address,
    input mmu_mem_ready,
    input [31:0] mmu_data_out,
    output [31:0] mmu_address,
    output cache_miss,
    output [31:0] data_out
);
    localparam TAG_WIDTH        = 32 - (INDEX_WIDTH + OFFSET_WIDTH);
    localparam NUM_OF_BLOCKS    = 2**INDEX_WIDTH;
    localparam BLOCK_SIZE       = 2**(OFFSET_WIDTH+3); // (bits), = 2**OFFSET_WIDTH bytes

    // Cache memory
    reg [BLOCK_SIZE-1:0] l1_block_data [0:NUM_OF_BLOCKS-1];
    reg [TAG_WIDTH-1:0] l1_tag_array [0:NUM_OF_BLOCKS-1];
    reg l1_block_valid [0:NUM_OF_BLOCKS-1];

    wire [TAG_WIDTH-1:0]    l1_tag;
    wire [INDEX_WIDTH-1:0]  l1_index;
    wire [OFFSET_WIDTH-1:0] l1_offset;
    assign l1_tag       = address[31:INDEX_WIDTH+OFFSET_WIDTH];
    assign l1_index     = address[INDEX_WIDTH+OFFSET_WIDTH-1 : OFFSET_WIDTH];
    assign l1_offset    = address[OFFSET_WIDTH-1:0];

    integer i;
    initial begin
        for (i = 0; i < NUM_OF_BLOCKS; i = i + 1) begin
            // l1_block_valid[i] = 0;
            l1_tag_array[i] = 0;
        end
    end

    assign mmu_address = 0;
    assign cache_miss = (l1_tag_array[l1_index] != l1_tag);
    assign data_out = l1_block_data[l1_index];

    always @(posedge clk) begin
        ;
    end
endmodule
