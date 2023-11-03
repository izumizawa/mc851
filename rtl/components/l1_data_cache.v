module l1_data_cache #(
    parameter OFFSET_WIDTH = 5,
    parameter INDEX_WIDTH = 7,
) (
    input clk,
    input mmu_mem_ready,
    input write_enable,
    input read_enable,
    input  [31:0] address,
    input  [31:0] write_data,
    output [31:0] read_data,
    output [31:0] cache_miss
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
