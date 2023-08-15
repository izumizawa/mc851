module alu_module_tb();
    reg [3:0] alu_tb_input_op;
    reg [31:0] alu_tb_input_a;
    reg [31:0] alu_tb_input_b; 
    wire [31:0] alu_tb_result;

    alu_module uut(
        .alu_input_op(alu_tb_input_op),
        .alu_input_a(alu_tb_input_a),
        .alu_input_b(alu_tb_input_b),
        .alu_output_result(alu_tb_result)
    );

    task test_add();
    begin
        $write("  test_add: ");
        alu_tb_input_a <= 4'h1;
        alu_tb_input_b <= 4'h1;
        alu_tb_input_op <= 4'b0100;
        #100;
        if (alu_tb_result != 4'h2)
            $error("alu_tb_result should be 0x0002, but is %4h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_sub();
    begin
        $write("  test_sub: ");
        alu_tb_input_a <= 4'h1;
        alu_tb_input_b <= 4'h1;
        alu_tb_input_op <= 4'b0101;
        #100;
        if (alu_tb_result != 4'h0)
            $error("alu_tb_result should be 0x0000, but is %4h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_and();
    begin
        $write("  test_and: ");
        alu_tb_input_a <= 4'h1;
        alu_tb_input_b <= 4'h1;
        alu_tb_input_op <= 4'b0110;
        #100;
        if (alu_tb_result != 4'h1)
            $error("alu_tb_result should be 0x0001, but is %4h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_or();
    begin
        $write("  test_or: ");
        alu_tb_input_a <= 4'h0;
        alu_tb_input_b <= 4'h1;
        alu_tb_input_op <= 4'b0111;
        #100;
        if (alu_tb_result != 4'h1)
            $error("alu_tb_result should be 0x0001, but is %4h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    task test_xor();
    begin
        $write("  test_xor: ");
        alu_tb_input_a <= 4'h1;
        alu_tb_input_b <= 4'h1;
        alu_tb_input_op <= 4'b1000;
        #100;
        if (alu_tb_result != 4'h0)
            $error("alu_tb_result should be 0x0000, but is %4h", alu_tb_result);
        else
            $display("passed!");
    end
    endtask

    initial begin
        $display("alu_module_tb: starting tests");
        test_add();
        test_sub();
        test_and();
        test_or();
        test_xor();
    end
endmodule