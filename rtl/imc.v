module l1_cache #(
    parameter INDEX_WIDTH = 6
) (
    input  wire         clk,
    input  wire         reset_n,
    input  wire         write_enable,
    input  wire         read_enable,
    input  wire [31:0]  address,
    input  wire [31:0]  data_in,
    output wire [31:0]  data_out,
    output wire         cache_ready
);

    /***************************************************************************
    * ROM (Read-Only Memory)
    */
    reg         rom_read_enable;
    wire [31:0] rom_address;
    wire [31:0] rom_data_out;
    // -------------------------------------------------------------------------


    /***************************************************************************
    * RAM (Random Access Memory)
    */
    reg         ram_write_enable;
    reg         ram_read_enable;
    wire [31:0] ram_address;
    wire [31:0] ram_data_in;
    wire [31:0] ram_data_out;
    // -------------------------------------------------------------------------

    // Atribuir data_in (onde aplicável) e address de todos os dispositivos
    assign ram_data_in = data_in_aux;
    assign rom_address = {2'b0, address_aux[31:2]};
    assign ram_address = {2'b0, address_aux[31:2]};

    /* Mapeamento do espaço de endereçamento
        * ROM: 0x00000000 .. 0x00FFFFFF
        * RAM: 0x01000000 .. 0x01FFFFFF
        * ... RESERVADO: 0x01000000 .. 0xFFFFFFFF
        *
        * Terminologia:
        * RANGE: Número de bits de endereçamento disponíveis pro dispositivo.
        * SELECT: (32 - #RANGE) bits p/ selecionar o dispositivo.
        */
    localparam ROM_SELECT   = 8'h00;
    localparam ROM_RANGE    = 24;
    localparam RAM_SELECT   = 8'h01;
    localparam RAM_RANGE    = 24;

    // Selecionar dispositivo de escrita/leitura com base no endereço
    always @(*) begin
        rom_read_enable = 0;
        ram_write_enable = 0;
        ram_read_enable = 0;
        data_out_aux = 0;

        if (address[31:ROM_RANGE] == ROM_SELECT) begin
            rom_read_enable = read_enable_aux;
            data_out_aux = rom_data_out;
        end else if (address[31:RAM_RANGE] == RAM_SELECT) begin
            ram_write_enable = write_enable_aux;
            ram_read_enable = read_enable_aux;
            data_out_aux = ram_data_out;
        end
    end
endmodule
