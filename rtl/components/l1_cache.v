module l1_data_cache #(
    parameter INDEX_WIDTH = 6
) (
    input  wire         clk,
    input  wire         reset_n,
    input  wire         write_enable,
    input  wire         read_enable,
    input  wire [31:0]  address,
    input  wire [31:0]  data_in,
    output wire [31:0]  data_out,
    output wire         cache_miss
);
    localparam OFFSET_WIDTH     = 2; // BLOCK_SIZE = 2**OFFSET_WIDTH = 4 bytes
    localparam TAG_WIDTH        = 32 - (INDEX_WIDTH + OFFSET_WIDTH);
    localparam NUM_OF_BLOCKS    = 2**INDEX_WIDTH;

    // TODO: Implementar memória de cache com duas B-SRAMs (flags+tag e dados)
    reg l1_block_valid [0:NUM_OF_BLOCKS-1];
    reg l1_block_dirty [0:NUM_OF_BLOCKS-1];
    reg [TAG_WIDTH-1:0] l1_tag_array [0:NUM_OF_BLOCKS-1];
    reg [31:0] l1_block_data [0:NUM_OF_BLOCKS-1];

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
            l1_block_dirty[i] = 0;
            l1_tag_array[i] = 0;
            l1_block_data[i] = 0;
        end
    end

    assign cache_miss = read_enable && (!l1_block_valid[l1_index] || l1_tag_array[l1_index] != l1_tag)
                    || write_enable && (l1_block_dirty[l1_index] && l1_tag_array[l1_index] != l1_tag);
    assign data_out = l1_block_data[l1_index];

    always @(posedge clk) begin
        if (write_enable) begin
            l1_block_valid[l1_index] <= 1;
            l1_block_dirty[l1_index] <= 1;
            l1_block_data[l1_index] <= data_in;
            l1_tag_array[l1_index] <= l1_tag;
        end
    end

endmodule
