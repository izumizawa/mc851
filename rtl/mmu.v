`include "define.v"
`include "components/ram.v"
`include "components/rom.v"

module mmu #(
    parameter ROMFILE=""
) (
    input clk, reset_n,
    input write_enable,
    input read_enable,
    input mem_signed_read,
    input [ 1:0] mem_data_width,
    input [31:0] address,
    input [31:0] data_in,
    output reg [31:0] data_out,
    output reg mem_ready
);

    /***************************************************************************
     * ROM (Read-Only Memory)
     */
    localparam ROM_ADDR_WIDTH = 8;
    reg rom_read_enable;
    wire  [ROM_ADDR_WIDTH-1:0] rom_address;
    wire [31:0] rom_data_out;

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
    reg ram_write_enable;
    reg ram_read_enable;
    wire  [RAM_ADDR_WIDTH-1:0] ram_address;
    wire  [31:0] ram_data_in;
    wire [31:0] ram_data_out;

    ram #( .ADDR_WIDTH(RAM_ADDR_WIDTH) ) ram_inst (
        .clk            (clk                ),
        .write_enable   (ram_write_enable   ),
        .read_enable    (ram_read_enable    ),
        .address        (ram_address        ),
        .data_in        (ram_data_in        ),
        .data_out       (ram_data_out       )
    );
    // -------------------------------------------------------------------------

    reg [31:0] data_out_aux;    // Saída de uma única leitura, selecionada dentre os dispositivos
    reg [31:0] data_in_aux;     // Entrada de uma única escrita, distribuída para os dispositivos
    reg [31:0] address_aux;     // Endereço de um único acesso de memória
    reg read_enable_aux;        // Habilita leitura em um único dispositivo
    reg write_enable_aux;       // Habilita escrita em um único dispositivo
    wire [ 1:0] byte_offset;    // Offset do byte dentro da word
    reg [31:0] mem_write_data;
    wire [31:0] mem_read_data_1;
    reg [31:0] mem_read_data_2; // Primeiro valor lido da memória caso seja feito acesso desalinhado
    reg [31:0] mem_read_unsigned;
    wire aligned_access;

    // Atribuir data_in (onde aplicável) e address de todos os dispositivos
    assign ram_data_in = data_in_aux;
    assign rom_address = address_aux[ROM_ADDR_WIDTH+1:2];
    assign ram_address = address_aux[RAM_ADDR_WIDTH+1:2];

    assign mem_read_data_1 = data_out_aux;
    assign byte_offset = address[1:0];
    assign aligned_access = (byte_offset + mem_data_width < 4) ? 1 : 0;

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

    always @(*) begin
        // Recuperar dado da memória a partir de uma leitura (acesso alinhado) ou de duas leituras (desalinhado)
        case (byte_offset)
            0: begin
                mem_read_unsigned[ 7: 0] = mem_read_data_1[7:0];
                mem_read_unsigned[15: 8] = (mem_data_width >= 1) ? mem_read_data_1[15: 8] : 8'b0;
                mem_read_unsigned[23:16] = (mem_data_width >= 2) ? mem_read_data_1[23:16] : 8'b0;
                mem_read_unsigned[31:24] = (mem_data_width == 3) ? mem_read_data_1[31:24] : 8'b0;
            end
            1: begin
                mem_read_unsigned[ 7: 0] = mem_read_data_1[15:8];
                mem_read_unsigned[15: 8] = (mem_data_width >= 1) ? mem_read_data_1[23:16] : 8'b0;
                mem_read_unsigned[23:16] = (mem_data_width >= 2) ? mem_read_data_1[31:24] : 8'b0;
                mem_read_unsigned[31:24] = (mem_data_width == 3) ? mem_read_data_2[ 7: 0] : 8'b0;
            end
            2: begin
                mem_read_unsigned[ 7: 0] = mem_read_data_1[23:16];
                mem_read_unsigned[15: 8] = (mem_data_width >= 1) ? mem_read_data_1[31:24] : 8'b0;
                mem_read_unsigned[23:16] = (mem_data_width >= 2) ? mem_read_data_2[ 7: 0] : 8'b0;
                mem_read_unsigned[31:24] = (mem_data_width == 3) ? mem_read_data_2[15: 8] : 8'b0;
            end
            3: begin
                mem_read_unsigned[ 7: 0] = mem_read_data_1[31:24];
                mem_read_unsigned[15: 8] = (mem_data_width >= 1) ? mem_read_data_2[ 7: 0] : 8'b0;
                mem_read_unsigned[23:16] = (mem_data_width >= 2) ? mem_read_data_2[15: 8] : 8'b0;
                mem_read_unsigned[31:24] = (mem_data_width == 3) ? mem_read_data_2[23:16] : 8'b0;
            end
        endcase

        // Fazer extensão de sinal do valor lido
        if (mem_signed_read) begin
            case (mem_data_width)
                0: data_out = { {24{mem_read_unsigned[ 7]}}, mem_read_unsigned[ 7:0] };
                1: data_out = { {16{mem_read_unsigned[15]}}, mem_read_unsigned[15:0] };
                2: data_out = { { 8{mem_read_unsigned[23]}}, mem_read_unsigned[23:0] };
                3: data_out = mem_read_unsigned;
            endcase
        end else begin
            data_out = mem_read_unsigned;
        end
    end

    always @(*) begin
        // Palavra a ser escrita na memória de maneira a preservar os bytes não modificados, se for escrita de byte/half.
        case (byte_offset)
            0: begin
                mem_write_data[ 7: 0] = data_in[7:0];
                mem_write_data[15: 8] = (mem_data_width >= 1) ? data_in[15: 8] : mem_read_data_1[15: 8];
                mem_write_data[23:16] = (mem_data_width >= 2) ? data_in[23:16] : mem_read_data_1[23:16];
                mem_write_data[31:24] = mem_read_data_1[31:24];
            end
            1: begin
                mem_write_data[ 7: 0] = mem_read_data_1[7:0];
                mem_write_data[15: 8] = data_in[7:0];
                mem_write_data[23:16] = (mem_data_width >= 1) ? data_in[15: 8] : mem_read_data_1[23:16];
                mem_write_data[31:24] = (mem_data_width >= 2) ? data_in[23:16] : mem_read_data_1[31:24];
            end
            2: begin
                mem_write_data[ 7: 0] = mem_read_data_1[7:0];
                mem_write_data[15: 8] = mem_read_data_1[15:8];
                mem_write_data[23:16] = data_in[7:0];
                mem_write_data[31:24] = (mem_data_width >= 1) ? data_in[15:8] : mem_read_data_1[31:24];
            end
            3: begin
                mem_write_data[ 7: 0] = mem_read_data_1[7:0];
                mem_write_data[15: 8] = mem_read_data_1[15:8];
                mem_write_data[23:16] = mem_read_data_1[23:16];
                mem_write_data[31:24] = data_in[7:0];
            end
        endcase
    end

    localparam STATE_READY              = 3'd0;
    localparam STATE_ALIGNED_WRITE      = 3'd1;
    localparam STATE_UNALIGNED_READ     = 3'd2;
    localparam STATE_UNALIGNED_WRITE1   = 3'd3;
    localparam STATE_UNALIGNED_WRITE2   = 3'd4;
    localparam STATE_UNALIGNED_WRITE3   = 3'd5;
    localparam STATE_UNALIGNED_WRITE4   = 3'd6;

    reg [2:0] current_state = STATE_READY;

    // Selecionar sinais de controle
    always @(*) begin
        data_in_aux = data_in;
        address_aux = address;
        read_enable_aux = 0;
        write_enable_aux = 0;

        case (current_state)
            STATE_READY: begin
                if (write_enable && aligned_access) begin
                    if (mem_data_width == `MMU_WIDTH_WORD) begin
                        // Se for escrita de WORD, apenas escrever o data_in
                        read_enable_aux = read_enable;
                        write_enable_aux = 1;
                    end else begin
                        // Se for escrita de HALF ou BYTE, primeiro ler a palavra inteira
                        read_enable_aux = 1;
                        write_enable_aux = 0;
                    end
                end

                else if (write_enable && !aligned_access) begin
                    address_aux = address + 4;
                    read_enable_aux = 1;
                    write_enable_aux = 0;
                end

                else if (read_enable && aligned_access) begin
                    read_enable_aux = 1;
                    write_enable_aux = 0;
                end

                else if (read_enable && !aligned_access) begin
                    address_aux = address + 4;
                    read_enable_aux = 1;
                    write_enable_aux = 0;
                end
            end

            STATE_ALIGNED_WRITE: begin
                read_enable_aux = 0;
                write_enable_aux = 1;
                data_in_aux = mem_write_data;
            end

            STATE_UNALIGNED_READ: begin
                read_enable_aux = 1;
                write_enable_aux = 0;
            end

            default: begin
                ; // Fazer nada
            end
        endcase
    end

    // Realiza operações de leitura/escrita em múltiplos ciclos
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            mem_ready <= 1;
            mem_read_data_2 <= 0;
            current_state <= STATE_READY;
        end else begin
            case (current_state)
                STATE_READY: begin
                    mem_ready <= 1;
                    current_state <= STATE_READY;

                    if (write_enable && aligned_access && (mem_data_width != `MMU_WIDTH_WORD)) begin
                        mem_ready <= 0;
                        current_state <= STATE_ALIGNED_WRITE;
                    end
                    else if (write_enable && !aligned_access) begin
                        mem_ready <= 0;
                        current_state <= STATE_UNALIGNED_WRITE1;
                    end
                    else if (read_enable && !aligned_access) begin
                        mem_read_data_2 <= data_out_aux;
                        mem_ready <= 0;
                        current_state <= STATE_UNALIGNED_READ;
                    end
                end

                STATE_ALIGNED_WRITE: begin
                    mem_ready <= 1;
                    current_state <= STATE_READY;
                end

                STATE_UNALIGNED_READ: begin
                    mem_ready <= 1;
                    current_state <= STATE_READY;
                end

                // TODO: Terminar de implementar acesso desalinhado à memória (não requerido para o propósito do trabalho)
                STATE_UNALIGNED_WRITE1: begin
                    current_state <= STATE_UNALIGNED_WRITE2;
                end
                // end TODO

                default: begin
                    mem_ready <= 1;
                    current_state <= STATE_READY;
                end
            endcase
        end
    end

endmodule
