module soc #(
    parameter ROMFILE="../src/memdump/addi.mem"
) (
    input  wire clk,
    input  wire reset_n,

    // Peripherals
    input  wire button_1,
    input  wire button_2,
    input  wire uart_rx,
    output wire uart_tx
);

    // Instruction MMU
    wire        immu_mem_ready;
    wire [31:0] immu_data_out;
    wire        immu_write_enable;
    wire        immu_read_enable;
    wire [ 1:0] immu_data_width;
    wire [31:0] immu_virtual_address;
    wire [31:0] immu_data_in;
    //--------------------------//


    // Data MMU
    wire        dmmu_mem_ready;
    wire [31:0] dmmu_data_out;
    wire        dmmu_write_enable;
    wire        dmmu_read_enable;
    wire [ 1:0] dmmu_data_width;
    wire [31:0] dmmu_virtual_address;
    wire [31:0] dmmu_data_in;
    //--------------------------//


    // IMC (Integrated Memory Controller)
    wire        imc_immu_mem_ready;
    wire [31:0] imc_immu_data_out;
    wire        imc_immu_write_enable;
    wire        imc_immu_read_enable;
    wire [31:0] imc_immu_physical_address;
    wire [31:0] imc_immu_data_in;
    //--------------------------
    wire        imc_dmmu_mem_ready;
    wire [31:0] imc_dmmu_data_out;
    wire        imc_dmmu_write_enable;
    wire        imc_dmmu_read_enable;
    wire [31:0] imc_dmmu_physical_address;
    wire [31:0] imc_dmmu_data_in;
    //--------------------------
    wire [31:0] imc_mem_address;
    wire [31:0] imc_mem_data_in;
    //--------------------------//


    /***************************************************************************
     * ROM (Read-Only Memory)
     */
    localparam ROM_ADDR_WIDTH = 8;
    wire rom_read_enable;
    wire  [ROM_ADDR_WIDTH-1:0] rom_address;
    wire [31:0] rom_data_out;

    assign rom_address = imc_mem_address[ROM_ADDR_WIDTH+1:2];

    rom #(
        .ADDR_WIDTH(ROM_ADDR_WIDTH),
        .ROMFILE(ROMFILE)
    ) rom_inst (
        .clk            (clk            ),
        .read_enable    (rom_read_enable),
        .address        (rom_address    ),
        .data_out       (rom_data_out   )
    );
    // -------------------------------------------------------------------------


    /***************************************************************************
     * RAM (Random Access Memory)
     */
    localparam RAM_ADDR_WIDTH = 8;
    wire ram_write_enable;
    wire ram_read_enable;
    wire  [RAM_ADDR_WIDTH-1:0] ram_address;
    wire  [31:0] ram_data_in;
    wire [31:0] ram_data_out;

    assign ram_address = imc_mem_address[RAM_ADDR_WIDTH+1:2];
    assign ram_data_in = imc_mem_data_in;

    ram #( .ADDR_WIDTH(RAM_ADDR_WIDTH) ) ram_inst (
        .clk            (clk                ),
        .write_enable   (ram_write_enable   ),
        .read_enable    (ram_read_enable    ),
        .address        (ram_address        ),
        .data_in        (ram_data_in        ),
        .data_out       (ram_data_out       )
    );
    // -------------------------------------------------------------------------

    cpu cpu_core0 (
        .clk (clk),
        .reset_n (reset_n),

        .immu_mem_ready(immu_mem_ready),
        .immu_data_out(immu_data_out),
        .immu_write_enable(immu_write_enable),
        .immu_read_enable(immu_read_enable),
        .immu_data_width(immu_data_width),
        .immu_virtual_address(immu_virtual_address),
        .immu_data_in(immu_data_in),

        .dmmu_mem_ready(dmmu_mem_ready),
        .dmmu_data_out(dmmu_data_out),
        .dmmu_write_enable(dmmu_write_enable),
        .dmmu_read_enable(dmmu_read_enable),
        .dmmu_data_width(dmmu_data_width),
        .dmmu_virtual_address(dmmu_virtual_address),
        .dmmu_data_in(dmmu_data_in)
    );

    mmu instruction_mmu (
        .clk(clk),
        .reset_n(reset_n),
        .write_enable(immu_write_enable),
        .read_enable(immu_read_enable),
        .data_width(immu_data_width),
        .virtual_address(immu_virtual_address),
        .data_in(immu_data_in),
        .mmu_ready(immu_mem_ready),
        .data_out(immu_data_out),

        .imc_mem_ready(imc_immu_mem_ready),
        .imc_data_out(imc_immu_data_out),
        .imc_write_enable(imc_immu_write_enable),
        .imc_read_enable(imc_immu_read_enable),
        .imc_physical_address(imc_immu_physical_address),
        .imc_data_in(imc_immu_data_in)
    );

    mmu data_mmu (
        .clk(clk),
        .reset_n(reset_n),
        .write_enable(dmmu_write_enable),
        .read_enable(dmmu_read_enable),
        .data_width(dmmu_data_width),
        .virtual_address(dmmu_virtual_address),
        .data_in(dmmu_data_in),
        .mmu_ready(dmmu_mem_ready),
        .data_out(dmmu_data_out),

        .imc_mem_ready(imc_dmmu_mem_ready),
        .imc_data_out(imc_dmmu_data_out),
        .imc_write_enable(imc_dmmu_write_enable),
        .imc_read_enable(imc_dmmu_read_enable),
        .imc_physical_address(imc_dmmu_physical_address),
        .imc_data_in(imc_dmmu_data_in)
    );

    imc imc_module (
        .clk(clk),
        .reset_n(reset_n),

        .immu_write_enable(imc_immu_write_enable),
        .immu_read_enable(imc_immu_read_enable),
        .immu_physical_address(imc_immu_physical_address),
        .immu_data_out(imc_immu_data_in),
        .immu_data_in(imc_immu_data_out),
        .immu_mem_ready(imc_immu_mem_ready),

        .dmmu_write_enable(imc_dmmu_write_enable),
        .dmmu_read_enable(imc_dmmu_read_enable),
        .dmmu_physical_address(imc_dmmu_physical_address),
        .dmmu_data_out(imc_dmmu_data_in),
        .dmmu_data_in(imc_dmmu_data_out),
        .dmmu_mem_ready(imc_dmmu_mem_ready),

        .mem_rom_data_out(rom_data_out),
        .mem_ram_data_out(ram_data_out),
        .mem_address(imc_mem_address),
        .mem_data_in(imc_mem_data_in),
        .mem_rom_read_enable(rom_read_enable),
        .mem_ram_write_enable(ram_write_enable),
        .mem_ram_read_enable(ram_read_enable)
    );

endmodule
