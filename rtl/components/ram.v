/* // ! ATENÇÃO
 * No futuro, esse módulo de memória SRAM será o "data memory" / "L1d cache".
 * Quando um dado não estiver na cache, buscar na SDRAM (64Mb). Isso requer
 * interagir com um controlador especial built-in do FPGA. O sinal read_enable
 * ainda vai fazer sentido.
 */

module ram #(
    parameter MEMORY_SIZE = 1024  // 1 KiB
) (
    input clk,
    input read_enable,
    input [ 3:0] write_enable,
    input [31:0] address,
    input [31:0] data_in,
    output reg  [31:0] data_out
);
    localparam WORD_WIDTH = 32;
    localparam NUM_WORDS = MEMORY_SIZE / WORD_WIDTH;

    reg [WORD_WIDTH-1:0] mem [0:NUM_WORDS-1];

    always @(posedge clk) begin
        if (read_enable) data_out <= mem[address];

        if (write_enable[0]) mem[address][ 7: 0] <= data_in[ 7: 0];
		if (write_enable[1]) mem[address][15: 8] <= data_in[15: 8];
		if (write_enable[2]) mem[address][23:16] <= data_in[23:16];
		if (write_enable[3]) mem[address][31:24] <= data_in[31:24];
    end

endmodule
