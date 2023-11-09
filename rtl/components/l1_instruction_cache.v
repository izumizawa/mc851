module l1_instruction_cache #(
    parameter OFFSET_WIDTH = 5,
    parameter INDEX_WIDTH = 7
) (
    input clk, reset_n,
    input [31:0] address,
    input mmu_mem_ready,
    input [31:0] mmu_data_out,
    output [31:0] mmu_address,
    output cache_miss,
    output [31:0] data_out
);

endmodule
