module l1_data_cache #(
    parameter OFFSET_WIDTH = 5,
    parameter INDEX_WIDTH = 7
) (
    input clk, reset_n,
    input mem_write,
    input mem_read,
    input [31:0] address,
    input [31:0] data_in,
    input mmu_mem_ready,
    input [31:0] mmu_data_out,
    output mmu_write_enable,
    output mmu_read_enable,
    output mmu_mem_signed_read,
    output [ 1:0] mmu_mem_data_width,
    output [31:0] mmu_data_in,
    output [31:0] mmu_address,
    output cache_miss,
    output [31:0] data_out
);

    /*
     *  BLOCK_SIZE          = 2**OFFSET_WIDTH (bytes)
     *  NUM_OF_BLOCKS       = 2**INDEX_WIDTH
     *  CACHE_SIZE          = NUM_OF_BLOCKS * BLOCK_SIZE
     */

    assign mmu_write_enable = 0;
    assign mmu_read_enable = 0;
    assign mmu_mem_signed_read = 0;
    assign mmu_mem_data_width = 0;
    assign mmu_data_in = 0;
    assign mmu_address = 0;
    assign cache_miss = 0;
    assign data_out = 0;

endmodule
