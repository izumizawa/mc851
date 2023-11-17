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

    // Cache memory
    reg [31:0] l1_block_data [0:NUM_OF_BLOCKS-1];
    reg [TAG_WIDTH-1:0] l1_tag_array [0:NUM_OF_BLOCKS-1];
    reg l1_block_valid [0:NUM_OF_BLOCKS-1];

    wire [TAG_WIDTH-1:0]    l1_tag;
    wire [INDEX_WIDTH-1:0]  l1_index;
    wire [OFFSET_WIDTH-1:0] l1_offset;

    assign l1_tag       = address[31:INDEX_WIDTH+OFFSET_WIDTH];
    assign l1_index     = address[INDEX_WIDTH+OFFSET_WIDTH-1 : OFFSET_WIDTH];
    assign l1_offset    = address[OFFSET_WIDTH-1:0];

    initial begin: label0
        integer i;
        for (i = 0; i < NUM_OF_BLOCKS; i = i + 1) begin
            l1_block_valid[i] = 0;
            l1_tag_array[i] = 0;
            l1_block_data[i] = 0;
        end
    end

    assign cache_miss = !l1_block_valid[l1_index] || (l1_tag_array[l1_index] != l1_tag);
    assign data_out = l1_block_data[l1_index]; // if
    assign mmu_address = address;

    always @(posedge clk) begin
        if (cache_miss && mmu_mem_ready) begin
            l1_block_data[l1_index] <= mmu_data_out;
            l1_tag_array[l1_index] <= l1_tag;
            l1_block_valid[l1_index] <= 1;
        end
    end
endmodule
