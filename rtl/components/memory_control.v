`include "ram.v"
`include "rom.v"

module memory_control (
    input clk,
    input [ 3:0] write_enable,
    input [31:0] address,
    input [31:0] data_in,
    output reg [31:0] data_out
);
    reg [31:0] rom_address;
    reg [31:0] rom_data_out;

    .rom rom (
        .clk            (clk            ),
        .address        (rom_address    ),
        .data_out       (rom_data_out   )
    );

    reg [ 3:0] ram_write_enable;
    reg [31:0] ram_address;
    reg [31:0] ram_data_in;
    reg [31:0] ram_data_out;

    .ram ram (
            .clk            (clk                ),
            .write_enable   (ram_write_enable   ),
            .address        (ram_address        ),
            .data_in        (ram_data_in        ),
            .data_out       (ram_data_out       )
    );

    // Mapeamento do espaço de endereçamento
    localparam ROM_ADDRESS_START =  8'h00000000;
    localparam ROM_ADDRESS_END =    8'h00FFFFFF;
    localparam RAM_ADDRESS_START =  8'h01000000;
    localparam RAM_ADDRESS_END =    8'h01FFFFFF;
    // ... RESERVADO: 0x01000000 .. 0xFFFFFFFF
    // TODO: Flash, GPIO, periféricos

    always @(posedge clk) begin
        ram_write_enable <= 0;
        data_out <= 0;
        rom_address <= address - ROM_ADDRESS_START;
        ram_address <= address - RAM_ADDRESS_START;
        ram_data_in <= data_in;

        if (ROM_ADDRESS_START <= address && address <= ROM_ADDRESS_END) begin
            data_out <= rom_data_out;
        end else if (RAM_ADDRESS_START <= address && address <= RAM_ADDRESS_END) begin
            data_out <= ram_data_out;
        end
    end

endmodule
