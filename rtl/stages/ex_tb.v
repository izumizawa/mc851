module alu_1_tb();
    reg [3:0] alu_tb_input_op;
    reg [31:0] alu_tb_input_a;
    reg [31:0] alu_tb_input_b; 
    wire [31:0] alu_tb_result;

    alu_1 uut(
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

    initial begin
        $display("alu_1_tb: starting tests");
        test_add();
    end
endmodule