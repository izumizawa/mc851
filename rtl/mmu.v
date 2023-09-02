`include "components/ram.v"
`include "components/rom.v"

module mmu (
    input clk, reset,
    input write_enable,
    input read_enable,
    input mem_signed,
    input [ 1:0] mem_width,
    input [31:0] address,
    input [31:0] data_in,
    output reg [31:0] data_out,
    output reg mem_ready
);
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

    /***************************************************************************
     * ROM (Read-Only Memory)
     */
    localparam ROM_ADDR_WIDTH = 8;
    reg rom_read_enable;
    reg  [ROM_ADDR_WIDTH-1:0] rom_address;
    wire [31:0] rom_data_out;

    rom #( .ADDR_WIDTH(ROM_ADDR_WIDTH) ) rom_inst (
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
    reg ram_write_enable;
    reg ram_read_enable;
    reg  [RAM_ADDR_WIDTH-1:0] ram_address;
    reg  [31:0] ram_data_in;
    wire [31:0] ram_data_out;

    ram #( .ADDR_WIDTH(RAM_ADDR_WIDTH) ) ram (
        .clk            (clk                ),
        .write_enable   (ram_write_enable   ),
        .read_enable    (ram_read_enable    ),
        .address        (ram_address        ),
        .data_in        (ram_data_in        ),
        .data_out       (ram_data_out       )
    );
    // -------------------------------------------------------------------------

    reg [31:0] data_out_aux;    // Saída de uma única leitura
    reg [31:0] data_out_unsigned;
    reg [31:0] data_in_aux;     // Entrada de dados compartilhada
    reg read_enable_aux;        // Habilita leitura em um único dispositivo
    reg write_enable_aux;       // Habilita escrita em um único dispositivo
    reg [ 1:0] byte_offset;     // Offset do byte dentro da word
    reg [31:0] mem_read1;
    reg [31:0] mem_read2;       // Segunda operação de leitura (usada apenas em acessos de memória desalinhados)
    reg aligned_access;

    assign byte_offset = address[1:0];
    assign aligned_access = (byte_offset + mem_width < 4) ? 1 : 0;
    assign ram_data_in = data_in_aux;

    localparam STATE_IDLE               = 4'd0;
    localparam STATE_ALIGNED_READ       = 4'd1;
    localparam STATE_ALIGNED_WRITE      = 4'd2;
    localparam STATE_UNALIGNED_READ1    = 4'd3;
    localparam STATE_UNALIGNED_READ2    = 4'd4;
    localparam STATE_UNALIGNED_WRITE1   = 4'd5;
    localparam STATE_UNALIGNED_WRITE2   = 4'd6;

    reg [3:0] current_state = STATE_IDLE;

    always @(posedge clk) begin
        data_out_aux <= 0;
        data_in_aux <= data_in;
        rom_read_enable <= 0;
        ram_write_enable <= 0;
        ram_read_enable <= 0;
        rom_address <= address[ROM_ADDR_WIDTH+1:2];
        ram_address <= address[RAM_ADDR_WIDTH+1:2];

        // Recuperar saída a partir de uma leitura (acesso alinhado) ou de duas leituras (desalinhado)
        case (byte_offset)
            0: begin
                data_out_unsigned[ 7: 0] <= mem_read1[7:0];
                data_out_unsigned[15: 8] <= (mem_width >= 1) ? mem_read1[15: 8] : 8'b0;
                data_out_unsigned[23:16] <= (mem_width >= 2) ? mem_read1[23:16] : 8'b0;
                data_out_unsigned[31:24] <= (mem_width == 3) ? mem_read1[31:24] : 8'b0;
            end 
            1: begin
                data_out_unsigned[ 7: 0] <= mem_read1[15:8];
                data_out_unsigned[15: 8] <= (mem_width >= 1) ? mem_read1[23:16] : 8'b0;
                data_out_unsigned[23:16] <= (mem_width >= 2) ? mem_read1[31:24] : 8'b0;
                data_out_unsigned[31:24] <= (mem_width == 3) ? mem_read2[ 7: 0] : 8'b0;
            end
            2: begin
                data_out_unsigned[ 7: 0] <= mem_read1[23:16];
                data_out_unsigned[15: 8] <= (mem_width >= 1) ? mem_read1[31:24] : 8'b0;
                data_out_unsigned[23:16] <= (mem_width >= 2) ? mem_read2[ 7: 0] : 8'b0;
                data_out_unsigned[31:24] <= (mem_width == 3) ? mem_read2[15: 8] : 8'b0;
            end
            3: begin
                data_out_unsigned[ 7: 0] <= mem_read1[31:24];
                data_out_unsigned[15: 8] <= (mem_width >= 1) ? mem_read2[ 7: 0] : 8'b0;
                data_out_unsigned[23:16] <= (mem_width >= 2) ? mem_read2[15: 8] : 8'b0;
                data_out_unsigned[31:24] <= (mem_width == 3) ? mem_read2[23:16] : 8'b0;
            end
        endcase

        if (mem_signed) begin
            case (mem_width)
                0: data_out <= { {24{data_out_unsigned[ 7]}}, data_out_unsigned[ 7:0] };
                1: data_out <= { {16{data_out_unsigned[15]}}, data_out_unsigned[15:0] };
                2: data_out <= { { 8{data_out_unsigned[23]}}, data_out_unsigned[23:0] };
                3: data_out <= data_out_unsigned;
            endcase
        end else begin
            data_out <= data_out_unsigned;
        end

        // Selecionar dispositivo de escrita/leitura com base no endereço
        if (address[31:ROM_RANGE] == ROM_SELECT) begin
            rom_read_enable <= read_enable_aux;
            data_out_aux <= rom_data_out;
        end else if (address[31:RAM_RANGE] == RAM_SELECT) begin
            ram_write_enable <= write_enable_aux;
            ram_read_enable <= read_enable_aux;
            data_out_aux <= ram_data_out;
        end

        // Controla sinais de leitura/escrita durante as etapas da operação
        case (current_state)
            STATE_IDLE: begin
                mem_ready <= 0;

                if (write_enable && aligned_access) begin
                    current_state <= STATE_ALIGNED_WRITE;
                end else if (write_enable && !aligned_access) begin
                    current_state <= STATE_UNALIGNED_WRITE1;
                end else if (read_enable && aligned_access) begin
                    current_state <= STATE_ALIGNED_READ;
                end else if (read_enable && !aligned_access) begin
                    current_state <= STATE_UNALIGNED_READ1;
                end else begin
                    mem_ready <= 1; // Continuar ocioso e disponível
                    current_state <= STATE_IDLE;
                end
            end

            STATE_ALIGNED_READ: begin
                read_enable_aux <= 1;
                write_enable_aux <= 0;
                mem_read1 <= data_out_aux;
                current_state <= STATE_IDLE;
            end

            STATE_ALIGNED_WRITE: begin
                read_enable_aux <= read_enable;
                write_enable_aux <= 1;
                mem_read1 <= data_out_aux;
                data_in_aux <= data_in;
                current_state <= STATE_IDLE;
            end

            // TODO: Terminar de implementar acesso desalinhado à memória
            STATE_UNALIGNED_READ1: begin
                read_enable_aux <= 1;
                write_enable_aux <= 0;
                mem_read2 <= data_out_aux;
                current_state <= STATE_UNALIGNED_READ2;
            end

            STATE_UNALIGNED_READ2: begin
                read_enable_aux <= 1;
                write_enable_aux <= 0;
                mem_read2 <= data_out_aux;
                current_state <= STATE_IDLE;
            end

            STATE_UNALIGNED_WRITE1: begin
                current_state <= STATE_UNALIGNED_WRITE2;
            end

            STATE_UNALIGNED_WRITE2: begin
                current_state <= STATE_IDLE;
            end

            default: begin
                current_state <= STATE_IDLE;
            end

        endcase
    end

endmodule
