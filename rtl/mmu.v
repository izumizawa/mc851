`include "define.v"

module mmu #(
    parameter ROMFILE="../src/memdump/addi.mem"
) (
    input  wire         clk,
    input  wire         reset_n,
    input  wire         write_enable,
    input  wire         read_enable,
    input  wire         signed_read,
    input  wire [ 1:0]  data_width,
    input  wire [31:0]  address,
    input  wire [31:0]  data_in,
    output wire         mem_ready,
    output wire [31:0]  data_out,

    // Interface do Controlador de Memória
    input  wire         imc_mem_ready,
    input  wire [31:0]  imc_data_out,
    output wire         imc_write_enable,
    output wire         imc_read_enable,
    output wire [31:0]  imc_address,
    output wire [31:0]  imc_data_in
);
    //TODO: Instanciar Cache L1
    wire         l1_write_enable;
    wire         l1_read_enable;
    wire [31:0]  l1_address;
    wire [31:0]  l1_data_in;
    wire [31:0]  l1_data_out;
    wire         l1_cache_miss;

    reg  [31:0] data_out_aux;       // Saída de uma única leitura
    reg  [31:0] data_in_aux;        // Entrada de uma única escrita
    reg  [31:0] address_aux;        // Endereço de um único acesso de memória
    reg         read_enable_aux;    // Habilita leitura em um único dispositivo
    reg         write_enable_aux;   // Habilita escrita em um único dispositivo
    wire [ 1:0] byte_offset;        // Offset do byte dentro da word
    reg  [31:0] mem_write_data;
    wire [31:0] mem_low_word;
    reg  [31:0] mem_high_word;      // Primeiro valor lido da memória caso seja feito acesso desalinhado
    reg  [31:0] data_out_unsigned;
    wire        aligned_access;

    assign mem_low_word     = data_out_aux;
    assign byte_offset      = address[1:0];
    assign aligned_access   = (byte_offset + data_width < 4) ? 1 : 0;

    always @(*) begin
        // Recuperar dado da memória a partir de uma leitura (acesso alinhado) ou de duas leituras (desalinhado)
        case (byte_offset)
            0: begin
                data_out_unsigned[ 7: 0] = mem_low_word[7:0];
                data_out_unsigned[15: 8] = (data_width >= 1) ? mem_low_word[15: 8] : 8'b0;
                data_out_unsigned[23:16] = (data_width >= 2) ? mem_low_word[23:16] : 8'b0;
                data_out_unsigned[31:24] = (data_width == 3) ? mem_low_word[31:24] : 8'b0;
            end
            1: begin
                data_out_unsigned[ 7: 0] = mem_low_word[15:8];
                data_out_unsigned[15: 8] = (data_width >= 1) ? mem_low_word[23:16] : 8'b0;
                data_out_unsigned[23:16] = (data_width >= 2) ? mem_low_word[31:24] : 8'b0;
                data_out_unsigned[31:24] = (data_width == 3) ? mem_high_word[ 7: 0] : 8'b0;
            end
            2: begin
                data_out_unsigned[ 7: 0] = mem_low_word[23:16];
                data_out_unsigned[15: 8] = (data_width >= 1) ? mem_low_word[31:24] : 8'b0;
                data_out_unsigned[23:16] = (data_width >= 2) ? mem_high_word[ 7: 0] : 8'b0;
                data_out_unsigned[31:24] = (data_width == 3) ? mem_high_word[15: 8] : 8'b0;
            end
            3: begin
                data_out_unsigned[ 7: 0] = mem_low_word[31:24];
                data_out_unsigned[15: 8] = (data_width >= 1) ? mem_high_word[ 7: 0] : 8'b0;
                data_out_unsigned[23:16] = (data_width >= 2) ? mem_high_word[15: 8] : 8'b0;
                data_out_unsigned[31:24] = (data_width == 3) ? mem_high_word[23:16] : 8'b0;
            end
        endcase

        if (signed_read) begin
            case (data_width)
                0: data_out = { {24{data_out_unsigned[ 7]}}, data_out_unsigned[ 7:0] };
                1: data_out = { {16{data_out_unsigned[15]}}, data_out_unsigned[15:0] };
                2: data_out = { { 8{data_out_unsigned[23]}}, data_out_unsigned[23:0] };
                3: data_out = data_out_unsigned;
            endcase
        end else begin
            data_out = data_out_unsigned;
        end
    end

    always @(*) begin
        // Palavra a ser escrita na memória de maneira a preservar os bytes não modificados, se for escrita de byte/half.
        case (byte_offset)
            0: begin
                mem_write_data[ 7: 0] = data_in[7:0];
                mem_write_data[15: 8] = (data_width >= 1) ? data_in[15: 8] : mem_low_word[15: 8];
                mem_write_data[23:16] = (data_width >= 2) ? data_in[23:16] : mem_low_word[23:16];
                mem_write_data[31:24] = mem_low_word[31:24];
            end
            1: begin
                mem_write_data[ 7: 0] = mem_low_word[7:0];
                mem_write_data[15: 8] = data_in[7:0];
                mem_write_data[23:16] = (data_width >= 1) ? data_in[15: 8] : mem_low_word[23:16];
                mem_write_data[31:24] = (data_width >= 2) ? data_in[23:16] : mem_low_word[31:24];
            end
            2: begin
                mem_write_data[ 7: 0] = mem_low_word[7:0];
                mem_write_data[15: 8] = mem_low_word[15:8];
                mem_write_data[23:16] = data_in[7:0];
                mem_write_data[31:24] = (data_width >= 1) ? data_in[15:8] : mem_low_word[31:24];
            end
            3: begin
                mem_write_data[ 7: 0] = mem_low_word[7:0];
                mem_write_data[15: 8] = mem_low_word[15:8];
                mem_write_data[23:16] = mem_low_word[23:16];
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
                    if (data_width == `MMU_WIDTH_WORD) begin
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
            mem_high_word <= 0;
            current_state <= STATE_READY;
        end else begin
            case (current_state)
                STATE_READY: begin
                    mem_ready <= 1;
                    current_state <= STATE_READY;

                    if (write_enable && aligned_access && (data_width != `MMU_WIDTH_WORD)) begin
                        mem_ready <= 0;
                        current_state <= STATE_ALIGNED_WRITE;
                    end
                    else if (write_enable && !aligned_access) begin
                        mem_ready <= 0;
                        current_state <= STATE_UNALIGNED_WRITE1;
                    end
                    else if (read_enable && !aligned_access) begin
                        mem_high_word <= data_out_aux;
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
                    mem_ready <= 0;
                    current_state <= STATE_READY;
                end
            endcase
        end
    end

endmodule
