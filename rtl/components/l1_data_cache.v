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
     * Outros parâmetros:
     *  CACHE_ASSOCIATIVITY: Número de vias (blocos por linha de cache)
     *
     * Conversões úteis:
     *  BLOCK_SIZE           = 2**OFFSET_WIDTH (bytes)
     *  NUM_OF_CACHE_LINES   = 2**INDEX_WIDTH
     *  NUM_OF_BLOCKS        = NUM_OF_CACHE_LINES * CACHE_ASSOCIATIVITY
     *  CACHE_SIZE = NUM_OF_BLOCKS * BLOCK_SIZE
     */

endmodule
