module l1_data_cache #(
    parameter OFFSET_WIDTH = 5,
    parameter INDEX_WIDTH = 7,
) (
    input clk,
    input mmu_mem_ready,
    input read_enable,
    input  [31:0] address,
    output [31:0] read_data,
    output [31:0] cache_miss
)

endmodule
