`include "../define.v"

module alu_module_tb();
    reg  [3:0]   alu_op;
    reg  [31:0]  alu_input_a;
    reg  [31:0]  alu_input_b;
    wire [31:0]  alu_out;


    alu_module uut(
        .alu_op(alu_op),
        .alu_input_a(alu_input_a),
        .alu_input_b(alu_input_b),
        .alu_out(alu_out)
    );

    task test_add();
    begin
        $write("  test_add: ");
        alu_input_a <= 32'h1;
        alu_input_b <= 32'h1;
        alu_op <= `ALU_ADD;
        #100;
        if (alu_out != 32'h2)
            $error("alu_out should be 32'h2, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_sub();
    begin
        $write("  test_sub: ");
        alu_input_a <= 32'h1;
        alu_input_b <= 32'h1;
        alu_op <= `ALU_SUB;
        #100;
        if (alu_out != 32'h0)
            $error("alu_out should be 32'h0, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_and();
    begin
        $write("  test_and: ");
        alu_input_a <= 32'h7;
        alu_input_b <= 32'h3;
        alu_op <= `ALU_AND;
        #100;
        if (alu_out != 32'h3)
            $error("alu_out should be 32'h3, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_or();
    begin
        $write("  test_or: ");
        alu_input_a <= 32'h4;
        alu_input_b <= 32'h3;
        alu_op <= `ALU_OR;
        #100;
        if (alu_out != 32'h7)
            $error("alu_out should be 32'h7, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_xor();
    begin
        $write("  test_xor: ");
        alu_input_a <= 32'b1001;
        alu_input_b <= 32'b1111;
        alu_op <= `ALU_XOR;
        #100;
        if (alu_out != 32'b0110)
            $error("alu_out should be 32'b0111, but is %b", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_sll();
    begin
        $write("  test_sll: ");
        alu_input_a <= 32'h3;
        alu_input_b <= 32'h2;
        alu_op <= `ALU_SLL;
        #100;
        if (alu_out != 32'hC)
            $error("alu_out should be 32'hC, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_srl();
    begin
        $write("  test_srl: ");
        alu_input_a <= 32'hFF;
        alu_input_b <= 32'h4;
        alu_op <= `ALU_SRL;
        #100;
        if (alu_out != 32'hF)
            $error("alu_out should be 32'hF, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask


    task test_sra();
    begin
        $write("  test_sra: ");
        alu_input_a <= 32'hFFFF0000;
        alu_input_b <= 32'h4;
        alu_op <= `ALU_SRA;
        #100;
        if (alu_out != 32'hFFFFF000)
            $error("alu_out should be 32'hFFFFF000, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_slt();
    begin
        $write("  test_slt: ");
        alu_input_a <= -32'h4;
        alu_input_b <= 32'h5;
        alu_op <= `ALU_SLT;
        #100;
        if (alu_out != 32'h1)
            $error("alu_out should be 32'h1, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    task test_sltu();
    begin
        $write("  test_sltu: ");
        alu_input_a <= -32'h4;
        alu_input_b <= 32'h5;
        alu_op <= `ALU_SLTU;
        #100;
        if (alu_out != 32'h0)
            $error("alu_out should be 32'h0, but is %h", alu_out);
        else
            $display("passed!");
    end
    endtask

    initial begin
        $display("alu_module: starting tests");
        test_add();
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
