module soc #(
    parameter ROMFILE="../src/memdump/addi.mem"
) (
    input  wire clk,
    input  wire button_1,
    input  wire button_2,
    input  wire uart_rx,
    output wire uart_tx
);
    wire reset_n;
    assign reset_n = button_1;

    // Instruction MMU
    wire        immu_mem_ready;
    wire [31:0] immu_data_out;
    wire        immu_write_enable;
    wire        immu_read_enable;
    wire        immu_signed_read;
    wire [ 1:0] immu_data_width;
    wire [31:0] immu_address;
    wire [31:0] immu_data_in;
    //--------------------------
    wire        immu_imc_mem_ready;
    wire [31:0] immu_imc_data_out;
    wire        immu_imc_write_enable;
    wire        immu_imc_read_enable;
    wire [31:0] immu_imc_address;
    wire [31:0] immu_imc_data_in;
    //--------------------------
    wire        immu_l1_cache_miss;
    wire [31:0] immu_l1_data_out;
    wire        immu_l1_write_enable;
    wire        immu_l1_read_enable;
    wire [31:0] immu_l1_address;
    wire [31:0] immu_l1_data_in;
    //--------------------------//

    // Data MMU
    wire        dmmu_mem_ready;
    wire [31:0] dmmu_data_out;
    wire        dmmu_write_enable;
    wire        dmmu_read_enable;
    wire        dmmu_signed_read;
    wire [ 1:0] dmmu_data_width;
    wire [31:0] dmmu_address;
    wire [31:0] dmmu_data_in;
    //--------------------------
    wire        dmmu_imc_mem_ready;
    wire [31:0] dmmu_imc_data_out;
    wire        dmmu_imc_write_enable;
    wire        dmmu_imc_read_enable;
    wire [31:0] dmmu_imc_address;
    wire [31:0] dmmu_imc_data_in;
    //--------------------------
    wire        dmmu_l1_cache_miss;
    wire [31:0] dmmu_l1_data_out;
    wire        dmmu_l1_write_enable;
    wire        dmmu_l1_read_enable;
    wire [31:0] dmmu_l1_address;
    wire [31:0] dmmu_l1_data_in;
    //--------------------------//

    cpu cpu_core0 (
        .clk (clk),
        .reset_n (reset_n),

        .immu_mem_ready(immu_mem_ready),
        .immu_data_out(immu_data_out),
        .immu_write_enable(immu_write_enable),
        .immu_read_enable(immu_read_enable),
        .immu_signed_read(immu_signed_read),
        .immu_data_width(immu_data_width),
        .immu_address(immu_address),
        .immu_data_in(immu_data_in),

        .dmmu_mem_ready(dmmu_mem_ready),
        .dmmu_data_out(dmmu_data_out),
        .dmmu_write_enable(dmmu_write_enable),
        .dmmu_read_enable(dmmu_read_enable),
        .dmmu_signed_read(dmmu_signed_read),
        .dmmu_data_width(dmmu_data_width),
        .dmmu_address(dmmu_address),
        .dmmu_data_in(dmmu_data_in)
    );

    mmu instruction_mmu (
        .clk(clk),
        .reset_n(reset_n),
        .write_enable(immu_write_enable),
        .read_enable(immu_read_enable),
        .signed_read(immu_signed_read),
        .data_width(immu_data_width),
        .address(immu_address),
        .data_in(immu_data_in),
        .mem_ready(immu_mem_ready),
        .data_out(immu_data_out),

        .imc_mem_ready(immu_imc_mem_ready),
        .imc_data_out(immu_imc_data_out),
        .imc_write_enable(immu_imc_write_enable),
        .imc_read_enable(immu_imc_read_enable),
        .imc_address(immu_imc_address),
        .imc_data_in(immu_imc_data_in)
    );

    mmu data_mmu (
        .clk(clk),
        .reset_n(reset_n),
        .write_enable(dmmu_write_enable),
        .read_enable(dmmu_read_enable),
        .signed_read(dmmu_signed_read),
        .data_width(dmmu_data_width),
        .address(dmmu_address),
        .data_in(dmmu_data_in),
        .mem_ready(dmmu_mem_ready),
        .data_out(dmmu_data_out),

        .imc_mem_ready(dmmu_imc_mem_ready),
        .imc_data_out(dmmu_imc_data_out),
        .imc_write_enable(dmmu_imc_write_enable),
        .imc_read_enable(dmmu_imc_read_enable),
        .imc_address(dmmu_imc_address),
        .imc_data_in(dmmu_imc_data_in)
    );

    //TODO: Instanciar Memory Controller (IMC)

    //TODO: Instanciar pROM, Semi dual-port B-SRAM, User Flash, etc...

endmodule
