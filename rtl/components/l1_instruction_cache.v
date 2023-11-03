module l1_instruction_cache #(
    parameter OFFSET_WIDTH = 5,
    parameter INDEX_WIDTH = 7
) (
    input clk,
    input mem_data_available,
    input  [31:0] address,
    output cache_miss,
    output [31:0] data_out
);

endmodule
