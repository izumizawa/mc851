module register_file_tb;

    reg clk;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg write_enable;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    // Instanciar o módulo RegisterFile
    register_file dut (
        .clk(clk),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_enable(write_enable),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always#(5)
    begin
        clk = ~clk;
    end

    // Estímulos (inputs) para o módulo
    task Teste(); 
    begin
        clk = 0;
        #10;
        // Teste 1 - Escrita e leitura básica
        write_enable = 1;
        write_reg = 5'b00001;
        write_data = 32'hAABBCCDD;
        #20;

        read_reg1 = 5'b00001;
        read_reg2 = 5'b00000;
        #10;

        
        if (write_data === read_data1) begin
            $display("SUCCESS: Test 1 - Escrita e leitura básica");
        end else begin
            $display("FAILURE Teste 1 - Escrita e leitura básica (Expected: %h, Actual: %h)", write_data, read_data1);
        end

        // Teste 2 - Escrita em um registrador diferente e leitura no mesmo registrador
        write_enable = 1;
        write_reg = 5'b00100;
        write_data = 32'h12345678;
        #20;

        read_reg1 = 5'b00100;
        read_reg2 = 5'b00000;
        #10;
        
        if (write_data === read_data1) begin
            $display("SUCCESS: Test 2 - Escrita em um registrador diferente e leitura no mesmo registrador");
        end else begin
            $display("FAILURE Test 2 - Escrita em um registrador diferente e leitura no mesmo registrador (Expected: %h, Actual: %h)", write_data, read_data1);
        end

        // Teste 3 - Leitura de um registrador inexistente (retorna 0)
        read_reg1 = 5'b01010;
        read_reg2 = 5'b00000;
        #10;

        if (32'hxxxxxxxx === read_data1) begin
            $display("SUCCESS: Test 3 - Leitura de registrador inexistente");
        end else begin
            $display("FAILURE Test 3 - Leitura de registrador inexistente (Expected: %h, Actual: %h)", write_data, read_data1);
        end

        // Teste 4 - Leitura após uma escrita em um registrador diferente
        write_enable = 1;
        write_reg = 5'b00011;
        write_data = 32'h87654321;
        #20;

        read_reg1 = 5'b00011;
        read_reg2 = 5'b00000;
        #10;

        if (write_data === read_data2) begin
            $display("FAILURE Test 4 - Leitura após uma escrita em um registrador diferente");
        end else begin
            $display("SUCCESS: Test 4 - Leitura após uma escrita em um registrador diferente");
        end

        // Teste 5 - Escrita em dois registradores diferentes e leitura nos dois registradores
        write_enable = 1;
        write_reg = 5'b00101;
        write_data = 32'hABCDEFFF;
        #20;

        read_reg1 = 5'b00101;
        read_reg2 = 5'b00011;
        #10;

        if ((write_data === read_data1) && (32'h87654321 === read_data2)) begin
            $display("SUCCESS: Test 5 - Escrita em dois registradores diferentes e leitura nos dois registradores");
        end else begin
            $display("FAILURE Test 5 - Escrita em dois registradores diferentes e leitura nos dois registradores");
        end

        // Teste 6 - Tentativa de escrita no registrador x0
        write_enable = 1;
        write_reg = 5'b00000;
        write_data = 32'hABCDEFFF;
        #20;

        read_reg1 = 5'b00000;
        #10;

        if ((read_data1 === 32'b0)) begin
            $display("SUCCESS: Teste 6 - Tentativa de escrita no registrador x0");
        end else begin
            $display("FAILURE Teste 6 - Registrador x0 possui valor diferente de 0");
        end

        // Simulação completa após um tempo
        #1000;
        $finish;
    end
    endtask
    
    initial begin
        Teste();
    end

endmodule
