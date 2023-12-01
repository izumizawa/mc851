module imc (
    input  wire         clk,
    input  wire         reset_n,

    input  wire         immu_write_enable,
    input  wire         immu_read_enable,
    input  wire [31:0]  immu_physical_address,
    input  wire [31:0]  immu_data_out,
    output reg  [31:0]  immu_data_in,
    output reg          immu_mem_ready,
    //--------------------------
    input  wire         dmmu_write_enable,
    input  wire         dmmu_read_enable,
    input  wire [31:0]  dmmu_physical_address,
    input  wire [31:0]  dmmu_data_out,
    output reg  [31:0]  dmmu_data_in,
    output reg          dmmu_mem_ready,
    //--------------------------
    // TODO: Implementar um barramento de memória de verdade em vez de ter uma interface pra cada dispositivo
    input  wire [31:0]  mem_rom_data_out,
    input  wire [31:0]  mem_ram_data_out,
    output wire [31:0]  mem_address,
    output wire [31:0]  mem_data_in,
    output reg          mem_rom_read_enable,
    output reg          mem_ram_write_enable,
    output reg          mem_ram_read_enable
);

    reg         mem_write_enable_aux;
    reg         mem_read_enable_aux;
    reg [31:0]  mem_data_out_aux;
    reg         mem_ready_aux;

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
        mem_rom_read_enable = 0;
        mem_ram_write_enable = 0;
        mem_ram_read_enable = 0;
        mem_ready_aux = 0;
        mem_data_out_aux = 0;

        if (mem_address[31:ROM_RANGE] == ROM_SELECT) begin
            mem_rom_read_enable = mem_read_enable_aux;
            mem_data_out_aux = mem_rom_data_out;
            mem_ready_aux = 1;
        end else if (mem_address[31:RAM_RANGE] == RAM_SELECT) begin
            mem_ram_write_enable = mem_write_enable_aux;
            mem_ram_read_enable = mem_read_enable_aux;
            mem_data_out_aux = mem_ram_data_out;
            mem_ready_aux = 1;
        end
    end

    // Mecanismo de prioridade para acessos das MMUs
    always @(*) begin
        immu_mem_ready = 0;
        immu_data_in = 0;
        dmmu_mem_ready = 0;
        dmmu_data_in = 0;

        mem_write_enable_aux = 0;
        mem_read_enable_aux = 0;
        mem_address = 0;
        mem_data_in = 0;

        if (dmmu_write_enable || dmmu_read_enable) begin
            dmmu_mem_ready = mem_ready_aux;
            dmmu_data_in = mem_data_out_aux;

            mem_write_enable_aux = dmmu_write_enable;
            mem_read_enable_aux = dmmu_read_enable;
            mem_address = dmmu_physical_address;
            mem_data_in = dmmu_data_out;
        end else if (immu_write_enable || immu_read_enable) begin
            immu_mem_ready = mem_ready_aux;
            immu_data_in = mem_data_out_aux;

            mem_write_enable_aux = immu_write_enable;
            mem_read_enable_aux = immu_read_enable;
            mem_address = immu_physical_address;
            mem_data_in = immu_data_out;
        end
    end
endmodule
