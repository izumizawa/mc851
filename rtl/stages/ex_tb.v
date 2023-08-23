module alu_module_tb();
    reg          alu_tb_input_enable;
    reg  [3:0]   alu_tb_input_op;
    reg  [31:0]  alu_tb_input_a;
    reg  [31:0]  alu_tb_input_b;
    wire [31:0]  alu_tb_result;


    alu_module uut(
        .alu_input_enable(alu_tb_input_enable),
        .alu_input_op(alu_tb_input_op),
        .alu_input_a(alu_tb_input_a),
        .alu_input_b(alu_tb_input_b),
        .alu_output_result(alu_tb_result)
    );

    task test_add();
    begin
        $write("  test_add: ");
        alu_tb_input_enable = 1'b1;
        alu_tb_input_a <= 32'h1;
        alu_tb_input_b <= 32'h1;
        alu_tb_input_op <= `ALU_ADD;
        #100;
        if (alu_tb_result != 32'h2)
            $error("alu_tb_result should be 32'h2, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_enable();
    begin
        $write("  test_enable: ");
        alu_tb_input_enable = 1'b0;
        alu_tb_input_a <= 32'h2;
        alu_tb_input_b <= 32'h2;
        alu_tb_input_op <= `ALU_ADD;
        #100;
        if (alu_tb_result != 32'h0)
            $error("alu_tb_result should be 32'h0, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_sub();
    begin
        $write("  test_sub: ");
        alu_tb_input_enable = 1'b1;
        alu_tb_input_a <= 32'h1;
        alu_tb_input_b <= 32'h1;
        alu_tb_input_op <= `ALU_SUB;
        #100;
        if (alu_tb_result != 32'h0)
            $error("alu_tb_result should be 32'h0, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_and();
    begin
        $write("  test_and: ");
        alu_tb_input_a <= 32'h7;
        alu_tb_input_b <= 32'h3;
        alu_tb_input_op <= `ALU_AND;
        #100;
        if (alu_tb_result != 32'h3)
            $error("alu_tb_result should be 32'h3, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_or();
    begin
        $write("  test_or: ");
        alu_tb_input_a <= 32'h4;
        alu_tb_input_b <= 32'h3;
        alu_tb_input_op <= `ALU_OR;
        #100;
        if (alu_tb_result != 32'h7)
            $error("alu_tb_result should be 32'h7, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_xor();
    begin
        $write("  test_xor: ");
        alu_tb_input_a <= 32'b1001;
        alu_tb_input_b <= 32'b1111;
        alu_tb_input_op <= `ALU_XOR;
        #100;
        if (alu_tb_result != 32'b0110)
            $error("alu_tb_result should be 32'b0111, but is %b", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_sll();
    begin
        $write("  test_sll: ");
        alu_tb_input_a <= 32'h3;
        alu_tb_input_b <= 32'h2;
        alu_tb_input_op <= `ALU_SLL;
        #100;
        if (alu_tb_result != 32'hC)
            $error("alu_tb_result should be 32'hC, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_srl();
    begin
        $write("  test_srl: ");
        alu_tb_input_a <= 32'hFF;
        alu_tb_input_b <= 32'h4;
        alu_tb_input_op <= `ALU_SRL;
        #100;
        if (alu_tb_result != 32'hF)
            $error("alu_tb_result should be 32'hF, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask


    task test_sra();
    begin
        $write("  test_sra: ");
        alu_tb_input_a <= 32'hFFFF0000;
        alu_tb_input_b <= 32'h4;
        alu_tb_input_op <= `ALU_SRA;
        #100;
        if (alu_tb_result != 32'hFFFFF000)
            $error("alu_tb_result should be 32'hFFFFF000, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_slt();
    begin
        $write("  test_slt: ");
        alu_tb_input_a <= 32'h4;
        alu_tb_input_b <= 32'h5;
        alu_tb_input_op <= `ALU_SLT;
        #100;
        if (alu_tb_result != 32'h1)
            $error("alu_tb_result should be 32'h1, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_sltu();
    begin
        $write("  test_slt: ");
        alu_tb_input_a <= -32'h4;
        alu_tb_input_b <= 32'h5;
        alu_tb_input_op <= `ALU_SLTU;
        #100;
        if (alu_tb_result != 32'h1)
            $error("alu_tb_result should be 32'h1, but is %h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    initial begin
        $display("alu_module_tb: starting tests");
        alu_tb_input_enable = 1'b1;
        test_add();
        test_enable();
        test_sub();
        test_and();
        test_or();
        test_xor();
        test_sll();
        test_srl();
        test_sra();
        test_slt();
        test_sltu();
    end
endmodule