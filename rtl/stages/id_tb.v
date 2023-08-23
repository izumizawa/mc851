module RegisterFile_Testbench();

    reg clock;
    reg reset;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg write_enable;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    // Instanciar o módulo RegisterFile
    RegisterFile uut (
        .clock(clock),
        .reset(reset),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_enable(write_enable),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Função para comparar os resultados e imprimir mensagens
    task check_result(string desc, logic [31:0] expected, logic [31:0] actual);
        if (expected === actual) begin
            $display("%s: SUCCESS", desc);
        end else begin
            $display("%s: FAILURE (Expected: %h, Actual: %h)", desc, expected, actual);
        end
    endtask

    // Estímulos (inputs) para o módulo
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Gera um sinal de clock periódico

        reset = 0; // Ativa o reset
        #10;
        reset = 1; // Desativa o reset

        // Teste 1 - Escrita e leitura básica
        write_enable = 1;
        write_reg = 5'b00001;
        write_data = 32'hAABBCCDD;
        #20;

        read_reg1 = 5'b00001;
        read_reg2 = 5'b00000;
        #10;
        check_result("Test 1 - Read/Write", write_data, read_data1);

        // Teste 2 - Escrita em um registrador diferente e leitura no mesmo registrador
        write_enable = 1;
        write_reg = 5'b00100;
        write_data = 32'h12345678;
        #20;

        read_reg1 = 5'b00100;
        read_reg2 = 5'b00000;
        #10;
        check_result("Test 2 - Write/Read", write_data, read_data1);

        // Teste 3 - Leitura de um registrador inexistente (retorna 0)
        read_reg1 = 5'b01010;
        read_reg2 = 5'b00000;
        #10;
        check_result("Test 3 - Read Nonexistent", 32'h00000000, read_data1);

        // Teste 4 - Leitura após uma escrita em um registrador diferente
        write_enable = 1;
        write_reg = 5'b00011;
        write_data = 32'h87654321;
        #20;

        read_reg1 = 5'b00011;
        read_reg2 = 5'b00000;
        #10;
        check_result("Test 4 - Read After Write", write_data, read_data2);

        // Teste 5 - Escrita em dois registradores diferentes e leitura nos dois registradores
        write_enable = 1;
        write_reg = 5'b00101;
        write_data = 32'hABCDEFFF;
        #20;

        read_reg1 = 5'b00101;
        read_reg2 = 5'b00011;
        #10;
        check_result("Test 5 - Read/Write Multiple", write_data, read_data1);
        check_result("Test 5 - Read/Write Multiple", 32'h87654321, read_data2);

        // Simulação completa após um tempo
        #1000;
        $finish;
    end

endmodule
